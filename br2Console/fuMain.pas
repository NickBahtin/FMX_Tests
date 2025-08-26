unit fuMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IdContext,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  IdGlobal, System.SyncObjs,
  System.Generics.Collections,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, FMX.Edit,
  FMX.EditBox, FMX.NumberBox, FMX.Objects, FMX.Layouts;

const GPRSMax=15000;
      ClientMax=254;
      ClientKontactMax=20;
      WaitAnsw: DWORD =5000;
      VersionBroker='1.10.12.02';

type
  PInfoGPRS = ^TInfoGPRS;
  (*      PInfoGPRS=^TInfoGPRS;
      TInfoGPRS=record
             id_gprs: dword;
             hw: dword;
             lasttime: dword;
             sock: TIdPeerThread;
             teklen: dword;
             srezdt1: dword; // срез GetTickCount;
             busy: boolean;
             busycl: byte;
             somecl_wait: byte;
             tmpbuf: array[0..1151] of byte;
           end;
*)
  TInfoGPRS = record
    id_gprs: DWORD;
    hw: DWORD;
    sock: TIdContext;  // было TIdPeerThread
    lasttime: DWORD;
    srezdt1: DWORD;
    busy: Boolean;
    teklen: Integer;
    tmpbuf: TIdBytes;  // было array[0..2047] of Byte
    somecl_wait: DWORD;
    busycl: byte;
  end;

  TMainForm = class(TForm)
    GPRSSrv: TIdTCPServer;
    OPCBroker: TIdTCPServer;
    Memo1: TMemo;
    Layout1: TLayout;
    Text1: TText;
    NumberBox1: TNumberBox;
    procedure GPRSSrvConnect(AContext: TIdContext);
    procedure StrToLog(AStr: string; Option: byte);
    procedure FormCreate(Sender: TObject);
    procedure GPRSSrvExecute(AContext: TIdContext);
    procedure FormDestroy(Sender: TObject);
    procedure GPRSSrvDisconnect(AContext: TIdContext);
    procedure GPRSSrvException(AContext: TIdContext; AException: Exception);
    procedure OPCBrokerConnect(AContext: TIdContext);
    procedure OPCBrokerDisconnect(AContext: TIdContext);
    procedure OPCBrokerExecute(AContext: TIdContext);
    procedure OPCBrokerException(AContext: TIdContext; AException: Exception);
    procedure NumberBox1Change(Sender: TObject);

  private
    { Private declarations }
    maxclient,maxGPRS,debuglevel,savestatbool: dword;
    { Private declarations }
    mainreplp: string;
    GPRS_Con,Client_Con,CntHW,bigKSPD,bigkl,bigklcont: dword; // кол-во активных соединений
    tbigKSPD,tbigkl,tbigklcont: TDateTime;
    CheckHW: boolean;

    procedure AddGPRSDevice(id_gprs: DWORD; AContext: TIdContext);
    function IsContextConnected(AContext: TIdContext): Boolean;
   //procedure ProcessCommand(AContext: TIdContext; const Buffer: TIdBytes;
    //  numOPC: Byte; const sNumOPC, ClientIP: string);
    //procedure ProcessCommand1(AContext: TIdContext; numOPC: Byte);
    procedure ProcessTransitPacket(AContext: TIdContext; const Buffer: TIdBytes;
      Size: Integer; numOPC: Byte; const sNumOPC: string; gtk: DWORD;
      const ClientIP: string);
    procedure HandleCommand1(AContext: TIdContext; var buf: TArray<Byte>;
      numOPC: Byte);
    procedure HandleCommand2(buf: TArray<Byte>);
    procedure HandleCommand3(AContext: TIdContext; buf: TArray<Byte>;
      numOPC: Byte; gtk: Cardinal);
    procedure HandleCommand5(AContext: TIdContext; buf: TArray<Byte>);
    procedure HandleCommand6;
    procedure HandleCommand7(AContext: TIdContext; buf: TArray<Byte>);
    procedure CopyMemory(Destination, Source: Pointer; Length: NativeUInt);
    function DateTimeToCTime(ADateTime: TDateTime): Cardinal;
    function GetGPRSListItem(Index: Integer): PInfoGPRS;
//    procedure HandleStatisticsResponse(const Buffer: TIdBytes; Size: Integer;AContext: TIdContext);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
// Массив подключенных OPC клиентов (вместо TIdPeerThread используем TIdContext)
  opc_socket: array[1..ClientMax] of TIdContext;

  // Список GPRS устройств - рекомендуется использовать современные контейнеры
  GPRSList: TDictionary<DWORD, PInfoGPRS>; // или TObjectDictionary для автоматического управления памятью

  // Время последней активности OPC клиентов
  opc_lasttime: array[1..ClientMax] of DWORD;

  // Служебные переменные времени
  predGTC, startbrokerdt: DWORD;

  // Список строк для KSPD (заменил TStrings на TStringList для явного управления)
  kspdstrlist: TStringList;

  // Критическая секция для потокобезопасности (если использовалась в Delphi 7)
    CS,CSBin: TCriticalSection;

implementation
uses IdIPWatch,IdTCPConnection,DateUtils,IdStack,
     IdSocketHandle;
{$R *.fmx}

// Реализация вспомогательных функций
procedure TMainForm.CopyMemory(Destination, Source: Pointer; Length: NativeUInt);
begin
  Move(Source^, Destination^, Length);
end;

function TMainForm.DateTimeToCTime(ADateTime: TDateTime): Cardinal;
begin
  // Реализуйте вашу функцию конвертации даты
  Result := 0; // Заглушка - замените на вашу реализацию
end;

