
unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  Fmx.Grid, Fmx.StdCtrls,
  FMX.Menus;

  const
    cKEY_Up=38;
    cKEY_Down=40;
    cKEY_Left=37;
    cKEY_Right=39;
    cRowSize=10;
    cColSize=10;
    cRecWidth=50;
    cRecHeight=50;
type
  TSnakeItemType=(sitNone,sitHeadBottom,sitHeadLeft,sitHeadRight,sitHeadTop,sitTailLeft,sitTailRight,sitTailTop,sitTailBottom,sitStone,sitFruit,sitHBody,sitVBody);
  TSnakeDirection=(sdUp,sdDown,sdLeft,sdRight);
  TMyPoint=record
  pos:TPoint;
  Direction:TSnakeDirection;
  end;
const
  cSnakeItemTypeName:array[TSnakeItemType] of String=('sitNone','sitHeadBottom','sitHeadLeft','sitHeadRight','sitHeadTop','sitTailLeft','sitTailRight',
                                                      'sitTailTop','sitTailBottom','sitStone','sitFruit','sitHBody','sirVBody');

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    StyleBook1: TStyleBook;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MenuItem4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);//приводит RecArray в соответствие с содержимым MаpArray

  private
    FirstActivate:boolean;
    procedure RecreateMap;
    function CheckGrowing(ADirection:TSnakeDirection):boolean;
    procedure SyncroBodyWithMap;
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateGrid;
  end;

var
  myPosArray:array of TMyPoint;
  Form1: TForm1;
  MapArray:array[0..cColSize-1,0..cRowSize-1] of TSnakeItemType;
  RecArray:array[0..cColSize-1,0..cRowSize-1] of TButton;

implementation

{$R *.fmx}

uses uDebug;


procedure TForm1.FormActivate(Sender: TObject);
begin
  if FirstActivate then
   begin
     FirstActivate:=False;
     RecreateMap();
   end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if MessageDlg('Завершить работу?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0)<>mrYes then
       CanClose:=False;

end;


procedure TForm1.RecreateMap();
var
  Col: Integer;
  Row: Integer;
  acol:TColumn;
begin
  //Карта - пока все пусто
  DebugForm.Grid1.RowCount:=0;
  DebugForm.Grid1.ClearColumns();
  for Col := 0 to cColSize-1 do
  begin
    acol:=TColumn.Create(DebugForm.Grid1);
    acol.Width:=25;
    acol.Header:=IntToStr(Col+1);
    DebugForm.Grid1.AddObject(acol);
    for Row := 0 to cRowSize-1 do
    begin
       MapArray[Col,Row]:=sitNone;
       if Assigned(RecArray[Col,Row]) then
         FreeAndNil(RecArray[Col,Row]);
       RecArray[Col,Row]:=TButton.Create(self);
       RecArray[Col,Row].Width:=cRecWidth;
       RecArray[Col,Row].Enabled:=False;
       RecArray[Col,Row].Height:=cRecHeight;
       RecArray[Col,Row].Position.X:=Col*cRecWidth;
       RecArray[Col,Row].Position.Y:=Row*cRecHeight;
       RecArray[Col,Row].Parent:=self;
       RecArray[Col,Row].Visible:=False;
    end;
  end;
  for Col := 1 to 5 do
  begin
    //Распределяем фрукты
    MapArray[Random(cColSize-1),Random(cRowSize-1)]:=sitFruit;
    //Распределяем камни
    MapArray[Random(cColSize-1),Random(cRowSize-1)]:=sitStone;
  end;
  DebugForm.Grid1.RowCount:=cRowSize;
  //Змейка
  MapArray[0,0]:=sitHeadBottom;
  SetLength(myPosArray,1);//координата под голову
  UpdateGrid;
end;

//приводит RecArray в соответствие с содержимым MаpArray
procedure TForm1.UpdateGrid;
var
  Col: Integer;
  Row: Integer;
begin
  //Карта - пока все пусто
  for Col := 0 to cColSize-1 do
    for Row := 0 to cRowSize-1 do
    begin
      //Пока простейший вариант - отображаем голову
      RecArray[col,row].Visible:= not (MapArray[col,row] = sitNone);
      RecArray[col,row].StyleLookup:=cSnakeItemTypeName[MapArray[col,row]];
    end;
 if Assigned(DebugForm) then
    DebugForm.UpdateGrid;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FirstActivate:=True;
end;

function TForm1.CheckGrowing(ADirection:TSnakeDirection):boolean;
var len:integer;
  I: Integer;//дина тела
  tmpH:TMyPoint;
  tmpT: TMyPoint;
begin
  len:=Length(MyPosArray);
  //Повернули голову, куда шли
  MyPosArray[0].Direction:=ADirection;
  tmpH:=MyPosArray[0];//Запоминаем голову до шага вперед
  tmpT:=MyPosArray[len-1];//Запоминаем хвост
  case ADirection of
    sdUp: begin
          MyPosArray[0].pos.Y:=MyPosArray[0].pos.Y-1;//Перемещаемся
    end;
    sdDown: begin
        MyPosArray[0].pos.Y:=MyPosArray[0].pos.Y+1;//Перемещаемся
    end;
    sdLeft: begin
      MyPosArray[0].pos.X:=MyPosArray[0].pos.X-1;//Перемещаемся
    end;
    sdRight: begin
      MyPosArray[0].pos.X:=MyPosArray[0].pos.X+1;//Перемещаемся
    end;
  end;
  if MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y] = sitFruit then
  begin
    result:=True;
    //Увеличичваем длину
    SetLength(MyPosArray,len+1);
    //в новый элемент тела копируем крайние координаты
    MyPosArray[len].pos.X:=tmpT.pos.X;
    MyPosArray[len].pos.Y:=tmpT.pos.Y;
    MyPosArray[len].Direction:=tmpT.Direction;
  end
  else begin
    result:=False;
    //Перетащить все ячейки хвоста если хвосн не нулевой длины
    if len>1 then
    begin
      //перемещаем тело
      for I := len-1 downto 1 do
      begin
        //Если это не голова - голова переместилась
        if i>1 then
        begin
          MyPosArray[i-1].pos.X:=MyPosArray[i].pos.X;
          MyPosArray[i-1].pos.Y:=MyPosArray[i].pos.Y;
          MyPosArray[i-1].Direction:=MyPosArray[i].Direction;
        end
        else begin
          MyPosArray[i].pos.X:=tmpH.pos.X;
          MyPosArray[i].pos.Y:=tmpH.pos.Y;
          MyPosArray[i].Direction:=tmpH.Direction;
        end;
      end;
    end;
  end;
  SyncroBodyWithMap();
