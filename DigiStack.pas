{****************************************************
 * Author  : Dumitru Uzun
 * Web     : http://duzun.me
 * Created : 25.12.2009
 * 
 *  TDigiStack este un container pentru componente de tip TDigiBox.
 *  Se foloseste pentru reprezentarea vizuala a unei liste de numere sau
 *  cuvinte. Lista se contine intr-o proprietate speciala FDL de tip TStrStack.
 *  Proprietatea FDL poate fi modificata in alte fire de executie, fiind 
 *  independenta fata de componenta vizuala TDigiStack.     
 *  Skimbarile continutului FDL sunt automat reflectate pe componentele TDigiBox.
 *  
 * Proprietati:  
 *   Items: TStrings - Continutul stivei ca lista de string.
 *   Count: Integer  - Numarul de elemente din stiva.
 * 
 *   BrColor  : TColor     - Border Color
 *   BkColor  : TColor     - Background Color
 *   TextColor: TColor     - Text Color
 * 
 *   Shape      : TShapeType    - Forma componentelor TDigiBox
 *   AutoResize : Boolean       - Autoredimensionarea TDigiBox la modificarea continutului
 *   Space      : Integer       - Spatiul intre Border si Text    
 *   Interval   : Integer       - Intervalul intre elementele stivei
 *   Direction  : TDigiStackDir - Modul de aranjare vizuala a elementelor: dsdUpDown, dsdLeftRight, dsdDownUp, dsdRightLeft
 *   RefreshTime: integer       - intervalul de redesenate (milisecunde)
 *   SleepCount : Integer       - Pauza dupa fiecare operatie I/O (milisecunde)
 * 
 *   DHeight: Integer - Inaltimea unui elemente TDigiBox
 *   DWidth : Integer - Latimea unui elemente TDigiBox
 * 
 *   Memo     : TCustomMemo - Componenta TMemo in care se va scrie rezultatul
 *   ScrollBar: TScrollBar  - Componenta TScrollBar care dirijeaza cu viteza de executie
 * 
 * Proceduri:
 *   Sort(Dir: Integer=1); // 1 - asscending, -1 - desscending
 *   ToMemo - Scrie continutul stivei in Memo
 *   Clear  - Curate stiva
 * 
 * 
 * Istorie:
 * 
 ****************************************************}
unit DigiStack;
{$M+}
interface
uses Windows, Classes, Contnrs, Controls, Graphics, StdCtrls,
     SysUtils, Dialogs, Types, SyncObjs, ExtCtrls, 
     DigiBox, StrStack, Interfata;

type
TDigiStackDir = (dsdFree, dsdUpDown, dsdDownUp, dsdLeftRight, dsdRightLeft);
TDigiStack = class(TPanel)
  private
    FDL        : TStrStack;
    FScrollBar : TScrollBar;
    FShape     : TShapeType;
    FDirection : TDigiStackDir;
    FSpace     : Integer;
    FInterval  : Integer;
    FDWidth    : Integer;
    FDHeight   : Integer;
    FBrColor   : TColor;
    FBkColor   : TColor;

    FDClick  , FDDblClick : TNotifyEvent;
    FDSelect , FDDeselect : TNotifyEvent;
    FDMouseUp, FDMouseDown: TMouseEvent;
    FOnChange  : TNotifyEvent;
    FOnDirection: TNotifyEvent;
    FDMouseMove: TMouseMoveEvent;
    FSleepCount: Integer;