function TMainForm.GetGPRSListItem(Index: Integer): PInfoGPRS;
var
  i: Integer;
  Key: Cardinal;
begin
  Result := nil;
  i := 0;
  for Key in GPRSList.Keys do
  begin
    if i = Index then
    begin
      Result := GPRSList.Items[Key];
      Exit;
    end;
    Inc(i);
  end;
end;

function GetLocalIP: string;
var
  IPWatch: TIdIPWatch;
begin
  IPWatch := TIdIPWatch.Create(nil);
  try
    Result := IPWatch.LocalIP;
  finally
    IPWatch.Free;
  end;
end;

function GetAllLocalIPs: TArray<string>;
var
  IPList: TIdStackLocalAddressList;
  i: Integer;
begin
  SetLength(Result, 0);
  IPList := TIdStackLocalAddressList.Create;
  try
    GStack.GetLocalAddressList(IPList);
    SetLength(Result, IPList.Count);
    for i := 0 to IPList.Count - 1 do
      Result[i] := IPList[i].IPAddress;
  finally
    IPList.Free;
  end;
end;

function GetIDGPRS(AContext: TIdContext): string;
var
  i: PInfoGPRS;
begin
  if AContext.Data <> nil then
  begin
    i := PInfoGPRS(AContext.Data);
    try
      Result := IntToStr(i^.id_gprs);
    except
      Result := 'badunk';
    end;
  end
  else
    Result := 'unk';
end;

function GetIDOPC(AContext: TIdContext): string;
var
  i: Integer;
begin
  if AContext.Data <> nil then
  begin
    i := Integer(AContext.Data);
    try
      Result := IntToStr(i);
    except
      Result := 'badunk';
    end;
  end
  else
    Result := 'unk';
end;

function WriteCRC16(const Data: array of Byte; DataSize: Integer): Word;
const
  CRC16Table: array[0..255] of Word = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040
  );

var
  i: Integer;
  CRC: Word;
begin
  CRC := $FFFF;
  for i := 0 to DataSize - 1 do
    CRC := (CRC shr 8) xor CRC16Table[(CRC xor Data[i]) and $FF];
  Result := CRC;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  IPList: TIdStackLocalAddressList;
  i: Integer;
begin
//  // Инициализация массива сокетов
//  SetLength(opc_socket, maxclient + 1);
//  for i := 1 to maxclient do
//opc_socket[i] := nil;
  maxclient := 100;//инициализация
  Memo1.Lines.Clear;
  Memo1.Lines.Add('=== Все IP-адреса ===');

    // Создание словаря GPRS устройств
  GPRSList := TDictionary<DWORD, PInfoGPRS>.Create;


  IPList := TIdStackLocalAddressList.Create;
  try
    GStack.GetLocalAddressList(IPList);

    for i := 0 to IPList.Count - 1 do
    begin
      Memo1.Lines.Add(Format('%d. %s', [
        i + 1,
        IPList[i].IPAddress
      ]));
    end;
  finally
    IPList.Free;
  end;
  Memo1.Lines.Add('==================');
 GPRSSrv.Active:=True;
  // Настройка сервера
  OPCBroker.MaxConnections := maxclient;
  OPCBroker.Active := True;
 debuglevel:=1;
 // Инициализация критической секции
 CSBin := TCriticalSection.Create;
 CS := TCriticalSection.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  PIGP: PInfoGPRS;
begin

  CSBin.Enter;
  try
    if Assigned(GPRSList) then
    begin
      for PIGP in GPRSList.Values do
        Dispose(PIGP);
      GPRSList.Free;
    end;
  finally
    CSBin.Leave;
  end;
  CSBin.Free;
  CS.Free;
end;

procedure TMainForm.GPRSSrvConnect(AContext: TIdContext);
var
  i: Integer;
begin
  StrToLog('c_GPRS ' + AContext.Connection.Socket.Binding.IP, 0);
  AContext.Data := nil;
  // Инициализация массива OPC сокетов
  for i := 1 to ClientMax do
    opc_socket[i] := nil;

  // Инициализация времени последней активности
  for i := 1 to ClientMax do
    opc_lasttime[i] := 0;


  // Создание строкового списка
  kspdstrlist := TStringList.Create;

  predGTC := TThread.GetTickCount;
  startbrokerdt := TThread.GetTickCount;
end;

procedure TMainForm.GPRSSrvDisconnect(AContext: TIdContext);
var
  i: Integer;
  s: string;
  PIGP: PInfoGPRS;
  Keys: TArray<DWORD>;
  Key: DWORD;
begin
  try
    if AContext.Data <> nil then
      PIGP := PInfoGPRS(AContext.Data)
    else
      PIGP := nil;

    if Assigned(PIGP) then
    begin
      s := 'DisC_GPRS ' + GetIDGPRS(AContext);
      if PIGP^.sock = AContext then
      begin
        StrToLog(s, 0);
        CSBin.Enter;
        try
          GPRSList.Remove(PIGP^.id_gprs);
        finally
          CSBin.Leave;
        end;
        Dispose(PIGP);
        AContext.Data := nil;
        Exit;
      end
      else
        StrToLog(s + ' Bad', 0);
    end
    else
      StrToLog('DisC_GPRS ' + AContext.Connection.Socket.Binding.PeerIP, 0);

    // Поиск по табличке и исключение из обмена
    CSBin.Enter;
    try
      Keys := GPRSList.Keys.ToArray;
      for Key in Keys do
      begin
        if GPRSList.TryGetValue(Key, PIGP) then
        begin
          if (PIGP^.sock = AContext) then
          begin
            Dispose(PIGP);
            GPRSList.Remove(Key);
            StrToLog('DisC_GPRS NOREG', 0);
            AContext.Data := nil;
            Break;
          end;
        end;
      end;
    finally
      CSBin.Leave;
    end;

  except
    on E: Exception do
    begin
      StrToLog('ErrDiscGPRS: ' + E.Message, 0);
    end;
  end;
