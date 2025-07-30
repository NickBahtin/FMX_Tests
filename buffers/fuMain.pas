unit fuMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  IdGlobal,
  FMX.ListBox, FMX.Objects, FMX.Edit, FMX.EditBox, FMX.NumberBox;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    Layout1: TLayout;
    btnShowBuffers: TCornerButton;
    nbShift: TNumberBox;
    Text1: TText;
    ComboBox1: TComboBox;
    nbValue: TNumberBox;
    btnWrite: TCornerButton;
    CornerButton1: TCornerButton;
    procedure btnShowBuffersClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
  private
    { Private declarations }
    procedure Write(const ABuffer: TIdBytes; const ALength: Integer = -1;
  const AOffset: Integer = 0);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  buferror: array[0..11] of Byte;
  buf: array[0..255] of Byte;

implementation

{$R *.fmx}

procedure TMainForm.btnShowBuffersClick(Sender: TObject);
var i,j:integer;
    s:string;
begin
  Memo1.Lines.Clear;
  Memo1.WordWrap:=True;
  Memo1.Lines.Add('buferror:');
  s:='';
  for I := Low(buferror) to High(buferror) do
      s:=s+IntToHex(buferror[i],2)+' ';
  Memo1.Lines.Add(s);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('buf:');
  s:='';
  for I := Low(buf) to High(buf) do
      s:=s+IntToHex(buf[i],2)+' ';
  Memo1.Lines.Add(s);


end;

procedure copymem(dest,src:PByte;len:integer);
var i:integer;
begin
  for I := 1 to len do
  begin
    //dest[i-1]:=src[i-1];
    PByte(dest+(i-1))^:=PByte(src+(i-1))^;
  end;
end;

const
  cMaxShift:array[0..1] of Integer=(High(buferror),High(buf));
procedure TMainForm.btnWriteClick(Sender: TObject);
var i,j,len:integer;
    tmpB:TIdBytes;
begin
  i:=Round(nbShift.Value);
  j:=Round(nbValue.Value);
  len:=Length(buferror);
  if ComboBox1.ItemIndex = 0  then
  begin
     buferror[i]:=j;
     nbShift.Value:=nbShift.Value+1;
     nbValue.Value:=Random(255);
  end
  else begin
     SetLength(tmpB,len);
     copymem(@tmpB[0],@buferror[0],len);
     Write(tmpB,len,i);
  end;
  btnShowBuffersClick(nil);

end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  if ComboBox1.ItemIndex  in [0..1] then
     nbShift.Max:=cMaxShift[ComboBox1.ItemIndex];
  nbValue.Visible:=ComboBox1.ItemIndex = 0;
end;

procedure TMainForm.CornerButton1Click(Sender: TObject);
var xbuf:TIdBytes;
begin
  SetLength(xbuf,Length(buf));
  PWord(@Buferror[0])^ := PWord(@buf[0])^ or $8000;
  btnShowBuffersClick(nil);
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  btnShowBuffersClick(nil);
end;

procedure TMainForm.Write(const ABuffer: TIdBytes; const ALength,
  AOffset: Integer);
var i:integer;
begin
  //Запись в массив buf
  for I := 1 to ALength do
     buf[AOffset+(i-1)]:=ABuffer[(i-1)];
end;

end.
