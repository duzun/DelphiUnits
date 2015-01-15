{********************************
   Autor: Dumitru Uzun (DUzun)
   Data: 25.05.2009
 ********************************}
unit CRT;

interface
const
       { CRT modes }
       BW40          = 0;            { 40x25 Black/White }
       CO40          = 1;            { 40x25 Color }
       BW80          = 2;            { 80x25 Black/White }
       CO80          = 3;            { 80x25 Color }
       Mono          = 7;            { 80x25 Black/White }
       Font8x8       = 256;          { Add-in for 80x43 or 80x50 mode }
     
       { Mode constants for Turbo Pascal 3.0 compatibility }
       C40           = CO40;
       C80           = CO80;

procedure readkey;
procedure writeln(param: array of const);
procedure write(param: array of const);

implementation
uses Dialogs, Windows, SysUtils;

const endl = #13#10;
var msg_buf: String;

procedure readkey;
begin
  if msg_buf <> '' then begin
     ShowMessage(msg_buf);
     msg_buf := '';
  end else begin
     Sleep(3000);
  end;
end;

procedure write(param: array of const);
var i, l: integer;
begin
  l := Length(param);
  i := 0;
  while i < l do with param[i] do begin
    case VType of
      vtInteger:    msg_buf := msg_buf + IntToStr(VInteger);
      vtInt64:      msg_buf := msg_buf + IntToStr(VInt64^);
      vtExtended:   msg_buf := msg_buf + FloatToStr(VExtended^);
      vtBoolean:    msg_buf := msg_buf + BoolToStr(VBoolean);
      vtChar:       msg_buf := msg_buf + (VChar);
      vtWideChar:   msg_buf := msg_buf + (VWideChar);
      vtString:     msg_buf := msg_buf + (VString^);
      vtPChar:      msg_buf := msg_buf + (VPChar);
      vtPWideChar:  msg_buf := msg_buf + (VPWideChar);
      vtAnsiString: msg_buf := msg_buf + String(PAnsiString(VAnsiString));
      vtWideString: msg_buf := msg_buf + String(PWideString(VWideString));
    end;
    inc(i);
  end;
end;

procedure writeln(param: array of const);
begin
  write(param);
  msg_buf := msg_buf + endl;
end;


begin
  msg_buf := '';
end.
