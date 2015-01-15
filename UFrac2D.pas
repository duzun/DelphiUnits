Unit UFrac2D;

interface
uses Graphics, ExtCtrls, UGraph, Classes, Types;

type
   FracNumber  = Extended;
   RealRect    = array[1..4] of Extended; {x_min, y_min, x_max, y_max}
   PRealRect   = ^RealRect;
   TFrac2DPixF = function (x, y: FracNumber; iterations: byte): byte;
//   TByteDynArray   = array of Byte;
   TByteGrid   = array of String;
   TMJFlip     = (mjFlipVert, mjFlipHoriz, mjProportional, mjFracChanged, mjAutoCalc);

  TFrac2D = class(TComponent)
  private
    FGrid    : TByteGrid ;
    Fb       : TBits       ;
    FFracPixF: TFrac2DPixF ; // Functia de calculare a Fractalului
    FB2CF    : TByte2ColorF; // Functia de convertire a numarului in culoare
    FMaxIter : Integer     ; // Numarul de iteratii
    FDrawMode: TDrawMode   ; // Modul de suprapunere cu Bitmap
    FUpdateCount: word;
    FUpdateCountFr: word;
    FRatio   : Real        ;    {Fractal's Width / Height}
    X1, Y1, X2, Y2: FracNumber; {Fractal Box}
    FOnChangeFr: TNotifyEvent;
    FOnCalcFr: TNotifyEvent;
    FOnChange: TNotifyEvent;
    function  GetB    (Index: integer                          ): Boolean;
    procedure SetB    (Index: integer; const Value: Boolean    );
    function  GetProp (const idx: integer                      ): Boolean;
    procedure SetProp (const idx: integer; const Value: Boolean);
    function  GetFrame: RealRect;
    procedure SetFrame(const Value: RealRect                   );
    procedure SetX1(const Value: FracNumber);
    procedure SetX2(const Value: FracNumber);
    procedure SetY1(const Value: FracNumber);
    procedure SetY2(const Value: FracNumber);
    function  GetHeight: integer;
    function  GetWidth : integer;
    procedure SetHeight(const Value: integer);
    procedure SetWidth (const Value: integer);
    procedure SetB2CF(const Value: TByte2ColorF);
    procedure SetFracPixF(const Value: TFrac2DPixF);
    procedure SetFracChanged(const Index: Integer; const Value: Boolean);
    procedure SetRatio(const Value: Real);
    procedure SetAutoCalcFr(const Index: Integer; const Value: Boolean);
    procedure SetDrawMode(const Value: TDrawMode);
    procedure SetMaxIter(const Value: Integer);

  protected
    property FrChgd: Boolean index mjFracChanged read GetB write SetFracChanged default false;
    property SBits[Index: Integer]: Boolean read GetB write SetB;
    procedure ChangedFr;
    procedure Changed;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure BeginFracUpdate;
    function  EndFracUpdate: boolean;
    procedure BeginUpdate;
    function  EndUpdate: boolean;

    procedure   Calc;
    function    DrawTo(Bmp: TBitmap; x: integer = 0; y: integer = 0): TBitmap; overload;
    function    DrawTo(Bmp: TBitmap; x, y: integer; dm: TDrawMode): TBitmap;   overload;

    property    Frame: RealRect read GetFrame write SetFrame;
    property    FracFunc: TFrac2DPixF  read FFracPixF write SetFracPixF;
    property    Byte2ColorFunc: TByte2ColorF  read FB2CF write SetB2CF;
    property    FracChanged: Boolean index mjFracChanged read GetB;

  published
    property Height : integer  read GetHeight write SetHeight;
    property Width  : integer  read GetWidth  write SetWidth ;
    property MaxIter: Integer  read FMaxIter  write SetMaxIter default 100;
    property DrawMode: TDrawMode read FDrawMode write SetDrawMode default dNIL;
    property x_min: FracNumber read X1 write SetX1;
    property y_min: FracNumber read Y1 write SetY1;
    property x_max: FracNumber read X2 write SetX2;
    property y_max: FracNumber read Y2 write SetY2;
    property AutoCalcFr: Boolean index mjAutoCalc    read GetB    write SetAutoCalcFr    default false;
    property FlipVertically  : Boolean index mjFlipVert     read GetB    write SetB    default false;
    property FlipHorizontally: Boolean index mjFlipHoriz    read GetB    write SetB    default false;
    property FrameProp       : Boolean index mjProportional read GetProp write SetProp default true;
    property Ratio           : Real                         read FRatio  write SetRatio;

    property OnChangeFr: TNotifyEvent read FOnChangeFr write FOnChangeFr;
    property OnChange  : TNotifyEvent read FOnChange write FOnChange;
    property OnCalcFr: TNotifyEvent read FOnCalcFr write FOnCalcFr;
  end;

var ca, cb: FracNumber;

const
   ManRect: RealRect = (-1.8, -1.3, 1.0, 1.3);
   JulRect: RealRect = (-1.3, -1.8, 1.3, 1.8);

function MandelbrotPix(a, b: FracNumber; k: byte): byte;
function JuliaPix(x, y: FracNumber; k: byte): byte;

procedure Register;

implementation

uses Controls;
{-----------------------------------------------------------------}
procedure Register; begin RegisterComponents('DUzuns', [TFrac2D]); end;
{-----------------------------------------------------------------}
function MandelbrotPix(a, b: FracNumber; k: byte): byte;
var xy, x2,y2, x,y: FracNumber;
    r: FracNumber;
begin
   r := 0;
   Result := k;
   x := ca; y := cb;
   while (Result>0)and(r<4) do begin
      x2 := x*x;
      y2 := y*y;
      xy := x*y;

      x := x2 - y2 + a;   { x` = x^2 - y^2 + a }
      y :=  2 * xy + b;   { y` = 2*xy + b      }

      r := x2+y2;
      dec(Result)
   end;
   Result := Result * $FE div k;
end;
{-----------------------------------------------------------------}
function JuliaPix(x, y: FracNumber; k: byte): byte;
var xy, x2,y2: FracNumber;
    r: FracNumber;
begin
   r := 0;
   Result := k;
   while (Result>0)and(r<4) do begin
      {Z1 := Z0^2 + C}
      x2 := x*x;
      y2 := y*y;
      xy := x*y;

      x := x2 - y2 - 0.55;   { x` = x^2 - y^2 + a }
      y :=  2 * xy - 0.55;   { y` = 2*xy + b      }

      r := x2+y2;
      dec(Result)
   end;
   Result := Result * $FE div k;
end;
{-----------------------------------------------------------------}
{ TFrac2D }

constructor TFrac2D.Create(AOwner: TComponent);
begin
  inherited;
  FOnChangeFr  := nil;
  FOnCalcFr    := nil;
  FOnChange    := nil;
  FGrid        := nil;
  FUpdateCount := 0;
  FFracPixF    := @MandelbrotPix; // Functia pentru calcularea fractalului
  FB2CF        := @GradientB2C;   // Functia pentru transpunerea in imagine a fractalului calculat
  Fb           := TBits.Create;
  Ratio        := 1;
  FrameProp    := true;
  FMaxIter     := 100;
  FDrawMode    := dATTRIB;
  Frame        := ManRect;
  FrChgd  := true;
end;
{-----------------------------------------------------------------}
destructor TFrac2D.Destroy;
begin
  Fb.Free;  
  inherited;
end;

function TFrac2D.GetB;
begin
  Result := (Index<Fb.Size) and Fb[Index];
end;

procedure TFrac2D.SetB;
var res: boolean;
begin
  res := Fb.Size <= Index; // Resize required
  if res and not Value or not res and (Value=Fb[Index]) then Exit;
  if res then Fb.Size := Index+1;
  Fb[Index] := Value;
end;

procedure TFrac2D.Calc;
var hx,hy, x,y: FracNumber;
    w, h, i: Integer;
    P: ^String;
begin
   Assert(Assigned(FFracPixF));

   h := Height;
   w := Width;
   hx := (x2-x1) / w;
   hy := (y1-y2) / h;

   y  := y2;
   while(h > 0) do begin
      dec(h);
      x := x1;
      P := @FGrid[h];
      w := Length(P^);
      i := 1;
      while i <= w do begin
        P^[i] := Char(FFracPixF(x,y, MaxIter));
        x := x + hx;
        inc(i);
      end;
      y := y + hy;
   end;
   FrChgd := false;
   if Assigned(FOnCalcFr) then FOnCalcFr(Self);
end;
{-----------------------------------------------------------------}
procedure TFrac2D.SetAutoCalcFr(const Index: Integer;
  const Value: Boolean);
begin
  if Value = GetB(Index) then Exit;
  SetB(Index, Value);
  if Value and FrChgd then Calc;
end;
{-----------------------------------------------------------------}
function TFrac2D.GetFrame: RealRect;
begin
  Result[1] := x1;
  Result[2] := y1;
  Result[3] := x2;
  Result[4] := y2;
end;

procedure TFrac2D.SetFrame(const Value: RealRect);
begin
  x_min := Value[1];
  y_min := Value[2];
  x_max := Value[3];
  y_max := Value[4];
end;

procedure TFrac2D.SetProp(const idx: integer; const Value: Boolean);
var x1, y1, p: Extended;
begin
  if Value = GetB(idx) then Exit;
  SetB(idx, Value);
  if not Value then Exit;
  BeginFracUpdate;
  if Ratio <= 0 then Ratio := 1;
  x1 := x_max - x_min;
  y1 := y_max - y_min;
  if x1 = 0 then begin  // if no width, take height for width
    x_min := x_min - y1 / 2;
    x_max := x_max + y1 / 2;
  end else
  if y1 = 0 then begin  // if no height, take width for height
    y_min := y_min - x1 / 2;
    y_max := y_max + x1 / 2;
  end else begin
    p := x1 / y1;
    if p > Ratio then begin
       x_max := x_max / p * Ratio; // ???
       x_min := x_min / p * Ratio;
    end else
    if p < Ratio then begin
       y_max := y_max * p / Ratio;
       y_min := y_min * p / Ratio;
    end;
  end;
  EndFracUpdate;
end;

function TFrac2D.GetProp(const idx: integer): Boolean;
begin
  Result := GetB(idx) and (Ratio > 0);
end;

procedure TFrac2D.SetX1(const Value: FracNumber);
begin
   if X1 = Value then Exit;
   X1 := Value;
   FrChgd := true;
   if not FrameProp then Exit;

end;

procedure TFrac2D.SetX2(const Value: FracNumber);
begin
   if X2 = Value then Exit;
   X2 := Value;
   FrChgd := true;
   if not FrameProp then Exit;

end;

procedure TFrac2D.SetY1(const Value: FracNumber);
begin
   if Y1 = Value then Exit;
   Y1 := Value;
   FrChgd := true;
   if not FrameProp then Exit;

end;

procedure TFrac2D.SetY2(const Value: FracNumber);
begin
   if Y2 = Value then Exit;
   Y2 := Value;
   FrChgd := true;
   if not FrameProp then Exit;

end;

function TFrac2D.GetHeight: integer;
begin
   Result := Length(FGrid);
end;

function TFrac2D.GetWidth: integer;
var i: integer;
begin
   if FGrid = nil then Result := 0 else
   Result := Length(FGrid[0]);
end;

procedure TFrac2D.SetHeight(const Value: integer);
var i, j: integer;
begin
  i := Length(FGrid);
  if i = Value then Exit;
  j := Width;             
  SetLength(FGrid, Value);
  if j > 0 then while i < Value do begin
    SetLength(FGrid[i], j);
    inc(i);
  end;
  FrChgd := true;
end;

procedure TFrac2D.SetWidth(const Value: integer);
var i, l: integer;
    c: boolean;
begin
  c := true;
  if Length(FGrid) = 0 then SetLength(FGrid, 1) else c := false;
  for i := High(FGrid) downto 0 do begin
    c := c or (Length(FGrid[i]) <> Value);
    SetLength(FGrid[i], Value);
  end;
  FrChgd := c or FrChgd;
end;

function TFrac2D.DrawTo(Bmp: TBitmap; x, y: integer): TBitmap;
var w, h, i, j, k: integer;
    pf: TPixelFormat;
    P: Pointer;
    F: ^String;
    fh, fv: boolean;
begin
  Assert(Assigned(FB2CF));
  Result := Bmp;
  if not Assigned(Result) then Exit;
  if AutoCalcFr and FrChgd then Calc;

  w := Bmp.Width;
  h := Bmp.Height;
  j := Height;
  if(x > w) or (y > h) then Exit;
  dec(w, x);
  dec(h, y);
  fh := FlipHorizontally;
  fv := FlipVertically;
  if h < j then j := h else h := j;

  pf := Bmp.PixelFormat ;
  Bmp.PixelFormat := pf24bit;

  while j > 0 do begin
    dec(j);
    P := Bmp.ScanLine[j+y];
    inc(PChar(P), x);
    if fv then F := @FGrid[h-j-1]
          else F := @FGrid[j];
    i := Length(F^);
    if w < i then i := w;
    if fh then begin k := i-1; i := -i; end else k := 0;
    ApplyB2SL(P, PChar(F^)+k, i, FB2CF, FDrawMode);
  end;

  Bmp.PixelFormat := pf;
end;

function TFrac2D.DrawTo(Bmp: TBitmap; x, y: integer; dm: TDrawMode): TBitmap;
var d: TDrawMode;
begin
  d := FDrawMode;
  FDrawMode := dm;
  DrawTo(Bmp, x, y);
  FDrawMode := d;
end;

procedure TFrac2D.SetB2CF(const Value: TByte2ColorF);
begin
  if @FB2CF = @Value then Exit;
  FB2CF := Value;
  Changed;
end;

procedure TFrac2D.SetFracPixF(const Value: TFrac2DPixF);
begin
  if @FFracPixF = @Value then Exit;
  FFracPixF := Value;
  FrChgd := true;
end;

procedure TFrac2D.SetFracChanged(const Index: Integer;
  const Value: Boolean);
begin
  if Value = GetB(Index) then Exit;
  SetB(Index, Value);
  if Value then ChangedFr;
  if AutoCalcFr and GetB(Index) then Calc;
end;

procedure TFrac2D.SetRatio(const Value: Real);
begin
  FRatio := Value;
end;

procedure TFrac2D.BeginUpdate;
begin
  inc(FUpdateCount);
end;

function TFrac2D.EndUpdate: boolean;
begin
  if FUpdateCount > 0 then dec(FUpdateCount);
  Result := FUpdateCount = 0;
  if Result then Changed;
end;

procedure TFrac2D.BeginFracUpdate;
begin
  inc(FUpdateCountFr);
end;

function TFrac2D.EndFracUpdate: boolean;
begin
  if FUpdateCountFr > 0 then dec(FUpdateCountFr);
  Result := FUpdateCountFr = 0;
  if Result then ChangedFr;
end;

procedure TFrac2D.ChangedFr;
begin
  if FUpdateCountFr <> 0 then Exit;
  if FrChgd and Assigned(OnChangeFr) then OnChangeFr(Self);
end;

procedure TFrac2D.Changed;
begin
  if (FUpdateCount = 0) and Assigned(OnChange) then OnChange(Self);
end;

procedure TFrac2D.SetDrawMode(const Value: TDrawMode);
begin
  if FDrawMode = Value then Exit;
  FDrawMode := Value;
  Changed;
end;

procedure TFrac2D.SetMaxIter(const Value: Integer);
begin
  if FMaxIter <> Value then Exit;
  FMaxIter := Value;
  FrChgd := true;
end;

initialization
  ca := 0;
  cb := 0;

end.
