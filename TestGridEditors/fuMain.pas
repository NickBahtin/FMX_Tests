unit fuMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.EditBox, FMX.NumberBox, FMX.Edit, FMX.ListBox, FmxFloatEdit;

type
  TParameterType = (ptComboBox, ptNumber, ptSingle, ptText);

  TParameter = record
    Name: string;
    Value: TValue;
    ParamType: TParameterType;
    Items: TArray<string>; // Для ComboBox
  end;

  TMainForm = class(TForm)
    Grid1: TGrid;
    Column1: TColumn;
    Column2: TColumn;
    procedure FormCreate(Sender: TObject);
    procedure Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure Grid1SetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);

    procedure Grid1CreateCustomEditor(Sender: TObject; const Column: TColumn;
      var Control: TStyledControl);
    procedure Grid1EditingDone(Sender: TObject; const ACol, ARow: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FParameters: TArray<TParameter>;
    [Weak] FActiveEditor: TStyledControl; // Храним ссылку на активный редактор
    FEditorRow: Integer;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}
uses FMX.Pickers;



procedure TMainForm.FormCreate(Sender: TObject);
begin
// Инициализация параметров
  SetLength(FParameters, 4);

  // Параметр с ComboBox
  FParameters[0].Name := 'Тип устройства';
  FParameters[0].ParamType := ptComboBox;
  FParameters[0].Value := 0; // Индекс выбранного элемента
  FParameters[0].Items := ['Принтер', 'Сканер', 'Монитор', 'Клавиатура'];

  // Параметр с NumberBox
  FParameters[1].Name := 'Количество';
  FParameters[1].ParamType := ptNumber;
  FParameters[1].Value := 1;

  // Параметр с обычным текстом
  FParameters[2].Name := 'Описание';
  FParameters[2].ParamType := ptText;
  FParameters[2].Value := '';

  FParameters[3].Name := 'Точность';
  FParameters[3].ParamType := ptSingle;
  FParameters[3].Value := 0.5; // Значение по умолчанию

  // Обновляем Grid
  Grid1.RowCount := Length(FParameters);
  FActiveEditor := nil;
  FEditorRow := -1;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
// Явная очистка только при уничтожении формы
  if FActiveEditor <> nil then
  begin
    FActiveEditor.Parent := nil;
    FActiveEditor.Free;
  end;
end;

procedure TMainForm.Grid1CreateCustomEditor(Sender: TObject;
  const Column: TColumn; var Control: TStyledControl);
var
  CellRect: TRectF;
  Row: Integer;
begin
  Row := Grid1.Selected;
  if (Column.Index = 1) and (Row >= 0) and (Row < Length(FParameters)) then
  begin
    CellRect := Grid1.CellRect(Column.Index, Row);

    // Только мягкий сброс ссылки без принудительного освобождения
    FActiveEditor := nil;

    case FParameters[Row].ParamType of
      ptComboBox:
        begin
          var Combo := TComboBox.Create(nil);
          Combo.Parent := Grid1;
          Combo.Position.Point := CellRect.TopLeft;
          Combo.Width := CellRect.Width;
          Combo.Items.AddStrings(FParameters[Row].Items);
          Combo.ItemIndex := FParameters[Row].Value.AsInteger;
          Control := Combo;
          FActiveEditor := Combo;
          FEditorRow := Row;
        end;

      ptNumber:
        begin
          var NumBox := TNumberBox.Create(nil);
          NumBox.Parent := Grid1;
          NumBox.Position.Point := CellRect.TopLeft;
          NumBox.Width := CellRect.Width;
          NumBox.Value := FParameters[Row].Value.AsInteger;
          NumBox.StyledSettings := NumBox.StyledSettings - [TStyledSetting.Size];
          Control := NumBox;
          FActiveEditor := NumBox;
          FEditorRow := Row;
        end;

      ptSingle:
        begin
          var FloatEdit := TFmxFloatEdit.Create(nil);
          FloatEdit.Parent := Grid1;
          FloatEdit.Position.Point := CellRect.TopLeft;
          FloatEdit.Width := CellRect.Width;
          FloatEdit.Value := FParameters[Row].Value.AsExtended;
          FloatEdit.StyledSettings := FloatEdit.StyledSettings - [TStyledSetting.Size];
          Control := FloatEdit;
          FActiveEditor := FloatEdit;
          FEditorRow := Row;
        end;

      ptText:
        begin
          var Edit := TEdit.Create(nil);
          Edit.Parent := Grid1;
          Edit.Position.Point := CellRect.TopLeft;
          Edit.Width := CellRect.Width;
          Edit.Text := FParameters[Row].Value.AsString;
          Control := Edit;
          FActiveEditor := Edit;
          FEditorRow := Row;
        end;
    end;

    if Assigned(Control) then
    begin
      Control.BringToFront;
      Control.SetFocus;
    end;
  end;
