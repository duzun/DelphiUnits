unit UBaze;

interface

const cifre='0123456789ABCDEF';

FUNCTION cif(n: byte): char;
function num(c: char): byte;
function valoare(sir: string; baza: byte): longword;
function sirnum(val: longword; baza: byte): string;
function convert(sir: string; bi, br: byte): string;

implementation

FUNCTION cif(n: byte): char; begin cif := cifre[n mod 16 + 1]; end;
function num(c: char): byte; begin num := pos(upcase(c), cifre) - 1; end;

function valoare(sir: string; baza: byte): longword;
var a, u: longword;
    i, n, l: byte;
begin
  valoare := 0;
  if(not (baza in [2..16])) then exit;
  a := 0;
  l := length(sir);
  u := 1;
  for i := l downto 1 do begin
     n := num(sir[i]);
     if (n = 255)or(n >= baza) then exit;
     a := a + n * u;
     u :=u * baza;
  end;
  valoare := a;
end;

function sirnum(val: longword; baza: byte): string;
var a: string;
    c: byte;
begin
  sirnum := 'NaN';
  if (not (baza in [2..16])) or (val<0) then exit;
  a := '';
  repeat
     c := val mod baza;
     a := cif(c) + a;
     val := val div baza;
  until val = 0;
  sirnum := a;
end;

function convert(sir: string; bi, br: byte): string;
begin convert := sirnum(valoare(sir, bi), br); end;

BEGIN

END.
