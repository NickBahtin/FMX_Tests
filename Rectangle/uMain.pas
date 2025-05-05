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
    cKEY_Space=32;
    cRowSize=15;
    cColSize=15;
    cRecWidth=50;
    cRecHeight=50;
type
  TSnakeItemType=(sitNone,sitHeadBottom,sitHeadLeft,sitHeadRight,sitHeadTop,sitTailLeft,sitTailRight,sitTailTop,sitTailBottom,sitStone,sitFruit,sitHBody,sitVBody,sitLTBody,sitRTBody,sitRBBody,sitLBBody,sitJawHeadBottom,sitJawHeadLeft,sitJawHeadRight,sitJawHeadTop);
  TSnakeDirection=(sdUp,sdDown,sdLeft,sdRight);
  TMyPoint=record
    pos:TPoint;
    Direction:TSnakeDirection;
    State:TSnakeItemType;
  end;
const
  cSnakeItemTypeName:array[TSnakeItemType] of String=('sitNone','sitHeadBottom','sitHeadLeft','sitHeadRight','sitHeadTop','sitTailLeft','sitTailRight',
                                                      'sitTailTop','sitTailBottom','sitStone','sitFruit','sitHBody','sitVBody'
                                                      ,'sitLTBody','sitRTBody','sitRBBody','sitLBBody','sitJawHeadBottom','sitJawHeadLeft','sitJawHeadRight','sitJawHeadTop');

  cSnakeDirectionName:array[TSnakeDirection] of string =('^','v','<','>');
  cSnakeStateName:array[TSnakeItemType] of string =('N','HB','HL','HR','HT','TL','TR','TT','TB','ST','FR','H','V','LT','RT','RB','LB','JHB','JHL','JHR','JHT');
type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    StyleBook1: TStyleBook;
    Image1: TImage;
    MenuItem5: TMenuItem;
    Timer1: TTimer;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MenuItem4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);//приводит RecArray в соответствие с содержимым MаpArray
    procedure MenuItem5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    FirstActivate:boolean;
    procedure RecreateMap;
    function CheckGrowing(ADirection:TSnakeDirection):boolean;
    procedure SyncroBodyWithMap;
    procedure NextStepForDirection;
    procedure SyncroBody;
    procedure UpdateSnake;
    function GetDebug: Boolean;
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateGrid;
    property Debug:Boolean read GetDebug;
  end;

var
  myPosArray:array of TMyPoint;//тело змейки
  Form1: TForm1;
  MapArray:array[0..cColSize-1,0..cRowSize-1] of TSnakeItemType;
  RecArray:array[0..cColSize-1,0..cRowSize-1] of TButton;
  LastPressedKey: Word;  // Будет хранить код последней нажатой клавиши
  FLastKeyPressTime: TDateTime;

implementation

{$R *.fmx}

