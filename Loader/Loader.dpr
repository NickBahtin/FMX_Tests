program Loader;

uses
  System.StartUpCopy,
  FMX.Forms,
  fuMain in 'fuMain.pas' {frmMain},
  fuSetup in 'fuSetup.pas' {frmSetup},
  uLoaderTypes in 'uLoaderTypes.pas',
  uDevice in 'uDevice.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmSetup, frmSetup);
  Application.Run;
end.