end;

//переностим тело змеи на карту
procedure TForm1.SyncroBodyWithMap();
var
  Col: Integer;
  Row: Integer;
  i,len: integer;
begin
  for Col := 0 to cColSize-1 do
  begin
    for Row := 0 to cRowSize-1 do
    begin
      //sitNone,sitHeadBottom,sitHeadLeft,sitHeadRight,sitHeadTop,sitTailLeft,sitTailRight,sitTailTop,sitTailBottom,sitStone,sitFruit,sitHBody,sirVBody
      //Если ячейка относится к змейке - ее стираем
      if MapArray[Col,Row] in [sitHeadBottom..sitTailBottom,sitHBody,sitVBody] then
         MapArray[Col,Row]:=sitNone;
    end;
  end;
  len:=Length(myPosArray);
  for I := 0 to len-1 do
  begin
     Col:=myPosArray[i].pos.X;
     Row:=myPosArray[i].pos.Y;
     case myPosArray[i].Direction of
     sdUp: begin
            if i=0 then
            begin
              //голова
              MapArray[Col,Row]:=sitHeadTop;
            end
            else if i=(len-1) then
            begin
              //Хвост
              MapArray[Col,Row]:=sitTailTop;
            end
            else begin
             //Тело
              MapArray[Col,Row]:=sitVBody;
            end;
           end;
     sdDown:begin
            if i=0 then
            begin
              //голова
              MapArray[Col,Row]:=sitHeadBottom;
            end
            else if i=(len-1) then
            begin
              //Хвост
              MapArray[Col,Row]:=sitTailBottom;
            end
            else begin
             //Тело
              MapArray[Col,Row]:=sitVBody;
            end;
           end;

     sdLeft:begin
            if i=0 then
            begin
              //голова
              MapArray[Col,Row]:=sitHeadLeft;
            end
            else if i=(len-1) then
            begin
              //Хвост
              MapArray[Col,Row]:=sitTailLeft;
            end
            else begin
             //Тело
              MapArray[Col,Row]:=sitHBody;
            end;
           end;

     sdRight:begin
            if i=0 then
            begin
              //голова
              MapArray[Col,Row]:=sitHeadRight;
            end
            else if i=(len-1) then
            begin
              //Хвост
              MapArray[Col,Row]:=sitTailRight;
            end
            else begin
             //Тело
              MapArray[Col,Row]:=sitHBody;
            end;
           end;

     end;

  end;

end;
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    cKEY_Up:
    begin
         //если нет препятсвия  перед нами
         if (MyPosArray[0].pos.Y <> 0) and (MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y-1] in [sitNone,sitFruit])  then
           begin
            //Делаем операцию с хвостом
            CheckGrowing(sdUp);
           end
         else
            MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadTop;
    end;

    cKEY_Down:
    begin
         //если нет препятсвия  под нами
         if (MyPosArray[0].pos.Y <> (cRowSize-1)) and (MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y+1] in [sitNone,sitFruit])  then
         begin
          //Делаем операцию с хвостом
          CheckGrowing(sdDown);
         end
         else
            MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadBottom;
    end;

    cKEY_Left:
    begin
         //если нет препятсвия  cлева
         if (MyPosArray[0].pos.X <> 0) and (MapArray[MyPosArray[0].pos.X-1,MyPosArray[0].pos.Y] in [sitNone,sitFruit])  then
           begin
            //Делаем операцию с хвостом
            CheckGrowing(sdLeft);
        end
        else
           MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadLeft;
    end;

    cKEY_Right:
    begin
       if (MyPosArray[0].pos.X <> (cColSize-1)) and  (MapArray[MyPosArray[0].pos.X+1,MyPosArray[0].pos.Y] in [sitNone,sitFruit])  then
       begin
              //Скушали фрукт - растем
              CheckGrowing(sdRight);
       end
       else
           MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadRight;
    end;
  end;//case
  UpdateGrid;
end;




procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  DebugForm.Show
end;

end.
