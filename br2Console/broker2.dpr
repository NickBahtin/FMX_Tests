program broker2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ugprsbroker in 'ugprsbroker.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
