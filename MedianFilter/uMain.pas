unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FmxMedianFilter,
  FMX.Memo.Types, FMX.ExtCtrls, FMX.Edit, FMX.EditBox, FMX.SpinBox,
  FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FMX.Layouts, FMXTee.Series;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    Text1: TText;
    Button1: TButton;
    Text2: TText;
    sbWindowSize: TSpinBox;
    Memo2: TMemo;
    Chart1: TChart;
    Layout1: TLayout;
    Series1: TLineSeries;
    Series2: TLineSeries;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbWindowSizeChange(Sender: TObject);
  private
    { Private declarations }
    Filter:TFmxMedianFilter;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.Button1Click(Sender: TObject);
var i:integer;
    s:String;
    val,outval:Single;
begin
  Memo2.Lines.Clear;
  Series1.Clear;
  Series2.Clear;
  for i := 0 to Memo1.Lines.Count-1 do
    begin
      s:=Memo1.Lines[i];
      if s<>'' then
      begin
        val:=StrToFloatDef(s,0);
        Series1.Add(val);
        Series2.Add(outval);
        outval:=Filter.Filter(val);
        Memo2.Lines.Add(IntToStr(i+1)+' In '+FormatFloat('0.0000',val)+' Out '+FormatFloat('0.0000',outval));
      end;
    end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
//var
//  i,j: Integer;
begin
  Filter:=TFmxMedianFilter.Create(Round(sbWindowSize.Value));
//  Memo1.lines.Clear;
//  j:=0;
//  for i := 0 to 100 do
//  begin
//    if j in [0..14,17..20]  then begin
//      Inc(j);
//      Memo1.lines.Add(FormatFloat('0.0000',15+Random(5)/3));
//    end
//    else begin
//      Memo1.lines.Add(FormatFloat('0.0000',15+Random(50)/5));
//      if j=21 then j:=0;
//    end
//  end;
end;

procedure TMainForm.sbWindowSizeChange(Sender: TObject);
begin
 Filter.Size:=Round(sbWindowSize.Value);
end;

end.
