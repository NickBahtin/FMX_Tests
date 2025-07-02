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
    procedure btnAddTableClick(Sender: TObject);
    procedure btnAddStringClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    mycol:TInitGridRecord;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.fmx}


procedure TForm1.btnAddStringClick(Sender: TObject);
//  AddTextToListView(lvResult,btnAddString.Tag,'Результат: '+IntToStr(btnAddString.Tag)+' Компонентов:'+IntToStr(lvResult.ComponentCount+1));
//  btnAddString.Tag:=btnAddString.Tag+1;
var
  i: Integer;
  Grid: TGrid;
  Lab: TText;
begin
  // Предполагается, что ScrollBox уже добавлен на форму и его имя ScrollBox1
  for i := 0 to 4 do // Создадим 5 гридов для примера
  begin
    Grid := TGrid.Create(ScrollBox1);
    Grid.Parent := ScrollBox1;
    Grid.Align := TAlignLayout.Top;
    Grid.Height := 100; // Установите нужную высоту для каждого грида
    Grid.Margins.Top := 5; // Отступ сверху для каждого грида

    Lab := TText.Create(ScrollBox1);
    Lab.Parent := ScrollBox1;
    Lab.Align := TAlignLayout.Top;
    Lab.Margins.Top := 1; // Отступ сверху для каждого грида
    Lab.Text:='Таблица '+IntToStr(i+1);
    Lab.TextSettings.Font.Style:=[ TFontStyle.fsBold];
    Lab.TextSettings.HorzAlign:=TTextAlign.Leading;
  end;
end;

procedure TForm1.btnAddTableClick(Sender: TObject);
begin
  AddTableToListView(ScrollBox1,mycol);
  btnAddTable.Tag:=btnAddTable.Tag+1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetLength(mycol.Columns,3);
  mycol.Header:='Таблица результатов';
end;

end.
