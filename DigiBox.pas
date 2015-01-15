{****************************************************
 * Author  : Dumitru Uzun (DUzun)
 * Web     : http://duzun.teologie.net
 * Created : 03.05.2009
 *
 *  TDigiBox asemanator cu un TShape, numai ca poate
 * contine un numar/text.
 *
 *
 * Istorie:
 * 03.01.2010 - CreateParented
 * 04.01.2010 - Text / Value / DigiInt; AutoRedraw, AutoResize
 * 22.01.2010 - HTML
 * 23.01.2010 - Assign
 *
 ****************************************************}
unit DigiBox;
{$M+}
interface
uses
  Windows, SysUtils, Graphics, Controls, ExtCtrls, Classes,
  Interfata;
(*------------------------------------------------------------------------*)
type
  DigiBoxConst = (dbcChanged, dbcSelectedState, dbcSelected, dbcAutoResize);

  TDigiBox = class(TImage)
  private
    FText:  String;
    FList:  TStrings;
    FIndex: Integer;

    FShape: TShapeType;
    FSpace: Integer;
    Fb: DWORD;
    FLock: TRTLCriticalSection;
    FOnSelect, FOnDeselect: TNotifyEvent;

    function  GetText: String;
    function  GetDigit: Extended;
    function  GetDigitInt: Integer;

    procedure SetText(const Value: String);
    procedure SetDigit(const Value: Extended);
    procedure SetDigitInt(const Value: Integer);

    procedure SetSpace(const Value: Integer);
    procedure SetShape(const Value: TShapeType);

    function  GetGrColor(Index: Integer): TColor;
    procedure SetGrColor(Index: Integer; const Value: TColor);

    function  GetBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
    function  GetFont: TFont;

    function  GetB(Index: Integer): Boolean;
    procedure SetB(Index: Integer; const Value: Boolean);
    function  SetBCh(Index: Integer; const Value: Boolean): Boolean;

    function  GetChanged(const Index: Integer): Boolean;
    procedure SetChanged(const Index: Integer; const Value: Boolean);

    procedure SetIndex(const Value: Integer);
    procedure SetSelected(Index: Integer; const Value: Boolean);
    procedure SetSelectedState(const Index: Integer; const Value: Boolean);
    procedure SetAutoResize(const Index: Integer; const Value: Boolean);

  protected
    property  Bits[Index: Integer]: Boolean read GetB write SetB;
    procedure AdaptSize;

  public
    procedure Drow;
    procedure Paint; override;  // Used by Win for drowing the Control
    
    property DigiInt: Integer  read GetDigitInt write SetDigitInt default 0;
    function HTML(Attr: string=''): String;

    procedure SetAspect(ASpace: Word=0; AShape: TShapeType = stRoundRect; ATextColor: TColor=clBlack; ABkColor: TColor=clWhite; ABrColor: TColor=clBlack); overload;
    procedure SetAspect(ADigiBox: TDigiBox); overload;

    procedure SetColors(ATextColor, ABkColor, ABrColor: TColor); overload;
    procedure SetColors(ADigiBox: TDigiBox); overload;

    procedure Assign(Source: TPersistent); override;

    // Comparatia
    function    Comp(s: Extended): ShortInt;     overload;
    function    Comp(s: String)  : ShortInt;     overload;
    function    Comp(s: TDigiBox): ShortInt;     overload;
    function    CompStr(s: String)  : ShortInt;  overload;
    function    CompStr(s: Extended): ShortInt;  overload;
    function    CompStr(s: TDigiBox): ShortInt;  overload;

    // Constructori
    constructor Create(AOwner: TComponent); overload; override; 
    constructor Create(AOwner: TComponent; ADigitStr: String);   overload;
    constructor Create(AOwner: TComponent; ADigit   : Extended); overload;
    constructor Create(ADigiBox: TDigiBox);                      overload;
    constructor Create(AOwner: TComponent; AList: TStrings; AIndex: Integer); overload;
    constructor CreateParented(ParentWindow: TWinControl; ADigitStr: String); overload;
    destructor  Destroy; override;
    
    procedure Lock;
    procedure UnLock;

    procedure FreeMe;

    property Changed: Boolean index dbcChanged read GetChanged write SetChanged default false;
    property SelectedState: Boolean index dbcSelectedState read GetB write SetSelectedState nodefault;

  published
    property Selected:   Boolean index dbcSelected   read GetB write SetSelected   default false;
    property AutoResize: Boolean index dbcAutoResize read GetB write SetAutoResize default true;

    property List: TStrings read FList write FList;
    property Index: Integer read FIndex write SetIndex;

    property Bitmap: TBitmap  read GetBitmap write SetBitmap;
    property Font  : TFont    read GetFont ;
    property Text  : String   read GetText  write SetText;
    property Value : Extended read GetDigit write SetDigit;

    property Shape    : TShapeType read FShape       write SetShape     default stRoundRect;
    property Space    : integer        read FSpace     write SetSpace  default 5;
    property TextColor: TColor index 0 read GetGrColor write SetGrColor nodefault;
    property BkColor  : TColor index 1 read GetGrColor write SetGrColor nodefault;
    property BrColor  : TColor index 2 read GetGrColor write SetGrColor nodefault;
    property TransparentColor: TColor index 3 read GetGrColor write SetGrColor nodefault;
    property Transparent default true;

    property OnSelect  : TNotifyEvent  read FOnSelect   write FOnSelect;
    property OnDeselect: TNotifyEvent  read FOnDeselect write FOnDeselect;
  end;

  TDigiBoxList = array of TDigiBox;