end;


procedure TMainForm.Grid1EditingDone(Sender: TObject; const ACol,
  ARow: Integer);
  var i:integer;
begin
if (ACol = 1) and (ARow >= 0) and (ARow < Length(FParameters)) and (FActiveEditor <> nil) then
  begin
    try
    case FParameters[ARow].ParamType of
      ptComboBox:
        if FActiveEditor is TComboBox then
        begin
          i:=TComboBox(FActiveEditor).ItemIndex;
          FParameters[ARow].Value := i;
        end;

      ptNumber:
        if FActiveEditor is TNumberBox then
          FParameters[ARow].Value := Round(TNumberBox(FActiveEditor).Value);

      ptSingle:
        if FActiveEditor is TFmxFloatEdit then
          FParameters[ARow].Value := TFmxFloatEdit(FActiveEditor).Value;

      ptText:
        if FActiveEditor is TEdit then
          FParameters[ARow].Value := TEdit(FActiveEditor).Text;
    end;

    // Обновляем отображение грида
    Grid1.RowCount := Grid1.RowCount;

    finally
      // Только отвязываемся от редактора, не освобождая его
      FActiveEditor.Parent := nil; // Отсоединяем от родителя
      FActiveEditor := nil;
    end;

  end;
end;


procedure TMainForm.Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
  var row,col:integer;
begin
  row:=ARow;
  col:=ACol;
  if (Row >= 0) and (Row < Length(FParameters)) then
  begin
    case ACol of
      0: Value := FParameters[Row].Name; // Название параметра
      1:
        case FParameters[Row].ParamType of
          ptComboBox:
            if (FParameters[Row].Value.AsInteger >= 0) and (FParameters[Row].Value.AsInteger < Length(FParameters[Row].Items)) then
              Value := FParameters[Row].Items[FParameters[Row].Value.AsInteger];
          ptNumber:Value := FParameters[Row].Value.AsInteger;
          ptSingle: Value := FParameters[Row].Value.AsExtended;
          ptText: Value := FParameters[Row].Value.AsString;
        end;
    end;
  end;
end;

function FindStringIndex(const AStr: string; const AArray: TArray<string>): Integer;
begin
  for Result := 0 to High(AArray) do
    if SameText(AArray[Result], AStr) then
      Exit;
  Result := -1;
end;

procedure TMainForm.Grid1SetValue(Sender: TObject; const ACol, ARow: Integer;
  const Value: TValue);
  var row,col:integer;
begin
  row:=ARow;
  col:=ACol;
 if (Col = 1) and (Row >= 0) and (Row < Length(FParameters)) then
  begin
    case FParameters[Row].ParamType of
      ptComboBox:
        if Value.IsType<string> then
        begin
          var Index := FindStringIndex(Value.ToString, FParameters[Row].Items);
          if Index >= 0 then
            FParameters[Row].Value := Index;
        end;
      ptNumber:
        if Value.IsType<integer> then
          FParameters[Row].Value := Value.AsInteger;
      ptSingle:
          // Безопасное получение Single значения
        if Value.IsType<Double> or
           Value.IsType<Single> or
           Value.IsType<Extended>
          then
            FParameters[Row].Value := Value.AsExtended;
      ptText:
        if Value.IsType<string> then
          FParameters[Row].Value := Value.ToString;
    end;
  end;
end;


end.
