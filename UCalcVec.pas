unit UCalcVec;
{---------------------------------------------------------------}
interface
{$N+}
{---------------------------------------------------------------}
type
     TCoord    = Extended;

     TVector   = packed array[1..3] of TCoord;
     PVector = ^TVector;
     TVec2Real = TVector;

     TPlan     = packed record n: TVector; C: TCoord; end; {n - vectorul normal, C - coeficientul liber al ecuatiei}
     PPlan = ^TPlan;

     TVecList = array[0..100] of PVector;
     PVecList = ^TVecList;

     TVec2Int  = packed array[1..2] of Integer;

{---------------------------------------------------------------}
const VecZero: TVector = (0, 0, 0);
      VecI: TVector = (1, 0, 0); {Vectorii unitari}
      VecJ: TVector = (0, 1, 0);
      VecK: TVector = (0, 0, 1);
      xOy:  TPlan = (n: (0, 0, 1); C: 0);
      yOz:  TPlan = (n: (1, 0, 0); C: 0);
      zOx:  TPlan = (n: (0, 1, 0); C: 0);
      Pi_c = 3.1415926535897932384626433832795;
      Radiani = 180 / Pi_c; { x * Radiani = y Grade}
      Grade   = Pi_c / 180; { x * Grade   = y Radiani}
      Ax_X = 1;
      Ax_Y = 2;
      Ax_Z = 3;

