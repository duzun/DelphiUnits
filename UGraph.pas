{****************************************************
 * Author  : Dumitru Uzun
 * Web     : http://duzun.me
 * Repo    : https://github.com/duzun/DelphiUnits
 * Created : 29.01.2009
 *
 *  Modul pentru prelucratea Bitmap-urilor la nivel de pixel.
 *
 *
 * Istorie:
 * - 06.06.2009
 *   Am adaugat MulColor, pentru obtinerea intensitatii dorite a culorii
 *
 * - 07.06.2009
 *   Am adaugat functia GetIco si am facut niste corectari pentru GetBMP
 * 
 * - 18.06.2010
 *   Am adaugat procedura ApplyB2SL si functiile aferente.
 *   Am corectat niste greseli in legatura cu ordinea bitilor pentru RGB in Bitmap.
 *   Am extins tipul TDrawMode:  dATTRIB, dADD, dSUB 
 *   Am adaugat functii pentru prelucrarea rapida a Bitmap-urilor de 24bits.
 *    
 ****************************************************}

{-----------------------------------------------------------------}
Unit UGraph;

interface
uses Graphics, ExtCtrls, Controls, Types;

{-----------------------------------------------------------------}
type
   TDrawMode     = (dNIL, dATTRIB, dXOR, dOR, dAND, dINTENS, dADD, dSUB);
   TDrowMode     = TDrawMode;
   TByte2ColorF  = function (n: byte): TColor;
   TConvColorF   = function (c: TColor): TColor;
   TBytes2SLineF = procedure (sl, bs: Pointer; len: integer; f: TByte2ColorF);
   TRGBPack      = packed array[0..3] of Byte; // PixelFormat = 24
   TRGB_Rec      = packed record r,g,b: Byte; end;
   TBGR_Rec      = packed record b,g,r: Byte; end;
   PRGBPack      = ^TRGBPack;
   PRGB_Rec      = ^TRGB_Rec;
   PBGR_Rec      = ^TBGR_Rec;

var GradientStartColor, GradientEndColor: TColor; // Used in GradientB2C

{-----------------------------------------------------------------}
// Convert the bytes from bs into a color using f then combine with sl (Bitmap.ScanLine).
// sl is a secuence of BGR BGR BGR ...

(* sl se parcurge de la sl[0] pana la sl[abs(len)]
 * bs se parcurge de la bs[idx] pana la bs[idx+(len-1)]
 *)

procedure   ApplyB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF; mode: TDrawMode);

procedure   attrB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
procedure intensB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
procedure    xorB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
procedure     orB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
procedure    andB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
procedure    addB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
procedure    subB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);

{-----------------------------------------------------------------}
/// Copy n to each color (RGB)
function CpyB2C(n: byte): TColor;

/// n in [0..254] ~ [GradientStartColor..GradientEndColor]
function GradientB2C(n: byte): TColor;

{-----------------------------------------------------------------}
function SimetricColor(C: TColor): TColor;
{-----------------------------------------------------------------}
function  PixelCount(Bmp: TBitmap): byte;
function  RGB(r, g, b: Integer): TColor;
Procedure RGBSplit(Color: TColor; var r, g, b: Byte);
function  MulColor(Color: TColor; Num: Extended): TColor;
function  InvertBMP(B: TBitmap): boolean;
function  FlipHorizBMP(B: TBitmap): boolean;
function  FlipVertBMP(B: TBitmap): boolean;

Function  ReadRGB (P: Pointer; bits: byte=8): TRGBPack;
Function  PackRGB (C: TColor; bits: integer=8): Integer;
Function  WriteRGB(C: TColor; P: Pointer; bits: byte=8): Integer;

// Pentru BMP de 24bits
Procedure GetRGB(P: Pointer; var r, g, b: byte);
Procedure PutRGB(P: Pointer; r, g, b: byte);
Function  ReadColor24 (P: Pointer): TColor;
Procedure WriteColor24(P: Pointer; C: TColor);


function GetBMP(var Dst: TBitmap; Src: TGraphic; PixelFmt: TPixelFormat = pf24bit): boolean; overload;
function GetBMP(Src: TGraphic; PixelFmt: TPixelFormat = pf24bit): TBitmap;                   overload;
function GetIco(Src: TGraphic; TransparentColor: TColor): TIcon;
{-----------------------------------------------------------------}
implementation
{-----------------------------------------------------------------}
function SimetricColor(C: TColor): TColor;
begin
  Result := C;
  TRGBPack(Result)[2] := TRGBPack(Result)[1] + $7F;
  TRGBPack(Result)[1] := TRGBPack(Result)[0] + $7F;
  TRGBPack(Result)[0] := TRGBPack(C)[2] + $7F;
end;
{-----------------------------------------------------------------}
function CpyB2C(n: byte): TColor; begin Result := RGB(n,n,n); end;

