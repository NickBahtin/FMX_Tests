program buffers;

uses
  System.StartUpCopy,
  FMX.Forms,
  fuMain in 'fuMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