{---------------------------------------------------------------}
function  IsNul(v: TVector): boolean;        { v = 0 }
function  Modul(v: TVector): Extended;       { |v| }
function  ProdScal(v1, v2: TVector): Extended; { v1*v2 }
procedure ProdVec (var r: TVector; v1, v2: TVector); { r := [v1,v2] }
procedure AddVec  (var r: TVector; v1, v2: TVector); { r := v1 + v2 }
procedure SubVec  (var r: TVector; v1, v2: TVector); { r := v1 - v2 }
procedure MulScal (var r: TVector; v: TVector; scal: TCoord); { r := v * scal }
procedure AddScal (var r: TVector; v: TVector; scal: TCoord); { r := v + scal }
function  VecParal(var u: TVector; v: TVector; scal: TCoord): TCoord; { u // v, |u| = scal }

function EcPlan(var n: TVector; var A, B, C: TVector): TCoord; {n - vectorul normal, return C}
function CosVec(v1, v2: PVector): Real;
{---------------------------------------------------------------}
procedure MulScal2D(var r: TVec2Real; v: TVec2Real; scal: TCoord); { r := v * scal }
procedure AddVec2D (var r: TVec2Real; v1, v2: TVec2Real); { r := v1 + v2 }
procedure SubVec2D (var r: TVec2Real; v1, v2: TVec2Real); { r := v1 - v2 }
{---------------------------------------------------------------}
procedure RotAx(var v: TVector; rad: Real; ax: byte); {roteste v cu rad in jurul ax}
procedure RotVec(v1, v2: TVector; rad: Real; var x, y: TVector);
function  r(g:Real):Real; {grade   -> radiani}
function  g(r:Real):Real; {radiani -> grade  }
{---------------------------------------------------------------}

implementation
{---------------------------------------------------------------}
function EcPlan(var n: TVector; var A, B, C: TVector): TCoord;
begin
    n[1] := (B[2]-A[2])*(C[3]-A[3]) - (B[3]-A[3])*(C[2]-A[2]) ;
    n[2] := (B[3]-A[3])*(C[1]-A[1]) - (B[1]-A[1])*(C[3]-A[3]) ;
    n[3] := (B[1]-A[1])*(C[2]-A[2]) - (B[2]-A[2])*(C[1]-A[1]) ;
    EcPlan := -A[1]*n[1] -A[2]*n[2] -A[3]*n[3] ;
end;
{---------------------------------------------------------------}
function CosVec(v1, v2: PVector): Real;
var m: Extended;
begin
  m := (Modul(v1^)*Modul(v2^));
  if m = 0 then CosVec := 1 else
  CosVec := ProdScal(v1^, v2^) / m;
end;
{---------------------------------------------------------------}
procedure MulScal2D(var r: TVec2Real; v: TVec2Real; scal: TCoord);
begin  { r := v * scal }
   r[1] := v[1] * scal;
   r[2] := v[2] * scal;
end;
{---------------------------------------------------------------}
procedure AddVec2D (var r: TVec2Real; v1, v2: TVec2Real);
begin  { r := v1 + v2 }
   r[1] := v1[1] + v2[1];
   r[2] := v1[2] + v2[2];
end;
{---------------------------------------------------------------}
procedure SubVec2D (var r: TVec2Real; v1, v2: TVec2Real);
begin  { r := v1 - v2 }
   r[1] := v1[1] - v2[1];
   r[2] := v1[2] - v2[2];
end;
{---------------------------------------------------------------}
procedure RotAx(var v: TVector; rad: Real; ax: byte);
var sn, cs: Real;
    x, y: TCoord;
    i, j: byte;
begin
   { case ax of 1: Ox; 2: Oy; 3: Oz; }
   sn := sin(rad);  i := ax mod 3 + 1; inc(ax);  x := v[i];
   cs := cos(rad);  j := ax mod 3 + 1;           y := v[j];

   v[i] := x*cs - y*sn;
   v[j] := x*sn + y*cs;
end;
{---------------------------------------------------------------}
procedure RotVec(v1, v2: TVector; rad: Real; var x, y: TVector);
var sn, cs: Real;
begin {Roteste v1 spre v2}
  sn := sin(rad);
  cs := cos(rad);
  MulScal(x,  v1, cs);  MulScal(y,  v2, cs);
  MulScal(v1, v1, sn);  MulScal(v2, v2, sn);
  SubVec(x, x, v2);     AddVec(y, y, v1);
end;
{---------------------------------------------------------------}
function  VecParal(var u: TVector; v: TVector; scal: TCoord): TCoord;
var M: TCoord;
begin { u // v, |u| = scal }
   M := Modul(v);
   if M <> 0 then MulScal(u, v, scal/M)
             else u := v;
   VecParal := M;
end;
{---------------------------------------------------------------}
procedure MulScal(var r: TVector; v: TVector; scal: TCoord);
begin  { r := v * scal }
   r[1] := v[1] * scal;
   r[2] := v[2] * scal;
   r[3] := v[3] * scal;
end;
{---------------------------------------------------------------}
procedure AddScal(var r: TVector; v: TVector; scal: TCoord);
begin  { r := v + scal }
   r[1] := v[1] + scal;
   r[2] := v[2] + scal;
   r[3] := v[3] + scal;
end;
{---------------------------------------------------------------}
procedure AddVec(var r: TVector; v1, v2: TVector);
begin  { r := v1 + v2 }
   r[1] := v1[1] + v2[1];
   r[2] := v1[2] + v2[2];
   r[3] := v1[3] + v2[3];
end;
{---------------------------------------------------------------}
procedure SubVec(var r: TVector; v1, v2: TVector);
begin  { r := v1 - v2 }
   r[1] := v1[1] - v2[1];
   r[2] := v1[2] - v2[2];
   r[3] := v1[3] - v2[3];
end;
{---------------------------------------------------------------}
procedure  ProdVec(var r: TVector; v1, v2: TVector);
begin  { r := [v1,v2] }
   r[1] := v1[2]*v2[3] - v1[3]*v2[2];
   r[2] := v1[3]*v2[1] - v1[1]*v2[3];
   r[3] := v1[1]*v2[2] - v1[2]*v2[1];
end;
{---------------------------------------------------------------}
function  ProdScal(v1, v2: TVector): Extended; { v1*v2 }
begin ProdScal := v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3] end;
{---------------------------------------------------------------}
function  Modul(v: TVector): Extended; { |v| }
begin Modul := sqrt(sqr(v[1])+sqr(v[2])+sqr(v[3])) end;
{---------------------------------------------------------------}
function  IsNul(v: TVector): boolean; { v = 0 }
begin IsNul := (v[1] = 0) and (v[2] = 0) and (v[3] = 0) end;
{---------------------------------------------------------------}
function r(g:Real):Real; begin r:=g*Grade; end;
function g(r:Real):Real; begin g:=r*Radiani; end;
{---------------------------------------------------------------}
end.
