unit uLoaderTypes;

interface
uses
  PluginUnit; //Интерфейс к библиотеке

type
  TCreatePluginFunc = function: IUnitProtocol;

  //архивный заголовок
  TArhieveRec=record
    Idx:LongInt;
    DT:TDateTime;
  end;

  TTLoaderModelRec=record
    ID:Byte;
    Name:String;
    ShortName:string;
  end;

const
  OneSecond = 1/86400;   // 1 секунда в долях дня
  OneMinute = 1/1440;    // 1 минута в долях дня
  OneHour = 1/24;        // 1 час в долях дня
  OneDay = 1;            // 1 день
  LoaderModels: array[0..61] of TTLoaderModelRec = (
    (ID: 0;  Name: 'КМ-5-1';     ShortName: 'KM5'),
    (ID: 1;  Name: 'КМ-5-2';     ShortName: 'KM5'),
    (ID: 2;  Name: 'КМ-5-3';     ShortName: 'KM5'),
    (ID: 3;  Name: 'КМ-5-4';     ShortName: 'KM5'),
    (ID: 4;  Name: 'КМ-5-5';     ShortName: 'KM5'),
    (ID: 5;  Name: 'КМ-5-6';     ShortName: 'KM5'),
    (ID: 6;  Name: 'КМ-5-6И';    ShortName: 'KM5'),
    (ID: 7;  Name: 'РМ-5';       ShortName: 'KM5'),
    (ID: 8;  Name: '';           ShortName: ''),  // Пустая запись
    (ID: 9;  Name: 'КМ-5M';      ShortName: 'KM5M'),
    (ID: 10; Name: 'ВИСТ';       ShortName: 'VIST'),
    (ID: 11; Name: 'ТСК7';       ShortName: 'VKT7'),
    (ID: 12; Name: 'SA-94/3';    ShortName: 'SA94'),
    (ID: 13; Name: 'ТЭМ-106';    ShortName: 'TEM106'),
    (ID: 14; Name: 'Практика';   ShortName: 'PRKT'),
    (ID: 15; Name: 'УВП-280';    ShortName: 'UVP280'),
    (ID: 16; Name: 'ТСРВ-22';    ShortName: 'TSRV22'),
    (ID: 17; Name: 'ТСРВ-23';    ShortName: 'TSRV23'),
    (ID: 18; Name: 'Меркурий 200'; ShortName: 'MRK200'),
    (ID: 19; Name: 'Меркурий 230'; ShortName: 'MRK230'),
    (ID: 20; Name: 'ВКГ-3';      ShortName: 'VKG3'),
    (ID: 21; Name: 'SA-94/1';    ShortName: 'SA94'),
    (ID: 22; Name: 'SA-94/2';    ShortName: 'SA94'),
    (ID: 23; Name: 'SA-94/2M';   ShortName: 'SA94'),
    (ID: 24; Name: 'АП-9';       ShortName: 'AP9'),
    (ID: 25; Name: 'КМ-5M(погр)'; ShortName: 'KM5M'),
    (ID: 26; Name: 'NP542.24T';  ShortName: 'NP542'),
    (ID: 27; Name: 'NP545.24T';  ShortName: 'NP545'),
    (ID: 28; Name: 'NP515.23D';  ShortName: 'NP515'),
    (ID: 29; Name: 'EK270';      ShortName: 'EK270'),
    (ID: 30; Name: 'ИМ2300';     ShortName: 'IM230'),
    (ID: 31; Name: '';           ShortName: ''),  // Пустая запись
    (ID: 32; Name: 'ВИСТм';      ShortName: 'VISTM'),
    (ID: 33; Name: 'СЕ303';      ShortName: 'CE303'),
    (ID: 34; Name: 'МКТС';       ShortName: 'MKTC'),
    (ID: 35; Name: 'ТСРВ-031';   ShortName: 'TSRV3x'),
    (ID: 36; Name: 'ТСРВ-033';   ShortName: 'TSRV3x'),
    (ID: 37; Name: 'ТСРВ-034';   ShortName: 'TSRV3x'),
    (ID: 38; Name: '';           ShortName: ''),  // Пустая запись
    (ID: 39; Name: 'ВТД-В';      ShortName: 'VTDV'),
    (ID: 40; Name: '';           ShortName: ''),  // Пустая запись
    (ID: 41; Name: 'ВТД-У';      ShortName: 'VTDU'),
    (ID: 42; Name: 'ТВ7';        ShortName: 'TV7'),
    (ID: 43; Name: 'ТМК-Н100';   ShortName: 'TMKH100'),
    (ID: 44; Name: 'ВТД';        ShortName: 'VTD'),
    (ID: 45; Name: 'ТЭМ-104';    ShortName: 'TSM104'),
    (ID: 46; Name: 'ТСК-9';      ShortName: 'VKT9'),
    (ID: 47; Name: 'ТСРВ-043';   ShortName: 'TSRV43'),
    (ID: 48; Name: 'СТЭМ-300';   ShortName: 'STEM300'),
    (ID: 49; Name: 'Меркурий 234'; ShortName: 'MRK234'),
    (ID: 50; Name: 'АТ-Т-1';     ShortName: 'ATT'),
    (ID: 51; Name: 'АТ-Т-2';     ShortName: 'ATT'),
    (ID: 52; Name: 'АТ-Т-3';     ShortName: 'ATT'),
    (ID: 53; Name: 'АТ-Т-4';     ShortName: 'ATT'),
    (ID: 54; Name: 'АТ-Т-5';     ShortName: 'ATT'),
    (ID: 55; Name: 'АТ-Т-6';     ShortName: 'ATT'),
    (ID: 56; Name: 'АТ-Т-7';     ShortName: 'ATT'),
    (ID: 57; Name: 'АТ-Р';       ShortName: 'ATT'),
    (ID: 58; Name: 'АТ-А';       ShortName: 'ATT'),
    (ID: 59; Name: 'КАРАТ-307';  ShortName: 'KARAT307'),
    (ID: 60; Name: 'СТ-10';      ShortName: 'VTE1'),
    (ID: 101; Name: 'ФОБОС-1';   ShortName: 'PHOBOS-1')
  );