end;

procedure TMainForm.GPRSSrvException(AContext: TIdContext;
  AException: Exception);
begin
  StrToLog('ErrGPRS: ' + AException.Message, 0);
end;

procedure TMainForm.GPRSSrvExecute(AContext: TIdContext);
var
  buf, buf1: TIdBytes;
  idarr, sostkontact: Byte;
  id_gprs, k, x, l1, hwid, tekDW, i: DWORD;
  found1, manypos: Boolean;
  s, s1: string;
  dd, mm, yy, hh, nn, ss, ms: Word;
  PIGP: PInfoGPRS;
  Connection: TIdTCPConnection;
  Binding: TIdSocketHandle;
begin
  TRY

    Connection := AContext.Connection;
    Binding := Connection.Socket.Binding;

    // пришли данные от GPRS прибора
    SetLength(buf, Connection.IOHandler.InputBuffer.Size);
    if Length(buf) > 0 then
    begin
      Connection.IOHandler.ReadBytes(buf, Length(buf), False);
      i := Length(buf);

      if i > 0 then
      begin
        if i > 2048 then
        begin
          StrToLog('Err: BigOPCPackl=' + IntToStr(i), 0);
          SetLength(buf, 2048);
          i := 2048;
        end;

        tekDW := TThread.GetTickCount;

        // проверка сигнатуры 'TBN'
        if ((i = 8) or (i = 12)) and
           (PInteger(@buf[0])^ and $00FFFFFF = $004E4254) then
        begin
          // прибор кинул ID проверяем - сохраняем в табличке
          id_gprs := PCardinal(@buf[4])^;
          if i = 12 then
            hwid := PCardinal(@buf[8])^
          else
            hwid := 0;

          s := 'ID=' + IntToStr(id_gprs) + '/' + IntToStr(hwid);

          found1 := False;
          if Assigned(AContext.Data) then
          begin
            PIGP := PInfoGPRS(AContext.Data);
            if PIGP^.sock = AContext then
            begin // типа просто пинг
              found1 := True;
              PIGP^.lasttime := tekDW;
              PIGP^.somecl_wait := 0;
              PIGP^.srezdt1 := tekDW;
              PIGP^.busy := False;
              StrToLog(s + ' p', 1);
            end;
          end;

          if not found1 then
          begin
            //PIGP := GPRSList.Items[id_gprs];
            //в TDictionary нет свойства Items с доступом по ключу. Нужно использовать метод TryGetValue.
            if not GPRSList.TryGetValue(id_gprs, PIGP) then
               PIGP := nil;
            if Assigned(PIGP) then
            begin // GPRS контроллер на связи - Rewrite Session
              PIGP^.hw := hwid;
              PIGP^.sock := AContext;
              PIGP^.lasttime := tekDW;
              PIGP^.somecl_wait := 0;
              PIGP^.busy := False;
              PIGP^.srezdt1 := tekDW;
              AContext.Data := TObject(PIGP);
              StrToLog(s + ' r', 0);
            end
            else
            begin // добавляем - первая регистрация
              try
                New(PIGP);
                PIGP^.id_gprs := id_gprs;
                PIGP^.hw := hwid;
                PIGP^.sock := AContext;
                PIGP^.lasttime := tekDW;
                PIGP^.srezdt1 := tekDW;
                PIGP^.busy := False;
                PIGP^.teklen := 0;
                PIGP^.somecl_wait := 0;
                SetLength(PIGP^.tmpbuf,2047);
                AContext.Data := TObject(PIGP);

                CSBin.Enter;  // Вместо EnterCriticalSection(CSBin);
                try
                  GPRSList.Add(id_gprs, PIGP);
                finally
                  CSBin.Leave;  // Вместо LeaveCriticalSection(CSBin);
                end;

                if bigKSPD < GPRSList.Count then
                begin
                  bigKSPD := GPRSList.Count;
                  tbigKSPD := Now;
                end;
                StrToLog(s + ' +', 0);
              except
                StrToLog('No mem on create PIGP', 0);
              end;
            end;
          end;

          try
            PInteger(@buf[0])^ := $004E4254;
            DecodeDateTime(Now, yy, mm, dd, hh, nn, ss, ms);
            buf[3] := dd;
            buf[4] := mm;
            buf[5] := yy - 2000;
            buf[6] := hh;
            buf[7] := nn;
            buf[8] := ss;

            Connection.IOHandler.Write(buf, 9);
          except
            on E: Exception do
              StrToLog('Error sending response: ' + E.Message, 0);
          end;
        end
        else // не ID, а данные для транзита
        begin
          if Assigned(AContext.Data) then
          begin
            PIGP := PInfoGPRS(AContext.Data);
            PIGP^.lasttime := tekDW;
            id_gprs := PIGP^.id_gprs;
          end;

          if debuglevel > 1 then
            StrToLog('GPRSrd ' + GetIDGPRS(AContext) + ' len=' + IntToStr(i) + ' ' +
                     IntToStr(PWord(@buf[6])^), 0);

          if debuglevel > 2 then
          begin
            s := 'From: ';
            if i > 16 then
              x := 15
            else
              x := i - 1;
            for k := 0 to x do
              s := s + ' ' + IntToHex(buf[k], 2);
            StrToLog(s, 0);
          end;

          // Обработка транзита данных к OPC клиентам
          if (i >= 12) and ((buf[1] = $41) or (buf[1] = $42)) and
             (buf[9] < 7) and (buf[7] < 8) then
          begin
            // Проверка на "KSPD:Not Supported"
            if (PCardinal(@buf[11])^ = $4450534B) then
              Exit;

            if (PWord(@buf[6])^ > i - 12) then
            begin // пакет раздробился - собираем
              if (i < 1153) and Assigned(AContext.Data) then
              begin
                StrToLog('First part', 1);
                PIGP := PInfoGPRS(AContext.Data);
                PIGP^.teklen := i;
                Move(buf[0], PIGP^.tmpbuf[0], i);
                Exit;
              end;
            end;

            x := 0;
            manypos := False;

            while x < i do
            begin
              if (i - x >= 12) and ((buf[x+1] = $41) or (buf[x+1] = $42)) then
              begin
                l1 := PWord(@buf[x+6])^ + 12;
                if (x + l1) <= i then
                begin
                  id_gprs := PCardinal(@buf[x+2])^;
                  idarr := buf[x];

                  if Assigned(AContext.Data) then
                  begin
                    PIGP := PInfoGPRS(AContext.Data);
                    PIGP^.teklen := 0;
                    PIGP^.busy := False;
                  end;

                  // Отправка данных OPC клиенту
                  try
                    StrToLog('Tranzit GPRS ' + IntToStr(id_gprs) + ' to OPC' + IntToStr(idarr), 0);

                    SetLength(buf1, l1);
                    Move(buf[x], buf1[0], l1);

                  if IsContextConnected(opc_socket[idarr]) then
                  begin
                    try
                      opc_socket[idarr].Connection.IOHandler.Write(buf1, l1);
                    except
                      on E: Exception do
                        StrToLog('Err: send2opc ' + IntToStr(idarr) + ': ' + E.Message, 0);
                    end;
                  end;

                  except
                    on E: Exception do
                      StrToLog('Err: send2opc ' + IntToStr(idarr) + ': ' + E.Message, 0);
                  end;

                  Inc(x, l1);
                end
                else
                  Break;
              end
              else
                Break;
            end;
          end
          else
          begin // Обработка частей раздробленного пакета
            if (i < 1153) and Assigned(AContext.Data) then
            begin
              PIGP := PInfoGPRS(AContext.Data);
              if PIGP^.teklen > 0 then
              begin
                x := PIGP^.teklen;
                l1 := PWord(@PIGP^.tmpbuf[6])^ + 12;

                if (x + i) <= l1 then
                begin
                  SetLength(PIGP^.tmpbuf, x + i);
                  Move(buf[0], PIGP^.tmpbuf[x], i);
                  PIGP^.teklen := x + i;

                  if (x + i) = l1 then
                  begin // пакет полностью собран
                    PIGP^.busy := False;
                    StrToLog('Finish part', 1);

                    id_gprs := PCardinal(@PIGP^.tmpbuf[2])^;
                    idarr := PIGP^.tmpbuf[0];

                    try
                      StrToLog('Tranzit GPRS ' + IntToStr(id_gprs) + ' to OPC' + IntToStr(idarr), 0);

                      if (idarr > 0) and (idarr <= maxclient) and
                         IsContextConnected(opc_socket[idarr]) then
                      begin
                        //opc_socket[idarr].IOHandler.Write(PIGP^.tmpbuf, Length(PIGP^.tmpbuf));
                        try
                            opc_socket[idarr].Connection.IOHandler.Write(PIGP^.tmpbuf, Length(PIGP^.tmpbuf));
                        except
                            on E: Exception do
                              StrToLog('Err: send2opc ' + IntToStr(idarr) + ': ' + E.Message, 0);
                        end;
                      end;
                    except
                      on E: Exception do
                        StrToLog('Err: send2opc ' + IntToStr(idarr) + ': ' + E.Message, 0);
                    end;

                    PIGP^.teklen := 0;
                    SetLength(PIGP^.tmpbuf, 0);
                  end
                  else
                    StrToLog('Next part', 1);
                end
                else
                begin
                  // Переполнение буфера - сбрасываем
                  PIGP^.teklen := 0;
                  SetLength(PIGP^.tmpbuf, 0);
                  StrToLog('Buffer overflow, reset', 1);
                end;
              end;
            end;
          end;
        end;
      end;
    end;

  EXCEPT
    on E: Exception do
    begin
      StrToLog('ErrReadGPRS: ' + E.Message, 0);
    end;
  END;
