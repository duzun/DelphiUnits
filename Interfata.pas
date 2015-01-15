{****************************************************
 * Author  : Dumitru Uzun
 * Web     : http://duzun.me
 * Created : 02.05.2009
 * History:
 *  
 *    03.06.2009:
 *      ReadNr, ReadInt
 *       
 *    22.01.2010
 *      FontToCSS, CanvasToCSS, ControlToCSS, ColorToStr, Trim, Quote
 *       
 *    22.01.2010   
 *      UniqueElement, UnifyNameValues, QuoteNVValues     
 * 
 *
 *    Acest modul contine subprograme pentru
 *  manipularea informatiei textuale din diferite
 *  componente vizuale (si nu numai) - citire/scriere.
 *
 ****************************************************}

unit Interfata;

interface
uses StdCtrls, ComCtrls, ExtCtrls, SysUtils, Menus, Classes, Graphics,
     Dialogs, Controls;
(*-----------------------------------------------------------------*)
const  endl   = #13#10; {End Line}
(*-----------------------------------------------------------------*)
var
   FormatSettings: TFormatSettings;
   FloatPrecision: Integer;
   FloatDigits:    Integer;
(*-----------------------------------------------------------------*)
{ Daca e specificat CSS, va avea prioritate asupra proprieratilor Font } 
function FontToCSS(Font: TFont; CSS: String=''): String;

function CanvasToCSS(Canvas: TCanvas; CSS: String): String;   overload;
function CanvasToCSS(Canvas: TCanvas; incFont: boolean=true): String;  overload;

function ControlToCSS(Control: TControl; CSS: String): String; overload;
function ControlToCSS(Control: TControl; Canvas: TCanvas=nil): String; overload;

function RGBColor(Color: TColor): TColor;
function ColorToStr(Color: TColor): String;

function Trim(S: String; Chars: String): String; overload;
function Quote(S: String; QuoteCh: Char='"'): String;
function QuoteNVValues(S: TStrings; QuoteCh: Char='"'): TStrings;

{ Formeaza instructiunea de atribuire: " VarName := Val ; " }
function ValToVar(const VarName: string; Val: string): string;

{Citeste o expresie Pascal din Edit}
function ReadExpr(Sender: TObject): string;

{Citirea/Scrierea textului din/in componenta vizuala Sender}
function PutText (Sender: TObject; s: String): Boolean;
function ReadText(Sender: TObject): String;

{Obtile link la Lines sau Items dintr-un Control}
function GetStrings(Sender: TObject): TStrings;

function FindControl(Parent: TWinControl; PartName: String; ClType: TClass=nil): TControl;
function FindCtrlText(Parent: TWinControl; PartName: String; ClType: TClass=nil): String;
function TextFindCtrl(Text: String; Parent: TWinControl; PartName: String; ClType: TClass=nil): TControl;

{Citeste textul din Sender, asigurand formatul numeric corect}
function ReadNr  (Sender: TObject): String;
function ReadInt (Sender: TObject): String;

function OGetNr  (Sender: TObject): Extended;
function OGetInt (Sender: TObject): Int64;

{Formateaza un string care contine un numar real}
function FormatFloatStr(Nr: String; Precision:Integer=0; Digits:Integer=0; Exp:Boolean=false): String;
function FloatStrToInt(Nr: String; Factor: real=1): integer;
function StrToReal(Nr: String): Extended;
function RealToStr(Nr: Extended; Precision:Integer=0; Digits:Integer=0; Exp:Boolean=false): String;

{Inpartirea unui text intr-o lista}
function Split(const Delimiter: Char; Input: string; const Strings: TStrings; DelNil: boolean=false): TStrings; overload;
function Split(const Delimiters: String; Input: string; const Strings: TStrings; DelNil: boolean=false): TStrings; overload;

{Unirea elementelor unei liste intr-un text}
function Join(const Delimiter: String; Input: TStrings; DelNil: boolean=false): string;

{Elems se considera o lista de elemente separate prin oricare din caracterele Delim.
 Se elimina orice element repetat. Separatorul nou va fi Delim[1] sau '' }
function UniqueElement(Elms: String; Delim: String): String;

{Uneste mai multe siruri ce contin perechi nume-valoare, eliminand toate repetarile numelui.
 Valoarea asociata fiecarui nume este utima valoare intalnita. }
