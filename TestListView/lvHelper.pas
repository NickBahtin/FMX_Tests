unit lvHelper;

interface
uses
  FMX.StdCtrls,
  FMX.Types,
  FMX.Layouts,
  System.UITypes,
  FMX.Grid;
type
  TInitColumnRecord=record
    Header:string;
    Mask:string;
    width:Integer;
  end;

  TInitGridRecord=record
    Header:string;
    Idx:integer;
    OnGetValue:TOnGetValue;
    OnSellClick:TCellClick;
    Columns:array of TInitColumnRecord;
  end;

function AddTableToListView(lv: TScrollBox;columns:TInitGridRecord):TGrid;
function AddTextToListView(lv: TScrollBox;Idx:integer;aValue:String):TLabel;

implementation

function AddTableToListView(lv: TScrollBox;columns:TInitGridRecord):TGrid;
var ic:TIntegerColumn;
    fc:TFloatColumn;
    header:TLabel;
begin
  //таблица
  result:=TGrid.Create(lv);
  result.Parent:=lv;
  result.Tag:=columns.Idx;
  result.Margins.Top:=5;
  result.Align:=TAlignLayout.Top;
  result.OnGetValue:=columns.OnGetValue;//заполнение клеток
  result.OnCellDblClick:=columns.OnSellClick;//на случай активации функции отключения каких то результатов
  //Добавляем заголовок
  header:=TLabel.Create(lv);
  header.Margins.Top:=5;
  header.Text:=columns.Header;
  header.Parent:=lv;
  header.Align:=TAlignLayout.Top;
  header.TextSettings.Font.Style:=[TFontStyle.fsBold];
  header.TextSettings.HorzAlign:=TTextAlign.Leading;

//  //Добавляем заголовок
//  header:=TLabel.Create(lv);
//  header.Text:=columns.Header;
//  header.Parent:=lv;
//  header.Align:=TAlignLayout.Top;
//  header.TextSettings.Font.Style:=[TFontStyle.fsBold];
//  header.TextSettings.HorzAlign:=TTextAlign.Leading;
//  lv.AddObject(header);
end;


function AddTextToListView(lv: TScrollBox;Idx:integer;aValue:String):TLabel;
begin
  result:=TLabel.Create(lv);
  result.Parent:=lv;
  result.Tag:=Idx;
//  result.Margins.Left:=5;
  result.Align:=TAlignLayout.Top;
  result.Text:=aValue;
  lv.AddObject(result);
end;


end.