end;

procedure TMainForm.StrToLog(AStr: string; Option: byte);
begin
  if debuglevel>(Option and $7F) then
   begin
     TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
           if Assigned(Memo1) then
              Memo1.Lines.Add(TimeToStr(Time)+' '+AStr);
        end);
   end;
end;

procedure TMainForm.AddGPRSDevice(id_gprs: DWORD; AContext: TIdContext);
var
  PIGP: PInfoGPRS;
begin
  New(PIGP);
  PIGP^.id_gprs := id_gprs;
  PIGP^.sock := AContext;

  CSBin.Enter;
  try
    GPRSList.AddOrSetValue(id_gprs, PIGP);
  finally
    CSBin.Leave;
  end;
end;

function TMainForm.IsContextConnected(AContext: TIdContext): Boolean;
begin
  Result := False;
  try
    if Assigned(AContext) and
       Assigned(AContext.Connection) then
      Result := AContext.Connection.Connected;
  except
    on E: Exception do
    begin
      Result := False;
      StrToLog('Error checking connection: ' + E.Message, 0);
    end;
  end;
end;

procedure TMainForm.NumberBox1Change(Sender: TObject);
begin
  debuglevel:=Round(NumberBox1.Value);
end;

procedure TMainForm.OPCBrokerConnect(AContext: TIdContext);
var
  i: Integer;
  ClientIP: string;
