{****************************************************
 * Author  : Dumitru Uzun
 * Web     : http://duzun.me
 * Created : 03.05.2009
 *
 *  Acest modul reprezinta o interfata de subprograme
 * destinate simularii modulului Graph din TurboPascal.
 *
 *
 * Istorie:
 * - 23.05.2009
 *   Am adaugat InitGraph si FCanvas
 * - 25.05.2009
 *   Am adaugat constantele pentru culori   
 ****************************************************}

unit Graph;

interface
uses Graphics, Classes, Forms, Dialogs, SysUtils, Types;

(*-----------------------------------------------------------------*)
const
    { Foreground and background color constants }
      BLACK     = clBlack;
      WHITE     = clWhite;
      RED       = clRed;
      GREEN     = clGreen;
      BLUE      = clBlue;
      YELLOW    = clYellow;
      GREY      = clGray;
      DarkGray  = clDkGray;
      LightGray = clLtGray;
      CYAN      = clAqua;
      Magenta   = clFuchsia;
      BROWN     = TColor($004B96);

(*-----------------------------------------------------------------*)
type PointType = TPoint;
     PointList = array[1..200] of PointType;

     TColor = Graphics.TColor;
(*-----------------------------------------------------------------*)
function  InitGr(APicture: TPicture; aWidth: integer = 0; aHeight: integer = 0): boolean;
procedure SetGrSize(mx: integer=0; my: integer=0);
procedure CloseGraph;
function  GraphOk: boolean;

procedure ClearViewPort;

procedure SetColor(Color: TColor);
procedure SetFillColor(Color: TColor);
procedure SetTextColor(Color: TColor);
procedure SetBkColor(Color: TColor);

function  GetColor: TColor;
function  GetFillColor: TColor;
function  GetTextColor: TColor;
function  GetBkColor: TColor;

function GetMaxX: integer;
function GetMaxY: integer;
function GetMidX: integer;
function GetMidY: integer;
function GetPixel(x, y: integer): TColor;

function GetX: integer;
function GetY: integer;

procedure MoveTo(x,y: integer);
procedure LineTo(x,y: integer);
procedure MoveRel(Dx,Dy: integer);
procedure LineRel(Dx,Dy: integer);
procedure Line(x1, y1, x2, y2: integer);
procedure PutPixel(x, y: integer; Color: TColor);

procedure Rectangle(x1, y1, x2, y2: integer);
procedure Ellipse(x1, y1, x2, y2: integer);
procedure Circle(x, y, r: integer);
procedure FillPoly(Vert: Array of TPoint); overload
procedure FillPoly(NumVert: Word; var Vert: Array of TPoint); overload

procedure TextOut(x, y: integer; Text: string);
procedure OutText(Text: string);
function  TextWidth (Text: string): integer;
function  TextHeight(Text: string): integer;

(*-----------------------------------------------------------------*)
{Functii pentru compatibilitate cu TP}
procedure InitGraph(gd, gm: integer; Path: String=''); {InitGr}
procedure OutTextXY(x, y: integer; Text: string);   {TextOut}
function  GraphResult: integer;
(*-----------------------------------------------------------------*)
const grOk     = 0;
      DETECT   = 0;
      DefRatio = 3 / 4;  { DefMaxX / DefMaxY }
      DefMaxX  = 800;
      DefMaxY  = Trunc(DefMaxX * DefRatio);
(*-----------------------------------------------------------------*)
function GetPic: TPicture;
(*-----------------------------------------------------------------*)
implementation
var FPicture : TPicture;
    FCanvas  : TCanvas;
    FOwnBmp  : boolean;
    FBkColor : TColor;
    FGrResult: Integer;

(*-----------------------------------------------------------------*)
function GetPic: TPicture; begin Result := FPicture; end;
(*-----------------------------------------------------------------*)
procedure chkGr; begin Assert(GraphOk, 'Modul grafic nu a fost initializat!'); end;
procedure FreeBmp;
begin
  if FOwnBmp and Assigned(FPicture.Bitmap) then begin
    FPicture.Bitmap.Free;
    FPicture.Bitmap := nil;
    FOwnBmp := false;
  end;
end;
procedure Lock; begin FCanvas.Lock; end;
procedure UnLock; begin FCanvas.UnLock; end;
(*-----------------------------------------------------------------*)
procedure FillPoly(Vert: Array of TPoint);
begin Lock; FCanvas.Polygon(Vert); Unlock; end;
(*-----------------------------------------------------------------*)
procedure FillPoly(NumVert: Word; var Vert: Array of TPoint);
var Verts: array of TPoint;
    i: integer;
begin
  SetLength(Verts, NumVert);
  i := NumVert;
  while i > 0 do begin
    dec(i);
    Verts[i] := Vert[i];
  end;
  Lock; FCanvas.Polygon(Verts); Unlock;
end;
(*-----------------------------------------------------------------*)
procedure SetGrSize(mx: integer=0; my: integer=0);
var ax, ay: integer;
begin
  if not Assigned(FPicture) then Exit;
  if not GraphOk then Exit;
  if my <> 0 then ay := my else if mx = 0 then ay := DefMaxY else ay := Round(mx * DefRatio);
  if mx <> 0 then ax := mx else if my = 0 then ax := DefMaxX else ax := Round(my / DefRatio);
  with FPicture do
    if not Assigned(Bitmap) then begin
      FOwnBmp := true;
      Bitmap := TBitmap.Create;
      Bitmap.PixelFormat := pf32bit;
      Bitmap.Width  := ax;
      Bitmap.Height := ay;
    end else with Bitmap do begin
      if (mx <> 0) or (Width  = 0) then Width  := ax;
      if (my <> 0) or (Height = 0) then Height := ay;
    end;
