unit fuMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView,
  lvHelper,
  FMX.Effects, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FMX.ListBox,
  FMX.Objects;

type
  //2025-07-02 - тестирование добавления таблиц и строк в TListView
  TForm1 = class(TForm)
    Layout1: TLayout;
    btnAddString: TCornerButton;
    btnAddTable: TCornerButton;
    ShadowEffect2: TShadowEffect;
    ShadowEffect3: TShadowEffect;
    ShadowEffect4: TShadowEffect;
    lvresult: TListView;
    ScrollBox1: TScrollBox;
    btnClear: TCornerButton;
    ShadowEffect1: TShadowEffect;
    ShadowEffect5: TShadowEffect;
    procedure btnAddTableClick(Sender: TObject);
    procedure btnAddStringClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    mycol:TInitGridRecord;
    procedure OnCellDblClick(const Column: TColumn; const Row: Integer);
    procedure OnGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.fmx}


procedure TForm1.btnAddStringClick(Sender: TObject);
begin
  if ScrollBox1.ComponentCount>3 then
     AddTextToScrollBox(ScrollBox1,btnAddString.Tag,'Результат: '+IntToStr(btnAddString.Tag)+' Компонентов:'+IntToStr(ScrollBox1.ComponentCount+1)+' Позиция:'+FloatToStr(TText(ScrollBox1.Components[ScrollBox1.ComponentCount-1]).Position.y)+
     'Idx:'+IntToStr(TText(ScrollBox1.Components[ScrollBox1.ComponentCount-1]).ComponentIndex))
  else
     AddTextToScrollBox(ScrollBox1,btnAddString.Tag,'Результат: '+IntToStr(btnAddString.Tag)+' Компонентов:'+IntToStr(ScrollBox1.ComponentCount+1),TTextAlign.Leading);
  btnAddString.Tag:=btnAddString.Tag+1;
  Caption:=TText(ScrollBox1.Components[ScrollBox1.ComponentCount-1]).Text;
end;

procedure TForm1.btnAddTableClick(Sender: TObject);
begin
  mycol.Header:='Таблица '+IntToStr(btnAddTable.Tag+1);
  AddTableToScrollBox(ScrollBox1,mycol);
  btnAddTable.Tag:=btnAddTable.Tag+1;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  ClearTextAndGridsFromScrollBox(ScrollBox1);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetLength(mycol.Columns,4);
  mycol.RowCount:=5;
  mycol.RowHeight:=16;
  mycol.Header:='Таблица результатов';
  mycol.OnGetValue:=OnGetValue;
  mycol.OnSellClick:=OnCellDblClick;
  //
  mycol.Columns[0].Header:='№п.п.';
  mycol.Columns[0].width:=40;
  mycol.Columns[0].Mask:='%d';
  mycol.Columns[0].IsInteger:=True;
  //
  mycol.Columns[1].Header:='Объем по эталону,л';
  mycol.Columns[1].width:=150;
  mycol.Columns[1].Mask:='%8.4f';
  mycol.Columns[1].IsInteger:=False;
  //
  mycol.Columns[2].Header:='Объем по поверяемому,л';
  mycol.Columns[2].width:=150;
  mycol.Columns[2].Mask:='%8.4f';
  mycol.Columns[2].IsInteger:=False;
  //
  mycol.Columns[3].Header:='Погрешность,%';
  mycol.Columns[3].width:=100;
  mycol.Columns[3].Mask:='%4.2f';
  mycol.Columns[3].IsInteger:=False;
end;

procedure TForm1.OnCellDblClick(const Column: TColumn; const Row: Integer);
begin
  //
end;

procedure TForm1.OnGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
  var s:string;
begin
  //
//  if mycol.Columns[ACol].IsInteger then
   if ACol=0 then
     Value:=Format(mycol.Columns[ACol].Mask, [ARow+1])
   else
     Value:=Format(mycol.Columns[ACol].Mask, [(ARow+1)*Random(10)/3]);
end;



end.
