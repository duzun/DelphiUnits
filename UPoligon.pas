Unit UPoligon;
interface
uses UCalc3D, UCalcVec, Graph;
{---------------------------------------------------------------}
type
     TPoli = record n: word; P: PVecList; end;
{---------------------------------------------------------------}
function  GetPoli(var Poli: TPoli; nr: word): boolean;
procedure FreePoli(var Poli: TPoli);
procedure PoliG(Var Poli: TPoli; Var G: TVec2Real);

{---------------------------------------------------------------}
implementation
{---------------------------------------------------------------}
function GetPoli(var Poli: TPoli; nr: word): boolean;
begin
    with Poli do begin
      GetMem(P, nr*SizeOf(Pointer));
      if P = nil then n := 0 else n := nr;
      GetPoli := n = nr;
    end;
end;
{---------------------------------------------------------------}
procedure FreePoli(var Poli: TPoli);
begin
    with Poli do begin
      FreeMem(P, n*SizeOf(Pointer));
      P := nil;
      n := 0;
    end;
end;
{---------------------------------------------------------------}
procedure PoliG(Var Poli: TPoli; Var G: TVector);
var i, j: integer;
begin
   G := VecZero;
   if Poli.P = nil then exit;
   with Poli do for i := 0 to n - 1 do begin
     if P^[i] = nil then Continue;
     G[1] := G[1] + P^[i]^[1];
     G[2] := G[2] + P^[i]^[2];
     G[3] := G[3] + P^[i]^[3];
   end;
   G[1] := G[1] / Poli.n;
   G[2] := G[2] / Poli.n;
   G[3] := G[3] / Poli.n;
end;
{---------------------------------------------------------------}

end.