(*------------------------------------------------------------------------*)
  function FindDigi(d: TDigiBox; var List: TDigiBoxList): integer;      // Find s in the list
  function AddDigi(d: TDigiBox; var List: TDigiBoxList): integer;       // Add d to the end of List
  function AddUniqueDigi(d: TDigiBox; var List: TDigiBoxList): integer; // Add d to the end of List
  function DeleteDigi(d: TDigiBox; var List: TDigiBoxList): integer;    // Delete d from the the List
  function Comp(a, b: TDigiBox): Integer;                              // Compare a with b
  function CompI(a, b: TDigiBox): Integer;                             // Compare b with a
(*------------------------------------------------------------------------*)
procedure Register;

implementation

procedure Register; begin RegisterComponents('DUzuns', [TDigiBox]); end;

(*------------------------------------------------------------------------*)
function FindDigi(d: TDigiBox; var List: TDigiBoxList): integer;
var l: integer;
begin
   l := Length(List);
   Result := 0;
   while Result < l do
     if List[Result] = d then Exit
                         else inc(Result);
   Result := -1;
end;
(*------------------------------------------------------------------------*)
function AddDigi(d: TDigiBox; var List: TDigiBoxList): integer; // Add d to the end of List
begin
  Result := Length(List);
  SetLength(List, Result+1);
  List[Result] := d;
end;
(*------------------------------------------------------------------------*)
function AddUniqueDigi(d: TDigiBox; var List: TDigiBoxList): integer; // Add d to the end of List
begin
  Result := FindDigi(d, List);
  if Result = -1 then
    Result := AddDigi(d, List);
end;
(*------------------------------------------------------------------------*)
function DeleteDigi(d: TDigiBox; var List: TDigiBoxList): integer;
var i, j: integer;
begin
  Result := Length(List);
  i := 0;
  while (i < Result) and (List[i] <> d) do inc(i);
  j := i;
  while (i < Result) do begin
    if List[i] <> d then begin
      List[j] := List[i];
      inc(j);
    end;
    inc(i);
  end;
  Result := j;
  SetLength(List, Result);
end;
(*------------------------------------------------------------------------*)
function Comp (a, b: TDigiBox): Integer; begin Result := a.Comp(b); end;
function CompI(a, b: TDigiBox): Integer; begin Result := b.Comp(a); end;
(*------------------------------------------------------------------------*)

{ TDigiBox }
constructor TDigiBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitializeCriticalSection(FLock);
  Fb := 0;  // Selected, SelectedState, AutoResize, Changed = false
  FShape := stRoundRect;
  FSpace := 5;
  FText := ' ';
  FList := nil;
  FIndex := -1;
  AutoResize := true;
  Transparent := true;
  with Canvas do begin
    Font.Color  := Graphics.clHotLight;  // TextColor
    Brush.Color := Graphics.clGradientInactiveCaption;  // BkColor
    Pen.Color   := Graphics.clSkyBlue; // BrColor
  end;
  Changed := true;
end;

