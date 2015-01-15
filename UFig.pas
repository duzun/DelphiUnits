{$F+}
{$N+}
Unit UFig;
interface
uses UCalc3D, UCalcVec, UPoligon, Graph;
{---------------------------------------------------------------}
type  TDrowFig = PROCEDURE (Sis: TReper);
      TPointList = array[0..100] of PointType;
      PPointList = ^TPointList;

{---------------------------------------------------------------}
var RazaFig: integer;
    DrowFig: TDrowFig;
    Figures: record n: byte; Drow: array[byte] of TDrowFig; end;
    ActiveFig : byte;
{---------------------------------------------------------------}
PROCEDURE Cub(Sis: TReper);                   {Desenarea cubului}
PROCEDURE FillCub(Sis: TReper);               {Desenarea cubului cu fete}
PROCEDURE Tetraedru(Sis: TReper);             {Desenarea tetraedrului}
PROCEDURE Octaedru(Sis: TReper);              {Desenarea octaedrului}
PROCEDURE Icosaedru(Sis: TReper);             {Desenarea icosaedrului}
{---------------------------------------------------------------}
function Line2d(p1, p2: TVec2Real): boolean;
procedure FillPoly2D(var Poli: TPoli);
{---------------------------------------------------------------}
implementation
{---------------------------------------------------------------}
procedure FillCub(Sis: TReper);
var P : array[0..7] of TVector;
    Fete: array[0..5] of array[0..3]of byte;
    Poli: TPoli;
    Ro : array[0..5] of Real;
    Ord: array[0..5] of byte;
    G : TVector;
    i, j, k : byte;
    Cl: TColor;
begin
  if not GetPoli(Poli, 4) then Exit;{Alocarea memoriei dinamice}

  {Amplasarea figurilor in spatiu (reper)}
  for i:=0 to 7 do begin
     if (i and 1) <> 0 then p[i][1] := RazaFig else p[i][1] := -RazaFig;
     if (i and 2) <> 0 then p[i][2] := RazaFig else p[i][2] := -RazaFig;
     if (i and 4) <> 0 then p[i][3] := RazaFig else p[i][3] := -RazaFig;
  end;

  {Baza de sus}
  Fete[0][0] := 0;  Fete[0][1] := 1;
  Fete[0][2] := 3;  Fete[0][3] := 2;
  {Baza de jos}
  Fete[5][0] := 4;  Fete[5][1] := 5;
  Fete[5][2] := 7;  Fete[5][3] := 6;
  {Fetele laterale}
  for i:= 0 to 3 do for j := 1 to 4 do
     Fete[j][i] := Fete[5*(i shr 1)][(j-1+i-(i shr 1)*(i-1+i and 1)) and 3];

  {Calcularea coordonatelor in sistemul absolut de coordonate}
  for i:=0 to 7 do CoordAbsol(P[i], Sis, P[i]);

  {Determinam distantele de la observator pana la centrul de masa al fiecarui poligon}
  for i := 0 to 5 do begin
    for j := 0 to 3 do Poli.P^[j] := @P[Fete[i][j]];
    PoliG(Poli, G);
    G[3] := G[3] - Depth;
    Ro[i] := Modul(G);
  end;

  {Ordonarea fetelor cubului dupa distanta de la observator}
  for i := 0 to 5 do Ord[i] := i; {Lista permutarilor}
  for i := 0 to 4 do
     for j := i+1 to 5 do if Ro[Ord[i]] < Ro[Ord[j]] then
       begin k := Ord[i]; Ord[i] := Ord[j]; Ord[j] := k; end;

  Cl := GetFillColor;
  {Cantitatea de lumina care cade pe fiecare fata}
  for i := 0 to 5 do begin
    EcPlan(G, P[Fete[i][0]], P[Fete[i][1]], P[Fete[i][2]]);
    Ro[i] := (Abs(CosVec(@G, @VecK))+1)/2;
  end;

  {Calcularea coordonatelor plane - I metoda}
  for i:=0 to 7 do Proiec(P[i], P[i]);

  {Desenarea fetelor in ordine}
  for i := 0 to 5 do begin
     for j := 0 to 3 do Poli.P^[j] := @P[Fete[Ord[i]][j]];
     SetFillColor(MulColor(Cl, Ro[Ord[i]]));
     FillPoly2d(Poli);
  end;
  SetFillColor(Cl);

  {Eliberarea memoriei alocate}
  FreePoli(Poli);
end;
{---------------------------------------------------------------}
procedure Cub(Sis: TReper);
var P :array[0..7] of TVector;
    P2:array[0..7] of TVec2Real;
    V : TVector;
    i : integer;
begin
  {Amplasarea figurilor in spatiu (reper)}
  for i:=0 to 7 do begin
     if (i and 1) <> 0 then p[i][1] := RazaFig else p[i][1] := -RazaFig;
     if (i and 2) <> 0 then p[i][2] := RazaFig else p[i][2] := -RazaFig;
     if (i and 4) <> 0 then p[i][3] := RazaFig else p[i][3] := -RazaFig;
  end;

  {Calcularea coordonatelor plane - I metoda}
  for i:=0 to 7 do begin
     CoordAbsol(P[i], Sis, V);
     Proiec(V, P2[i]);
  end;

  {Desenarea segmentelor figurii}
  for i:=0 to 3 do begin
    Line2D(P2[i],   P2[i+4]);
    Line2D(P2[2*i], P2[2*i+1]);
    Line2D(P2[i+i and 2+2], P2[i+i and 2]);
  end;
