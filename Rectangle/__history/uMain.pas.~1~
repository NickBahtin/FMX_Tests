unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

  const
    cKEY_Up=38;
    cKEY_Down=40;
    cKEY_Left=37;
    cKEY_Right=39;
type

  TForm1 = class(TForm)
    Rec: TRectangle;
    Text1: TText;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
  cKEY_Up: begin
     Rec.Position.Y:=Rec.Position.Y-Rec.Height;
  end;
  cKEY_Down: begin
     Rec.Position.Y:=Rec.Position.Y+Rec.Height;
  end;
  cKEY_Left: begin
     Rec.Position.X:=Rec.Position.X-Rec.width;
  end;
  cKEY_Right: begin
     Rec.Position.X:=Rec.Position.X+Rec.width;
  end;
  end;
//  Caption:=IntToStr(Key);
 Text1.text:=Format('X=%d Y=%d',[Round(Rec.Position.X / Rec.width),Round(Rec.Position.Y / Rec.Height)]);
end;

end.
