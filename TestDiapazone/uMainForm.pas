unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.EditBox, FMX.NumberBox, FMX.Controls.Presentation, FMX.Edit;

type
  TMainForm = class(TForm)
    Edit1: TEdit;
    NumberBox1: TNumberBox;
    Button1: TButton;
    NumberBox2: TNumberBox;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}
uses FmxHelper;

procedure TMainForm.Button1Click(Sender: TObject);
begin
   if IsValueInRange(Edit1.Text,Round(NumberBox1.Value)) then
      ShowMessage('�������� '+NumberBox1.Text+' ���� � ���������:'+#130#10+Edit1.Text)
   else
      ShowMessage('�������� '+NumberBox1.Text+' ����������� � ���������:'+#130#10+Edit1.Text);
end;

procedure TMainForm.Button2Click(Sender: TObject);
var i:integer;
begin
   i:=GetElementByIndex(Edit1.Text,Round(NumberBox2.Value)-1);
   if i>0 then
      ShowMessage('����� �������� '+NumberBox2.Text+' � ���������:'+#130#10+Edit1.Text+' �������� '+IntToStr(i))
   else
      ShowMessage('����� �������� '+NumberBox2.Text+' ����������� � ���������:'+#130#10+Edit1.Text);
end;

end.