// private Methods
    function  GetItems: TStrings;
    function  GetCount: Integer;

    procedure SetBkColor  (const Value: TColor);
    procedure SetBrColor  (const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetColor    (const Value: TColor);

    procedure SetShape    (const Value: TShapeType);
    procedure SetSpace    (const Value: Integer);

    procedure SetDHeight  (Value: Integer);
    procedure SetDWidth   (Value: Integer);
    procedure SetDirection(const Value: TDigiStackDir);
    procedure SetInterval (const Value: Integer);

    function  GetText: String;
    procedure SetText(const Value: String);
    procedure SetMemo(const Value: TCustomMemo);
    function  GetTextColor: TColor;

    // DigiBox Events
    procedure SetDOnClick(const Value: TNotifyEvent);
    procedure SetDOnDblClick(const Value: TNotifyEvent);
    procedure SetDOnMouseDown(const Value: TMouseEvent);
    procedure SetDOnMouseUp(const Value: TMouseEvent);
    procedure SetDOnMouseMove(const Value: TMouseMoveEvent);
    procedure SetDOnDeselect(const Value: TNotifyEvent);
    procedure SetDOnSelect(const Value: TNotifyEvent);

    function  GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    
    function  GetSelItem: TDigiBox;
    procedure SetSelItem(const Value: TDigiBox);

    function  GetB(Index: Integer): boolean;
    procedure SetB(Index: Integer; const Value: boolean);

    function  GetObjs(Index: Integer): TDigiBox;
    function  GetObjCount: Integer;
    procedure SetObjCount(Value: Integer);
    procedure SetSleepCount(const Value: Integer);
    function  GetMemo: TCustomMemo;

    procedure SetAutoResize(Index: Integer; const Value: Boolean);
    procedure SetClientAnchors(const Index: Integer; const Value: Boolean);

  protected
    function  GetColor: TColor;

    procedure SetItems(Value: TStrings); virtual;
    procedure SetCount(Value: Integer);

    procedure DAttachEvents(D: TDigiBox);
    procedure DsAttachEvents;

    procedure ReAlign; virtual;
    procedure Changed; virtual;
    procedure OnUpdate; virtual;
    procedure DLChanged(Sender: TObject); // este kemata de catre FDL

    procedure Select(Sender: TObject);
    procedure Deselect(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure Lock; dynamic;
    procedure UnLock; dynamic;

    procedure Paint; override;  // Used by Win for drowing the Control
    procedure Update; override;

    procedure AspectToItem(Item: TDigiBox); overload;
    procedure AspectToItem(Index: integer); overload;
    function  ItemRect(Index: integer): TRect;
    procedure AlignItem(Index: integer);

    // Aliniaza elementele stivei astfel ca sa nu iasa in afara stivei
    procedure BringItemInClient(Idx: Integer);   overload;
    procedure BringItemInClient(Item: TDigiBox); overload;
    procedure BringItemsInClient;

    function  IndexOf(Item: TObject): Integer; // In Components list
    procedure Sort(Dir: Integer=1); // 1 - asscending, -1 - desscending
    procedure ToMemo;  virtual;
    function  HTML: String;

    // Lucrul cu componentele
    function SyncObjs: integer;
    property Objs[Index: Integer]: TDigiBox read GetObjs;
    property SelItem: TDigiBox read GetSelItem write SetSelItem;

    property First: TDigiBox index  0 read GetObjs;
    property Last:  TDigiBox index -1 read GetObjs;

    function Push(Txt: String): TDigiBox;      overload;
    function Push(DigiBox: TObject): TDigiBox; overload;
    function Pop: boolean;

    function  Insert(Idx: integer; d: TDigiBox): TDigiBox; overload; virtual;
    function  Insert(Idx: integer; Txt: String): TDigiBox; overload; virtual;

    // Eliminarea din lista
    function  Delete(Sender: TObject): Boolean; Overload; virtual; // Extrage fara sa-l distruga
    function  Delete(Index:Integer): Boolean; Overload; virtual; // Extrage fara sa-l distruga
    procedure Clear;

    procedure Validate; virtual;

    property Stack: TStrStack read FDL;

    property Text: String read GetText write SetText;

    procedure TrySleep(NoSleep: Boolean = false);
    procedure DoSleep(Sender: TObject);

    procedure ProcessKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function WriteSettings(List: TStrings): integer; overload;
    function ReadSettings(List: TStrings): integer;  overload;

    function WriteSettings(Ctrl: TWinControl): integer; overload;
    function ReadSettings(Ctrl: TWinControl): integer;  overload;

  published
    property Items: TStrings read GetItems write SetItems;
    property Count: Integer  read GetCount write SetCount nodefault;

    // Indexul elementului selectat (incepe cu 0). -1 pentru anularea selectiei
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;

    // Culorile
    property BrColor  : TColor     read FBrColor     write SetBrColor   nodefault;
    property BkColor  : TColor     read FBkColor     write SetBkColor   nodefault;
    property TextColor: TColor     read GetTextColor write SetTextColor nodefault;
    property Color    : TColor     read GetColor     write SetColor   nodefault;

    // Spatiul intre textul elementelor stivei si marginea acestora
    property Space    : Integer    read FSpace       write SetSpace     default 5;
    // Forma DigiBox-elor (elementelor) stivei
    property Shape    : TShapeType read FShape       write SetShape     default stRectangle;

    // Intervalul intre elementele stivei
    property Interval : Integer   read FInterval write SetInterval   default 1;

    // Modul de aranjare vizuala a elementelor:
    // dsdUpDown, dsdLeftRight, dsdDownUp, dsdRightLeft
    property Direction: TDigiStackDir read FDirection write SetDirection default dsdDownUp;

    // Dimensiunile unui element al stivei
    property DHeight: Integer read FDHeight  write SetDHeight default 15;
    property DWidth : Integer read FDWidth   write SetDWidth  default 50;

    // Autodimensionarea elementelor dupa continut
    property AutoResize   : Boolean index 1  read GetB write SetAutoResize  default false;

    // Latime sau inaltime a elementelor dupa dim. stivei, in functie de aliniere
    property ClientAnchors: Boolean index 2  read GetB write SetClientAnchors  default true;

    // Daca FALSE, nu se reflecta skimbarile din stiva interna pe componenta vizuala
    property Synchronized: Boolean index 3  read GetB write SetB  default true;

    // Un memo unde se vor scrie valorile stivei la apelul ToMemo
    property Memo: TCustomMemo read GetMemo write SetMemo;

    // Controleaza viteza de executie in %
    property ScrollBar: TScrollBar read FScrollBar write FScrollBar;

    // Pauza dupa fiecare operatie I/O in milisecunde
    property SleepCount: Integer  read FSleepCount write SetSleepCount default 100;

    property OnChange: TNotifyEvent  read FOnChange write FOnChange;
    property OnDirection: TNotifyEvent read FOnDirection write FOnDirection;

    // Evenimente asociate elementelor stivei
    property DOnClick    : TNotifyEvent read FDClick     write SetDOnClick;
    property DOnDblClick : TNotifyEvent read FDDblClick  write SetDOnDblClick;
    property DOnMouseUp  : TMouseEvent  read FDMouseUp   write SetDOnMouseUp;
    property DOnMouseDown: TMouseEvent  read FDMouseDown write SetDOnMouseDown;
    property DOnMouseMove: TMouseMoveEvent read FDMouseMove write SetDOnMouseMove;
    property DOnDeselect : TNotifyEvent read FDDeselect   write SetDOnDeselect;
    property DOnSelect   : TNotifyEvent read FDSelect     write SetDOnSelect;

  end;

procedure Register;

implementation
uses Clipbrd;
var Clipb: TClipboard;
procedure Register; begin RegisterComponents('DUzuns', [TDigiStack]); end;

type
{ TStrSt }
  TStrSt = class(TStrStack)
  public
    property  SBits;

  end;

{ TDigiStack }

constructor TDigiStack.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDL            := TStrSt.Create;
  FDL.OnChange   := DLChanged;
  FDL.OnSelect   := Select;
  FDL.OnDeselect := Deselect;
  FDWidth      := 50;
  FDHeight     := 20;
  FInterval    := 1;
  FSpace       := 5;
  FDirection   := dsdDownUp;
  Width        := FDWidth * 2;
  Height       := FDHeight * 20;
  AutoResize   := false;
  ClientAnchors:= true;
  Synchronized := true;
  Font.Size    := 10;
  FBkColor     := Graphics.clGradientInactiveCaption;
  FBrColor     := Graphics.clSkyBlue;
  TextColor    := Graphics.clHotLight;
  FScrollBar   := nil; 
  FSleepCount  := 100;
end;

destructor TDigiStack.Destroy;
begin
  FDL.Free;
  inherited Destroy;
end;

procedure TDigiStack.SetBkColor(const Value: TColor);
var i: integer;
begin
  FBkColor := Value;
  i := SyncObjs;
  while i > 0 do begin
    dec(i);
    Objs[i].BkColor := Value;
  end;
  OnUpdate;
end;

procedure TDigiStack.SetBrColor(const Value: TColor);
var i: integer;
begin
  FBrColor := Value;
  i := SyncObjs;
  while i > 0 do begin
    dec(i);
    Objs[i].BrColor := Value;
  end;
  OnUpdate;
end;

procedure TDigiStack.SetColor(const Value: TColor);
var i: integer;
begin
  i := SyncObjs;
  while i > 0 do begin
    dec(i);
    Objs[i].TransparentColor := Value;
  end;
  inherited Color := Value;
  OnUpdate;
end;

procedure TDigiStack.SetShape(const Value: TShapeType);
var i: integer;
begin
  FShape := Value;
  i := SyncObjs;
  while i > 0 do begin dec(i); Objs[i].Shape := FShape; end;
  OnUpdate;
end;

procedure TDigiStack.SetSpace;
var i: integer;
begin
  FSpace := Value;
  i := SyncObjs;
  while i > 0 do begin dec(i); Objs[i].Space := FSpace; end;
  OnUpdate;
end;

procedure TDigiStack.SetTextColor(const Value: TColor);
var i: integer;
begin
  Font.Color := Value;
  i := SyncObjs;
  while i > 0 do begin
    dec(i);
    Objs[i].TextColor := Value;
  end;
  OnUpdate;
end;

function TDigiStack.GetTextColor: TColor;
begin
  Result := Font.Color;
end;

function TDigiStack.GetCount: Integer;
begin
  if Self = nil then Result := 0 else
  Result := FDL.Count
end;

procedure TDigiStack.SetCount(Value: Integer);
begin
  if (Self = nil) or (Value = FDL.Count) then Exit;
  FDL.Count := Value;
  OnUpdate;
end;

function TDigiStack.Delete(Sender: TObject): Boolean;
begin
  Result := Delete(IndexOf(Sender));
end;

function TDigiStack.Delete(Index: Integer): Boolean;
begin
  if (-1 < Index) and (Index < Count) then begin
     Result := True;
     Objs[Index].FreeMe;
     FDL.Delete(Index);
     Invalidate;
  end else Result := false;
end;

function TDigiStack.Insert(Idx: integer; d: TDigiBox): TDigiBox;
begin
  Result := Insert(Idx, d.Text);
  Result.Assign(d);
end;

function TDigiStack.Insert(Idx: integer; Txt: String): TDigiBox;
begin
   Stack.Insert(Idx, Txt);
   Result := Objs[Idx];
end;

function TDigiStack.GetItems;
begin
  Result := TStrings(FDL);
end;

procedure TDigiStack.SetItems(Value: TStrings);
begin
  if not Assigned(Value) then Exit;
  FDL.Assign(Value);
  Changed;
end;

procedure TDigiStack.AspectToItem(Index: integer);
begin
  AspectToItem(Objs[Index]);
end;

procedure TDigiStack.AspectToItem(Item: TDigiBox);
begin
  if Item = nil then Exit;
  Item.AutoResize := AutoResize;
  Item.Font.Assign(Self.Font);
  Item.TransparentColor := Color;
  Item.SetAspect(FSpace,FShape,TextColor,FBkColor,FBrColor);
end;

function TDigiStack.ItemRect(Index: integer): TRect;
var fw, fh, w, h, px, py: integer;
    d: TDigiBox;
begin
  if AutoResize then begin
    px := 0; py := 0;
    for w := 0 to Index-1 do begin
      inc(px, Objs[w].Width  + Interval);
      inc(py, Objs[w].Height + Interval);
    end;
    if Index >= 0 then d := Objs[Index] else d := Objs[-1];
    if d <> nil then begin
      w := d.Width;
      h := d.Height;
    end else begin
      w := FDWidth;
      h := FDHeight;
    end;
  end else begin
    w := FDWidth;
    h := FDHeight;
    px := Index * (w + Interval);
    py := Index * (h + Interval);
  end;
  if ClientAnchors and not AutoResize then begin
    fw := Width  - 2;
    fh := Height - 2;
  end else begin
    fw := w;
    fh := h;
  end;

  case FDirection of
    dsdUpDown:    Result := Rect((Width-fw) div 2, py+1, (Width+fw) div 2, py+1+h);
    dsdDownUp:    Result := Rect((Width-fw) div 2, Height-py-1-h, (Width+fw) div 2, Height-py-1);
    dsdLeftRight: Result := Rect(px+1, (Height-fh) div 2, px+1+w, (Height+fh) div 2);
    dsdRightLeft: Result := Rect(Width-px-1-w, (Height-fh) div 2, Width-px-1, (Height+fh) div 2);
    dsdFree :
      begin
        if Index > 0 then d := Objs[Index-1] else d := nil;
        if d = nil then Result := Rect(px, py, px+w, py+h)
        else Result := Rect(d.Left, d.Top+d.Height+Interval, d.Left+d.Width, 0);
      end;
  end;
end;

procedure TDigiStack.AlignItem(Index: Integer);
var d: TDigiBox;
begin
  if(Index < 0) or (SyncObjs <= Index) then Exit;
  d := Objs[Index];
  d.Index := Index;
  if FDirection = dsdFree then begin
    if not AutoResize then begin
      d.Width  := FDWidth;
      d.Height := FDHeight;
    end;
  end else begin
    d.BoundsRect := ItemRect(Index);
  end;
end;

function TDigiStack.IndexOf(Item: TObject): Integer;
begin
  Result := Self.ComponentCount;
  while Result > 0 do begin
    dec(Result);
    if Self.Components[Result] = Item then Exit;
  end;
  Result := -1;
end;

procedure TDigiStack.SetDWidth;
begin
//  if Value > Width then Value := Width - FInterval*2;
  if FDWidth = Value then Exit;
  FDWidth := Value;
  Invalidate;
end;

procedure TDigiStack.SetDHeight;
begin
//  if Value > Width then Value := Width - FInterval*2;
  if FDHeight = Value then Exit;
  FDHeight := Value;
  Invalidate;
end;

procedure TDigiStack.ReAlign;
var i: integer;
begin
  i := SyncObjs;
  while i > 0 do begin
    dec(i);
    AlignItem(i);
    Objs[i].Font.Assign(Font);
  end;
end;

procedure TDigiStack.SetDirection(const Value: TDigiStackDir);
begin
  if Value = FDirection then Exit;
  FDirection := Value;
  if Assigned(FOnDirection) then FOnDirection(Self);
  Invalidate;
end;

procedure TDigiStack.SetInterval;
begin
  if FInterval = Value then Exit;
  FInterval := Value;
  Invalidate;
end;

procedure TDigiStack.Clear; begin Count := 0; Invalidate; end;

procedure TDigiStack.SetAutoResize;
var i: integer;
begin
  if GetB(Index) = Value then exit;
  SetB(Index, Value);
  i := SyncObjs;
  while Boolean(i) do begin dec(i); Objs[i].AutoResize := Value; end;
  if Value then ClientAnchors := false;
  Invalidate;
end;

procedure TDigiStack.SetClientAnchors(const Index: Integer;
  const Value: Boolean);
begin
  if GetB(Index) = Value then exit;
  SetB(Index, Value);
  if Value then AutoResize := false;
  Invalidate;
end;

procedure TDigiStack.Lock;  begin FDL.Lock;   end;
procedure TDigiStack.UnLock;begin FDL.UnLock; end;

function TDigiStack.GetText: String;
begin
  Result := FDL.Text;
end;

procedure TDigiStack.SetText(const Value: String);
begin
  FDL.Text := Value;
end;

procedure TDigiStack.ToMemo;
begin
  if Memo = nil then Exit;
  Memo.Lines.Append(StringReplace(Trim(Text),#13#10, ', ', [rfReplaceAll]));
end;

function TDigiStack.GetMemo: TCustomMemo;
begin
  Result := FDL.Memo;
end;

procedure TDigiStack.SetMemo(const Value: TCustomMemo);
begin
  FDL.Memo := Value;
end;

function TDigiStack.HTML: String;
var i: integer;
begin
  Result := '';
  i := 0;
  while i < SyncObjs do begin
     Result := Result + Objs[i].HTML(Format('style="margine:%dpx"', [Self.Interval]));
     inc(i);
  end;
  Result := '<div style="'+ControlToCSS(Self, 'display:table-cell;position:relative')+'">'#13#10 +
            Result +
            '</div>'#13#10;
end;

procedure TDigiStack.SetDOnClick(const Value: TNotifyEvent);
begin
  FDClick := Value;
  DsAttachEvents;
end;

procedure TDigiStack.SetDOnDblClick(const Value: TNotifyEvent);
begin
  FDDblClick := Value;
  DsAttachEvents;
end;

procedure TDigiStack.SetDOnMouseDown(const Value: TMouseEvent);
begin
  FDMouseDown := Value;
  DsAttachEvents;
end;

procedure TDigiStack.SetDOnMouseMove(const Value: TMouseMoveEvent);
begin
  FDMouseMove := Value;
  DsAttachEvents;
end;

procedure TDigiStack.SetDOnMouseUp(const Value: TMouseEvent);
begin
  FDMouseUp := Value;
  DsAttachEvents;
end;

procedure TDigiStack.SetDOnDeselect(const Value: TNotifyEvent);
begin
  FDDeselect := Value;
  DsAttachEvents;
end;

procedure TDigiStack.SetDOnSelect(const Value: TNotifyEvent);
begin
  FDSelect := Value;
  DsAttachEvents;
end;

procedure TDigiStack.DsAttachEvents;
var i: Integer;
begin
  i := SyncObjs;
  while Boolean(i)  do begin
    dec(i);
    DAttachEvents(Objs[i]);
  end;
end;

procedure TDigiStack.DAttachEvents(D: TDigiBox);
begin
   if not Assigned(D) then Exit;
   D.OnClick     := FDClick;
   D.OnDblClick  := FDDblClick;
   D.OnMouseDown := FDMouseDown;
   D.OnMouseMove := FDMouseMove;
   D.OnMouseUp   := FDMouseUp;
   D.OnSelect    := FDSelect;
   D.OnDeselect  := FDDeselect;
end;

procedure TDigiStack.Validate;
var tc: TColor;
begin

 tc := Self.Color;
 Self.Color := Self.BkColor;
 Self.BkColor := tc;

 Changed;

 tc := Self.Color;
 Self.Color := Self.BkColor;
 Self.BkColor := tc;

 OnUpdate;
end;

function TDigiStack.GetItemIndex: Integer;
begin Result := FDL.ItemIndex; end;

procedure TDigiStack.SetItemIndex(const Value: Integer);
begin FDL.ItemIndex := Value; end;

procedure TDigiStack.SetSelItem(const Value: TDigiBox);
begin
  if Value = nil then ItemIndex := -1 else
  ItemIndex := IndexOf(Value);
end;

function TDigiStack.GetSelItem: TDigiBox;
begin
  if (0 <= ItemIndex) then
     Result := Objs[ItemIndex]
  else Result := nil;
end;

procedure TDigiStack.Sort;
begin
  if not Boolean(Count) then Exit;
  FDL.SortNumbers(Dir);
  Invalidate;
  OnUpdate;
end;

function TDigiStack.GetB;
begin
  Result := TStrSt(FDL).SBits[Index];
end;

procedure TDigiStack.SetB;
begin
  TStrSt(FDL).SBits[Index] := Value;
end;

procedure TDigiStack.OnUpdate;
begin
end;

procedure TDigiStack.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TDigiStack.GetObjs(Index: Integer): TDigiBox;
var i: Integer;
begin
  i := SyncObjs;
  if Index < 0 then inc(Index, i);
  if (Index<0)or(i<Index) then Result := nil
  else Result := Components[Index] as TDigiBox;
end;

function TDigiStack.SyncObjs: integer;
begin
  if Synchronized then SetObjCount(Count);
  Result := GetObjCount;
end;

function TDigiStack.GetObjCount: Integer;
begin
   Result := ComponentCount;
end;

procedure TDigiStack.SetObjCount(Value: Integer);
var i: Integer;
    D: TDigiBox;
begin
   i := GetObjCount;
   if i = Value then Exit;
   while i > Value do begin
     dec(i);
     D := Components[i] as TDigiBox;
     D.List := nil; // De prisos, deoarece se elimina aici!
     if D.Owner <> nil then D.Owner.RemoveComponent(D);
     D.Free;
   end;
   while Value > i do begin
     D := TDigiBox.Create(Self, FDL, i);
     D.BoundsRect := ItemRect(i);
     AspectToItem(D);
     DAttachEvents(D);
     D.Parent := Self;
     i := GetObjCount;
   end;
end;

procedure TDigiStack.Update;
var i: integer;
    d: TDigiBox;
begin
  if Synchronized then
  begin
    i := SyncObjs;
    while i > 0 do begin
      dec(i);
      d := Objs[i];
      if Assigned(d) and d.Changed then d.Invalidate;
    end;
  end;
  inherited Update;
end;

procedure TDigiStack.Paint;
begin
  ReAlign;
  inherited Paint;
end;

procedure TDigiStack.SetSleepCount(const Value: Integer);
begin
  FSleepCount := Value;
end;

procedure TDigiStack.TrySleep(NoSleep: Boolean);
begin
  if not NoSleep then DoSleep(nil);
end;

procedure TDigiStack.DoSleep;
var s: integer;
begin
  if Boolean(FSleepCount) then begin
    if Assigned(FScrollBar) then begin
       with FScrollBar do
         s := Round(FSleepCount * Position/(Max-Min))
    end else
       s := FSleepCount ;
    if s > 0 then Sleep(s);
  end;  
end;

// Aceasta procedura de regula se keama dintr-un fir de executie secundar
procedure TDigiStack.DLChanged(Sender: TObject);
begin
   if Assigned(FOnChange) then TThread.Synchronize(nil, Changed);
   if Synchronized then
   begin
      TThread.Synchronize(nil, Update);
   end;
   TrySleep(is_main_thread);
end;

procedure TDigiStack.Deselect(Sender: TObject);
var ii: integer;
begin
  if not Assigned(Sender) or
     not (Sender is TStrStack) then Exit;
  ii := TStrStack(Sender).ItemIndex ;
  if ii >= 0 then TDigiBox(Objs[ii]).Selected := false;
end;

procedure TDigiStack.Select(Sender: TObject);
var ii: integer;
begin
  if not Assigned(Sender) or
     not (Sender is TStrStack) then Exit;
  ii := TStrStack(Sender).ItemIndex ;
  if ii >= 0 then TDigiBox(Objs[ii]).Selected := true;
end;

function TDigiStack.Pop: boolean;
begin
   Result := Stack.Count >= 0;
   if Result then Stack.Pop;
end;

function TDigiStack.Push(Txt: String): TDigiBox;
begin
   FDL.Push(Txt);
   Result := Last;
end;

function TDigiStack.Push(DigiBox: TObject): TDigiBox;
begin
   Result := nil;
   if not (DigiBox is TDigiBox) then Exit;
   FDL.Push(TDigiBox(DigiBox).Text, DigiBox);
   Result := Last;
   Result.Assign(TDigiBox(DigiBox));
end;

function TDigiStack.GetColor: TColor;
begin
  Result := inherited Color;
end;

procedure TDigiStack.BringItemInClient(Idx: Integer);
var oc: integer;
begin
  oc := SyncObjs;
  if Idx < 0 then inc(Idx, oc);
  if (0 <= Idx) and (Idx < oc) then BringItemInClient(Objs[Idx]);
end;

procedure TDigiStack.BringItemInClient(Item: TDigiBox);
begin
  if Item.Top+Item.Height > Height then Item.Top := Height - Item.Height;
  if Item.Left+Item.Width > Width  then Item.Left := Width - Item.Width;

  if Item.Top < 0 then Item.Top := 0;
  if Item.Left < 0 then Item.Left := 0;
end;

procedure TDigiStack.BringItemsInClient;
var i: integer;
begin
  i := SyncObjs;
  while i > 0 do begin
    dec(i);
    BringItemInClient(i);
  end;
end;

procedure TDigiStack.ProcessKeyDown;
begin
 if Shift = [ssAlt] then
 begin
    case Key of
     VK_UP   : if Direction = dsdUpDown then
                  Direction := dsdFree
               else
                  Direction := dsdUpDown ;
     VK_DOWN : Direction := dsdDownUp ;
     VK_LEFT : Direction := dsdLeftRight ;
     VK_RIGHT: Direction := dsdRightLeft ;
     VK_HOME : AutoResize := not AutoResize;
     VK_END  : ClientAnchors := not ClientAnchors;
    end
 end else
 if Shift = [ssCtrl] then
 begin
    case Key of
     VK_UP   : DHeight := DHeight + 1 ;
     VK_DOWN : DHeight := DHeight - 1 ;
     VK_LEFT : DWidth  := DWidth  - 2 ;
     VK_RIGHT: DWidth  := DWidth  + 2 ;
     VK_PRIOR: Interval := Interval + 1;
     VK_NEXT : Interval := Interval - 1;
     188: Space := Space - 1;
     190: Space := Space + 1;

     VK_INSERT: Clipb.AsText := Stack.SelStr;
    end;
 end else
 if Shift = [ssShift, ssCtrl] then begin
    case Key of
     VK_DELETE:
       begin
         Clipb.AsText := Stack.SelStr;
         Delete(SelItem);
       end;
     VK_INSERT:
         if ItemIndex < 0 then
             Push(Clipb.AsText)
         else
             Insert(ItemIndex, Clipb.AsText);
    end;
    Key := 0;
 end else
 if Shift = [] then
 begin
    case Key of
     VK_PRIOR   :
         if Stack.ItemIndex = -1 then Stack.ItemIndex := SyncObjs-1
                                 else Stack.ItemIndex := Stack.ItemIndex-1 ;

     VK_NEXT :
         if Stack.ItemIndex = -1 then Stack.ItemIndex := 0
                                 else Stack.ItemIndex := Stack.ItemIndex+1 ;
    end;
 end;   
end;

function TDigiStack.ReadSettings(Ctrl: TWinControl): integer;
var c: TControl;
begin
  c := FindControl(Ctrl, 'SleepCount'); if c <> nil then SleepCount := OGetInt(c);
  c := FindControl(Ctrl, 'DWidth');     if c <> nil then DWidth := OGetInt(c);
  c := FindControl(Ctrl, 'DHeight');    if c <> nil then DHeight := OGetInt(c);

  c := FindControl(Ctrl, 'Interval');  if c <> nil then Interval := OGetInt(c);
  c := FindControl(Ctrl, 'Space');     if c <> nil then Space := OGetInt(c);
  c := FindControl(Ctrl, 'FontSize');  if c <> nil then Font.Size := OGetInt(c);

  c := FindControl(Ctrl, 'AutoResize'  , TButtonControl);  if c <> nil then AutoResize    := TCheckBox(c).Checked;
  c := FindControl(Ctrl, 'ClientAnch'  , TButtonControl);  if c <> nil then ClientAnchors := TCheckBox(c).Checked;
  c := FindControl(Ctrl, 'Synchronized', TButtonControl);  if c <> nil then Synchronized  := TCheckBox(c).Checked;

  c := FindControl(Ctrl, 'Shape', TCustomCombo);
    if (c <> nil) and (TCustomCombo(c).ItemIndex>=0) then Shape := TShapeType(TCustomCombo(c).ItemIndex);
  c := FindControl(Ctrl, 'Dir', TCustomCombo);
    if (c <> nil) and (TCustomCombo(c).ItemIndex>=0) then Direction := TDigiStackDir(TCustomCombo(c).ItemIndex);
end;

function TDigiStack.ReadSettings(List: TStrings): integer;
var s: String;
begin
  if List = nil then Exit;
  // TColor
  s := List.Values['BkColor'];      if s<>'' then BkColor       := StringToColor(s);
  s := List.Values['TextColor'];    if s<>'' then TextColor     := StringToColor(s);
  s := List.Values['BrColor'];      if s<>'' then BrColor       := StringToColor(s);
  s := List.Values['Color'];        if s<>'' then Color         := StringToColor(s);
  // Integer
  s := List.Values['Interval'];     if s<>'' then Interval      := StrToIntNr(s);  
  s := List.Values['Space'];        if s<>'' then Space         := StrToIntNr(s);  
  s := List.Values['DHeight'];      if s<>'' then DHeight       := StrToIntNr(s);  
  s := List.Values['DWidth'];       if s<>'' then DWidth        := StrToIntNr(s);  
  s := List.Values['FontSize'];     if s<>'' then Font.Size     := StrToIntNr(s);  
  s := List.Values['SleepCount'];   if s<>'' then SleepCount    := StrToIntNr(s);  
  // Boolean
  s := List.Values['AutoResize'];   if s<>'' then AutoResize    := StrToBool(StrGetInt(s));
  s := List.Values['ClientAnchors'];if s<>'' then ClientAnchors := StrToBool(StrGetInt(s));
  s := List.Values['Synchronized']; if s<>'' then Synchronized  := StrToBool(StrGetInt(s));
  // Special
  s := List.Values['Shape'];        if s<>'' then Shape         := TShapeType(StrToIntNr(s));
  s := List.Values['Direction'];    if s<>'' then Direction     := TDigiStackDir(StrToIntNr(s));
end;

function TDigiStack.WriteSettings(Ctrl: TWinControl): integer;
var c: TControl;
begin
  c := FindControl(Ctrl, 'SleepCount'); if c <> nil then PutText(c, IntToStr(SleepCount));
  c := FindControl(Ctrl, 'DWidth');     if c <> nil then PutText(c, IntToStr(DWidth));
  c := FindControl(Ctrl, 'DHeight');    if c <> nil then PutText(c, IntToStr(DHeight));

  c := FindControl(Ctrl, 'Interval');  if c <> nil then PutText(c, IntToStr(Interval));
  c := FindControl(Ctrl, 'Space');     if c <> nil then PutText(c, IntToStr(Space));
  c := FindControl(Ctrl, 'FontSize');  if c <> nil then PutText(c, IntToStr(Font.Size));

  c := FindControl(Ctrl, 'AutoResize'  , TButtonControl);  if c <> nil then TCheckBox(c).Checked := AutoResize    ;
  c := FindControl(Ctrl, 'ClientAnch'  , TButtonControl);  if c <> nil then TCheckBox(c).Checked := ClientAnchors ;
  c := FindControl(Ctrl, 'Synchronized', TButtonControl);  if c <> nil then TCheckBox(c).Checked := Synchronized  ;

  c := FindControl(Ctrl, 'Shape', TCustomCombo);  if (c <> nil) then TCustomCombo(c).ItemIndex := Integer(Shape);
  c := FindControl(Ctrl, 'Dir', TCustomCombo);    if (c <> nil) then TCustomCombo(c).ItemIndex := Integer(Direction);
end;


function TDigiStack.WriteSettings(List: TStrings): integer;
var s: String;
begin
  if List = nil then Exit;
  // TColor
  List.Values['BkColor']       := ColorToString(BkColor  ) ;
  List.Values['TextColor']     := ColorToString(TextColor) ;
  List.Values['BrColor']       := ColorToString(BrColor  ) ;
  List.Values['Color']         := ColorToString(Color    ) ;
  // Integer                                                                      
  List.Values['Interval']      := IntToStr(Interval  ) ;  
  List.Values['Space']         := IntToStr(Space     ) ;  
  List.Values['DHeight']       := IntToStr(DHeight   ) ;  
  List.Values['DWidth']        := IntToStr(DWidth    ) ;  
  List.Values['FontSize']      := IntToStr(Font.Size ) ;  
  List.Values['SleepCount']    := IntToStr(SleepCount) ;  
  // Boolean                                                                      
  List.Values['AutoResize']    := BoolToStr(AutoResize   ) ;
  List.Values['ClientAnchors'] := BoolToStr(ClientAnchors) ;
  List.Values['Synchronized']  := BoolToStr(Synchronized ) ;
  // Special                                                                      
  List.Values['Shape']         := IntToStr(word(Shape));
  List.Values['Direction']     := IntToStr(word(Direction));
end;

initialization
  Clipb := TClipboard.Create;

finalization
  Clipb.Free;
  
end.
       
     
       
         

      
         
       
        
      
    

    
 
     
  

         
     
