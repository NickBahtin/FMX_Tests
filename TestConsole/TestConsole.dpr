program TestConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;


function GetKeyState: string;
var
  ShiftState: string;
begin
  ShiftState := '';
  // В Linux сложнее определить состояние клавиш-модификаторов, поэтому оставляем пустым
  Result := ShiftState;
end;

function Terminated():Boolean;
begin
  result:=GetKeyState()='';
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
     Writeln('Старт...');
     while Terminated() do
     begin

     end;
     Writeln('Останов...');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