begin
  ClientIP := AContext.Connection.Socket.Binding.PeerIP;

  // Ищем свободный слот
  for i := 1 to maxclient do
  begin
    if not Assigned(opc_socket[i]) then
    begin
      opc_socket[i] := AContext;
      AContext.Data := TObject(i); // Сохраняем номер клиента
      StrToLog('Client connected: ' + ClientIP + ' as client #' + IntToStr(i), 0);
      Exit;
    end;
  end;

  // Если не нашли свободный слот
  StrToLog('Maximum clients reached (' + IntToStr(maxclient) + '), rejecting connection from ' + ClientIP, 0);
  AContext.Connection.Disconnect;
end;

procedure TMainForm.OPCBrokerDisconnect(AContext: TIdContext);
var
  ClientNum: Integer;
begin
  if Assigned(AContext.Data) then
  begin
    ClientNum := Integer(AContext.Data);
    if (ClientNum > 0) and (ClientNum <= maxclient) then
    begin
      opc_socket[ClientNum] := nil;
      StrToLog('Client #' + IntToStr(ClientNum) + ' disconnected', 0);
    end;
  end;
  AContext.Data := nil;
end;


procedure TMainForm.ProcessTransitPacket(AContext: TIdContext; const Buffer: TIdBytes;
Size: Integer; numOPC: Byte; const sNumOPC: string; gtk: DWORD; const ClientIP: string);
var
  id_gprs: DWORD;
  PIGPRS: PInfoGPRS;
  ResponseBuffer: TIdBytes;
  ModifiedBuffer: TIdBytes;
  timeout: Integer;
  WaitAnsw: DWORD;
begin
  // Извлекаем ID GPRS
  Move(Buffer[2], id_gprs, 4);

  if numOPC > 0 then
  begin
    if not GPRSList.TryGetValue(id_gprs, PIGPRS) then
      PIGPRS := nil;
    //PIGPRS := GPRSList.Items[id_gprs];
    if Assigned(PIGPRS) then
    begin
      // GPRS контроллер на связи
      StrToLog(Format('Tranzit OPC2GPRS %s %d (IP: %s)', [sNumOPC, id_gprs, ClientIP]), 0);

      try
        // Подменяем номер контроллера
        SetLength(ModifiedBuffer, Size);
        Move(Buffer[0], ModifiedBuffer[0], Size);

        if ModifiedBuffer[0] <> numOPC then
        begin
          ModifiedBuffer[0] := numOPC;
          WriteCRC16(ModifiedBuffer, Size - 2);
        end;

        // Проверка занятости устройства
        if PIGPRS^.busy and ((PIGPRS^.srezdt1 + WaitAnsw) > gtk) then
        begin
          if numOPC = PIGPRS^.busycl then
          begin
            if debuglevel > 2 then StrToLog('Skip (busy)', 0);
            Exit;
          end;

          Inc(PIGPRS^.somecl_wait);
          timeout := PIGPRS^.srezdt1 + WaitAnsw;

          while gtk < timeout do
          begin
            TThread.Sleep(200);
            gtk := TThread.GetTickCount;
            if not PIGPRS^.busy then Break;
          end;

          if PIGPRS^.somecl_wait > 0 then
            Dec(PIGPRS^.somecl_wait);
        end
        else
        begin
          PIGPRS^.somecl_wait := 0;
        end;

        if debuglevel > 2 then StrToLog('Send Data to GPRS', 0);

        // Отправка данных GPRS устройству
        if Assigned(PIGPRS^.sock) and PIGPRS^.sock.Connection.Connected then
        begin
          PIGPRS^.sock.Connection.IOHandler.Write(ModifiedBuffer);
          PIGPRS^.busycl := numOPC;
          PIGPRS^.srezdt1 := gtk;
          PIGPRS^.busy := True;
        end
        else
        begin
          StrToLog(Format('GPRS device not connected: %d', [id_gprs]), 0);
        end;

      except
        on E: Exception do
        begin
          StrToLog(Format('Err: send2GPRS %d: %s', [id_gprs, E.Message]), 0);
        end;
      end;
    end
    else
    begin
      // Устройство не найдено - отправляем ошибку
      StrToLog(Format('Err: NF %d (IP: %s)', [id_gprs, ClientIP]), 0);

      try
        SetLength(ResponseBuffer, 12);
        PWord(@ResponseBuffer[0])^ := PWord(@Buffer[0])^ + $8000;
        PLongWord(@ResponseBuffer[2])^ := id_gprs;
        PWord(@ResponseBuffer[6])^ := 0;
        PWord(@ResponseBuffer[8])^ := PWord(@Buffer[8])^;
        WriteCRC16(ResponseBuffer, 10);

        AContext.Connection.IOHandler.Write(ResponseBuffer);
      except
        on E: Exception do
        begin
          StrToLog(Format('Error sending NF response: %s', [E.Message]), 0);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.OPCBrokerException(AContext: TIdContext;
  AException: Exception);
begin
  // Простой аналог оригинального кода
  StrToLog('ErrBroker: ' + AException.Message, 0);
end;

procedure TMainForm.OPCBrokerExecute(AContext: TIdContext);
var
  s: shortstring;
  s1, snumopc: shortstring;
  buf: TArray<Byte>;
  buferror: array[0..11] of Byte;
  bufstatist: array[0..12] of Byte;
  i, j, k: Integer;
  id_gprs, id1, gtk, timeout: Cardinal;
  tmpbuf: TArray<Byte>;
  numOPC: Byte;
  PIGPRS: PInfoGPRS;
  Connection: TIdTCPConnection;
  Bytes: TIdBytes;
  tmpL:longword;
  tmpBx:array [0..3] of byte absolute tmpL;
