unit uLoaderTypes;

interface
uses
  PluginUnit; //��������� � ����������

type
  TCreatePluginFunc = function: IUnitProtocol;

  //�������� ���������
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
  OneSecond = 1/86400;   // 1 ������� � ����� ���
  OneMinute = 1/1440;    // 1 ������ � ����� ���
  OneHour = 1/24;        // 1 ��� � ����� ���
  OneDay = 1;            // 1 ����
  LoaderModels: array[0..61] of TTLoaderModelRec = (
    (ID: 0;  Name: '��-5-1';     ShortName: 'KM5'),
    (ID: 1;  Name: '��-5-2';     ShortName: 'KM5'),
    (ID: 2;  Name: '��-5-3';     ShortName: 'KM5'),
    (ID: 3;  Name: '��-5-4';     ShortName: 'KM5'),
    (ID: 4;  Name: '��-5-5';     ShortName: 'KM5'),
    (ID: 5;  Name: '��-5-6';     ShortName: 'KM5'),
    (ID: 6;  Name: '��-5-6�';    ShortName: 'KM5'),
    (ID: 7;  Name: '��-5';       ShortName: 'KM5'),
    (ID: 8;  Name: '';           ShortName: ''),  // ������ ������
    (ID: 9;  Name: '��-5M';      ShortName: 'KM5M'),
    (ID: 10; Name: '����';       ShortName: 'VIST'),
    (ID: 11; Name: '���7';       ShortName: 'VKT7'),
    (ID: 12; Name: 'SA-94/3';    ShortName: 'SA94'),
    (ID: 13; Name: '���-106';    ShortName: 'TEM106'),
    (ID: 14; Name: '��������';   ShortName: 'PRKT'),
    (ID: 15; Name: '���-280';    ShortName: 'UVP280'),
    (ID: 16; Name: '����-22';    ShortName: 'TSRV22'),
    (ID: 17; Name: '����-23';    ShortName: 'TSRV23'),
    (ID: 18; Name: '�������� 200'; ShortName: 'MRK200'),
    (ID: 19; Name: '�������� 230'; ShortName: 'MRK230'),
    (ID: 20; Name: '���-3';      ShortName: 'VKG3'),
    (ID: 21; Name: 'SA-94/1';    ShortName: 'SA94'),
    (ID: 22; Name: 'SA-94/2';    ShortName: 'SA94'),
    (ID: 23; Name: 'SA-94/2M';   ShortName: 'SA94'),
    (ID: 24; Name: '��-9';       ShortName: 'AP9'),
    (ID: 25; Name: '��-5M(����)'; ShortName: 'KM5M'),
    (ID: 26; Name: 'NP542.24T';  ShortName: 'NP542'),
    (ID: 27; Name: 'NP545.24T';  ShortName: 'NP545'),
    (ID: 28; Name: 'NP515.23D';  ShortName: 'NP515'),
    (ID: 29; Name: 'EK270';      ShortName: 'EK270'),
    (ID: 30; Name: '��2300';     ShortName: 'IM230'),
    (ID: 31; Name: '';           ShortName: ''),  // ������ ������
    (ID: 32; Name: '�����';      ShortName: 'VISTM'),
    (ID: 33; Name: '��303';      ShortName: 'CE303'),
    (ID: 34; Name: '����';       ShortName: 'MKTC'),
    (ID: 35; Name: '����-031';   ShortName: 'TSRV3x'),
    (ID: 36; Name: '����-033';   ShortName: 'TSRV3x'),
    (ID: 37; Name: '����-034';   ShortName: 'TSRV3x'),
    (ID: 38; Name: '';           ShortName: ''),  // ������ ������
    (ID: 39; Name: '���-�';      ShortName: 'VTDV'),
    (ID: 40; Name: '';           ShortName: ''),  // ������ ������
    (ID: 41; Name: '���-�';      ShortName: 'VTDU'),
    (ID: 42; Name: '��7';        ShortName: 'TV7'),
    (ID: 43; Name: '���-�100';   ShortName: 'TMKH100'),
    (ID: 44; Name: '���';        ShortName: 'VTD'),
    (ID: 45; Name: '���-104';    ShortName: 'TSM104'),
    (ID: 46; Name: '���-9';      ShortName: 'VKT9'),
    (ID: 47; Name: '����-043';   ShortName: 'TSRV43'),
    (ID: 48; Name: '����-300';   ShortName: 'STEM300'),
    (ID: 49; Name: '�������� 234'; ShortName: 'MRK234'),
    (ID: 50; Name: '��-�-1';     ShortName: 'ATT'),
    (ID: 51; Name: '��-�-2';     ShortName: 'ATT'),
    (ID: 52; Name: '��-�-3';     ShortName: 'ATT'),
    (ID: 53; Name: '��-�-4';     ShortName: 'ATT'),
    (ID: 54; Name: '��-�-5';     ShortName: 'ATT'),
    (ID: 55; Name: '��-�-6';     ShortName: 'ATT'),
    (ID: 56; Name: '��-�-7';     ShortName: 'ATT'),
    (ID: 57; Name: '��-�';       ShortName: 'ATT'),
    (ID: 58; Name: '��-�';       ShortName: 'ATT'),
    (ID: 59; Name: '�����-307';  ShortName: 'KARAT307'),
    (ID: 60; Name: '��-10';      ShortName: 'VTE1'),
    (ID: 101; Name: '�����-1';   ShortName: 'PHOBOS-1')
  );

type

  //������ � �������
  TDeviceInformation=record
        // �������� �������� ����� (� ��������� �� null)
        ID:longword;//'id_counter'
        unit_type:integer;//��� ������� �� LoaderModels; (-1) - �� ������ � ������ LoaderModels
        net_addr:LongWord;//������� �����
        dec_hex_net_addr:boolean;//������� ����� ������ ���� ����������� � ������� ����������
        subnet_addr:longword;//������� - �� ��������� 0
        server_ip:string;//host
        port:Word;//����
        line:string;//�����
        Hour:TArhieveRec;
        Day:TArhieveRec;
        Month:TArhieveRec;
        Year:TArhieveRec;
        Err:TArhieveRec;
        libname:string;//��� ���������� - ���� �������
        Plugin:IDevicePlugin;//��������� ����������
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
