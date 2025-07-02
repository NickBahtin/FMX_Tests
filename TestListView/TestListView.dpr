program TestListView;

uses
  System.StartUpCopy,
  FMX.Forms,
  fuMain in 'fuMain.pas' {Form1},
  lvHelper in 'lvHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
