Unit MJFractal;
{ Componenta ManJul }

interface
uses Graphics, ExtCtrls, UGraph, UFrac2D, Classes, Dialogs;

type
   FracNumber = Extended;
   RealRect   = array[1..4] of Extended; {x_min, x_max, y_min, y_max}
   PRealRect  = ^RealRect;
   TFractalPix = function (a, b, x, y: FracNumber; k: integer): TColor;

  TManJul = class(TImage)
  private
      FFrac2D: TFrac2D;
      Fb: TBits;
      FCB: TStrings;

    function  GetB(Index: integer): Boolean;
    procedure SetB(Index: integer; const Value: Boolean);
    function GetDrawMode: TDrawMode;
    function GetFlipHorizontally: Boolean;
    function GetFlipVertically: Boolean;
    function GetFrameProp: Boolean;
    function GetMaxIter: Integer;
    function GetRatio: Real;
    function Getx_max: FracNumber;
    function Getx_min: FracNumber;
    function Gety_max: FracNumber;
    function Gety_min: FracNumber;
    procedure SetDrawMode(const Value: TDrawMode);
    procedure SetFlipHorizontally(const Value: Boolean);
    procedure SetFlipVertically(const Value: Boolean);
    procedure SetFrameProp(const Value: Boolean);
    procedure SetMaxIter(const Value: Integer);
    procedure SetRatio(const Value: Real);
    procedure Setx_max(const Value: FracNumber);
    procedure Setx_min(const Value: FracNumber);
    procedure Sety_max(const Value: FracNumber);
    procedure Sety_min(const Value: FracNumber);
    function GetB2CF: TByte2ColorF;
    function GetFracPixF: TFrac2DPixF;
    procedure SetB2CF(const Value: TByte2ColorF);
    procedure SetFracPixF(const Value: TFrac2DPixF);
    function GetAutoCalcFr: Boolean;
    procedure SetAutoCalcFr(const Value: Boolean);
  protected
      property SBits[Index: Integer]: Boolean read GetB write SetB;

  public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      procedure   Draw;

    property    FracFunc: TFrac2DPixF  read GetFracPixF write SetFracPixF;
    property    Byte2ColorFunc: TByte2ColorF  read GetB2CF write SetB2CF;

  published
      property Colors: TStrings read FCB write FCB;

      property MaxIter: Integer read GetMaxIter write SetMaxIter default 100;
      property DrawMode: TDrawMode read GetDrawMode write SetDrawMode default dATTRIB;
      property x_min: FracNumber read Getx_min write Setx_min;
      property y_min: FracNumber read Gety_min write Sety_min;
      property x_max: FracNumber read Getx_max write Setx_max;
      property y_max: FracNumber read Gety_max write Sety_max;
      property AutoCalcFr: Boolean read GetAutoCalcFr write SetAutoCalcFr  default false;
      property FlipVertically: Boolean read GetFlipVertically write SetFlipVertically default false;
      property FlipHorizontally: Boolean read GetFlipHorizontally write SetFlipHorizontally default false;
      property FrameProp       : Boolean read GetFrameProp write SetFrameProp default true;
      property Ratio: Real read GetRatio write SetRatio;

  end;

const
   ManRect: RealRect = (-1.8, -1.3, 1.0, 1.3);
   JulRect: RealRect = (-1.3, -1.8, 1.3, 1.8);

procedure Register;

implementation

uses Controls;
{-----------------------------------------------------------------}
procedure Register; begin RegisterComponents('DUzuns', [TManJul]); end;
{-----------------------------------------------------------------}
{ TManJul }

constructor TManJul.Create(AOwner: TComponent);
begin
  inherited;
  FFrac2D := TFrac2D.Create(Self);
  Fb := TBits.Create;
  Picture.Bitmap.PixelFormat := pf24bit;
  FCB := TStringList.Create;
end;
{-----------------------------------------------------------------}
destructor TManJul.Destroy;
begin
  Fb.Free;
  FFrac2D.Free;
  FCB.Free;
  inherited;
end;

