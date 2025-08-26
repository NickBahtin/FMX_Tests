unit uDevice;

interface

uses
  system.SysUtils,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  {$IFDEF LINUX}
//  dl, Libc,
  {$ENDIF}
  PluginUnit, //Интерфейс к библиотеке
  uLoaderTypes;

type
  TUnitDeviceOfLoader=class
    Info:TDeviceInformation;
    LibsPath: string;
    LibHandle: THandle;
    LibName:string;
  private
    FDebugMessage: string;
    procedure SetDebugMessage(const Value: string);
  public
    constructor Create(_Info:TDeviceInformation);
    property DebugMessage:string read FDebugMessage write SetDebugMessage;
  end;
implementation


function LoadLibraryHandle(const Path: string): THandle;
begin
  {$IFDEF MSWINDOWS}
  Result := THandle(Winapi.Windows.LoadLibrary(PWideChar(WideString(Path))));
  {$ENDIF}
  {$IFDEF LINUX}
//  Result := dlopen(PAnsiChar(AnsiString(Path)), RTLD_LAZY);
  Result := LoadLibrary(PWideChar(WideString(Path)));
  {$ENDIF}
end;

function GetProcedureAddress(LibHandle: THandle;
  const ProcName: string): TCreatePluginFunc;
var
  ProcAddr: THandle;
begin
  Result := nil;

  {$IFDEF MSWINDOWS}
  ProcAddr := THandle(Winapi.Windows.GetProcAddress(LibHandle, PAnsiChar(AnsiString(ProcName))));
  {$ENDIF}
  {$IFDEF LINUX}
  S:=ProcName;
  ProcAddr := THandle(GetProcAddress(LibHandle,PChar(s)));
  {$ENDIF}

  if ProcAddr<>0 then  Result := TCreatePluginFunc(ProcAddr);
end;


{ TDeviceOfLoader }

constructor TUnitDeviceOfLoader.Create(_Info: TDeviceInformation);
var
  CreatePlugin: TCreatePluginFunc;
  Plugin: IUnitProtocol;
begin
  Info:=_Info;
  Plugin := nil;
  LibsPath := ExtractFilePath(ParamStr(0)) + 'LIBS';
  {$IFDEF MSWINDOWS}
  LibName:=GetShortNameFromUnitType(Info.unit_type)+'Lib.dll';
  if LibName='' then Exit;
  {$ENDIF}
  {$IFDEF LINUX}
  LibName:='Lib'+GetShortNameFromUnitType(FDevice.unit_type)+'.so';
  {$ENDIF}
  LibHandle := LoadLibraryHandle(LibsPath + PathDelim + LibName);
  if LibHandle<>0 then
  begin
    try
      CreatePlugin := GetProcedureAddress(LibHandle, 'CreateUnitLibrary');
      if Assigned(CreatePlugin) then
      begin
        Plugin := CreatePlugin;
        if Assigned(Plugin) then
        begin
          Info.libname:=LibName+' успешно загружена!';
          DebugMessage:='Plugin loaded successfully: '+LibName;
        end
        else begin
          Info.libname:=LibName+' ошибка создания!';
          DebugMessage:='Failed to create plugin instance: '+LibName;
        end;
      end
      else begin
        Info.libname:=LibName+' не содержит требуемых функций!';
        DebugMessage:='Failed to locate the plugin creation function: '+LibName;
      end;
    finally
      {$IFDEF LINUX}
      //dlclose(LibHandle);
      {$ENDIF}
    end;
  end
  else begin
    Info.libname:=LibName+' не найдена!';
    DebugMessage:='Failed to load library: '+LibName;
  end;
end;

procedure TUnitDeviceOfLoader.SetDebugMessage(const Value: string);
begin
  FDebugMessage := Value;
end;

end.