constructor TDigiBox.Create(ADigiBox: TDigiBox);
begin
  if not Assigned(ADigiBox) then raise Exception.Create('TDigiBox.Create error:'#10' ADigiBox(nil) passed');
  Create(ADigiBox.Owner);
  SetAspect(ADigiBox);
  FText := ADigiBox.FText;
  Fb := ADigiBox.Fb;
  Font.Assign(ADigiBox.Font);
end;

constructor TDigiBox.Create(AOwner: TComponent; ADigitStr: String);
begin
  Create(AOwner);
  FText := ADigitStr;
end;

constructor TDigiBox.Create(AOwner: TComponent; ADigit: Extended);
begin Create(AOwner, FloatToStr(ADigit)); end;

constructor TDigiBox.Create(AOwner: TComponent; AList: TStrings; AIndex: Integer);
begin
  Create(AOwner);
  FList := AList;
  Index := AIndex; 
end;

constructor TDigiBox.CreateParented(ParentWindow: TWinControl; ADigitStr: String);
begin
   Create(ParentWindow.Owner, ADigitStr);
   Parent := ParentWindow;
end;

destructor TDigiBox.Destroy;
begin
   Lock; try
     FText := '';
     FList := nil;
     inherited;
   finally
     Unlock;
     DeleteCriticalSection(FLock);
   end;
end;

procedure TDigiBox.Assign(Source: TPersistent);
var d: TDigiBox;
begin
  if Source = Self then Exit;
//  inherited Assign(Source);
  if Assigned(Source) and (Source is TDigiBox) then begin
    d := TDigiBox(Source);
    Text := d.Text;
    Fb := d.Fb;
    Font.Assign(d.Font);
    SetAspect(d);
    Top := d.Top;
    Left := d.Left;
    Selected := false;
  end else Text := '';
end;

procedure TDigiBox.AdaptSize;
var w, h, r: integer;
    cl: TColor;
begin
  {Obtinem dimensiunile numarului din DigiBox}
  w := Canvas.TextWidth(Text);
  h := Canvas.TextHeight(Text);

  {Pentru figurile cu dimensiuni patrate}
  if Shape in [stCircle, stSquare, stRoundSquare] then
     if h > w then w := h else h := w;

  {Daca dimensiunile imaginii nu sunt potrivite pentru numar, corectam situatia}
  r := 2*Space;
  if r < 0 then r := 0;
  inc(h, r);
  inc(w, r);
  
  cl := Bitmap.TransparentColor;
  if h <> Height then Height := h ;
  if w <> Width  then Width  := w ;
  Bitmap.TransparentColor := cl;
end;

procedure TDigiBox.Drow;
var r, w, h: integer;
    cl: TColor;
    b: TBitmap;
begin
  if AutoResize then AdaptSize;

  b := Bitmap;
  if (b.Width <> Width) or (b.Height <> Height) then begin
      b.Width  := Width;
      b.Height := Height;
  end;

  {Curatim Imaginea}
  Canvas.Lock;
  with Canvas do try

    SelectedState := true;

    cl := Brush.Color;
    Brush.Color := Bitmap.TransparentColor;
    FillRect(ClipRect);
    Brush.Color := cl;

  {Alegem si desenam cutia in jurul cifrei}
    if Width > Height then r := Width else r := Height;
    case Shape of
      stRectangle:   Rectangle(0, 0, Width, Height);
      stRoundRect:   RoundRect(0, 0, Width, Height, Width shr 1, Height shr 1);
      stEllipse:     Ellipse  (0, 0, Width, Height);
      stSquare:      Rectangle(0, 0, r, r);
      stRoundSquare: RoundRect(0, 0, r, r, r shr 1, r shr 1);
      stCircle:      Ellipse  (0, 0, r, r);
    end;

  {Desenam continutul in cutie}
    w := TextWidth (Text);
    h := TextHeight(FText);
    TextOut((Width-w)div 2, (Height-h)div 2, FText);

    SelectedState := false;
    
  finally Canvas.Unlock end; // Canvas
  Changed := false;
end;

procedure TDigiBox.Paint;
begin
  if (FList <> nil) then
     Visible := (0 <= FIndex) and (FIndex < FList.Count);
  if not Visible then Exit;

  if Changed or
     (Bitmap.Width <> Width) or
     (Picture.Bitmap.Height <> Height)
     then Drow;

  inherited Paint;
end;
(*------------------------------------------------------------------------*)
function  TDigiBox.GetDigit;     begin Result := StrToNr(Text);    end;
procedure TDigiBox.SetDigit;     begin Text   := FloatToStr(Value);    end;
function  TDigiBox.GetDigitInt;  begin Result := StrToIntNr(Text); end;
procedure TDigiBox.SetDigitInt;  begin Text   := IntToStr(Value);      end;
(*------------------------------------------------------------------------*)
function TDigiBox.GetText: String;
begin
  if FList = nil then Result := FText else begin
    if (0 <= FIndex) and (FIndex < FList.Count) then
      Result := FList.Strings[FIndex]
    else
      Result := '';
    if Result = FText then Exit;
    Lock; try
      FText := Result;
      Changed := true;
    finally Unlock end;
  end;
end;

procedure TDigiBox.SetText(const Value: String);
begin
  if(FList <> nil)and(0 <= FIndex)and(FIndex < FList.Count)then begin
    Lock; try
    FList.Strings[FIndex] := Value;
    finally Unlock end;
  end;
  if FText = Value then Exit;
  Lock; try
    FText := Value;
    Changed := true;
  finally Unlock end;
end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.SetIndex(const Value: Integer);
begin
  if FIndex = Value then Exit;
  if (Hint = '') or (Hint = IntToStr(FIndex)) then Hint := IntToStr(Value);
  FIndex := Value;
  Changed := true;
end;
(*------------------------------------------------------------------------*)
function TDigiBox.GetChanged(const Index: Integer): Boolean;
begin
  Result := GetB(Index);
  if Result or (FList = nil) then Exit;
  if (0 <= FIndex) and (FIndex < FList.Count) then
    Result := FText <> FList.Strings[FIndex];
  Changed := Result;
end;

procedure TDigiBox.SetChanged(const Index: Integer; const Value: Boolean);
begin
  if SetBCh(Index, Value) and Value then Invalidate; // Do nothing, just wait for repaint
end;
(*------------------------------------------------------------------------*)
function  TDigiBox.GetB;
begin
   Result := Boolean(Fb and (1 shl Index) <> 0);
end;

procedure TDigiBox.SetB;
begin
  SetBCh(Index, Value);
end;

function  TDigiBox.SetBCh(Index: Integer; const Value: Boolean): Boolean;
begin
  Result := GetB(Index) <> Value;
  if not Result then Exit;
  Lock; try
    Fb := Fb xor (1 shl Index);
  finally Unlock end;
end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.SetSelectedState(const Index: Integer; const Value: Boolean);
begin
  if SelectedState = Value then Exit;     // Check
  if not Selected and Value then Exit;
  Lock; try
    if not SetBCh(Index, Value) then Exit;// Recheck
    Canvas.Lock; try
       Canvas.Brush.Color := RGBColor(Canvas.Brush.Color) xor RGBColor(Canvas.Pen.Color);
       Canvas.Font.Color  := RGBColor(Canvas.Font.Color)  xor RGBColor(Canvas.Pen.Color);
    finally Canvas.UnLock end;
  finally Unlock end;
end;

procedure TDigiBox.SetSelected;
begin
  if SetBCh(Index, Value) then begin
     Changed := true;
     if Value then begin
       if Assigned(FOnSelect)   then FOnSelect(Self);
     end else
       if Assigned(FOnDeselect) then FOnDeselect(Self);
  end;
end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.SetShape(const Value: TShapeType);
begin
  if Value = FShape then Exit;
  Lock; try
    FShape := Value;
    Changed := true;
  finally Unlock end;
end;

procedure TDigiBox.SetSpace;
begin
  if Value = FSpace then Exit;
  Lock; try
    FSpace := Value;
    Changed := true;
  finally Unlock end;
end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.SetGrColor;
var ss: boolean;
begin
   if (Picture.Graphic<>nil) and (GetGrColor(Index)=Value) then Exit;
//   GetBitmap; // Creates the Bitmap, if missing
   Canvas.Lock; try
     ss := SelectedState;
     SelectedState := false;
     with Canvas do case Index of
       0: Font.Color  := Value;
       1: Brush.Color := Value;
       2: Pen.Color   := Value;
       3: Bitmap.TransparentColor := Value;
     end;
     Changed := true;
     SelectedState := ss;
   finally Canvas.Unlock end;
end;
(*------------------------------------------------------------------------*)
function TDigiBox.GetGrColor;
begin
//  GetBitmap; // Can't use Canvas without Graphic. GetBitmap creates a Graphic.
  with Canvas do case Index of
   0: Result := Font.Color;
   1: Result := Brush.Color;
   2: Result := Pen.Color;
   3: Result := Bitmap.TransparentColor;
  end;
end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.SetColors(ATextColor, ABkColor, ABrColor: TColor);
begin
  Canvas.Lock;
  try
  SelectedState := false;
  with Canvas do begin
    Font.Color := ATextColor;
    Brush.Color := ABkColor;
    Pen.Color := ABrColor;
  end;
  finally Canvas.Unlock end;
  Changed := true;
end;
procedure TDigiBox.SetColors(ADigiBox: TDigiBox); begin if Assigned(ADigiBox) then with ADigiBox do Self.SetColors(TextColor, BkColor, Color); end;

procedure TDigiBox.SetAspect(ASpace: Word=0; AShape: TShapeType = stRoundRect; ATextColor: TColor=clBlack; ABkColor: TColor=clWhite; ABrColor: TColor=clBlack);
begin
  Lock; try
    FSpace    := ASpace;
    FShape    := AShape;
    SetColors(ATextColor, ABkColor, ABrColor);
  finally Unlock end;
end;

procedure TDigiBox.SetAspect(ADigiBox: TDigiBox);
begin
   if not Assigned(ADigiBox) then Exit;
   with ADigiBox do
     Self.SetAspect(FSpace, Shape, TextColor, BkColor, BrColor);
   Self.BoundsRect := ADigiBox.BoundsRect;
end;
(*------------------------------------------------------------------------*)
function TDigiBox.GetBitmap;
var b: TBitmap;
begin
  {Verificam prezenta componentelor necesare pentru desenarea imaginii}
  if Picture.Graphic = nil then begin
    b := TBitmap.Create;
    try
      b.Width  := Picture.Width;
      b.Height := Picture.Height;
      SetBitmap(b); // makes a copy of b
    finally
      b.Free
    end;
  end;
  Result := Picture.Bitmap;
end;

procedure TDigiBox.SetBitmap(const Value: TBitmap);
begin Picture.Graphic := Value; end;

function TDigiBox.GetFont: TFont; begin Result := Canvas.Font; end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.Lock;
begin
   EnterCriticalSection(FLock);
end;

procedure TDigiBox.UnLock;
begin
   LeaveCriticalSection(FLock);
end;
(*------------------------------------------------------------------------*)

function TDigiBox.Comp(s: Extended): ShortInt;
begin
   if Value < s then Result := -1 else
   if Value > s then Result :=  1 else
                     Result :=  0;
end;

function TDigiBox.CompStr(s: String): ShortInt;
begin
   if Text < s then Result := -1 else
   if Text > s then Result :=  1 else
                    Result :=  0;
end;

function TDigiBox.Comp(s: TDigiBox): ShortInt;    begin Result := Comp(s.Value); end;
function TDigiBox.CompStr(s: TDigiBox): ShortInt; begin Result := CompStr(s.Text); end;
function TDigiBox.Comp(s: String): ShortInt;      begin Result := Comp(StrToNr(s)); end;
function TDigiBox.CompStr(s: Extended): ShortInt; begin Result := CompStr(FloatToStr(s)); end;
(*------------------------------------------------------------------------*)
procedure TDigiBox.FreeMe;
begin
  if Self = nil then Exit;
//    Parent := nil;
  if Owner <> nil then Owner.RemoveComponent(Self);
  Free;
end;
(*------------------------------------------------------------------------*)
function TDigiBox.HTML;
var lst: TStringList;
begin
  Result := '';
  lst := TStringList.Create;
  with lst do try
    Delimiter := ' ';
    QuoteChar := '"';
    DelimitedText := Attr;

    Values['style'] := UnifyNameValues([ ControlToCSS(Self),
                                         CanvasToCSS(Canvas, true),
                                         'vertical-align:middle;text-align:center;display:table-cell;',
                                         Values['style'] ],
                                         ':', ';');

    if Self.Name <> '' then Values['id'] := Self.Name;
    if Self.Hint <> '' then Values['title'] := Self.Hint;

    QuoteNVValues(lst);
    Result := '<div '+lst.Text+'>'+Self.Text+'</div>'+sLineBreak;
  finally lst.Free end;
end;

procedure TDigiBox.SetAutoResize(const Index: Integer; const Value: Boolean);
begin
  if SetBCh(Index, Value) and Value then Changed := true;
end;

initialization
//InitializeCriticalSection(DigiBoxLock);

finalization
//DeleteCriticalSection(DigiBoxLock);

end.