end;
{---------------------------------------------------------------}
procedure Icosaedru(Sis: TReper);
var P :array[1..12] of TVector;
    P2:array[1..12] of TVec2Real;
    Im: TImReper; {Imaginea reperului 3D}
    u : real;
    i : integer;
begin
  u := 2*arctan(2/(sqrt(5)+1));

  {Amplasarea figurilor in spatiu (reper)}
  for i:=1 to 12 do begin
     P[i][1]:=0;    P[i][3]:=0;
  end;
  for i:=1 to 6  do p[i][2] := RazaFig;
  for i:=7 to 12 do p[i][2] :=-RazaFig;
  for i:=2 to 11 do RotAx(P[i], u,           3);
  for i:=2 to 6  do RotAx(P[i], r(72*i),     2);
  for i:=7 to 11 do RotAx(P[i], r(72*(i-3)), 2);

  {Proiectarea sistemului}
  ProiecReper(Sis, Im);

  {Calcularea coordonatelor plane - II metoda}
  for i:=1 to 12 do CoordAbsol2D(P[i], Im, P2[i]);

  {Desenarea segmentelor figurii}
  for i:=2 to 6  do Line2D(P2[1], P2[i]);
  for i:=7 to 11 do Line2D(P2[12],P2[i]);
  for I:=2 to 6 do begin
   Line2D(P2[i],  P2[(i-1)mod 5+2]);
   Line2D(P2[i+5],P2[(i-1)mod 5+7]);
   Line2D(P2[i],  P2[i+5]);
   Line2D(P2[i],  P2[(i-1)mod 5+7]);
  end;
end;
{---------------------------------------------------------------}
PROCEDURE Tetraedru(Sis: TReper);          {Desenarea tetraedrului}
VAR P : array[1..4] of TVector;
    V : TVector;
    i : integer;
BEGIN
  {Amplasarea punctelor in spatiu (in reper)}
  FOR i:=1 TO 4 DO P[i] := VecZero;
  P[1][2]:=-RazaFig*sqrt(6)*2/3;

  P[2][2]:= RazaFig*sqrt(6)/3;
  P[2][3]:= RazaFig*sqrt(3);

  P[3][1]:= RazaFig*3/2;
  P[3][2]:= P[2][2];
  P[3][3]:=-P[2][3]/2;

  P[4]   := P[3];
  P[4][1]:=-P[3][1];

  {Calcularea coordonatelor plane - I metoda}
  for i:=1 to 4 do Get2DVec(P[i], Sis, P[i]);

  {Desenarea segmentelor figurii}
  Line2D(P[1], P[3]);
  Line2D(P[2], P[4]);
  FOR i:=1 TO 4 DO
    Line2D(P[i], P[i mod 4 + 1]);
END;
{---------------------------------------------------------------}
PROCEDURE Octaedru(Sis: TReper);          {Desenarea octaedrului}
VAR P : array[0..5] of TVector;
    i : integer;
BEGIN
  {Amplasarea punctelor in spatiu (in reper)}
  FOR i:=0 TO 5 DO  P[i] := VecZero;
  P[0][1] :=  RazaFig;    P[3][2] := -RazaFig;
  P[1][2] :=  RazaFig;    P[4][3] := -RazaFig;
  P[2][3] :=  RazaFig;    P[5][1] := -RazaFig;

  {Calcularea coordonatelor plane}
  for i:=0 to 5 do Get2DVec(P[i], Sis, P[i]);

  {Desenarea segmentelor figurii}
  FOR i:=1 TO 4 DO BEGIN
    Line2D(P[i],           P[0]);
    Line2D(P[i],           P[5]);
    Line2D(P[i], P[i mod 4 + 1]);
  END;
END;
{---------------------------------------------------------------}
function Line2d(p1, p2: TVec2Real): boolean;
var i1,i2: TVec2Int;
begin
   {??? punctele pot iesi in afara limitelor ecranului}
   i1[1] := round(p1[1]);
   i2[1] := round(p2[1]);
   i1[2] := round(p1[2]);
   i2[2] := round(p2[2]);
   Line(GetMidX + i1[1], GetMidY - i1[2], GetMidX + i2[1], GetMidY - i2[2])
end;
{---------------------------------------------------------------}
procedure FillPoly2D(var Poli: TPoli);
var Tab: PPointList;
    i: word;
    MidX, MidY: Integer;
begin
  GetMem( Tab, Poli.n*SizeOf(PointType) );
  if Tab = nil then exit;
  MidX := GetMidX;
  MidY := GetMidY;
  with Poli do for i := 0 to n-1 do begin
    Tab^[i].x := MidX + round(P^[i]^[1]);
    Tab^[i].y := MidY - round(P^[i]^[2]);
  end;
  FillPoly(Poli.n, Tab^);
  FreeMem( Tab, Poli.n*SizeOf(PointType) )
end;
{---------------------------------------------------------------}
procedure DrowActiveFigure(Sis: TReper);
begin
   ActiveFig := ActiveFig mod Figures.n;
   Figures.Drow[ActiveFig](Sis);
end;
{---------------------------------------------------------------}
begin
  RazaFig := 10;
  DrowFig := DrowActiveFigure;
  ActiveFig := 1;
  with Figures do begin
     n := 5;
     Drow[0] := Cub;
     Drow[1] := FillCub;
     Drow[2] := Tetraedru;
     Drow[3] := Octaedru;
     Drow[4] := Icosaedru;
     Drow[n] := nil;
  end;
end.
