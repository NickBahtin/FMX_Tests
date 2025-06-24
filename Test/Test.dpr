program Test;

uses
  System.StartUpCopy,
  FMX.Forms,
  fuMain in 'fuMain.pas' {MainForm},
  uDM in 'uDM.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