begin

  if not Assigned(GPRSList) then
  begin
    StrToLog('GPRSList not initialized!', 0);
    Exit;
  end;
  Connection := AContext.Connection;

  // Чтение данных из соединения
  Connection.IOHandler.ReadBytes(Bytes, -1, False);
  if Length(Bytes) = 0 then Exit;

  // Преобразование TIdBytes в string
  s := TEncoding.ANSI.GetString(Bytes);
  i := Length(s);

  if i > 0 then
  begin
    gtk := TThread.GetTickCount;

    // Получение номера клиента
    if Assigned(AContext.Data) then
    begin
      k := Cardinal(AContext.Data);
      if (k > 0) and (k <= maxclient) then
        opc_lasttime[k] := gtk
      else
        k := 0;
    end
    else
      k := 0;

    numOPC := k;
    if numOPC > 99 then
      snumopc := IntToStr(numOPC)
    else if numOPC > 9 then
      snumopc := Chr($30 + (numOPC div 10)) + Chr($30 + (numOPC mod 10))
    else
      snumopc := Chr($30 + numOPC);

    if i > 2048 then
    begin
      StrToLog('Err: BigOPCPack' + snumopc + ' l=' + IntToStr(i), 0);
      i := 2048;
    end;

    // Подготовка буфера
    SetLength(buf, 2047);
    Move(s[1], buf[0], i);

    if debuglevel > 2 then
      StrToLog('Data from Client' + snumopc + ' l=' + IntToStr(i), 0);

    if i > 9 then
    begin
      if ((buf[1] = $41) or (buf[1] = $42)) and (PWord(@buf[6])^ = i - 12) then
      begin
        // Извлекаем ID GPRS
        id_gprs := PCardinal(@buf[2])^;

        if numOPC > 0 then
        begin
          if not GPRSList.TryGetValue(id_gprs, PIGPRS) then
            PIGPRS := nil;
          //PIGPRS := GPRSList.Items[id_gprs];
          if Assigned(PIGPRS) then
          begin
            StrToLog('Tranzit OPC2GPRS ' + snumopc + ' ' + IntToStr(id_gprs), 0);
            try
              // Подменяем номер контроллера (клиента)
              if buf[0] <> numOPC then
              begin
                buf[0] := numOPC and $FF;
                WriteCRC16(buf, i - 2);
              end;

              if (PIGPRS^.busy) and ((PIGPRS^.srezdt1 + WaitAnsw) > gtk) then
              begin
                if numOPC = PIGPRS^.busycl then
                begin
                  if debuglevel > 2 then StrToLog('Skip', 0);
                  Exit;
                end;

                Inc(PIGPRS^.somecl_wait);
                timeout := PIGPRS^.srezdt1 + WaitAnsw;

                while gtk < timeout do
                begin
                  TThread.Sleep(200);
                  gtk := TThread.GetTickCount;
                  if not PIGPRS^.busy then Break;
                end;

                if PIGPRS^.somecl_wait > 0 then
                  Dec(PIGPRS^.somecl_wait);
              end
              else
                PIGPRS^.somecl_wait := 0;

              if debuglevel > 2 then StrToLog('Send Data', 0);

              // Отправка данных через сокет
              PIGPRS^.sock.Connection.IOHandler.Write(TIdBytes(buf), i);
              PIGPRS^.busycl := numOPC;
              PIGPRS^.srezdt1 := gtk;
              PIGPRS^.busy := True;

            except
              on E: Exception do
                StrToLog('Err: send2GPRS ' + IntToStr(id_gprs) + ': ' + E.Message, 0);
            end;
          end
          else
          begin
            StrToLog('Err: NF ' + IntToStr(id_gprs), 0);
            try
              PWord(@buferror[0])^ := PWord(@buf[0])^ + $8000;
              PCardinal(@buferror[2])^ := id_gprs;
              PWord(@buferror[6])^ := 0;
              PWord(@buferror[8])^ := PWord(@buf[8])^;
              WriteCRC16(buferror, 10);

              // Отправка ошибки клиенту
              Connection.IOHandler.Write(RawToBytes(buferror[0], 12));
              //Connection.IOHandler.Write(TIdBytes(buferror), 12);
            except
              on E: Exception do
                StrToLog('Error sending error response: ' + E.Message, 0);
            end;
          end;
        end;
      end
      else
        StrToLog('Unknown pos. l=' + IntToStr(i), 0);
    end
    else
      begin
        if i = 8 then
        begin
          if debuglevel > 2 then
          begin
            s := 'Cmd From: ';
            var tmpb:byte;
            for k := 0 to 7 do begin
              tmpb:=buf[k];
              s := s + ' ' + IntToHex(tmpb, 2);
            end;
            StrToLog(s, 0);
          end;

          // НОВАЯ ПРОВЕРКА СИГНАТУРЫ:
          tmpL:=PCardinal(@buf[0])^;
          if (tmpL  and $FFFFFF = $4E4254) then // Big-endian 'TBN'
          begin
            id_gprs := buf[3];
            StrToLog('Cmd ' + Chr(id_gprs + $30) + ' OPC' + snumopc, 0);

            case id_gprs of
              1: HandleCommand1(AContext, buf, numOPC);
              2: HandleCommand2(buf);
              3: HandleCommand3(AContext, buf, numOPC, gtk);
              5: HandleCommand5(AContext, buf);
              6: HandleCommand6;
              7: HandleCommand7(AContext, buf);
            end;
          end
          else
          begin
            StrToLog('Bad sign: ' + IntToHex(PCardinal(@buf[0])^, 8), 0);
          end;
        end
        else
          StrToLog('l<>8', 0);// i=8
      end;
  end;
