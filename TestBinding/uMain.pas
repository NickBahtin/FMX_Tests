unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti,
  FMX.Grid.Style, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, FMX.ListBox, FMX.Edit, uFloatEdit;
const
  cMaxTextRec=6;
type
  TMyRec=record
    ID: Integer;
    Name: String;
    Value: Single;
    Operation: byte;
  end;

const
     // ������������� ������� �������
  MyRecArray: array [0..cMaxTextRec-1] of TMyRec = (
    (ID: 1; Name: 'First'; Value: 1.0; Operation: 1),
    (ID: 2; Name: 'Second'; Value: 1.0; Operation: 1),
    (ID: 3; Name: 'Third'; Value: 1.0; Operation: 1),
    (ID: 4; Name: 'Fourth'; Value: 1.0; Operation: 1),
    (ID: 5; Name: 'Fifth'; Value: 1.0; Operation: 1),
    (ID: 6; Name: 'Sixth'; Value: 1.0; Operation: 1)
  );

type

  TForm1 = class(TForm)
    memTable: TFDMemTable;
    memTableID: TIntegerField;
    memTableName: TStringField;
    memTableValue: TFloatField;
    memTableOperation: TSmallintField;
    Grid1: TGrid;
    Edit1: TEdit;
    FloatEdit1: TFloatEdit;
    DataSource1: TDataSource;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
memTable.Open;
for I := 0 to cMaxTextRec-1 do
   begin
     memTable.Append;
     memTable.FieldByName('ID').AsInteger:= MyRecArray[i].ID;
     memTable.FieldByName('Name').AsString:= MyRecArray[i].Name;
     memTable.FieldByName('Value').AsFloat:= MyRecArray[i].Value;
     memTable.FieldByName('Operation').AsInteger:= MyRecArray[i].Operation;
     memTable.Post;
   end;
end;

end.
