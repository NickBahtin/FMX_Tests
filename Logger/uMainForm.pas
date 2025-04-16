unit uMainForm;

interface

uses
  System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  uLoggerThread,uLogReaderThread, FMX.Edit, FMX.StdCtrls, FMX.EditBox,
  FMX.NumberBox;

type
  TForm1 = class(TForm)
    MemoLog: TMemo;
    Layout1: TLayout;
    Edit1: TEdit;
    Timer1: TTimer;
    cbAutoscroll: TCheckBox;
    edtTopLine: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbAutoscrollChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtTopLineChange(Sender: TObject);
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

uses System.IOUtils,
     System.SysUtils;  // Добавьте эту строку
{$R *.fmx}


function GetCurrentDir: string;
begin
  GetDir(0, Result);
end;

procedure TForm1.cbAutoscrollChange(Sender: TObject);
begin
 LogReader.AutoScroll:=cbAutoscroll.IsChecked;
end;

procedure TForm1.edtTopLineChange(Sender: TObject);
begin
  LogReader.TopLine:=StrToIntDef(edtTopLine.Text,LogReader.TopLine);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Timer1.Enabled:=False;
end;

procedure TForm1.FormCreate(Sender: TObject);
var FilePath:string;
begin
  FilePath:=TPath.Combine(GetCurrentDir,'log.txt');
  Logger := TLoggerThread.Create(FilePath);
  Logger.Start;

  LogReader := TLogReaderThread.Create(FilePath, OnLogRead, MemoLog);
  LogReader.WindowLines := 50;
  LogReader.AutoScroll := True;
  LogReader.Start;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  Logger.Terminate;
  Logger.Msg:='Завершение';
  Logger.WaitFor;
  Logger.Free;

  LogReader.Terminate;
  LogReader.WaitFor;
  LogReader.Free;
end;

procedure TForm1.OnLogRead(Sender: TObject);
var
  Lines: TStringDynArray;
begin
  TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      with TLogReaderThread(Sender) do
      begin
        MemoLog.BeginUpdate;
        MemoLog.Lines.Clear;
        Lines := LogContent.Split([#13]);
        if  Length(Lines)<WindowLines then
          MemoLog.Lines.AddStrings(Lines)
        else
          MemoLog.Lines.AddStrings(Lines);

       Caption:='Строк:'+IntToStr(MemoLog.Lines.Count);

        MemoLog.EndUpdate;
//
//        if AutoScroll then
//          MemoLog.SetFocus;
      end;
    end);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Edit1.Text:=DateTimeToStr(now)+' << '+' Параметр '+FloatToStr(15+Random(50)/10);
  Logger.Msg:=Edit1.Text;
end;

end.
