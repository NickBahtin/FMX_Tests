unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.WebBrowser;

type
  TForm1 = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
  System.IOUtils;
{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
var
  HTMLFileName: string;
  HTMLContent: string;
begin
  // ������� HTML-������� � ��������� ��������� UTF-8
  HTMLContent := '<html><head><meta charset="UTF-8"></head><body>';
  HTMLContent := HTMLContent + '<p><font color="red">������� �����</font> � <font color="blue">����� �����</font></p>';
  HTMLContent := HTMLContent + '<p><b>������ �����</b> � <i>��������� �����</i></p>';
  HTMLContent := HTMLContent + '<p><font size="20">����� �������� �������</font></p>';
  HTMLContent := HTMLContent + '</body></html>';

  // ������� ��������� ����
  HTMLFileName := TPath.Combine(TPath.GetTempPath, 'temp.html');
  TFile.WriteAllText(HTMLFileName, HTMLContent, TEncoding.UTF8);

  // ��������� HTML-���� � TWebBrowser
  WebBrowser1.Navigate(HTMLFileName);
end;


end.
