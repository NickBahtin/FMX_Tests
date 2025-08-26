unit fuMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListBox, FMX.Layouts, FMX.Memo, DateUtils, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Menus, fuSetup, REST.Types, REST.Client,
  System.JSON,
  uDevice,
  uLoaderTypes,
  PluginUnit, //Интерфейс к библиотеке
  Data.Bind.Components, Data.Bind.ObjectScope;

type

  // Объявляем типы для событий перед классами
  TLogEvent = procedure(const AMessage: string) of object;

  TConnectionKey = record
    ServerIP: string;
    Port: Word;
    Line: string;
    function ToString: string;
  end;

  TTaskType = (ttCurrentValues, ttHourArchive, ttDayArchive);

  TDeviceTask = class
  private
    FDevice: TUnitDeviceOfLoader;
    FTaskType: TTaskType;
    FNextRun: TDateTime;
    FOnLog: TLogEvent;
    FDebugMessage: string;
    procedure SetDebugMessage(const Value: string);
  public
    constructor Create(ADevice: TUnitDeviceOfLoader; ATaskType: TTaskType);
    property Device: TUnitDeviceOfLoader read FDevice;
    property TaskType: TTaskType read FTaskType;
    property NextRun: TDateTime read FNextRun write FNextRun;
    property OnLog: TLogEvent read FOnLog write FOnLog;
    property DebugMessage:string read FDebugMessage write SetDebugMessage;
  end;


  TConnectionWorker = class(TThread)
  private
    FConnectionKey: TConnectionKey;
    FTasks: TObjectList<TDeviceTask>;
    FBusy: Boolean;
    FOnLog: TLogEvent;
    procedure DoLog(const AMessage: string);
    procedure ReadCurrentValues(ADevice: TUnitDeviceOfLoader);
    procedure ReadHourArchive(ADevice: TUnitDeviceOfLoader);
    procedure ReadDayArchive(ADevice: TUnitDeviceOfLoader);
  protected
    procedure Execute; override;
  public
    constructor Create(AConnectionKey: TConnectionKey);
    destructor Destroy; override;
    procedure AddTask(ATask: TDeviceTask);
    property Busy: Boolean read FBusy;
    property OnLog: TLogEvent read FOnLog write FOnLog;
  end;

  TTaskManager = class
  private
    FWorkers: TObjectDictionary<TConnectionKey, TConnectionWorker>;
    FAllTasks: TObjectList<TDeviceTask>;
    FTimer: TTimer;
    FOnLog: TLogEvent;
    procedure OnTimer(Sender: TObject);
    function GetConnectionKey(ADevice: TDeviceInformation): TConnectionKey;
    procedure ScheduleTasks;
    procedure DoLog(const AMessage: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize(ADevices: TArray<TUnitDeviceOfLoader>);
    procedure StartMonitoring;
    procedure StopMonitoring;
    property OnLog: TLogEvent read FOnLog write FOnLog;
  end;

  TfrmMain = class(TForm)
    pnlTop: TPanel;
    btnStart: TButton;
    btnStop: TButton;
    memLog: TMemo;
    pnlDevices: TPanel;
    lbDevices: TListBox;
    Splitter1: TSplitter;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    miSettings: TMenuItem;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    btnConnectRestAPI: TButton;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure btnConnectRestAPIClick(Sender: TObject);
  private
    FTaskManager: TTaskManager;
    FDevices: TArray<TUnitDeviceOfLoader>;
    procedure LoadDevices;
    procedure LogMessage(const AMessage: string);
    procedure UpdateDevicesList;
    procedure ParseJsonDevice_List;
    procedure WriteLn(S:String; tmpS: String='';force:boolean=false);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

{ TConnectionKey }

function TConnectionKey.ToString: string;
begin
  Result := Format('%s:%d:%s', [ServerIP, Port, Line]);
end;

{ TDeviceTask }

constructor TDeviceTask.Create(ADevice: TUnitDeviceOfLoader; ATaskType: TTaskType);
begin
  inherited Create;
  FDevice := ADevice;
  FTaskType := ATaskType;
end;

procedure TDeviceTask.SetDebugMessage(const Value: string);
begin
  FDebugMessage := Value;
  if Assigned(FOnLog) then
    FOnLog(Value);
end;

{ TConnectionWorker }

constructor TConnectionWorker.Create(AConnectionKey: TConnectionKey);
begin
  inherited Create(True);
  FConnectionKey := AConnectionKey;
  FTasks := TObjectList<TDeviceTask>.Create(False);
  FreeOnTerminate := False;
end;

destructor TConnectionWorker.Destroy;
begin
  FTasks.Free;
  inherited;
end;

procedure TConnectionWorker.AddTask(ATask: TDeviceTask);
begin
  FTasks.Add(ATask);
end;

procedure TConnectionWorker.DoLog(const AMessage: string);
begin
  if Assigned(FOnLog) then
    FOnLog(AMessage);
end;

procedure TConnectionWorker.Execute;
var
  Task: TDeviceTask;
begin
  while not Terminated do
  begin
    if FTasks.Count > 0 then
    begin
      FBusy := True;
      try
        Task := FTasks[0];
        FTasks.Delete(0);

        DoLog(Format('Выполнение задачи для устройства %d', [Task.Device.Info.ID]));

        case Task.TaskType of
          ttCurrentValues: ReadCurrentValues(Task.Device);
          ttHourArchive: ReadHourArchive(Task.Device);
          ttDayArchive: ReadDayArchive(Task.Device);
        end;

      finally
        FBusy := False;
      end;
    end
    else
    begin
      Sleep(100);
    end;
  end;
end;

procedure TConnectionWorker.ReadCurrentValues(ADevice: TUnitDeviceOfLoader);
begin
  // Имитация чтения текущих значений
  Sleep(Random(1000) + 500);
  DoLog(Format('Прочитаны текущие значения устройства %d', [ADevice.Info.ID]));
end;

procedure TConnectionWorker.ReadHourArchive(ADevice: TUnitDeviceOfLoader);
begin
  // Имитация чтения часового архива
  Sleep(Random(2000) + 1000);
  DoLog(Format('Прочитан часовой архив устройства %d', [ADevice.Info.ID]));
end;

procedure TConnectionWorker.ReadDayArchive(ADevice: TUnitDeviceOfLoader);
begin
  // Имитация чтения суточного архива
  Sleep(Random(3000) + 2000);
  DoLog(Format('Прочитан суточный архив устройства %d', [ADevice.Info.ID]));
end;

{ TTaskManager }

constructor TTaskManager.Create;
begin
  inherited;
  FWorkers := TObjectDictionary<TConnectionKey, TConnectionWorker>.Create([doOwnsValues]);
  FAllTasks := TObjectList<TDeviceTask>.Create(True);
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 30000; // Проверка каждые 30 секунд
  FTimer.OnTimer := OnTimer;
end;

destructor TTaskManager.Destroy;
begin
  StopMonitoring;
  FWorkers.Free;
  FAllTasks.Free;
  FTimer.Free;
  inherited;
end;

procedure TTaskManager.DoLog(const AMessage: string);
begin
  if Assigned(FOnLog) then
    FOnLog(AMessage);
end;

function TTaskManager.GetConnectionKey(ADevice: TDeviceInformation): TConnectionKey;
begin
  Result.ServerIP := ADevice.server_ip;
  Result.Port := ADevice.port;
  Result.Line := ADevice.line;
end;

procedure TTaskManager.Initialize(ADevices: TArray<TUnitDeviceOfLoader>);
var
  Device: TUnitDeviceOfLoader;
  CurrentTask, HourTask, DayTask: TDeviceTask;
begin
  DoLog('Инициализация менеджера задач...');

  for Device in ADevices do
  begin
    //Создаем  устрйоство


    // Задача для мониторинга текущих значений (каждые 5 минут)
    CurrentTask := TDeviceTask.Create(Device, ttCurrentValues);
    CurrentTask.OnLog:=DoLog;
    CurrentTask.NextRun := Now + (5 * OneMinute); // 5 минут
    FAllTasks.Add(CurrentTask);

    // Задача для часового архива (каждый час)
    HourTask := TDeviceTask.Create(Device, ttHourArchive);
    HourTask.NextRun := Now + OneHour; // 1 час
    FAllTasks.Add(HourTask);

    // Задача для суточного архива (каждые 24 часа)
    DayTask := TDeviceTask.Create(Device, ttDayArchive);
    DayTask.NextRun := Now + OneDay; // 24 часа
    FAllTasks.Add(DayTask);
  end;

  DoLog(Format('Создано задач:%d ', [FAllTasks.Count]));
end;

procedure TTaskManager.ScheduleTasks;
var
  Task: TDeviceTask;
  ConnectionKey: TConnectionKey;
  Worker: TConnectionWorker;
  TasksScheduled: Integer;
begin
  TasksScheduled := 0;

  for Task in FAllTasks do
  begin
    if Task.NextRun <= Now then
    begin
      ConnectionKey := GetConnectionKey(Task.Device.Info);

      if not FWorkers.TryGetValue(ConnectionKey, Worker) then
      begin
        Worker := TConnectionWorker.Create(ConnectionKey);
        Worker.OnLog := DoLog;
        Worker.Start;
        FWorkers.Add(ConnectionKey, Worker);
        DoLog(Format('Создан новый воркер для %s', [ConnectionKey.ToString]));
      end;

      if not Worker.Busy then
      begin
        Worker.AddTask(Task);
        Inc(TasksScheduled);

        // Обновляем время следующего выполнения с использованием констант
        case Task.TaskType of
          ttCurrentValues: Task.NextRun := Now + (5 * OneMinute);
          ttHourArchive: Task.NextRun := Now + OneHour;
          ttDayArchive: Task.NextRun := Now + OneDay;
        end;
      end;
    end;
  end;

  if TasksScheduled > 0 then
    DoLog(Format('Запланировано %d задач', [TasksScheduled]));
end;

procedure TTaskManager.OnTimer(Sender: TObject);
begin
  ScheduleTasks;
end;


procedure TTaskManager.StartMonitoring;
begin
  FTimer.Enabled := True;
  DoLog('Мониторинг запущен');
end;

procedure TTaskManager.StopMonitoring;
var
  Worker: TConnectionWorker;
begin
  FTimer.Enabled := False;

  for Worker in FWorkers.Values do
  begin
    Worker.Terminate;
    Worker.WaitFor;
  end;

  FWorkers.Clear;
  DoLog('Мониторинг остановлен');
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  LibsPath: string;
begin
  // Определяем путь к каталогу LIBS
  LibsPath := ExtractFilePath(ParamStr(0)) + 'LIBS' + PathDelim;
  Randomize;
  // Проверяем и создаем каталог LIBS, если его нет
  if not DirectoryExists(LibsPath) then
  begin
    try
      CreateDir(LibsPath);
      WriteLn('Directory created: '+ LibsPath,'',true);
    except
      on E: Exception do
        WriteLn('Failed to create directory: ',E.Message,true);
    end;
  end;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FTaskManager.Free;
end;

procedure TfrmMain.btnConnectRestAPIClick(Sender: TObject);
begin
  try
    // Установите параметры запроса
    RESTClient1.BaseURL:=frmSetup.edtAddress.Text;
    RESTRequest1.Method := TRESTRequestMethod.rmGET; // или rmPOST, rmPUT и т.д.
    RESTRequest1.Resource := frmSetup.edtGetDevice_list.text; // например, 'users'

    // Выполните запрос
    RESTRequest1.Execute;

    // Проверьте ответ
    if RESTResponse1.StatusCode = 200 then
    begin
      // Успешный ответ
      frmSetup.mmoInJSON.Text:=RESTResponse1.Content;
      //Создаем устройства
      LoadDevices;
      UpdateDevicesList;

      FTaskManager := TTaskManager.Create;
      FTaskManager.OnLog := LogMessage;
      FTaskManager.Initialize(FDevices);
    end
    else
    begin
      // Ошибка
      frmSetup.mmoInJSON.Text:='Ошибка: ' + RESTResponse1.StatusText;
    end;
  except
    on E: Exception do
      ShowMessage('Исключение: ' + E.Message);
  end;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  FTaskManager.StartMonitoring;
  btnStart.Enabled := False;
  btnStop.Enabled := True;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  FTaskManager.StopMonitoring;
  btnStart.Enabled := True;
  btnStop.Enabled := False;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  // Дополнительный таймер для обновления интерфейса
end;

procedure TfrmMain.LogMessage(const AMessage: string);
begin
  TThread.Queue(nil, procedure
  begin
    memLog.Lines.Add(Format('%s: %s', [FormatDateTime('hh:nn:ss', Now), AMessage]));
  end);
end;

procedure TfrmMain.miSettingsClick(Sender: TObject);
begin
  frmSetup.ShowModal;
end;

procedure TfrmMain.LoadDevices;
begin
  ParseJsonDevice_List();
end;

procedure TfrmMain.UpdateDevicesList;
var
  I: Integer;
  Item: TListBoxItem;
  ModelName: string;
begin
  lbDevices.BeginUpdate;
  try
    lbDevices.Clear;

    for I := 0 to High(FDevices) do
    begin
      Item := TListBoxItem.Create(lbDevices);
      if (FDevices[I].Info.unit_type >= 0) and (FDevices[I].Info.unit_type <= High(LoaderModels)) then
        ModelName := LoaderModels[FDevices[I].Info.unit_type].Name
      else
        ModelName := 'Unknown';

      Item.Text := Format('Устройство %d: %s (%s:%d) библиотека: %s', [
        FDevices[I].Info.ID,
        ModelName,
        FDevices[I].Info.server_ip,
        FDevices[I].Info.port,
        FDevices[I].Info.libname
      ]);
      lbDevices.AddObject(Item);
    end;
  finally
    lbDevices.EndUpdate;
  end;
end;

procedure TfrmMain.ParseJsonDevice_List;
var
  JsonString: string;
  JsonObj: TJSONObject;
  DevicesArray: TJSONArray;
  DeviceObj: TJSONObject;
  I: Integer;
  s:string;
  DI:TDeviceInformation;
begin
try
    JsonObj := TJSONObject.ParseJSONValue(frmSetup.mmoInJSON.Text) as TJSONObject;
    if not Assigned(JsonObj) then
    begin
      Writeln('Ошибка: Некорректный JSON');
      Exit;
    end;
    try
      DevicesArray := JsonObj.GetValue<TJSONArray>('devices');

      // Инициализируем  массив устройств
      SetLength(FDevices, DevicesArray.Count);
      for I := 0 to DevicesArray.Count - 1 do
      begin
        DeviceObj := DevicesArray.Items[I] as TJSONObject;

        // Получаем значения полей (с проверкой на null)
        Writeln('Устройство ', IntToStr(I + 1)+':');
        DI.ID:=DeviceObj.GetValue<Integer>('id_counter');
        Writeln('  ID: ', IntToStr(DI.ID));
        s:=DeviceObj.GetValue<string>('unit_type');
        DI.unit_type:=GetUnitTypeFromShortName(s);
        Writeln('  Тип: ', s);
        DI.net_addr:=DeviceObj.GetValue<Integer>('net_addr');
        Writeln('  Сетевой адрес: ', IntToStr(DI.net_addr));

        if not (DeviceObj.GetValue('subnet_addr') is TJSONNull) then
        begin
           DI.subnet_addr:=DeviceObj.GetValue<Integer>('subnet_addr');
           Writeln('  Система: ', IntToStr(DI.subnet_addr));
        end
        else begin
          Writeln('  Система: (нет данных)');
          DI.subnet_addr:=0;
        end;

        DI.server_ip:=DeviceObj.GetValue<string>('server_ip');
        Writeln('  IP: ', DI.server_ip);

        DI.port:=DeviceObj.GetValue<Integer>('port');
        Writeln('  Порт: ',IntToStr(DI.port ));

        DI.line:=DeviceObj.GetValue<string>('line');
        Writeln('  Линия: ', DI.line);

        // Обработка nullable-полей (если null, то будет пустая строка или 0)
        if not (DeviceObj.GetValue('hour_max') is TJSONNull) then
        begin
          DI.Hour.DT:=ISO8601ToDate(DeviceObj.GetValue<string>('hour_max'),false);
          Writeln('  Часовой: ', DateTimeToStr(DI.Hour.DT));
        end
        else begin
          DI.Hour.DT:=0;
          Writeln('  Часовой: (нет данных)');
        end;

        if not (DeviceObj.GetValue('hour_idx') is TJSONNull) then
        begin
          DI.Hour.Idx:=DeviceObj.GetValue<Integer>('hour_idx');
          Writeln('  Часовой индекс: ', IntToStr(DI.Hour.Idx))
        end
        else begin
          DI.Hour.Idx:=-1;
          Writeln('  Часовой: индекс(нет данных)');
        end;

        if not (DeviceObj.GetValue('day_max') is TJSONNull) then
        begin
          DI.Day.DT:=ISO8601ToDate(DeviceObj.GetValue<string>('day_max'),false);
          Writeln('  Суточный: ', DateToStr(DI.Day.DT));
        end
        else begin
          DI.Day.DT:=0;
          Writeln('  Суточный: нет данных)');
        end;

        if not (DeviceObj.GetValue('day_idx') is TJSONNull) then
        begin
          DI.Day.Idx:=DeviceObj.GetValue<Integer>('day_idx');
          Writeln('  Суточный индекс: ', IntToStr(DI.Day.Idx));
        end
        else begin
          DI.Day.Idx:=-1;
          Writeln('  Суточный: индекс(нет данных)');
        end;

        if not (DeviceObj.GetValue('month_max') is TJSONNull) then
        begin
          DI.Month.DT:=ISO8601ToDate(DeviceObj.GetValue<string>('month_max'),false);
          Writeln('  Месячный: ', DateToStr(DI.Month.DT))
        end
        else begin
          DI.Month.DT:=0;
          Writeln('  Месячный: нет данных)');
        end;

        if not (DeviceObj.GetValue('month_idx') is TJSONNull) then
        begin
          DI.Month.Idx:=DeviceObj.GetValue<Integer>('month_idx');
          Writeln('  Месячный индекс: ', IntToStr(DI.Month.Idx));
        end
        else begin
          DI.Month.Idx:=-1;
          Writeln('  Месячный: индекс(нет данных)');
        end;

        if not (DeviceObj.GetValue('year_max') is TJSONNull) then
        begin
          DI.Year.DT:=ISO8601ToDate(DeviceObj.GetValue<string>('year_max'),false);
          Writeln('  Годовой: ', DateToStr(DI.Year.DT));
        end
        else begin
          DI.Year.DT:=0;
          Writeln('  Годовой: нет данных)');
        end;

        if not (DeviceObj.GetValue('year_idx') is TJSONNull) then
        begin
          DI.Year.Idx:=DeviceObj.GetValue<Integer>('year_idx');
          Writeln('  Годовой индекс: ', IntToStr(DI.Year.Idx));
        end
        else begin
          DI.Year.Idx:=-1;
          Writeln('  Годовой: индекс(нет данных)');
        end;

        if not (DeviceObj.GetValue('err_max') is TJSONNull) then
        begin
          DI.Err.DT:=ISO8601ToDate(DeviceObj.GetValue<string>('err_max'),false);
          Writeln('  Ошибки: ', DateTimeToStr(DI.Err.DT));
        end
        else begin
          DI.Err.DT:=0;
          Writeln('  Ошибки: нет данных)');
        end;

        if not (DeviceObj.GetValue('err_idx') is TJSONNull) then
        begin
          DI.Err.Idx:=DeviceObj.GetValue<Integer>('err_idx');
          Writeln('  Ошибки индекс: ', IntToStr(DI.Err.Idx))
        end
        else begin
          DI.Err.Idx:=-1;
          Writeln('  Ошибки: индекс(нет данных)');
        end;
        DI.ID := I + 1;
        FDevices[I]:=TUnitDeviceOfLoader.Create(DI);
        Writeln('----------------------------------');
      end;
    finally
      JsonObj.Free;
    end;
  except
    on E: Exception do
      Writeln('Ошибка при разборе JSON: ', E.Message);
  end;
end;

procedure TfrmMain.WriteLn(S:string;tmpS:String;force:boolean);
begin
  if Assigned(frmSetup) then
  if frmSetup.cbDebug.IsChecked or force then
     MemLog.Lines.Add(s+tmpS);
end;


end.