end;

// Вспомогательные методы для обработки команд
procedure TMainForm.HandleCommand1(AContext: TIdContext; var buf: TArray<Byte>; numOPC: Byte);
var
  j, k, i: Integer;
  tmpbuf: TArray<Byte>;
  PIGPRS: PInfoGPRS;
  id1: Cardinal;
  Connection: TIdTCPConnection;
begin
  Connection := AContext.Connection;
  j := GPRSList.Count;

  if j > 0 then
  begin
    TMonitor.Enter(CSBin);
    try
      SetLength(tmpbuf, 16 + (j * 8));
      FillChar(tmpbuf[0], Length(tmpbuf), 0);
      k := 16;
      for i := 0 to j - 1 do
      begin
        PIGPRS := GetGPRSListItem(i); // Исправленный вызов
        PCardinal(@tmpbuf[k])^ := PIGPRS^.id_gprs;
        PCardinal(@tmpbuf[k + 4])^ := PIGPRS^.hw;
        Inc(k, 8);
      end;
      PCardinal(@tmpbuf[0])^ := j;
    finally
      TMonitor.Exit(CSBin);
    end;
  end;

  if j > 0 then
  begin
    id1 := j div 127;
    k := j mod 127;
    if k > 0 then Inc(id1);
    if k = 0 then k := 127;

    try
      for i := 0 to id1 - 1 do
      begin
        if i = id1 - 1 then
        begin
          buf[3] := k;
          if i = 0 then
          begin
            Move(tmpbuf[16], buf[4], k * 8); // Замена CopyMemory на Move
            Connection.IOHandler.Write(TIdBytes(buf), 4 + (k * 8));
          end
          else
          begin
            Move(tmpbuf[16 + ((127 * 8) * i)], buf[4], k * 8);
            PCardinal(@buf[4 + (k * 8)])^ := (i shl 16) or Cardinal(j);
            Connection.IOHandler.Write(TIdBytes(buf), 8 + (k * 8));
          end;
        end
        else
        begin
          Move(tmpbuf[16 + ((127 * 8) * i)], buf[4], 127 * 8);
          buf[3] := 127;
          PCardinal(@buf[1020])^ := (i shl 16) or Cardinal(j);
          Connection.IOHandler.Write(TIdBytes(buf), 1024);

          Application.ProcessMessages;
          TThread.Sleep(400);
        end;
      end;
    except
      on E: Exception do
        StrToLog('Err: SM1: ' + E.Message, 0);
    end;
  end
  else
  begin
    buf[3] := 0;
    try
      Connection.IOHandler.Write(TIdBytes(buf), 4);
    except
      on E: Exception do
        StrToLog('Error sending empty response: ' + E.Message, 0);
    end;
  end;

  SetLength(tmpbuf, 0);
end;

procedure TMainForm.HandleCommand2(buf: TArray<Byte>);
var
  j, i: Integer;
  PIGPRS: PInfoGPRS;
begin
  if buf[7] < 4 then
  begin
    debuglevel := buf[7];
    StrToLog('Set DbgLevel ' + IntToStr(debuglevel), 0);
  end
  else
  begin
    StrToLog('Sbros Busy', 0);
    j := GPRSList.Count;
    if j > 0 then
    begin
      TMonitor.Enter(CSBin);
      try
        for i := 0 to j - 1 do
        begin
          try
            PIGPRS := GetGPRSListItem(i); // Исправленный вызов
            if Assigned(PIGPRS) then
            begin
              PIGPRS^.somecl_wait := 0;
              PIGPRS^.busy := False;
            end;
          except
            on E: Exception do
              StrToLog('Error in HandleCommand2: ' + E.Message, 0);
          end;
        end;
      finally
        TMonitor.Exit(CSBin);
      end;
    end;
  end;
end;

procedure TMainForm.HandleCommand3(AContext: TIdContext; buf: TArray<Byte>; numOPC: Byte; gtk: Cardinal);
var
  id_gprs: Cardinal;
  PIGPRS: PInfoGPRS;
  i, j: Integer;
  timeout: Cardinal;
  bufstatist: array[0..12] of Byte;
