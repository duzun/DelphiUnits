{****************************************************
 * 
 *
 * Author  : Dumitru Uzun
 * Web     : http://duzun.me
 * Repo    : https://github.com/duzun/DelphiUnits
 * Version : 06.06.2009
 ****************************************************}

Unit ManJul;

interface
uses Graphics, ExtCtrls, UGraph;

type
   RealRect  = array[1..4] of Real; {x_min, x_max, y_min, y_max}
   PRealRect = ^RealRect; 

const
   ManRect: RealRect = (-1.8, 1.0, -1.3, 1.3); 
   JulRect: RealRect = (-1.8, 1.8, -1.3, 1.3); 

procedure Fractal   (Img: TImage; fr: byte = 0; cm: TColor = $ffffff; mode: TDrowMode=dNIL);
function  FractalPix(a, b: Real; x: Real = 0; y: Real = 0; k: integer = 100): TColor;

procedure MandelBrot(Img: TImage; cm: TColor = $ffffff; mode: TDrowMode=dNIL);
procedure Julia     (Img: TImage; cm: TColor = $ffffff; mode: TDrowMode=dNIL);
function  MandelBrotPix (a,b: real): TColor;
function  JuliaPix      (x,y: real): TColor;


var MaxIter: integer;
implementation
{-----------------------------------------------------------------}
procedure MandelBrot;
begin
  Fractal (Img, 0, cm, mode);
end;

procedure Julia;
begin
  Fractal (Img, 1, cm, mode);
end;
{-----------------------------------------------------------------}

function MandelBrotPix; begin  Result := FractalPix(a,b,0,0, MaxIter) ;        end;
function JuliaPix;      begin  Result := FractalPix(-0.55,-0.55,x,y,MaxIter) ; end;

{-----------------------------------------------------------------}
procedure Fractal(Img: TImage; fr: byte = 0; cm: TColor = $ffffff; mode: TDrowMode=dNIL);
var hx,hy,x,y,a,b: Real;
    px,py: ^Real;
    i,j: Integer;
    Color: TColor;
    Cl: TRGBPack;
    cr,cg,cb: byte;
    Bounds: PRealRect;
    PixelBits, PixelBytes: byte;
    Bm: TBitmap;
    P: PRGBPack;
begin
   case fr of
   1:   begin   {Julia}
          px := @x;   a := -0.55;
          py := @y;   b := -0.55;
          Bounds := @JulRect;
        end
   else begin   {Mandelbrot}
          px := @a;   x  := 0;
          py := @b;   y  := 0;
          Bounds := @ManRect;
        end;
   end;
 try
   Bm := nil;
   GetBMP(Bm, Img.Picture.Bitmap);
   PixelBits  := PixelCount(Bm);
   if PixelBits < 8 then exit;
   PixelBytes := (PixelBits+7) shr 3;
   PixelBits := PixelBits div 3;

   RGBSplit(cm,cr,cg,cb);
   hx := (Bounds^[2]-Bounds^[1]) / Bm.Width;
   hy := (Bounds^[4]-Bounds^[3]) / Bm.Height;
   py^ := Bounds^[3];

   for j := 0 to Bm.Height-1 do begin
      P := Bm.ScanLine[j];
      px^ := Bounds^[1];
      case Mode of
      dNIL:
         for i := 0 to Bm.Width-1 do begin
           cm := FractalPix(a,b,x,y, MaxIter) * $ff div MaxIter;
           TColor(Cl) := RGB(cr+cm, cg+cm, cb+cm); 
           WriteRGB(Cl, P, PixelBits);
           inc(Integer(P),PixelBytes);
           px^ := px^ + hx;
         end;
      dXOR:
         for i := 0 to Bm.Width-1 do begin
           cm := FractalPix(a,b,x,y, MaxIter) * $ff div MaxIter;
           Color := RGB(cr+cm, cg+cm, cb+cm) xor TColor(ReadRGB(P, PixelBits));
           WriteRGB(Color, P, PixelBits);
           inc(Integer(P),PixelBytes);
           px^ := px^ + hx; 
         end;
      dOR:
         for i := 0 to Bm.Width-1 do begin
           cm := FractalPix(a,b,x,y, MaxIter) * $ff div MaxIter;
           Color := RGB(cr+cm, cg+cm, cb+cm) or TColor(ReadRGB(P, PixelBits));
           WriteRGB(Color, P, PixelBits);
           inc(Integer(P),PixelBytes);
           px^ := px^ + hx; 
         end;
      dAND:
         for i := 0 to Bm.Width-1 do begin
           cm := FractalPix(a,b,x,y, MaxIter) * $ff div MaxIter;
           Color := RGB(cr+cm, cg+cm, cb+cm) and TColor(ReadRGB(P, PixelBits));
           WriteRGB(Color, P, PixelBits);
           inc(Integer(P),PixelBytes);
           px^ := px^ + hx; 
         end;
      dINTENS:
         for i := 0 to Bm.Width-1 do begin
           RGBSplit(TColor(ReadRGB(P, PixelBits)),cr,cg,cb);
           cm := FractalPix(a,b,x,y, MaxIter) * $ff div MaxIter;
           Color := RGB(cr*cm div 255, cg*cm div 255, cb*cm div 255);
           WriteRGB(Color, P, PixelBits);
           inc(Integer(P),PixelBytes);
           px^ := px^ + hx; 
         end;
      
      end;
      py^ := py^ + hy;
   end;
   Img.Picture.Graphic := Bm;
 finally
   Bm.Free;
 end;  
end;
{-----------------------------------------------------------------}
function FractalPix;
var xy: real;
    x2,y2: real;
    r: real;
begin
   r := 0;
   while (k>0)and(r<4) do begin
      x2 := x*x;  y2 := y*y;  xy := x*y;

      x := x2 - y2 + a;   { x` = x^2 - y^2 + a }
      y :=  2 * xy + b;   { y` = 2*xy + b      }

      r := x2+y2;
      dec(k)
   end;
   Result := k;
end;
{-----------------------------------------------------------------}
begin
   MaxIter := 100;
end.