function UnifyNameValues(Param: array of const; NameValueSeparator: Char='='; Delimiter: String='|'#13#10 ): String;

function StrGetNr(Str: String): String;    // Citeste doar numarul din Str, restul se ignora
function StrGetInt(Str: String): String;   // Citeste doar numarul intreg din Str, restul se ignora
function StrToNr(Str: String): Extended;   // Analogic StrGetNr
function StrToIntNr(Str: String): Int64; // Analogic StrGetInt
function NumToStr(v: Extended; prec: byte=0): String;  // Obtine reprezentarea v cu max prec cifre in mantisa

function Max(x, y: Integer): Integer;
function Min(x, y: Integer): Integer;
(*-----------------------------------------------------------------*)
implementation
//uses Compilator;
uses Windows, ActnList, Forms;

type TMGControl=class(TGraphicControl) public property Canvas; property Color; end;
type TMControl =class(TControl) public property Color; end;

   function GetCtrlCanvas(Ctrl: TControl): TCanvas;
   begin
      Result := nil;
      if Ctrl is TGraphicControl then
         Result := TMGControl(Ctrl).Canvas;
   end;

   function GetCtrlColor(Ctrl: TControl): TColor;
   begin
      Result := TMControl(Ctrl).Color;
   end;
(*-----------------------------------------------------------------*)
function Max(x, y: Integer): Integer; begin if x > y then Result := x else Result := y; end;
function Min(x, y: Integer): Integer; begin if x < y then Result := x else Result := y; end;
(*-----------------------------------------------------------------*)
function ValToVar(const VarName: string; Val: string): string;
begin
  if Val = '' then Val := '''''';
  if VarName = '' then Result := ''
                  else Result := VarName + ' := ' + Val + ';' + endl ;
end;
(*-----------------------------------------------------------------*)
type TCtrlTxt = class(TControl) public property Text; end;

function PutText(Sender: TObject; s: String): Boolean;
begin
  Result := false;
  if not Assigned(Sender) then Exit;
  Result := true;
  if(Sender is TStrings)     then TStrings(Sender).Text := s else
  if(Sender is TCustomUpDown)then TUpDown(Sender).Position := StrToIntNr(s) else
// All descendants of TControl have Text or Caption property
  if(Sender is TControl)     then TCtrlTxt(Sender).Text := s else
// Derived from TComponent
  if(Sender is TMenuItem)    then TMenuItem(Sender).Caption := s else
  if(Sender is TCustomAction)then TCustomAction(Sender).Caption := s else
                             Result := false;
//   s := Sender.ClassName;
end;
(*-----------------------------------------------------------------*)
function ReadText(Sender: TObject): String;
begin
  Result := '';
  if not Assigned(Sender) then Exit;
  if(Sender is TStrings)     then Result := TStrings(Sender).Text else
  if(Sender is TCustomUpDown)then Result := IntToStr(TUpDown(Sender).Position) else
// All descendants of TControl have Text or Caption property
  if Sender is TControl      then Result := TCtrlTxt(Sender).Text else
// Derived from TComponent
  if(Sender is TMenuItem)    then Result := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll]) else
  if(Sender is TCustomAction)then Result := StringReplace(TCustomAction(Sender).Caption, '&', '', [rfReplaceAll]) else
                                  Result := '';
end;
(*-----------------------------------------------------------------*)
function GetStrings(Sender: TObject): TStrings;
begin
  Result := nil;
  if Sender = nil then Exit;
  if Sender is TCustomMemo    then Result := TCustomMemo(Sender).Lines else
  if Sender is TCustomCombo   then Result := TCustomCombo(Sender).Items else
  if Sender is TCustomListBox then Result := TCustomListBox(Sender).Items else
  if Sender is TStrings       then Result := TStrings(Sender);
end;
(*-----------------------------------------------------------------*)
function FindControl;
var i: integer;
begin
   Result := nil;
   if not Assigned(Parent) then Exit;
   i := Parent.ControlCount;
   PartName := LowerCase(PartName);
   while i>0 do begin
     dec(i);
     Result := Parent.Controls[i];
     with Result do begin
       if (not Assigned(ClType) or (Result is ClType)) and
          (Pos(PartName, LowerCase(Name)) > 0) then Exit;

       if (Result is TWinControl) and (TWinControl(Result).ControlCount>0) then
       begin
          Result := FindControl(TWinControl(Result), PartName, ClType);
          if Result <> nil then Exit;
       end;
     end;
   end;
   Result := nil;