uses uDebug, FMX.DialogService, DateUtils;



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
  for Col := 0 to cColSize do
  begin
    acol:=TColumn.Create(DebugForm.Grid1);
    acol.HeaderSettings.TextSettings.HorzAlign:=TTextAlign.Center;
    acol.Width:=25;
    if Col>0 then
       acol.Header:=IntToStr(Col-1)
    else
       acol.Header:='';

    DebugForm.Grid1.AddObject(acol);
    if Col < cColSize then
    for Row := 0 to cRowSize-1 do
    begin
       MapArray[Col,Row]:=sitNone;
       if Assigned(RecArray[Col,Row]) then
         FreeAndNil(RecArray[Col,Row]);
       RecArray[Col,Row]:=TButton.Create(Image1);
       RecArray[Col,Row].Width:=cRecWidth;
       RecArray[Col,Row].Enabled:=True;
       RecArray[Col,Row].Height:=cRecHeight;
       RecArray[Col,Row].Position.X:=Col*cRecWidth;
       RecArray[Col,Row].Position.Y:=Row*cRecHeight;
       RecArray[Col,Row].Parent:=Image1;
       RecArray[Col,Row].Visible:=False;
    end;
  end;
  for Col := 1 to 10 do
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
  Width:=cColSize*cRecWidth+12;
  Height:=cRowSize*cRecHeight+cRecHeight+2;
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
  I: Integer;//длина тела
  tmpH:TMyPoint;
  tmpT: TMyPoint;
  rndY: Integer;
  rndX: Integer;
  checkCreate: boolean;
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
  //если голова наехала на фрукт
  if MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y] = sitFruit then
  begin
     result:=True;
    //Увеличичваем длину
    SetLength(MyPosArray,len+1);
    Inc(Len);

    //переставляем координаты - потому что змея растет с хвоста
    for I := len-2 downto 1 do
    begin
        MyPosArray[i+1].pos.X:=MyPosArray[i].pos.X;
        MyPosArray[i+1].pos.Y:=MyPosArray[i].pos.Y;
        MyPosArray[i+1].State:=MyPosArray[i].State;
        MyPosArray[i+1].Direction:=MyPosArray[i].Direction;
    end;

    //в новый элемент тела копируем голову
    MyPosArray[1].pos.X:=tmpH.pos.X;
    MyPosArray[1].pos.Y:=tmpH.pos.Y;
    MapArray[MyPosArray[1].pos.X,MyPosArray[1].pos.Y]:=tmpH.State;

    case MyPosArray[1].Direction of
    sdUp: case tmpH.Direction of
          sdUp: MyPosArray[1].State:=sitVBody;
          sdLeft: MyPosArray[1].State:=sitLBBody;
          sdRight: MyPosArray[1].State:=sitRBBody;
          end;
    sdDown:case tmpH.Direction of
          sdDown: MyPosArray[1].State:=sitVBody;
          sdLeft: MyPosArray[1].State:=sitLTBody;
          sdRight: MyPosArray[1].State:=sitRTBody;
          end;
    sdLeft:case tmpH.Direction of
          sdUp: MyPosArray[1].State:=sitRTBody;
          sdDown: MyPosArray[1].State:=sitLBBody;
          sdLeft: MyPosArray[1].State:=sitHBody;
          end;
    sdRight:case tmpH.Direction of
          sdUp: MyPosArray[1].State:=sitLTBody;
          sdDown: MyPosArray[1].State:=sitLBBody;
          sdRight: MyPosArray[1].State:=sitHBody;
          end;
    end;
    MyPosArray[1].Direction:=tmpH.Direction;

    //в новый элемент тела копируем хвост
    MyPosArray[len-1].pos.X:=tmpT.pos.X;
    MyPosArray[len-1].pos.Y:=tmpT.pos.Y;
    MyPosArray[len-1].Direction:=tmpT.Direction;
    MyPosArray[len-1].State:=tmpT.State;

    rndX:=Random(cColSize-1);
    rndY:=Random(cRowSize-1);
    checkCreate:=false;

    while not checkCreate do
    begin
      //Добавляем новый фрукт в случайное пустое место на карте
      if MapArray[rndX,rndY]=sitNone then
      begin
        MapArray[rndX,rndY]:=sitFruit;
        checkCreate:=true  //создали фрукт - выходим из цикла
      end
      else
      begin
        rndX:=Random(cColSize-1);  // создаём новые переменные для возможного места создания фрукта
        rndY:=Random(cRowSize-1);
      end;
    end;

  end
  else begin
    result:=False;
    //Перетащить все ячейки хвоста если хвост не нулевой длины
    if len>1 then
    begin
      //перемещаем тело
       for I := len-1 downto 1 do
      begin
        //Если это не голова - голова переместилась
        if i>1 then
        begin
          // в элемент хвоста скопировали значения предхвостья
          MyPosArray[i].pos.X:=MyPosArray[i-1].pos.X;
          MyPosArray[i].pos.Y:=MyPosArray[i-1].pos.Y;
          case MyPosArray[i].Direction of
          sdUp: case MyPosArray[i-1].Direction of
                sdUp: MyPosArray[i].State:=sitVBody;
                //sdDown: ;
                sdLeft: MyPosArray[i].State:=sitLBBody;
                sdRight: MyPosArray[i].State:=sitRBBody;
                end;
          sdDown:case MyPosArray[i-1].Direction of
                //sdUp:
                sdDown: MyPosArray[i].State:=sitVBody;
                sdLeft: MyPosArray[i].State:=sitLTBody;
                sdRight: MyPosArray[i].State:=sitRTBody;
                end;
          sdLeft:case MyPosArray[i-1].Direction of
                sdUp: MyPosArray[i].State:=sitRTBody;
                sdDown: MyPosArray[i].State:=sitLBBody;
                sdLeft: MyPosArray[i].State:=sitHBody;
                end;
          sdRight:case MyPosArray[i-1].Direction of
                sdUp: MyPosArray[i].State:=sitLTBody;
                sdDown: MyPosArray[i].State:=sitLBBody;
                sdRight: MyPosArray[i].State:=sitHBody;
                end;
          end;
          MyPosArray[i].Direction:=MyPosArray[i-1].Direction;
        end
        else begin
          MyPosArray[i].pos.X:=tmpH.pos.X;
          MyPosArray[i].pos.Y:=tmpH.pos.Y;
          MyPosArray[i].Direction:=tmpH.Direction;
        end;
      end;
    end;
  end;
  //перерисовали змейку
  UpdateSnake();
  SyncroBodyWithMap();
