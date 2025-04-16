unit uDebug;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox;

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
    procedure Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure Grid1SetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
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

procedure TDebugForm.Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
  var s:String;
begin
   s:=IntToStr(ord(MapArray[ACol,ARow]));
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
