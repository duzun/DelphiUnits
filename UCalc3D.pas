unit UCalc3D;

interface
uses UCalcVec;
{---------------------------------------------------------------}
type
     {Orice 4 vectori nici care 3 din care nu sunt coliniari determina un reper afin}
     TReper   = packed array[0..3] of TVector;   {O, e1, e2, e3}
     TImReper = TReper;
{---------------------------------------------------------------}
var Depth: word; {Profunzime}
{---------------------------------------------------------------}
{Obtine coordonatele P din sistemul E in sistemul absolut de coordonate}
{ M := O + P1*e1 + P2*e2 +P3*e3 }
procedure CoordAbsol  (P: TVector; E: TReper;   var M: TVector);
procedure CoordAbsol2D(P: TVector; E: TImReper; var M: TVec2Real);

{Proiectarea centrala: 3D -> 2D}
function Proiec(xyz: TVector; var xy: TVec2Real): boolean;    {Vectorul}   
function ProiecReper(E3D: TReper; var EIm: TImReper): boolean;{Reperul}

{Obtinerea coordonatelor plane ale punctului din reper}
function Get2DVec(var P: TVector; E: TReper; Var M: TVector): boolean;

{Roteste reperul E cu rad radiani in jurul axei ax}
procedure RotSis(var E: TReper; rad: real; ax: byte);
procedure RotSisRel(var E: TReper; rad: real; ax: byte);

{---------------------------------------------------------------}
implementation
{---------------------------------------------------------------}
procedure CoordAbsol(P: TVector; E: TReper; var M: TVector);
begin { M = (O + P1*e1 + P2*e2 +P3*e3) }
   MulScal(e[1], e[1], P[1]); {e1 := P1 * e1}
   MulScal(e[2], e[2], P[2]); {e2 := P2 * e2}
   MulScal(e[3], e[3], P[3]); {e3 := P3 * e3}
   AddVec(M, e[0], e[1]);     {M := O + e1}
   AddVec(M, M,    e[2]);     {M := M + e2}
   AddVec(M, M,    e[3]);     {M := M + e3}
end;
{---------------------------------------------------------------}
procedure CoordAbsol2D(P: TVector; E: TImReper; var M: TVec2Real);
begin
   { M = (O + P1*E1 + P2*E2 +P3*E3) }
   MulScal2D(E[1], E[1], P[1]); {e1 := P1 * e1}
   MulScal2D(E[2], E[2], P[2]); {e2 := P2 * e2}
   MulScal2D(E[3], E[3], P[3]); {e3 := P3 * e3}
   AddVec2D(M, e[0], e[1]);     {M := O + e1}
   AddVec2D(M, M,    e[2]);     {M := M + e2}
   AddVec2D(M, M,    e[3]);     {M := M + e3}
end;
{---------------------------------------------------------------}
function Proiec(xyz: TVector; var xy: TVector): boolean;
begin  {3D -> 2D}
  { Atentie! xyz[3] <> -Depth, altfel se obtine eroare }
  if (xyz[3] <> -Depth) then begin
    xy[3]  := Depth  / (xyz[3]+Depth);
    Proiec := true;
  end else begin {punct impropriu}
    xy[3]  :=  1.7e+38; {infinit}
    Proiec := false;
  end;
  xy [1] := xyz[1] * xy[3]; { x := x * (Depth / (z+Depth)) }
  xy [2] := xyz[2] * xy[3]; { y := y * (Depth / (z+Depth)) }
end;
{---------------------------------------------------------------}
function ProiecReper(E3D: TReper; var EIm: TImReper): boolean;
var i: integer;
begin  {3D -> 2D}
   ProiecReper := true;
   {Transformarea vectorilor reperului in puncte din spatiu}
   AddVec(E3D[1], E3D[1], E3D[0]); {E1 = O + e1}
   AddVec(E3D[2], E3D[2], E3D[0]); {E2 = O + e2}
   AddVec(E3D[3], E3D[3], E3D[0]); {E3 = O + e3}
   {Proiectarea reperului}
   for i:=0 to 3 do begin
      if not Proiec(E3D[i], EIm[i]) then ProiecReper := false;
   end;
   {Transformarea punctelor in vectori ai imaginii reperului}
   SubVec2D(EIm[1], EIm[1], EIm[0]);
   SubVec2D(EIm[2], EIm[2], EIm[0]);
   SubVec2D(EIm[3], EIm[3], EIm[0]);
end;
{---------------------------------------------------------------}
function Get2DVec(var P: TVector; E: TReper; Var M: TVector): boolean;
begin
  CoordAbsol(P, E, M);
  Get2DVec := Proiec(M, M);
end;
{---------------------------------------------------------------}
procedure RotSis(var E: TReper; rad: real; ax: byte);
begin {A roti sistemul inseamna a roti vectorii sistemului}
   ax := ax mod 3;
   RotAx(e[1], rad, ax);
   RotAx(e[2], rad, ax);
   RotAx(e[3], rad, ax);
end;
{---------------------------------------------------------------}
procedure RotSisRel(var E: TReper; rad: real; ax: byte);
begin {A roti sistemul inseamna a roti vectorii sistemului}
   ax := ax mod 3 + 1;
   RotVec(e[ax], e[ax mod 3 + 1], rad, e[ax], e[ax mod 3 + 1]);
end;
{---------------------------------------------------------------}
begin
  Depth := 10000;
end.