end;

procedure TForm1.SyncroBody;
var i,Col,Row,len:integer;
    PrevDir, NextDir: TSnakeDirection;
begin
  Exit;
  // Отрисовка тела
  len:=Length(myPosArray);
  //Если есть тело, а не одна голова
  if len>1 then
  //бежим от шеи до предхвостья
  for I := 1 to len-2 do
  begin
    //элемент
    Col := myPosArray[i].pos.X;
    Row := myPosArray[i].pos.Y;
    prevDir := myPosArray[i-1].Direction;
    nextDir := myPosArray[i+1].Direction;

    if (prevDir = nextDir) then
    begin
      // Прямой сегмент
      if (prevDir in [sdLeft, sdRight]) then
        MapArray[Col,Row] := sitHBody
      else
        MapArray[Col,Row] := sitVBody;
    end
    else
    begin
      // Поворот
      if ((prevDir = sdLeft) and (nextDir = sdUp)) or
         ((prevDir = sdDown) and (nextDir = sdRight)) then
        MapArray[Col,Row] := sitLBBody
      else if ((prevDir = sdRight) and (nextDir = sdUp)) or
              ((prevDir = sdDown) and (nextDir = sdLeft)) then
        MapArray[Col,Row] := sitRBBody
      else if ((prevDir = sdLeft) and (nextDir = sdDown)) or
              ((prevDir = sdUp) and (nextDir = sdRight)) then
        MapArray[Col,Row] := sitLTBody
      else if ((prevDir = sdRight) and (nextDir = sdDown)) or
              ((prevDir = sdUp) and (nextDir = sdLeft)) then
        MapArray[Col,Row] := sitRTBody
      else
        if (prevDir in [sdLeft, sdRight]) then
          MapArray[Col,Row] := sitHBody
        else
          MapArray[Col,Row] := sitVBody;
    end;
  end;
end;

//переностим тело змеи на карту
procedure TForm1.SyncroBodyWithMap();
var
  Col: Integer;
  Row: Integer;
  i,len: integer;
  CurrentPos: TPoint;
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

     sdRight:
       begin
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
     end;//case

  end;//for
  SyncroBody();
end;


procedure TForm1.Timer1Timer(Sender: TObject);
//var
//  Key: Word;
//  KeyChar: WideChar;
//  Shift: TShiftState;
begin
  // Если с последнего нажатия прошло больше интервала таймера
//  if MilliSecondsBetween(Now, FLastKeyPressTime) >= Timer1.Interval then
    NextStepForDirection();
    UpdateGrid;
end;

//в зависимости от положения головы делает шаг
procedure TForm1.NextStepForDirection();
begin
  case MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y] of
    sitHeadTop: begin
        //движемся вверх
        //если нет препятсвия  перед нами
        if (MyPosArray[0].pos.Y <> 0) and (MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y-1] in [sitNone,sitFruit])  then
        begin
           //Делаем операцию с хвостом
            CheckGrowing(sdUp);
        end;
    end;
    sitHeadLeft: begin
        //движемся влево
        //если нет препятсвия  cлева
       if (MyPosArray[0].pos.X <> 0) and (MapArray[MyPosArray[0].pos.X-1,MyPosArray[0].pos.Y] in [sitNone,sitFruit])  then
       begin
        //Делаем операцию с хвостом
         CheckGrowing(sdLeft);
       end
    end;
    sitHeadRight: begin
        //движемся вправо
        if (MyPosArray[0].pos.X <> (cColSize-1)) and  (MapArray[MyPosArray[0].pos.X+1,MyPosArray[0].pos.Y] in [sitNone,sitFruit])  then
        begin
           //Скушали фрукт - растем
            CheckGrowing(sdRight);
        end
    end;
    sitHeadBottom: begin
        //движемся вниз
          //если нет препятсвия  под нами
          if (MyPosArray[0].pos.Y <> (cRowSize-1)) and (MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y+1] in [sitNone,sitFruit])  then
          begin
            //Делаем операцию с хвостом
             CheckGrowing(sdDown);
          end;
    end;
  end;//case