begin
  // Извлекаем ID GPRS
  id_gprs := PCardinal(@buf[4])^;
  if numOPC = 0 then
    bufstatist[0] := $FF
  else
    bufstatist[0] := numOPC;

  bufstatist[1] := $42;
  PCardinal(@bufstatist[6])^ := $00000001;
  bufstatist[10] := 2;

  if id_gprs > 0 then
  begin
    PIGPRS := GPRSList.Items[id_gprs];
    if Assigned(PIGPRS) then
    begin
      try
        StrToLog('ExStat for ' + IntToStr(id_gprs), 0);
        PCardinal(@bufstatist[2])^ := id_gprs;
        PWord(@bufstatist[11])^:=WriteCRC16(bufstatist, 11);

        if (PIGPRS^.busy) and ((PIGPRS^.srezdt1 + WaitAnsw) > gtk) then
        begin
          Inc(PIGPRS^.somecl_wait);
          timeout := PIGPRS^.srezdt1 + WaitAnsw;
          while gtk < timeout do
          begin
            TThread.Sleep(200);
            gtk := TThread.GetTickCount;
            if not PIGPRS^.busy then Break;
          end;
          if PIGPRS^.somecl_wait > 0 then
            Dec(PIGPRS^.somecl_wait);
        end
        else
          PIGPRS^.somecl_wait := 0;

        if debuglevel > 2 then
          StrToLog('Send Data', 0);

        PIGPRS^.sock.Connection.IOHandler.Write(RawToBytes(bufstatist[0],  13));
        PIGPRS^.busy := True;
        PIGPRS^.srezdt1 := gtk;
      except
        on E: Exception do
          StrToLog('Err: ExStat ' + IntToStr(id_gprs) + ': ' + E.Message, 0);
      end;
    end;
  end
  else
  begin
    j := GPRSList.Count;
    if j > 0 then
    begin
      for i := 0 to j - 1 do
      begin
        if i > (GPRSList.Count - 1) then
          Exit;

        try
          PIGPRS := GetGPRSListItem(i);
          PCardinal(@bufstatist[2])^ := PIGPRS^.id_gprs;
          WriteCRC16(bufstatist, 11);

          if (PIGPRS^.busy) and ((PIGPRS^.srezdt1 + WaitAnsw) > gtk) then
          begin
            Inc(PIGPRS^.somecl_wait);
            timeout := PIGPRS^.srezdt1 + WaitAnsw;
            while gtk < timeout do
            begin
              TThread.Sleep(200);
              gtk := TThread.GetTickCount;
              if not PIGPRS^.busy then Break;
            end;
            if PIGPRS^.somecl_wait > 0 then
              Dec(PIGPRS^.somecl_wait);
          end
          else
            PIGPRS^.somecl_wait := 0;

          if debuglevel > 2 then
            StrToLog('Send Data' + IntToStr(i), 0);

          PIGPRS^.sock.Connection.IOHandler.Write(RawToBytes(bufstatist[0], 13));
          TThread.Sleep(150);
          PIGPRS^.srezdt1 := gtk;
          PIGPRS^.busy := True;
        except
          on E: Exception do
            StrToLog('Err: ExStat ' + IntToStr(i) + ': ' + E.Message, 0);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.HandleCommand5(AContext: TIdContext; buf: TArray<Byte>);
var
  i, k: Integer;
  Connection: TIdTCPConnection;
begin
  Connection := AContext.Connection;

  PCardinal(@buf[4])^ := GPRSList.Count;
  PCardinal(@buf[8])^ := bigKSPD;
  PCardinal(@buf[12])^ := bigkl;
  PCardinal(@buf[16])^ := DateTimeToCTime(tbigKSPD);
  PCardinal(@buf[20])^ := DateTimeToCTime(tbigkl);

  k := 0;
  for i := 1 to maxclient do
  begin
    try
      if Assigned(opc_socket[i]) then
        Inc(k);
    except
      on E: Exception do
        StrToLog('Error counting clients: ' + E.Message, 0);
    end;
  end;

  PCardinal(@buf[24])^ := k;
  PCardinal(@buf[28])^ := startbrokerdt;

  try
    Connection.IOHandler.Write(TIdBytes(buf), 32);
    TThread.Sleep(400);
  except
    on E: Exception do
      StrToLog('Error sending command 5 response: ' + E.Message, 0);
  end;
end;

procedure TMainForm.HandleCommand6;
var
  j, i, k: Integer;
  tmpbuf: TArray<Byte>;
  PIGPRS: PInfoGPRS;
  s1: string;
begin
  j := GPRSList.Count;
  if j > 0 then
  begin
    TMonitor.Enter(CSBin);
    try
      SetLength(tmpbuf, 16 + (j * 8));
      FillChar(tmpbuf[0], Length(tmpbuf), 0);
      k := 16;
      for i := 0 to j - 1 do
      begin
        PIGPRS := GetGPRSListItem(i);
        PCardinal(@tmpbuf[k])^ := PIGPRS^.id_gprs;
        PCardinal(@tmpbuf[k + 4])^ := PIGPRS^.hw;
        Inc(k, 8);
      end;
      PCardinal(@tmpbuf[0])^ := j;
    finally
      TMonitor.Exit(CSBin);
    end;
  end;

  s1 := mainreplp + FormatDateTime('mmdd_hhnnss', Now) + '.csv';

  TMonitor.Enter(kspdstrlist);
  try
    kspdstrlist.BeginUpdate;
    try
      kspdstrlist.Add(DateTimeToStr(Now));
      kspdstrlist.Add('Кол-во КСПД: ' + IntToStr(j));
      kspdstrlist.Add('');

      k := 16;
      for i := 1 to j do
      begin
        kspdstrlist.Add(IntToStr(i) + ';' + IntToStr(PCardinal(@tmpbuf[k])^) +
                       ';' + IntToStr(PCardinal(@tmpbuf[k + 4])^));
        Inc(k, 8);
      end;
    finally
      kspdstrlist.EndUpdate;
    end;

    try
      kspdstrlist.SaveToFile(s1);
      StrToLog(s1, 0);
      kspdstrlist.Clear;
    except
      on E: Exception do
        StrToLog('Error saving to file: ' + E.Message, 0);
    end;
  finally
    TMonitor.Exit(kspdstrlist);
  end;

  SetLength(tmpbuf, 0);
end;

procedure TMainForm.HandleCommand7(AContext: TIdContext; buf: TArray<Byte>);
var
  Connection: TIdTCPConnection;
  activeConnections, activeThreads, idleThreads: Integer;
begin
  Connection := AContext.Connection;

  // Здесь должна быть реализация получения статистики потоков
  // Это зависит от вашей конкретной реализации пула потоков

      // Если менеджер потоков не назначен
  activeConnections := OPCBroker.Contexts.Count;
  activeThreads := activeConnections;
  idleThreads := 0;

  PCardinal(@buf[4])^ := activeConnections;
  PCardinal(@buf[8])^ := activeThreads;
  PCardinal(@buf[12])^ := idleThreads;

  try
    Connection.IOHandler.Write(TIdBytes(buf), 16);
  except
    on E: Exception do
      StrToLog('Error sending command 7 response: ' + E.Message, 0);
  end;
end;

end.
