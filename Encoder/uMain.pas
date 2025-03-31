unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox,
  FMX.NumberBox, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TMainForm = class(TForm)
    Text1: TText;
    Layout1: TLayout;
    Button1: TButton;
    Layout2: TLayout;
    Text2: TText;
    Button2: TButton;
    Layout3: TLayout;
    Text3: TText;
    nbKey: TNumberBox;
    mmoOrigin: TMemo;
    mmoCodered: TMemo;
    Splitter1: TSplitter;
    procedure Edit2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses FmxHelper;

{$R *.fmx}

procedure TMainForm.Edit1Change(Sender: TObject);
begin
  mmoCodered.Text:=EncryptStr(mmoOrigin.Text,Round(nbKey.value));
end;

procedure TMainForm.Edit2Change(Sender: TObject);
begin
  mmoOrigin.Text:=DecryptStr(mmoCodered.Text,Round(nbKey.value));
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if Height<150 then Height:=150;
  if Width<400 then Width:=400;

  Layout1.Height:=(height - Layout3.Height) / 3 - 10;
end;

end.
