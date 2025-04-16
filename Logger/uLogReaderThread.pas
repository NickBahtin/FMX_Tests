unit uLogReaderThread;

interface

uses
   System.SysUtils, System.Classes, System.Threading, System.IOUtils,
   System.Types,
   System.SyncObjs, FMX.Types, FMX.Controls;

const
  cBUFFER_SIZE=8492;
type
  TLogReaderThread = class(TThread)
  private
    FFileName: string;
    FOnLogRead: TNotifyEvent;
    FLogContent: string;
    FCriticalSection: TCriticalSection;
    FLinesCount: Int64;
    FTopLine: Int64;
    FWindowLines: Integer;
    FAutoScroll: Boolean;
    FFMXControl: TControl; // —сылка на FMX-контроль
    FLastKnownPosition:Int64;

    procedure CheckForUpdates;
    procedure SetLinesCount(const Value: Int64);
    procedure SetTopLine(const Value: Int64);
    procedure SetWindowLines(const Value: Integer);
    procedure SetAutoScroll(const Value: Boolean);
    procedure SetFMXControl(const Value: TControl);

  protected
    procedure Execute; override;
    procedure SynchronizeWithFMX(const AProc: TProc);

  public
    constructor Create(AFileName: string; AOnLogRead: TNotifyEvent;
      AControl: TControl = nil);
    destructor Destroy; override;

    property OnLogRead: TNotifyEvent read FOnLogRead write FOnLogRead;
    property LogContent: string read FLogContent;
    property LinesCount: Int64 read FLinesCount write SetLinesCount;
    property TopLine: Int64 read FTopLine write SetTopLine;
    property WindowLines: Integer read FWindowLines write SetWindowLines;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll;
    property FMXControl: TControl read FFMXControl write SetFMXControl;
    procedure ReadLogFromPosition(AStartPos: Int64; ALineCount: Integer);
  end;

implementation

constructor TLogReaderThread.Create(AFileName: string;
  AOnLogRead: TNotifyEvent; AControl: TControl = nil);
begin
  inherited Create(True);
  FFileName := AFileName;
  FOnLogRead := AOnLogRead;
  FFMXControl := AControl;
  FCriticalSection := TCriticalSection.Create;
  LinesCount := 0;
  TopLine := 0;
  WindowLines := 38;
  AutoScroll := True;
end;

destructor TLogReaderThread.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

procedure TLogReaderThread.SynchronizeWithFMX(const AProc: TProc);
begin
  if FFMXControl <> nil then
    TThread.Synchronize(nil,
      procedure
      begin
        if FFMXControl.Visible then
          AProc();
      end);
end;

procedure TLogReaderThread.CheckForUpdates;
var
  FileStream: TFileStream;
  NewContent: string;
  Buffer: TBytes;
  Size: Integer;
begin
  if not TFile.Exists(FFileName) then
    Exit;

  try
    FileStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    try
      Size := FileStream.Size - TopLine;
      if Size > 0 then
      begin
        SetLength(Buffer, Size);
        FileStream.Position := TopLine;
        FileStream.ReadBuffer(Buffer[0], Size);
        NewContent := TEncoding.ANSI.GetString(Buffer);

        FCriticalSection.Enter;
        try
          FLogContent := FLogContent + NewContent;
          TopLine := FileStream.Size;

          if Assigned(FOnLogRead) then
            SynchronizeWithFMX(procedure
            begin
              FOnLogRead(Self);
            end);
        finally
          FCriticalSection.Leave;
        end;
      end;
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
    begin
      //OutputDebugString(PChar(Format('ќшибка чтени€ лога: %s', [E.Message])));
    end;
  end;
end;

procedure TLogReaderThread.Execute;
begin
  while not Terminated do
  begin
    CheckForUpdates;
    Sleep(1000);
  end;
end;

procedure TLogReaderThread.ReadLogFromPosition(AStartPos: Int64;
  ALineCount: Integer);
var
  FileStream: TFileStream;
  Buffer: TBytes;
  CurrentPos: Int64;
  Lines: TStringDynArray;
begin
  if not TFile.Exists(FFileName) then
    Exit;

  FCriticalSection.Enter;
  try
    FTopLine := AStartPos;
    FWindowLines := ALineCount;
    FLogContent := '';

    FileStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    try
      CurrentPos := AStartPos;
      FileStream.Position := AStartPos;

      while (CurrentPos < FileStream.Size) and
            (Length(FLogContent.Split([sLineBreak])) < ALineCount) do
      begin
          SetLength(Buffer, cBUFFER_SIZE);
          FileStream.ReadBuffer(Buffer[0], cBUFFER_SIZE);
          FLogContent := FLogContent + TEncoding.ANSI.GetString(Buffer);
          Inc(CurrentPos, cBUFFER_SIZE);
      end;

      Lines := FLogContent.Split([sLineBreak]);
      if Length(Lines) > ALineCount then
        FLogContent := String.Join(sLineBreak,
          Copy(Lines, Length(Lines) - ALineCount + 1, ALineCount));

      FLastKnownPosition := CurrentPos;
    finally
      FileStream.Free;
    end;
  finally
    FCriticalSection.Leave;
  end;

  if Assigned(FOnLogRead) then
    SynchronizeWithFMX(procedure
    begin
      FOnLogRead(Self);
    end);
end;

procedure TLogReaderThread.SetAutoScroll(const Value: Boolean);
begin
  FAutoScroll := Value;
end;

procedure TLogReaderThread.SetFMXControl(const Value: TControl);
begin
  FFMXControl := Value;
end;

procedure TLogReaderThread.SetLinesCount(const Value: Int64);
begin
  FLinesCount := Value;
end;

procedure TLogReaderThread.SetTopLine(const Value: Int64);
begin
  FTopLine := Value;
end;

procedure TLogReaderThread.SetWindowLines(const Value: integer);
begin
  FWindowLines := Value;
end;

end.
