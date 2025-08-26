unit fuSetup;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.TabControl, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope;

type
  TfrmSetup = class(TForm)
    tcJSONEngine: TTabControl;
    TabItem1: TTabItem;
    Layout1: TLayout;
    Label1: TLabel;
    edtAddress: TEdit;
    Layout2: TLayout;
    Label2: TLabel;
    edtGetDevice_list: TEdit;
    Layout3: TLayout;
    Label3: TLabel;
    edtGetHourArc: TEdit;
    Layout4: TLayout;
    Label4: TLabel;
    edtGetDayArc: TEdit;
    Layout5: TLayout;
    Label5: TLabel;
    edtGetErrArc: TEdit;
    Layout6: TLayout;
    Label6: TLabel;
    edtGetYearArc: TEdit;
    Layout7: TLayout;
    Label7: TLabel;
    edtGetMonthArc: TEdit;
    TabItem2: TTabItem;
    mmoInJSON: TMemo;
    mmoOutJSON: TMemo;
    Splitter1: TSplitter;
    TabItem3: TTabItem;
    cbDebug: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSetup: TfrmSetup;

implementation

{$R *.fmx}



end.