end;
function FindCtrlText(Parent: TWinControl; PartName: String; ClType: TClass=nil): String;
begin
  Result := ReadText(FindControl(Parent, PartName, ClType));
end;
function TextFindCtrl(Text: String; Parent: TWinControl; PartName: String; ClType: TClass=nil): TControl;
begin
  Result := FindControl(Parent, PartName, ClType);
  if (Result <> nil) and not PutText(Result, Text) then Result := nil;
end;
(*-----------------------------------------------------------------*)
function StrGetInt(Str: String): String;
var i, j: integer;
    c, Sep: Char;
begin
   i := 1;
   Str := Trim(Str);
   if Str = '' then Str := '0' else
   if Str[i] in ['-','+'] then begin Result := Str[i]; inc(i) end else
   Result := '';

   {Corectam separatorul zecimal}
   Sep := FormatSettings.DecimalSeparator;
   if Sep = '.' then c := ',' else c := '.';
   j := Pos(c, Str);
   if j > 0 then Str[j] := Sep;
   j := i;

   {Partea intreaga}
   while (i <= Length(Str)) and (Str[i] in ['0'..'9']) do inc(i);
   if i>j then Result := Result + Copy(Str, j, i-j) else Result := '0';
//   j := i;
end;
(*-----------------------------------------------------------------*)
function StrGetNr(Str: String): String;
var i, j, l: integer;
    c, Sep: Char;
begin
   i := 1;
   Str := Trim(Str);
   if Str = '' then Str := '0' else
   if Str[i] in ['-','+'] then begin Result := Str[i]; inc(i) end else
   Result := '';
   l := Length(Str);

   {Corectam separatorul zecimal}
   Sep := FormatSettings.DecimalSeparator;
   if Sep = '.' then c := ',' else c := '.';
   j := Pos(c, Str);
   if j > 0 then Str[j] := Sep;
   j := i;

   {Partea intreaga}
   while (i <= l) and (Str[i] in ['0'..'9']) do inc(i);
   if i>j then Result := Result + Copy(Str, j, i-j) else Result := '0';
   j := i;

   {Mantisa}
   if(i<=l)and(Str[i]=Sep) then begin
      inc(i);
      while (i <= l) and (Str[i] in ['0'..'9']) do inc(i);
      if i-1>j then Result := Result + Copy(Str, j, i-j);
      j := i;
   end;

   {Exponentul}
   if(i<l)and(UpCase(Str[i])='E')and(Str[i+1] in ['-','+']) then begin
     inc(i, 2);
     while (i <= l) and (Str[i] in ['0'..'9']) do inc(i);
     if i-2>j then Result := Result + Copy(Str, j, i-j);
   end;
end;
(*-----------------------------------------------------------------*)
function OGetNr  (Sender: TObject): Extended; begin Result := StrToFloat(ReadNr(Sender), FormatSettings); end;
function OGetInt (Sender: TObject): Int64;  begin Result := StrToInt(ReadInt(Sender)); end;
(*-----------------------------------------------------------------*)
function StrToIntNr(Str: String): Int64;  begin Result := StrToInt64(StrGetInt(Str)); end;
function StrToNr   (Str: String): Extended; begin Result := StrToFloat(StrGetNr(Str)); end;
(*-----------------------------------------------------------------*)
function ReadNr  (Sender: TObject): String;
var s: string;
begin
   s := ReadText(Sender);
   Result := StrGetNr(s);
   if Result <> s then PutText(Sender, Result);
end;
(*-----------------------------------------------------------------*)
function ReadInt (Sender: TObject): String;
var s: string;
begin
   s := ReadText(Sender);
   Result := StrGetInt(s);
   if Result <> s then PutText(Sender, Result);
end;
(*-----------------------------------------------------------------*)
function ReadExpr(Sender: TObject): string;
var i: integer;
    state: integer;
    Sep: char;
