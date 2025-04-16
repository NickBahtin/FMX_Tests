unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  uLoggerThread,uLogReaderThread, FMX.Edit, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    MemoLog: TMemo;
    Layout1: TLayout;
    Edit1: TEdit;
    EditStartPos: TEdit;
    EditLineCount: TEdit;
    ButtonReadFromPosition: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure ButtonReadFromPositionClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    Logger: TLoggerThread;
    LogReader: TLogReaderThread;
    procedure OnLogRead(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses System.IOUtils;
{$R *.fmx}


function GetCurrentDir: string;
begin
  GetDir(0, Result);
end;

procedure TForm1.ButtonReadFromPositionClick(Sender: TObject);
var
  StartPos: Int64;
  LineCount: Integer;
begin
  StartPos := StrToInt64(EditStartPos.Text);
  LineCount := StrToInt(EditLineCount.Text);
  if Assigned(LogReader) then
  begin
    LogReader.ReadLogFromPosition(StartPos, LineCount);
    MemoLog.Lines.Text := LogReader.LogContent;
  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
var FilePath:string;
begin
  FilePath:=TPath.Combine(GetCurrentDir,'log.txt');
  Logger := TLoggerThread.Create(FilePath);
  Logger.Start;

  LogReader := TLogReaderThread.Create(FilePath, OnLogRead);
  LogReader.Start;

end;


procedure TForm1.OnLogRead(Sender: TObject);
begin
 MemoLog.Lines.Text := LogReader.LogContent;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Edit1.Text:=DateTimeToStr(now)+' << '+' Параметр '+FloatToStr(15+Random(50)/10);
  Logger.Msg:=Edit1.Text;
end;

end.