type

  //запись о приборе
  TDeviceInformation=record
        // Получаем значения полей (с проверкой на null)
        ID:longword;//'id_counter'
        unit_type:integer;//тип прибора из LoaderModels; (-1) - не найден в списке LoaderModels
        net_addr:LongWord;//сетевой адрес
        dec_hex_net_addr:boolean;//сетевой адрес должне быть представлен в двоично десятичном
        subnet_addr:longword;//система - по умолчанию 0
        server_ip:string;//host
        port:Word;//порт
        line:string;//Линия
        Hour:TArhieveRec;
        Day:TArhieveRec;
        Month:TArhieveRec;
        Year:TArhieveRec;
        Err:TArhieveRec;
        libname:string;//имя библиотеки - если найдена
        Plugin:IDevicePlugin;//Интерфейс библиотеки
  end;

function GetUnitTypeFromShortName(S:String):Integer;
function GetShortNameFromUnitType(I:integer):String;

implementation

uses
  System.SysUtils;

function GetUnitTypeFromShortName(S:String):Integer;
var i:Integer;
begin
   result:=-1;
   s:=AnsiUpperCase(s);
   for I := Low(LoaderModels) to High(LoaderModels) do
   begin
     if AnsiUpperCase(LoaderModels[i].ShortName)=s then
     begin
        result:=i;
        break
     end;
   end;
end;

function GetShortNameFromUnitType(I:integer):String;
begin
  if i in  [Low(LoaderModels)..High(LoaderModels)] then
     result:=LoaderModels[i].ShortName
  else
     result:='';
end;


end.