begin
   Result := Trim(ReadText(Sender));
   Sep := FormatSettings.DecimalSeparator;
   state  := 0;
   i      := 1;
   while i < length(Result) do begin
      case state of
      0: case UpCase(Result[i]) of  {operator}
         '0'..'9': state := 2;
         'A'..'Z', '_': state := 1;
         else if Result[i] = Sep then
             state := 2;
         end;
      1: case UpCase(Result[i]) of  {identificator}
         '0'..'9', 'A'..'Z', '_': ;
         else state := 0;
         end;
      2: case UpCase(Result[i]) of  {numar}
         'A'..'Z', '_':
            begin
               Insert('*', Result, i);
               inc(i);
               state := 1;
            end;
         '(':
            begin
              Insert('*', Result, i);
              inc(i);
              state := 0;
            end;
         '0'..'9', '.': ;
         else  state := 0;
         end;
      end;
      inc(i);
   end;
   PutText(Sender, Result);
end;
(*-----------------------------------------------------------------*)
function Trim(S: String; Chars: String): String; overload;
var b, e: integer;
begin
  b := 1;
  e := Length(S);
  while(b<=e)and(Boolean(Pos(S[b], Chars))) do inc(b);
  while(b<=e)and(Boolean(Pos(S[e], Chars))) do dec(e);
  Result := Copy(S, b, e-b+1);
end;
(*-----------------------------------------------------------------*)
function Quote(S: String; QuoteCh: Char): String;
begin
  if S = '' then Result := QuoteCh+QuoteCh else
  begin
    if (Length(S)>1)and(S[1]=QuoteCh)and(S[Length(S)]=QuoteCh) then Result := S
    else Result := QuoteCh + StringReplace(S, QuoteCh, QuoteCh+QuoteCh, [rfReplaceAll]) + QuoteCh;
  end;
end;
(*-----------------------------------------------------------------*)
function QuoteNVValues(S: TStrings; QuoteCh: Char='"'): TStrings;
var i: Integer;
begin
   Result := S;
   if not Boolean(S) then Exit;
   i := S.Count;
   while Boolean(i) do begin
     dec(i);
     S.ValueFromIndex[i] := Quote(S.ValueFromIndex[i], QuoteCh);
   end;
