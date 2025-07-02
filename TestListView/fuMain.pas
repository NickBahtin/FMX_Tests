unit fuMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView,
  FMX.Effects, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid;

type
  //2025-07-02 - тестирование добавления таблиц и строк в TListView
  TForm1 = class(TForm)
    lvResults: TListView;
    Layout1: TLayout;
    btnAddString: TCornerButton;
    btnAddTable: TCornerButton;
    ShadowEffect1: TShadowEffect;
    ShadowEffect2: TShadowEffect;
    ShadowEffect3: TShadowEffect;
    ShadowEffect4: TShadowEffect;
    procedure btnAddTableClick(Sender: TObject);
    procedure btnAddStringClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

function AddTableToListView(lv: TListView;Idx:integer):TGrid;
begin
  result:=TGrid.Create(lv);
  result.Parent:=lv;
  result.Tag:=Idx;
  result.Margins.Left:=5;
  result.Margins.Right:=5;
  result.Margins.Top:=5;
  result.Margins.Bottom:=5;
  result.Align:=TAlignLayout.Top;
  lv.AddObject(result);
end;


function AddTextToListView(lv: TListView;Idx:integer;aValue:String):TLabel;
begin
  result:=TLabel.Create(lv);
  result.Parent:=lv;
  result.Tag:=Idx;
  result.Margins.Left:=5;
  result.Margins.Right:=5;
  result.Margins.Top:=5;
  result.Margins.Bottom:=5;
  result.Align:=TAlignLayout.Top;
  result.Text:=aValue;
  lv.AddObject(result);
end;


procedure TForm1.btnAddStringClick(Sender: TObject);
begin
  AddTextToListView(lvResults,btnAddString.Tag,'Результат: '+IntToStr(btnAddString.Tag)+' Компонентов:'+IntToStr(lvResults.ComponentCount+1));
  btnAddString.Tag:=btnAddString.Tag+1;
end;

procedure TForm1.btnAddTableClick(Sender: TObject);
begin
  AddTableToListView(lvResults,btnAddTable.Tag);
  btnAddTable.Tag:=btnAddTable.Tag+1;
end;

end.