function GradientB2C(n: byte): TColor;
var i: integer;
begin
  Result := GradientStartColor;
  i := TRGBPack(GradientEndColor)[0];
  dec(i, TRGBPack(Result)[0]);
  inc(TRGBPack(Result)[0], i * n div 254);
  i := TRGBPack(GradientEndColor)[1];
  dec(i, TRGBPack(Result)[1]);
  inc(TRGBPack(Result)[1], i * n div 254);
  i := TRGBPack(GradientEndColor)[2];
  dec(i, TRGBPack(Result)[2]);
  inc(TRGBPack(Result)[2], i * n div 254);
end;
{-----------------------------------------------------------------}
procedure   ApplyB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF; mode: TDrawMode);
begin
  case mode of
    dATTRIB:   attrB2SL(sl, bs, len, f);
    dINTENS: intensB2SL(sl, bs, len, f); 
    dXOR   :    xorB2SL(sl, bs, len, f); 
    dOR    :     orB2SL(sl, bs, len, f); 
    dAND   :    andB2SL(sl, bs, len, f); 
    dADD   :    addB2SL(sl, bs, len, f); 
    dSUB   :    subB2SL(sl, bs, len, f); 
  end;
end;
{-----------------------------------------------------------------}
procedure   attrB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    WriteColor24(sl, f(PByte(bs)^));
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

procedure intensB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
    r,g,b,t,h,n: byte;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    GetRGB(sl, r,g,b);
    RGBSplit(f(PByte(bs)^), t,h,n);
    PutRGB(sl, r*t div $FF, g*h div $FF, b*n div $FF);
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

procedure    xorB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    WriteColor24(sl, f(PByte(bs)^) xor ReadColor24(sl));
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

procedure     orB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    WriteColor24(sl, f(PByte(bs)^) or ReadColor24(sl));
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

procedure    andB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    WriteColor24(sl, f(PByte(bs)^) and ReadColor24(sl));
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

procedure    addB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
    c1, c2: TColor;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    c1 := f(PByte(bs)^);
    c2 := ReadColor24(sl);
    inc(TRGBPack(c1)[0],TRGBPack(c2)[0]); 
    inc(TRGBPack(c1)[1],TRGBPack(c2)[1]); 
    inc(TRGBPack(c1)[2],TRGBPack(c2)[2]); 
    WriteColor24(sl, c1);
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

procedure    subB2SL(sl: Pointer; bs: Pointer; len: integer; f: TByte2ColorF);
var dir: integer;
    c1, c2: TColor;
begin
  if len > 0 then dir := 1 else if len < 0 then dir := -1 else Exit;
  inc(len, Integer(bs));
  while Integer(bs) <> len do begin
    c1 := f(PByte(bs)^);
    c2 := ReadColor24(sl);
    dec(TRGBPack(c1)[0],TRGBPack(c2)[0]); 
    dec(TRGBPack(c1)[1],TRGBPack(c2)[1]); 
    dec(TRGBPack(c1)[2],TRGBPack(c2)[2]); 
    WriteColor24(sl, c1);
    inc(Integer(bs), dir);
    inc(Integer(sl), 3);
  end;
end;

{-----------------------------------------------------------------}
Function  ReadColor24(P: Pointer): TColor;
begin
  TRGBPack(Result)[0] := PRGBPack(P)^[2];
  TRGBPack(Result)[1] := PRGBPack(P)^[1];
  TRGBPack(Result)[2] := PRGBPack(P)^[0];
  TRGBPack(Result)[3] := 0;
end;
{-----------------------------------------------------------------}
procedure WriteColor24(P: Pointer; C: TColor);
begin
   PRGBPack(P)^[2] := TRGBPack(C)[0];
   PRGBPack(P)^[1] := TRGBPack(C)[1];
   PRGBPack(P)^[0] := TRGBPack(C)[2];
end;

Procedure GetRGB(P: Pointer; var r, g, b: byte);
begin
   r := PRGBPack(P)^[2];
   g := PRGBPack(P)^[1];
   b := PRGBPack(P)^[0];
end;

Procedure PutRGB(P: Pointer; r, g, b: byte);
begin
   PRGBPack(P)^[2] := r;
   PRGBPack(P)^[1] := g;
   PRGBPack(P)^[0] := b;
end;
{-----------------------------------------------------------------}
Function ReadRGB(P: Pointer; bits: byte=8): TRGBPack;
var i: Integer;
    m: Integer;
begin
  m := 1 shl bits - 1;
  i := PInteger(P)^;
  Result[0] := i and m;
  Result[1] := i shr bits and m;
  Result[2] := i shr (bits shl 1) and m;
end;
{-----------------------------------------------------------------}
Function  PackRGB(C: TColor; bits: integer=8): Integer;
var m: integer;
begin
  m := 1 shl bits - 1;
  Result := ( TRGBPack(C)[0] and m) or
            ((TRGBPack(C)[1] and m) shl bits) or
            ((TRGBPack(C)[2] and m) shl (bits shl 1));
