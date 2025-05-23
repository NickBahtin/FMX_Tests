unit uLoggerThread;

interface

uses
   System.SysUtils, System.Classes, System.Threading, System.SyncObjs, System.Generics.Collections, System.IOUtils;



type
  TLoggerThread = class(TThread)
  private
    FFileName: string;
    FMessage: string;
    FMessageQueue: TQueue<string>;
    FCriticalSection: TCriticalSection;
    FEvent: TEvent;
    procedure ProcessQueue;
    procedure SetMsg(const Value: string);
  protected
    procedure Execute; override;
  public
    constructor Create(AFileName: string);
    destructor Destroy; override;
    property Msg:string read FMessage write SetMsg;

  end;
implementation

{ TLoggerThread }

constructor TLoggerThread.Create(AFileName:String);
begin
inherited Create(True);
  FFileName := AFileName;
  FMessageQueue := TQueue<string>.Create;
  FCriticalSection := TCriticalSection.Create;
  FEvent := TEvent.Create(nil, False, False, '');
end;

destructor TLoggerThread.Destroy;
begin
  FMessageQueue.Free;
  FEvent.Free;
  inherited;
end;

procedure TLoggerThread.Execute;
begin
 while not Terminated do
  begin
    FEvent.WaitFor(INFINITE);
    FEvent.ResetEvent;
    Synchronize(ProcessQueue);
  end;
 end;

procedure TLoggerThread.ProcessQueue;
var
  FileStream: TFileStream;
  Message: AnsiString;
begin
  if TFile.Exists(FFileName) then
    FileStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite)
  else
    FileStream := TFileStream.Create(FFileName, fmCreate or fmShareDenyWrite);
  try
    FCriticalSection.Enter;
    try
      while FMessageQueue.Count > 0 do
      begin
        Message := FMessageQueue.Dequeue;
        FileStream.Seek(0, soFromEnd);
        FileStream.Write(Message[1], Length(Message));
        FileStream.Write(#13#10, 2); // ��������� ������� ������
      end;
    finally
      FCriticalSection.Leave;
    end;
  finally
    FileStream.Free;
  end;
end;

procedure TLoggerThread.SetMsg(const Value: string);
begin
 FCriticalSection.Enter;
  try
    FMessageQueue.Enqueue(Value);
  finally
    FCriticalSection.Leave;
  end;
  FEvent.SetEvent;
end;

end.