function TManJul.GetB;
begin
  Result := (Index<Fb.Size) and Fb[Index];
end;

procedure TManJul.SetB;
var res: boolean;
begin
  res := Fb.Size <= Index; // Resize required
  if res and not Value or not res and (Value=Fb[Index]) then Exit;
  if res then Fb.Size := Index+1;
  Fb[Index] := Value;
end;

procedure TManJul.Draw;
var Bmp: TBitmap;
    s: string;
    i: integer;
begin
 try
   Bmp := Picture.Bitmap;
   FFrac2D.Height := Bmp.Height;
   FFrac2D.Width  := Bmp.Width;
   if FFrac2D.FracChanged then FFrac2D.Calc;

   CalcGradient(FCB);
   FFrac2D.DrawTo(Bmp);
 finally
   Invalidate;
//   Update;
 end;
end;
{-----------------------------------------------------------------}


function TManJul.GetDrawMode: TDrawMode;
begin
  Result := FFrac2D.DrawMode;
end;

function TManJul.GetFlipHorizontally: Boolean;
begin
  Result := FFrac2D.FlipHorizontally;
end;

function TManJul.GetFlipVertically: Boolean;
begin
  Result := FFrac2D.FlipVertically;
end;

function TManJul.GetFrameProp: Boolean;
begin
  Result := FFrac2D.FrameProp;
end;

function TManJul.GetMaxIter: Integer;
begin
  Result := FFrac2D.MaxIter;
end;

function TManJul.GetRatio: Real;
begin
  Result := FFrac2D.Ratio;
end;

function TManJul.Getx_max: FracNumber;
begin
  Result := FFrac2D.x_max;
end;

function TManJul.Getx_min: FracNumber;
begin
  Result := FFrac2D.x_min;
end;

function TManJul.Gety_max: FracNumber;
begin
  Result := FFrac2D.y_max;
end;

function TManJul.Gety_min: FracNumber;
begin
  Result := FFrac2D.y_min;
end;

procedure TManJul.SetDrawMode(const Value: TDrawMode);
begin
  FFrac2D.DrawMode := Value;
end;

procedure TManJul.SetFlipHorizontally(const Value: Boolean);
begin
  FFrac2D.FlipHorizontally := Value;
end;

procedure TManJul.SetFlipVertically(const Value: Boolean);
begin
  FFrac2D.FlipVertically := Value;
end;

procedure TManJul.SetFrameProp(const Value: Boolean);
begin
  FFrac2D.FrameProp := Value;
end;

procedure TManJul.SetMaxIter(const Value: Integer);
begin
  FFrac2D.MaxIter := Value;
end;

procedure TManJul.SetRatio(const Value: Real);
begin
  FFrac2D.Ratio := Value;
end;

procedure TManJul.Setx_max(const Value: FracNumber);
begin
  FFrac2D.x_max := Value;
end;

procedure TManJul.Setx_min(const Value: FracNumber);
begin
  FFrac2D.x_min := Value;
end;

procedure TManJul.Sety_max(const Value: FracNumber);
begin
  FFrac2D.y_max := Value;
end;

procedure TManJul.Sety_min(const Value: FracNumber);
begin
  FFrac2D.y_min := Value;
end;

function TManJul.GetB2CF: TByte2ColorF;
begin
  Result := FFrac2D.Byte2ColorFunc;
end;

function TManJul.GetFracPixF: TFrac2DPixF;
begin
  Result := FFrac2D.FracFunc;
end;

procedure TManJul.SetB2CF(const Value: TByte2ColorF);
begin
  FFrac2D.Byte2ColorFunc := Value;
end;

procedure TManJul.SetFracPixF(const Value: TFrac2DPixF);
begin
  FFrac2D.FracFunc := Value;
end;

function TManJul.GetAutoCalcFr: Boolean;
begin
  Result := FFrac2D.AutoCalcFr;
end;

procedure TManJul.SetAutoCalcFr(const Value: Boolean);
begin
  FFrac2D.AutoCalcFr := Value;
end;

end.