end;

//обновляем элемент тела
procedure TForm1.UpdateSnake;
var len:integer;
  I: Integer;
  PrevDir, NextDir: TSnakeDirection;
begin
  len:=Length(MyPosArray);
//  if Idx in [0..len-1]then
//  begin
//    //генерируем состояние для головы и хвоста
//    //для головы
//    case MyPosArray[0].Direction of
//      sdUp: MyPosArray[0].State:=sitHeadTop;
//      sdDown: MyPosArray[0].State:=sitHeadBottom;
//      sdLeft: MyPosArray[0].State:=sitHeadLeft;
//      sdRight: MyPosArray[0].State:=sitHeadRight;
//    end;
//
//    if len>1 then
//    begin
//      //для тела
//      //анализируем тело и расставляем статус элемента тела
//      //бежим от шеи до предхвостья
//      for I := 1 to len-2 do
//      begin
//         PrevDir:=MyPosArray[i-1].Direction;
//         NextDir:=MyPosArray[i+1].Direction;
//         case NextDir of
//          sdUp: case PrevDir of
//                sdUp: MyPosArray[i].State:=sitVBody;
//                sdLeft: MyPosArray[i].State:=sitLBBody;
//                sdRight: MyPosArray[i].State:=sitRBBody;
//                end;
//          sdDown:case PrevDir of
//                //sdUp:
//                sdDown: MyPosArray[i].State:=sitVBody;
//                sdLeft: MyPosArray[i].State:=sitLTBody;
//                sdRight: MyPosArray[i].State:=sitRTBody;
//                end;
//          sdLeft:case PrevDir of
//                sdUp: MyPosArray[i].State:=sitRTBody;
//                sdDown: MyPosArray[i].State:=sitLBBody;
//                sdLeft: MyPosArray[i].State:=sitHBody;
//                end;
//          sdRight:case PrevDir of
//                sdUp: MyPosArray[i].State:=sitLTBody;
//                sdDown: MyPosArray[i].State:=sitLBBody;
//                sdRight: MyPosArray[i].State:=sitHBody;
//                end;
//          end;//case
//      end;//for
//
//      //для хвоста
//      case MyPosArray[len-1].Direction of
//        sdUp: MyPosArray[len-1].State:=sitTailTop;
//        sdDown: MyPosArray[len-1].State:=sitTailBottom;
//        sdLeft: MyPosArray[len-1].State:=sitTailLeft;
//        sdRight: MyPosArray[len-1].State:=sitTailRight;
//      end;
//    end;
//  end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
FLastKeyPressTime := Now; // Запоминаем время нажатия
LastPressedKey := Key;  // Сохраняем последнюю нажатую клавишу
  if KeyChar=chr(cKEY_Space) then
     Timer1.Enabled:=False;
  case Key of
    cKEY_Up:
    begin
        MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadTop;
    end;

    cKEY_Down:
    begin
        MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadBottom;
    end;

    cKEY_Left:
    begin
        MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadLeft;
    end;

    cKEY_Right:
    begin
       MapArray[MyPosArray[0].pos.X,MyPosArray[0].pos.Y]:=sitHeadRight;
    end;
  end;//case
  if Key in [cKEY_Right,cKEY_Left,cKEY_Down,cKEY_Up] then
  begin
    //если нажата клавиша стрелок
    if not Timer1.Enabled then
    begin
      //Lets GO!
      Timer1.Enabled:=True;
    end;
  end;
  UpdateSnake;
  UpdateGrid;
end;




function TForm1.GetDebug: Boolean;
begin
  result:=DebugForm.Visible;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  DebugForm.Show
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var i,j:integer;
begin
  j:=0;
  for I := 0 to Image1.ComponentCount-1 do
    begin
      if Image1.Components[i] is TButton then
      begin
         if (TButton(Image1.Components[i]).StyleLookup=cSnakeItemTypeName[sitHBody]) or
            (TButton(Image1.Components[i]).StyleLookup=cSnakeItemTypeName[sitVBody])
         then
           Inc(j);
      end;
    end;
    ShowMessage('Тело змейки '+IntToStr(j)+' элементов');
end;

end.
