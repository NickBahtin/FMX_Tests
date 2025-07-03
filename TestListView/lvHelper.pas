unit lvHelper;

interface
uses
  FMX.StdCtrls,
  FMX.Types,
  FMX.Layouts,
  FMX.Objects,
  System.UITypes,
  FMX.Grid;
type
  TInitColumnRecord=record
    Header:string;
    Mask:string;
    width:Integer;
    IsInteger:Boolean;
  end;

  TInitGridRecord=record
    Header:string;
    Idx:integer;
    RowCount:Integer;
    RowHeight:Integer;
    OnGetValue:TOnGetValue;
    OnSellClick:TCellClick;
    Columns:array of TInitColumnRecord;
  end;

function AddTableToScrollBox(lv: TScrollBox;columns:TInitGridRecord):TGrid;
function AddTextToScrollBox(lv: TScrollBox;Idx:integer;aValue:String;AHorzAlign: TTextAlign=TTextAlign.Trailing):TText;
procedure ClearTextAndGridsFromScrollBox(lv: TScrollBox);

implementation

uses
  System.Rtti;

procedure OnGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
//
end;

function AddTableToScrollBox(lv: TScrollBox;columns:TInitGridRecord):TGrid;
var i:integer;
    ic:TIntegerColumn;
    fc:TFloatColumn;
    header:TText;
begin
  //таблица
  result:=TGrid.Create(lv);
  result.Parent:=lv;
  result.Tag:=columns.Idx;
  result.Margins.Top:=1;
  result.Margins.Bottom:=10;
  result.Align:=TAlignLayout.Top;
  result.OnGetValue:=columns.OnGetValue;//заполнение клеток
  result.OnCellDblClick:=columns.OnSellClick;//на случай активации функции отключения каких то результатов
  result.Options:=result.Options+[TGridOption.RowSelect,TGridOption.AlwaysShowSelection];
  result.Options:=result.Options-[TGridOption.Editing, TGridOption.AlwaysShowEditor,TGridOption.ColumnResize,TGridOption.ColumnMove];
  result.RowCount:=columns.RowCount;
  result.RowHeight:=columns.RowHeight;
  result.Height:=(columns.RowCount+1)*(result.RowHeight+2)+5;
  //столбцы
  //первый столбец, всегда номер записи
  for I := 1 to Length(columns.Columns) do
  begin
     if columns.Columns[i-1].IsInteger then
     begin
        ic:=TIntegerColumn.Create(result);
        ic.Parent:=Result;
        ic.HorzAlign:=TTextAlign.Center;
        ic.HeaderSettings.TextSettings.HorzAlign:=TTextAlign.Center;
        ic.Width:=columns.Columns[i-1].width;
        ic.Header:=columns.Columns[i-1].Header;
        if i=1 then begin
          ic.Enabled:=False;
          ic.Locked:=True;
        end;
     end
     else begin
        fc:=TFloatColumn.Create(result);
        fc.Parent:=Result;
        fc.HorzAlign:=TTextAlign.Center;
        fc.HeaderSettings.TextSettings.HorzAlign:=TTextAlign.Center;
        fc.Width:=columns.Columns[i-1].width;
        fc.Header:=columns.Columns[i-1].Header;
        if i=1 then fc.Enabled:=False;
     end;
  end;
  //Добавляем заголовок
  header:=TText.Create(lv);
  header.Margins.Top:=5;
  header.Margins.Bottom:=1;
  header.Text:=columns.Header;
  header.Height:=14;
  header.Parent:=lv;
  header.Align:=TAlignLayout.Top;
  header.TextSettings.Font.Style:=[TFontStyle.fsBold];
  header.TextSettings.HorzAlign:=TTextAlign.Leading;
end;


function AddTextToScrollBox(lv: TScrollBox;Idx:integer;aValue:String;AHorzAlign: TTextAlign):TText;
var
  txt: TText;
  LastTxt: TText;
  LastGrid: TGrid;
  Offset: Single;
begin
 // Определяем позицию для нового грида
  result:=TText.Create(lv);
  result.Parent:=lv;
  result.Align:=TAlignLayout.Top;
  result.Margins.Top:=1;
  result.Margins.Bottom:=1;
  result.Tag:=Idx;
  result.Height:=14;
  result.TextSettings.HorzAlign:=AHorzAlign;
  result.Text:=aValue;
end;

procedure ClearTextAndGridsFromScrollBox(lv: TScrollBox);
var i:integer;
begin
  for I := lv.ComponentCount downto 1 do
  begin
    if lv.Components[i-1] is TGrid then
       lv.Components[i-1].Free
    else if lv.Components[i-1] is TText then
       lv.Components[i-1].Free;
  end;
  AddTextToScrollBox(lv,0,'');
end;

end.
