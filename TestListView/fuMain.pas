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
    Layout2: TLayout;
    procedure btnAddTableClick(Sender: TObject);
    procedure btnAddStringClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
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
begin
  AddTextToScrollBox(Layout2,btnAddString.Tag,'Результат: '+IntToStr(btnAddString.Tag)+' Компонентов:'+IntToStr(lvResult.ComponentCount+1));
  btnAddString.Tag:=btnAddString.Tag+1;
end;

procedure TForm1.btnAddTableClick(Sender: TObject);
begin
  AddTableToScrollBox(Layout2,mycol);
  btnAddTable.Tag:=btnAddTable.Tag+1;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  ClearTextAndGridsFromScrollBox(Layout2);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetLength(mycol.Columns,3);
  mycol.Header:='Таблица результатов';
end;

end.