end;
(*-----------------------------------------------------------------*)
function InitGr(APicture: TPicture; aWidth: integer = 0; aHeight: integer = 0): boolean;
begin
  Result := Assigned(APicture);
  if not Result then Exit;
  if FPicture <> APicture then begin
    if GraphOk then FreeBmp;
    FPicture := APicture;
    if not Assigned(FCanvas) then FCanvas := FPicture.Bitmap.Canvas;
  end;
  SetGrSize(aWidth, aHeight);
  FBkColor := GetFillColor;
  ClearViewPort;
end;
(*-----------------------------------------------------------------*)
procedure CloseGraph;
begin
  FreeBmp;
  FCanvas := nil;
  FPicture := nil;
end;
(*-----------------------------------------------------------------*)
function GraphOk: boolean; begin Result := Assigned(FPicture) and Assigned(FPicture.Bitmap) or Assigned(FCanvas); end;
(*-----------------------------------------------------------------*)
procedure ClearViewPort;
var Cl: TColor;
begin
  Lock;
  Cl := GetFillColor;
  SetFillColor(FBkColor);
  FCanvas.FillRect(FCanvas.ClipRect);
  SetFillColor(Cl);
  Unlock;
end;
(*-----------------------------------------------------------------*)
procedure SetColor(Color: TColor);     begin Lock; FCanvas.Pen.Color := Color;   Unlock; end;
procedure SetFillColor(Color: TColor); begin Lock; FCanvas.Brush.Color := Color; Unlock; end;
procedure SetTextColor(Color: TColor); begin Lock; FCanvas.Font.Color := Color;  Unlock; end;
Procedure SetBkColor(Color: TColor);   begin FBkColor := Color; end;
(*-----------------------------------------------------------------*)
function  GetColor: TColor;            begin Result := FCanvas.Pen.Color;   end;
function  GetFillColor: TColor;        begin Result := FCanvas.Brush.Color; end;
function  GetTextColor: TColor;        begin Result := FCanvas.Font.Color; end;
function  GetBkColor: TColor;          begin Result := FBkColor; end;
(*-----------------------------------------------------------------*)
function GetMaxX: integer; begin with FCanvas.ClipRect do Result := (Right); end;
function GetMaxY: integer; begin with FCanvas.ClipRect do Result := (Bottom); end;
function GetMidX: integer; begin Result := GetMaxX div 2; end;
function GetMidY: integer; begin Result := GetMaxy div 2; end;
function GetX: integer; begin Result := FCanvas.PenPos.X; end;
function GetY: integer; begin Result := FCanvas.PenPos.Y; end;
(*-----------------------------------------------------------------*)
function GetPixel(x, y: integer): TColor; begin Lock; Result := FCanvas.Pixels[x, y]; Unlock; end;
procedure PutPixel(x, y: integer; Color: TColor);begin Lock; FCanvas.Pixels[x, y]:=Color; Unlock; end;
(*-----------------------------------------------------------------*)
procedure MoveTo(x,y: integer);begin FCanvas.MoveTo(x,y); end;
procedure LineTo(x,y: integer);begin Lock; FCanvas.LineTo(x,y); Unlock; end;
procedure MoveRel(Dx,Dy: integer);begin MoveTo(GetX+Dx,GetY+Dy); end;
procedure LineRel(Dx,Dy: integer);begin LineTo(GetX+Dx,GetY+Dy); end;
procedure Line(x1, y1, x2, y2: integer);begin MoveTo(x1, y1); LineTo(x2, y2);end;
(*-----------------------------------------------------------------*)
procedure Rectangle(x1, y1, x2, y2: integer);begin Lock;FCanvas.Rectangle(Rect(x1,y1,x2,y2));Unlock;end;
procedure Ellipse(x1, y1, x2, y2: integer);  begin Lock;FCanvas.Ellipse(x1,y1,x2,y2);Unlock;end;
procedure Circle(x, y, r: integer);          begin Lock;FCanvas.Ellipse(x-r,y-r,x+r,y+r);Unlock;end;
(*-----------------------------------------------------------------*)
procedure TextOut(x, y: integer; Text: string); begin chkGr; Lock;FCanvas.TextOut(x, y, Text);Unlock; end;
procedure OutText(Text: string);begin chkGr; Lock;with FCanvas do TextOut(PenPos.X, PenPos.Y, Text);Unlock;end;
function TextWidth(Text: string): integer; begin chkGr; Result := FCanvas.TextWidth(Text); end;
function TextHeight(Text: string): integer; begin chkGr; Result := FCanvas.TextHeight(Text); end;
(*-----------------------------------------------------------------*)
{Aditionale}
(*-----------------------------------------------------------------*)
procedure InitGraph(gd, gm: integer; Path: String='');
begin
  if GraphOk then FGrResult := 0 else
  if not Assigned(Application.MainForm) then FGrResult := 1 else
  if (Application.MainForm.GetFormImage = nil) then FGrResult := 2 else
  begin
    if not Assigned(FPicture) then begin // Just for compatibility
      FPicture := TPicture.Create;
      FPicture.Bitmap := Application.MainForm.GetFormImage; //???
    end;
    FCanvas := Application.MainForm.Canvas;
    FGrResult := 0;
    with Application.MainForm do InitGr( FPicture, Width, Height );
  end;
end;

function GraphResult: integer; begin if not GraphOk then Result := FGrResult else Result := grOk; end;
procedure OutTextXY(x, y: integer; Text: string); begin TextOut(x,y,Text) end;

(*-----------------------------------------------------------------*)
begin
   FOwnBmp  := false;
   FBkColor := clBlack;
   FGrResult := 0;
end.