end;
(*-----------------------------------------------------------------*)
function Split(const Delimiter: Char; Input: string; const Strings: TStrings; DelNil: boolean=false): TStrings;
var d: String; b,e: integer;
begin
   if Delimiter = ' ' then
      Result := Split(' '#13#10#9, Input, Strings, DelNil) else
   begin
     Assert(Assigned(Strings)) ;
     Result := Strings;
     Result.Clear;
     e := e xor e;
     repeat
       inc(e); b := e;
       while (e <= Length(Input)) and (Input[e] <> Delimiter) do inc(e);
       d := Copy(Input, b, e-b);
       if not DelNil or (Trim(d) <> '') then Result.Append(d);
     until e > Length(Input);
   end;
end;

function Split(const Delimiters: String; Input: string; const Strings: TStrings; DelNil: boolean=false): TStrings;
var d: String; b,e: integer;
begin
   Assert(Assigned(Strings)) ;
   Result := Strings;
   Result.Clear;
   e := e xor e;
   repeat
     inc(e); b := e;
     while (e <= Length(Input)) and (not Boolean(Pos(Input[e], Delimiters))) do inc(e);
     d := Copy(Input, b, e-b);
     if not DelNil or (Trim(d) <> '') then Result.Append(d);
   until e > Length(Input);
end;
(*-----------------------------------------------------------------*)
function Join(const Delimiter: String; Input: TStrings; DelNil: boolean=false): string;
var i: integer;
begin
   Assert(Assigned(Input)) ;
   if not Boolean(Input.Count) then Result := '' else
   begin
     Result := Input.Strings[0];
     i := 1;
     while i < Input.Count do begin
       if not DelNil or (Input.Strings[i] <> '') then
          Result := Result + Delimiter + Input.Strings[i];
       inc(i);
     end;
   end;
end;
(*-----------------------------------------------------------------*)
function UniqueElement(Elms: String; Delim: String): String;
var L: TStringList;
    i: Integer;
begin
  Result := '';
  if Elms = '' then Exit;
  L := TStringList.Create;
  try
    Split(Delim, Elms, L, true);
    L.Sort;
    i := L.Count;
    while i > 0 do begin
       dec(i);
       Elms := L.Strings[i];
       while (i > 0) and (L.Strings[i-1]=Elms) do begin
          L.Delete(i);
          dec(i);
       end;
    end;
    if Delim <> '' then Delim := Delim[1];
    Result := Join(Delim, L);
  finally L.Free end;
end;
(*-----------------------------------------------------------------*)
function UnifyNameValues(Param: array of const; NameValueSeparator: Char; Delimiter: String): String;
const cTrim = ' ''"'#13#10#9; // Caracterele eliminate din nume si valoare, daca se intalnesc la margine
var L, S: TStringList;
    T: TStrings;
    i, j: integer;
    buf: String;
begin
  Result := '';
  if not Boolean(Length(param)) then Exit;
  i := 0;
  L := TStringList.Create;
  S := TStringList.Create;
  T := nil;
  try
    L.NameValueSeparator := NameValueSeparator;
    S.NameValueSeparator := NameValueSeparator;
    while i < Length(Param) do with Param[i] do begin
      case VType of
        vtChar:       buf := String(VChar);
        vtWideChar:   buf := (VWideChar);
        vtString:     buf := (VString^);
        vtPChar:      buf := (VPChar);
        vtPWideChar:  buf := (VPWideChar);
        vtAnsiString: buf := String(PAnsiString(VAnsiString));
        vtWideString: buf := String(PWideString(VWideString));
        vtObject:    if VObject is TStrings then begin
                         T := TStrings(VObject);
                         buf := '';
                     end;
        else buf := '';
      end;
      inc(i);
      if buf <> '' then begin
        T := S;
        Split(Delimiter, buf, T, true);
      end;
      if Boolean(T) then begin
        j := 0;
        while j < T.Count do begin
          buf := Trim(T.Names[j], cTrim);
          if buf <> '' then L.Values[buf] := Trim(T.ValueFromIndex[j], cTrim);
          inc(j);
        end;
        T := nil;
      end;
    end;
    S.Clear;
    if Delimiter <> '' then Delimiter := Delimiter[1];
    Result := Join(Delimiter, L);
  finally L.Free; S.Free; end;
end;
(*-----------------------------------------------------------------*)
function NumToStr(v: Extended; prec: byte=0): string;
var s: string;
    t: Extended;
begin
   t := Int(abs(v));
   if t <> 0 then begin
     s := '';
     repeat
       s := Chr(Trunc(t) mod 10 + Ord('0')) + s ;
       t := Int(t/10);
     until t = 0;
     if v < 0 then s := '-' +  s;
   end else s := '0';

   t := Frac(abs(v));
   if (prec <> 0) and (t <> 0) then begin
     s := s + '.';
     repeat
       t := t * 10;
       s := s + Chr(Trunc(t)+Ord('0'));
       t := Frac(t);
       dec(prec);
     until (prec = 0) or (t = 0);
   end;
   NumToStr := s;
end;
(*-----------------------------------------------------------------*)
function FormatFloatStr(Nr: String; Precision:Integer=0; Digits:Integer=0; Exp:Boolean=false): String;
begin
   Result := RealToStr(StrToFloat(Trim(Nr), FormatSettings), Precision, Digits, Exp);
end;
(*-----------------------------------------------------------------*)
function FloatStrToInt(Nr: String; Factor: real=1): integer;
begin
   Result := trunc(StrToFloat(Nr, FormatSettings)*Factor);
end;
(*-----------------------------------------------------------------*)
function StrToReal(Nr: String): Extended; begin Result := StrToFloat(Nr, FormatSettings);end;
(*-----------------------------------------------------------------*)
function RealToStr(Nr: Extended;Precision:Integer=0; Digits:Integer=0; Exp:Boolean=false): String;
var Format: TFloatFormat;
    Buffer: PAnsiChar;
begin
  if Exp then Format := ffExponent else Format := ffFixed;
  if Digits    = 0 then Digits    := FloatDigits;
  if Precision = 0 then Precision := FloatPrecision;
  Buffer := AllocMem(256);
  Digits := FloatToText(Buffer, Nr, fvExtended,  Format, Precision, Digits, FormatSettings);
  Buffer[Digits] := #0;
  Result := String(Buffer);
  FreeMem(Buffer);
end;
(*-----------------------------------------------------------------*)
function RGBColor(Color: TColor): TColor;
begin
   if Color and clSystemColor = clSystemColor then
      Result := GetSysColor(Color and not clSystemColor)
   else Result := Color;
end;
(*-----------------------------------------------------------------*)
function ColorToStr(Color: TColor): String;
begin
  if Color = clNone then Result := '' else begin
    Color := RGBColor(Color);
    Result := '#' + IntToHex(($FF and Color)shl 16 or (Color shr 16) and $FF or Color and $FF00, 6);
  end;
end;
(*-----------------------------------------------------------------*)
function ControlToCSS(Control: TControl; CSS: String): String; overload;
var Styles: TStringList;
begin
   Result := '';
   if not Boolean(Control) then Exit;
   Styles := TStringList.Create;
   with Styles do try
     NameValueSeparator := ':';

     Values['position'] := 'absolute';
     Values['top']  := IntToStr(Control.Top)+'px';
     Values['left'] := IntToStr(Control.Left)+'px';

     if Boolean(Control.Height) then Values['height'] := IntToStr(Control.Height)+'px';
     if Boolean(Control.Width)  then Values['width']  := IntToStr(Control.Width)+'px';
     if not Control.Visible then Values['visibility'] := 'hidden'
                            else Values['visibility'] := 'visible';

//     Styles.Sort;
     if CSS <> '' then Result := UnifyNameValues([Styles, CSS],':', ';')
                  else Result := Join(';', Styles);

   finally Styles.Free; end;
end;

function ControlToCSS(Control: TControl; Canvas: TCanvas=nil): String;
begin
   if not Boolean(Canvas) then Canvas := GetCtrlCanvas(Control);
   Result := ControlToCSS(Control, CanvasToCSS(Canvas, true));
end;
(*-----------------------------------------------------------------*)
function CanvasToCSS(Canvas: TCanvas; incFont: boolean=true): String;
var css: string;
begin
   if not Boolean(Canvas) then Result := '' else
   begin
     if incFont and Boolean(Canvas.Font) then css := FontToCSS(Canvas.Font) else css := '';
     Result := CanvasToCSS(Canvas, css);
   end;  
end;

function CanvasToCSS(Canvas: TCanvas; CSS: String): String;
var Styles: TStringList;
    border_style: string;
begin
   Result := '';
   if not Boolean(Canvas) then Exit;
   Styles := TStringList.Create;
   with Styles do try
     NameValueSeparator := ':';

     case Canvas.Pen.Style of
       psSolid             : border_style := 'solid';
       psDash, psDashDot   : border_style := 'dashed';
       psDot, psDashDotDot : border_style := 'dotted';
       psClear             : border_style := 'none';
       psInsideFrame       : border_style := 'ridge';
     end;

     Values['border'] := Format('%dpx %s ',[Canvas.Pen.Width, border_style])+ColorToStr(Canvas.Pen.Color);
     Values['background-color'] := ColorToStr(Canvas.Brush.Color);

//     Styles.Sort;
     if CSS <> '' then Result := UnifyNameValues([Styles, CSS],':', ';')
                  else Result := Join(';', Styles);

   finally Styles.Free; end;
end;
(*-----------------------------------------------------------------*)
function FontToCSS(Font: TFont; CSS: String): String;
var Styles: TStringList;
begin
   { Charset: TFontCharset;  Pitch: TFontPitch; }
   Result := '';
   if not Boolean(Font) then Exit;
   Styles := TStringList.Create;
   with Styles do try
     NameValueSeparator := ':';

//     if CSS <> '' then Split(';', CSS, Styles, true);
     Values['text-color']  := ColorToStr(Font.Color);
     Values['font-family'] := Font.Name;
     Values['font-size']   := IntToStr(Font.Size)+'pt';
     With Font do begin
       if fsBold      in Style then Values['font-weight']      := 'bold';
       if fsItalic    in Style then Values['font-style']       := 'italic';
       if fsUnderline in Style then Values['text-decoration']  := 'underline';
       if fsStrikeOut in Style then Values['text-decoration']  := Values['text-decoration'] + ' line-through';
     end;

     if CSS <> '' then Result := UnifyNameValues([Styles, CSS],':', ';')
                  else Result := Join(';', Styles);

   finally Styles.Free; end;
end;
(*-----------------------------------------------------------------*)
initialization
  {Setarile implicite pentru formatarea numerelor reale}
  GetLocaleFormatSettings(0, FormatSettings);
  FormatSettings.DecimalSeparator := '.';  {Indiferent de setarile din sistem, separatorul zecimal va fi '.'}
  FloatPrecision := 30;
  FloatDigits    := 10;

end.
