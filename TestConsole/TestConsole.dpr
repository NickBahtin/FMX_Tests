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
  // � Linux ������� ���������� ��������� ������-�������������, ������� ��������� ������
  Result := ShiftState;
end;

function Terminated():Boolean;
begin
  result:=GetKeyState()='';
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
     Writeln('�����...');
     while Terminated() do
     begin

     end;
     Writeln('�������...');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
