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
  end;

  TInitGridRecord=record
    Header:string;
    Idx:integer;
    OnGetValue:TOnGetValue;
    OnSellClick:TCellClick;
    Columns:array of TInitColumnRecord;
  end;

function AddTableToScrollBox(lv: TLayout;columns:TInitGridRecord):TGrid;
function AddTextToScrollBox(lv: TLayout;Idx:integer;aValue:String):TText;
procedure ClearTextAndGridsFromScrollBox(lv: TLayout);

implementation

function AddTableToScrollBox(lv: TLayout;columns:TInitGridRecord):TGrid;
var ic:TIntegerColumn;
    fc:TFloatColumn;
    header:TText;
begin
  //таблица
  result:=TGrid.Create(lv);
  result.Parent:=lv;
  result.Tag:=columns.Idx;
  result.Margins.Top:=1;
  result.Align:=TAlignLayout.Top;
  result.OnGetValue:=columns.OnGetValue;//заполнение клеток
  result.OnCellDblClick:=columns.OnSellClick;//на случай активации функции отключения каких то результатов
  //Добавляем заголовок
  header:=TText.Create(lv);
  header.Margins.Top:=1;
  header.Text:=columns.Header;
  header.Height:=14;
  header.Parent:=lv;
  header.Align:=TAlignLayout.Top;
  header.TextSettings.Font.Style:=[TFontStyle.fsBold];
  header.TextSettings.HorzAlign:=TTextAlign.Leading;
end;


function AddTextToScrollBox(lv: TLayout;Idx:integer;aValue:String):TText;
var
  txt: TText;
  LastTxt: TText;
  Offset: Single;
begin
  result:=TText.Create(lv);
  result.Parent:=lv;
  result.Margins.Top:=1;
  result.Tag:=Idx;
  result.Height:=14;
  result.Align:=TAlignLayout.Top;
  result.TextSettings.HorzAlign:=TTextAlign.Trailing;
  result.Text:=aValue;
 // Определяем позицию для нового грида
  if lv.ChildrenCount > 0 then
  begin
    LastTxt := lv.Children[Lv.ChildrenCount - 1] as TText;
    Offset := LastTxt.Position.Y + LastTxt.Height;
  end
  else
  begin
    Offset := 0;
  end;
  LastTxt.Position.Y := Offset+10;
end;

procedure ClearTextAndGridsFromScrollBox(lv: TLayout);
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
