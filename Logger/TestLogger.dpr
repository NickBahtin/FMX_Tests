program TestLogger;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainForm in 'uMainForm.pas' {Form1},
  uLoggerThread in 'uLoggerThread.pas',
  uLogReaderThread in 'uLogReaderThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
