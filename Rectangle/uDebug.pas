unit uDebug;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Layouts, FMX.StdCtrls, FMX.ListBox;

type
  TDebugForm = class(TForm)
    Grid1: TGrid;
    Column1: TColumn;
    Column2: TColumn;
    Column3: TColumn;
    Column4: TColumn;
    Column5: TColumn;
    Column6: TColumn;
    Column7: TColumn;
    Column8: TColumn;
    Column9: TColumn;
    Column10: TColumn;
    Column11: TColumn;
    Layout1: TLayout;
    Label1: TLabel;
    ComboBox1: TComboBox;
    procedure Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure Grid1SetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure Grid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure Grid1DrawColumnBackground(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure Grid1DrawColumnHeader(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF);
    function GetSnakeItemDirection(ACol,ARow:integer):String;
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateGrid;
  end;

var
  DebugForm: TDebugForm;

implementation

{$R *.fmx}

uses uMain;

procedure TDebugForm.Grid1DrawColumnBackground(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
  var
     ACol,ARow:integer;
begin
  ACol:=Column.OriginalIndex-1;
  ARow:=Row;
  // –исуем фон €чейки, включа€ области под лини€ми
  if ACol>=0 then
  begin
    if MapArray[ACol,ARow] in [sitHeadBottom..sitTailBottom,sitHBody..sitJawHeadTop] then
      Canvas.Fill.Color := TAlphaColorRec.Wheat
    else if MapArray[ACol,ARow] in [sitStone] then
      Canvas.Fill.Color := TAlphaColorRec.Black
    else if MapArray[ACol,ARow] in [sitFruit] then
      Canvas.Fill.Color := TAlphaColorRec.Red
    else
      Canvas.Fill.Color := TAlphaColorRec.white;
  end
  else
      Canvas.Fill.Color := TAlphaColorRec.Silver;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
end;

procedure TDebugForm.Grid1DrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
  var
     fontColor:TAlphaColor;
     ACol,ARow:integer;
begin
  ACol:=Column.OriginalIndex-1;
  ARow:=Row;
  if ACol=-1 then
    fontColor:=TAlphaColorRec.Black
  else
    case MapArray[ACol,ARow] of
    sitHeadBottom..sitTailBottom:fontColor:=TAlphaColorRec.Brown;
    sitStone:fontColor:=TAlphaColorRec.White;
    sitFruit:fontColor:=TAlphaColorRec.White;
    sitHBody,sitVBody,sitLTBody,sitRTBody,sitRBBody,sitLBBody,sitJawHeadBottom,sitJawHeadLeft,sitJawHeadRight,
    sitJawHeadTop:
      fontColor:=TAlphaColorRec.Saddlebrown;
    end;

  if ACol>=0 then
  begin
    if MapArray[ACol,ARow] in [sitHeadBottom..sitTailBottom,sitHBody..sitJawHeadTop] then
      Canvas.Fill.Color := TAlphaColorRec.Wheat
    else if MapArray[ACol,ARow] in [sitStone] then
      Canvas.Fill.Color := TAlphaColorRec.Black
    else if MapArray[ACol,ARow] in [sitFruit] then
      Canvas.Fill.Color := TAlphaColorRec.Red
    else
      Canvas.Fill.Color := TAlphaColorRec.white;
  end
  else
      Canvas.Fill.Color := TAlphaColorRec.Silver;

  // –исуем фон €чейки, включа€ области под лини€ми
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  // –исуем текст
  Canvas.Fill.Color := fontColor;
  Canvas.Font.Size := 14;
  Canvas.FillText(Bounds, Value.AsString, False, 100, [], TTextAlign.Center, TTextAlign.Center);
end;

procedure TDebugForm.Grid1DrawColumnHeader(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
begin
 // ”станавливаем цвет фона заголовка
  Canvas.Fill.Color := TAlphaColorRec.Silver;
// –исуем фон заголовка
  Canvas.FillRect(Bounds, 0, 0, [], 1);

  // ”станавливаем цвет текста заголовка
  Canvas.Fill.Color := TAlphaColorRec.Black;

  // –исуем текст заголовка
  if Column.OriginalIndex>0 then
     Canvas.FillText(Bounds,IntToStr(Column.OriginalIndex-1), False, 1, [], TTextAlign.Center, TTextAlign.Center);

end;

procedure TDebugForm.ComboBox1Change(Sender: TObject);
begin
  Grid1.BeginUpdate;
  Grid1.EndUpdate;
end;

function TDebugForm.GetSnakeItemDirection(ACol,ARow:integer):String;
var i:integer;
begin
   result:=IntToStr(ord(MapArray[ACol,ARow]));
   for i:= 0 to Length(myPosArray)-1 do
   begin
      case ComboBox1.ItemIndex of
      1: if (myPosArray[i].pos.X=ACol) and  (myPosArray[i].pos.Y=ARow) then
         begin
            result:=cSnakeDirectionName[myPosArray[i].Direction];
            Break;
         end;
      2:if (myPosArray[i].pos.X=ACol) and  (myPosArray[i].pos.Y=ARow) then
        begin
          result:=cSnakeStateName[myPosArray[i].State];
          Break;
        end;
      end;
   end;
end;

procedure TDebugForm.Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
  var s:String;
  var
    intersection:Boolean;//совпаденеи с телом змейки
begin
   if ACol=0 then
     s:=IntToStr(ARow)
   else
     s:=GetSnakeItemDirection(ACol-1,ARow);
   Value:=s;
end;

procedure TDebugForm.Grid1SetValue(Sender: TObject; const ACol, ARow: Integer;
  const Value: TValue);
  var s:String;
begin
  s:=Value.AsString;
  MapArray[ACol,ARow]:=TSnakeItemType(StrToIntDef(s,0));
  Form1.UpdateGrid;
end;

procedure TDebugForm.UpdateGrid;
begin
  Grid1.BeginUpdate;
  Grid1.EndUpdate;
end;

end.