end;
{-----------------------------------------------------------------}
Function WriteRGB(C: TColor; P: Pointer; bits: byte=8): Integer;
begin
  Result := PackRGB(C, bits);
  Inc(bits, (bits shl 1)); {bits := 3*bits}
  if bits > 24 then PLongInt(P)^ := Result else
  if bits > 16 then begin
      PWord(P)^ := Result;
      PRGBPack(P)^[2] := TRGBPack(Result)[2];
  end else
  if bits >  8 then PWord(P)^ := Result else
                    PByte(P)^ := TRGBPack(Result)[0];
end;
{-----------------------------------------------------------------}
function RGB_(r, g, b: Integer): TColor;
asm
     mov eax, low b;
     shl eax, 8
     mov ecx, low g;
     or  eax, ecx
     shl eax, 8
     mov ecx, low r;
     or  eax, ecx
end;

function RGB(r, g, b: Integer): TColor;
begin
   if r > $ff then r := $ff;
   if g > $ff then g := $ff;
   if b > $ff then b := $ff;
   TRGBPack(Result)[0] := r;
   TRGBPack(Result)[1] := g;
   TRGBPack(Result)[2] := b;
//   Result := (r or (g shl 8) or (b shl 16));
end;
{-----------------------------------------------------------------}
Procedure RGBSplit(Color: TColor; var r, g, b: Byte);
begin
    r := TRGBPack(Color)[0];
    g := TRGBPack(Color)[1];
    b := TRGBPack(Color)[2];
end;
{-----------------------------------------------------------------}
function MulColor(Color: TColor; Num: Extended): TColor;
var r,g,b: byte;
begin
  TRGBPack(Result)[0] := Trunc(TRGBPack(Color)[0]*Num);
  TRGBPack(Result)[1] := Trunc(TRGBPack(Color)[1]*Num);
  TRGBPack(Result)[2] := Trunc(TRGBPack(Color)[2]*Num);
end;
{-----------------------------------------------------------------}
function  PixelCount(Bmp: TBitmap): byte;
var pf : TPixelFormat;
begin
  Result := 0;
  if Bmp <> nil then begin
  pf := Bmp.PixelFormat;
//  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom);
  case pf of
    pf1bit : Result := 1;
    pf4bit : Result := 4;
    pf8bit : Result := 8;
    pf15bit: Result := 15;
    pf16bit: Result := 16;
    pf24bit: Result := 24;
    pf32bit: Result := 32;
  end;
  end;
end;
{-----------------------------------------------------------------}
function InvertBMP(B: TBitmap): boolean;
var i, j, l: integer;
    PixelLength, m: byte;
    Cl: TColor;
    P: PRGBPack;
begin
  Result := false;
  if not Assigned(B) then Exit;
  PixelLength := PixelCount(B);
  if PixelLength = 0 then Exit;
  m := (PixelLength + 7) shr 3; {Nr of bytes}
  PixelLength := PixelLength div 3;
  j := B.Height-1;
  while j > 0 do begin
    dec(j);
    P := B.ScanLine[j];
    i := B.Width-1;
    while i > 0 do begin
       dec(i);
       Cl := not TColor(ReadRGB(P, PixelLength));
       WriteRGB(Cl,P, PixelLength);
       inc(Integer(P),m);
    end;
  end;
  Result := true;
end;
{-----------------------------------------------------------------}
function  FlipHorizBMP(B: TBitmap): boolean;
begin
end;
function  FlipVertBMP(B: TBitmap): boolean;
begin
end;
{-----------------------------------------------------------------}
function GetBMP(var Dst: TBitmap; Src: TGraphic; PixelFmt: TPixelFormat = pf24bit): boolean;
begin
  Result := false;
  if Dst = nil then Dst := TBitmap.Create;
  try
    Dst.Assign(Src);
    Result := true;
  finally
    Dst.PixelFormat := PixelFmt;
  end;
end;

function GetBMP(Src: TGraphic; PixelFmt: TPixelFormat = pf24bit): TBitmap;
begin
  Result := TBitmap.Create;
  try
    Result.PixelFormat := PixelFmt;
    if Src is TBitmap then Result.Assign(Src)
    else begin
      Result.Width  := Src.Width;
      Result.Height := Src.Height;
      Result.Canvas.Draw(0, 0, Src);
    end;
  except
    Result.Free;
    raise;
  end;
end;
{-----------------------------------------------------------------}
function GetIco(Src: TGraphic; TransparentColor: TColor): TIcon;
var Bmp: TBitmap;
begin
  with TImageList.CreateSize(Src.Width, Src.Height) do
    try
      AllocBy := 1;
      Bmp := GetBMP(Src);
      AddMasked(Bmp, TransparentColor);
      Result := TIcon.Create;
      try
        GetIcon(0, Result);
      except
        Result.Free;
        raise;
      end;
    finally
      Bmp.Free;
      Free;
    end;
end;
{-----------------------------------------------------------------}
initialization
  // Used in GradientB2C
  GradientStartColor := clGreen;
  GradientEndColor   := clBlue;


end.
