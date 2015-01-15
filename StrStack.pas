{****************************************************
 * Author  : Dumitru Uzun
 * Web     : http://duzun.me
 * Repo    : https://github.com/duzun/DelphiUnits
 * Created : 03.02.2010
 *
 *  O extensie a clasei TStringList.
 *  Poate fi utilizat in calitate de stiva, coada sau pur si simplu lista
 *  de elemente de tip Integer, Real sau String.
 *   
 * Proprietati:  
 *   Items[Index: Integer]: TObject - Accesarea obiectelor asociate elementelor
 *   Count: Integer      - Numarul de elemente din stiva.
 *   Memo : TCustomMemo  - Componenta TMemo in care se va scrie rezultatul
 *   Mirror: TPersistent - O un obiect derivat din TStrings pentru a se sinhroniza cu Self
 *   Text : String       - Accesarea stivei ca un text.
 *
 * Proceduri:
 *   ToMemo - Scrie continutul stivei in Memo
 *   ToMirror - Sinhronizeaza cu Mirror. (Este kemat automat)
 *   Clear  - Curate stiva
 *   SortNumbers(Dir: Integer=1); // 1 - asscending, -1 - desscending
 *   Sort(Dir: Integer=1);        // 1 - asscending, -1 - desscending
 *   
 *   // Comparatia numerica si alfanumerica
 *   CompNumbers(Index1, Index2: Integer): Integer;
 *   CompStr(Index1, Index2: Integer): Integer;
 *
 * Accesul la date:
 *   Str[Index: Integer]: String   
 *   Int[Index: Integer]: Integer  
 *   Flt[Index: Integer]: Extended 
 *    
 *  Index = 0 este primul element. Index = Count-1 este ultimul element. 
 *  Daca Index < 0, se indexseaza de la urma (Index = -1 este ultimul element).
 *  La atribuire, daca Index = Count, se adauga un nou element.
 *  La citire, daca Index = Count - eroare
 *  Index > Count - eroare 
 *   
 *   LastStr: String   
 *   LastInt: Integer  
 *   LastFlt: Extended 
 *
 *   FirstStr: String  
 *   FirstInt: Integer 
 *   FirstFlt: Extended
 *
 *   // Adaugarea elementelor la coada
 *   function Push(S: String; AObject: TObject=nil)  : String; 
 *   function Push(R: Extended; AObject: TObject=nil): String; 
 *
 *   // Adaugarea elementelor in fata
 *   function UnShift(S: String; AObject: TObject=nil)  : String; 
 *   function UnShift(R: Extended; AObject: TObject=nil): String; 
 *
 *   // Extragerea elementelor de la coada
 *   function Pop      : String;   
 *   function PopReal  : Extended; 
 *   function PopInt   : Integer;  
 *   function PopObj   : TObject;  
 *
 *   // Extragerea elementelor din fata
 *   function Shift    : String;   
 *   function ShiftReal: Extended; 
 *   function ShiftInt : Integer;  
 *   function ShiftObj : TObject;   
 *    
 * Istorie:
 *
 ****************************************************}
unit StrStack;
{$M+}
interface
uses Interfata, Windows, Classes, StdCtrls, SysUtils, Forms;

resourcestring
   SList2IndexError = 'Array second index out of bounds (%d)';

type
TArrayInt64 = array of int64;
TArrayInt = array of integer;
TStrStack = class(TStringList)
  private
    FLock      : TRTLCriticalSection;
    FMemo      : TCustomMemo;
    Fb         : TBits;
    FItemIndex : Integer;
    FMirror    : TPersistent;
    FMirrorCall: Boolean;

// private Methods
    function  GetItems(Index: Integer): TObject;
    procedure SetItems(Index: Integer; AObject: TObject); virtual;

    function  GetStr(Index: Integer): String;
    function  GetFlt(Index: Integer): Extended;
    function  GetInt(Index: Integer): Int64;
    function  GetChr(Index, Pos: Integer): Char;
    function  GetByt(Index, Pos: Integer): Byte;
    function  GetBit(Index, Pos: Integer): Boolean;

    procedure SetStr(Index: Integer; const Value: String);
    procedure SetFlt(Index: Integer; const Value: Extended);
    procedure SetInt(Index: Integer; const Value: Int64);
    procedure SetChr(Index, Pos: Integer; const Value: Char);
    procedure SetByt(Index, Pos: Integer; const Value: Byte);
    procedure SetBit(Index, Pos: Integer; const Value: Boolean);

    procedure SetMemo(const Value: TCustomMemo);
    procedure SetMirror(Value: TPersistent);
    procedure SetMirrorCall(const Value: Boolean);

    function  GetItemIndex: Integer;
    procedure SetItemIndex(Index: Integer);

    function  GetSelItem: TObject;
    procedure SetSelItem(const Value: TObject);

    function  GetB(Index: byte): Boolean;
    procedure SetB(Index: byte; const Value: Boolean);

    function GetCount: Integer;

    function GetSelStr: PChar;
    function GetSelInt: Int64;
    procedure SetSelStr(const Value: PChar);
    procedure SetSelInt(const Value: Int64);

  protected
    function  Get(Index: Integer): String;          override;
    procedure Put(Index: Integer; const S: String); override;
    procedure SetCount(Value: Integer); virtual; // ceva nou fata de TStrings

    // Urmatoarele sunt pentru a adauga Lock/Unlock la metodele mostenite
    procedure SetTextStr(const Value: String); override;
    procedure InsertItem(Index: Integer; const S: string; AObject: TObject); virtual;

    procedure WriteToMirror; virtual;
    procedure WriteToMemo;   virtual;

    procedure Changed; override;
    function  CheckIndex(var Index: Integer; raise_:Boolean=true): Integer;

    // MirrorCall ajuta pentru a evita recursia circulara a Self si Mirror la OnChange
    property MirrorCall: Boolean read FMirrorCall write SetMirrorCall;

    property SBits[Index: Byte]: Boolean read GetB write SetB;

  public
    OnSelect:   TNotifyEvent;
    OnDeselect: TNotifyEvent;

    constructor Create;
    destructor  Destroy; override;

    procedure Lock  (Update: integer = 0); dynamic;
    procedure UnLock(Update: integer = 0); dynamic;

    // Urmatoarele sunt pentru a adauga Lock/Unlock la metodele mostenite
    procedure Clear; override;
    procedure Assign(Source: TPersistent); override;
    procedure Exchange(Index1, Index2: Integer); override;
    procedure CustomSort(Compare: TStringListSortCompare); virtual;
    
    function  Sum: Extended;
    function  SumInt: Int64;
    function  Ints: TArrayInt64;

    // Incrementari / Decrementari
    function  Inc(Idx: integer; Val: Extended=1): Int64;
    function  Dec(Idx: integer; Val: Extended=1): Int64;
    function  DecFirst(Val: Extended=1): Int64;
    function  IncFirst(Val: Extended=1): Int64;
    function  DecLast(Val: Extended=1): Int64;
    function  IncLast(Val: Extended=1): Int64;


    function  CompNumbers(Index1, Index2: Integer): Integer;
    function  CompStr(Index1, Index2: Integer): Integer;
    procedure SortNumbers(Dir: Integer=1); overload;// 1 - asscending, -1 - desscending

    procedure ToMemo;  virtual;
    procedure ToMirror;

    // Lucrul cu componentele
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: TObject read GetItems write SetItems; // ~ Objects[Index]
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property SelItem: TObject read GetSelItem write SetSelItem;
    property SelStr: PChar read GetSelStr write SetSelStr;
    property SelInt: Int64 read GetSelInt write SetSelInt;

    property FirstItem: TObject Index  0 read GetItems write SetItems;
    property LastItem : TObject Index -1 read GetItems write SetItems;

    // Eliminarea din lista
    procedure Delete(Index:Integer); Overload; override;         // Extrage fara sa-l distruga
    function  Delete(Item: TObject): Integer; Overload; virtual; // Extrage fara sa-l distruga
    function  Remove(Index:Integer): Boolean; OverLoad; virtual; // Distruge, daca e propriu
    function  Remove(Item: TObject): Integer; OverLoad; virtual; // Distruge, daca e propriu

    // Accesul la date
    property Str[Index: Integer]: String   read GetStr write SetStr;
    property Int[Index: Integer]: Int64    read GetInt write SetInt; default;
    property Flt[Index: Integer]: Extended read GetFlt write SetFlt;
    property Chr[Index: Integer; Pos: Integer]: Char read GetChr write SetChr;
    property Byt[Index: Integer; Pos: Integer]: Byte read GetByt write SetByt;
    property Bit[Index: Integer; Pos: Integer]: Boolean read GetBit write SetBit;

    property LastStr: String   index -1 read GetStr write SetStr;
    property LastInt: Int64    index -1 read GetInt write SetInt;
    property LastFlt: Extended index -1 read GetFlt write SetFlt;

    property FirstStr: String   index 0 read GetStr write SetStr;
    property FirstInt: Int64    index 0 read GetInt write SetInt;
    property FirstFlt: Extended index 0 read GetFlt write SetFlt;

    // Functii de stiva
    function Push(S: String; AObject: TObject=nil)  : String; overload;
    function Push(R: Extended; AObject: TObject=nil): String; overload;

    function UnShift(S: String; AObject: TObject=nil)  : String; overload;
    function UnShift(R: Extended; AObject: TObject=nil): String; overload;

    function Pop      : String;     virtual;
    function PopReal  : Extended;   virtual;
    function PopInt   : Integer;    virtual;
    function PopObj   : TObject;    virtual;

    function Shift    : String;     virtual;
    function ShiftReal: Extended;   virtual;
    function ShiftInt : Integer;    virtual;
    function ShiftObj : TObject;    virtual;

    procedure OnMirrorChanged(AMirror: TObject);

  published
    property Memo: TCustomMemo read FMemo write SetMemo;
    property Mirror: TPersistent read FMirror write SetMirror;
    property Text; // TStrings

  end;

  function is_main_thread: Boolean; // nu lucreaza in DLL

implementation
uses RTLConsts, Math;
{ TStrStack }

  function is_main_thread: Boolean;
  begin Result := Windows.GetCurrentThreadId() = System.MainThreadID end;

constructor TStrStack.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  OnSelect   := nil;
  OnDeselect := nil;
  FMemo      := nil;
  FItemindex := -1;
  Fb         := TBits.Create;
  FMirror    := nil;
  FMirrorCall:= false;
end;

destructor TStrStack.Destroy;
begin
  Lock; try
    FMirror := nil;
    FMemo := nil;
    Fb.Free;
    inherited Destroy;
  finally
    Unlock;
    DeleteCriticalSection(FLock);
  end;
end;

procedure TStrStack.SetCount(Value: Integer);
var i: integer;
begin
  i := GetCount;
  if (Value = i) then Exit;
  if (0 > Value) or (Value > MaxListSize) then
    raise ERangeError.CreateFmt('%d is not within the valid range of %d..%d', [Value, 0, MaxListSize]);

   Lock(1); try
   while i > Value do begin
     System.Dec(i);
     inherited Delete(i); // ! inherited - for speed
   end;
   if Value = 0 then inherited Clear else
   while i < Value do begin
     Add('');
     System.Inc(i);
   end;
   finally Unlock(1); end;
end;

function TStrStack.GetItems(Index: Integer): TObject;
begin
  if CheckIndex(Index, false) < 0 then Result := nil
  else Result := GetObject(Index);
end;

procedure TStrStack.SetItems(Index: Integer; AObject: TObject);
begin
  if CheckIndex(Index) < 0 then Exit;
  Lock(1); try
    PutObject(Index, AObject);
  finally Unlock(1) end;
end;

procedure TStrStack.Delete(Index: Integer);
begin
  if CheckIndex(Index) < 0 then Exit;
  Lock(1); try
     inherited Delete(Index);
  finally Unlock(1) end;
end;

function TStrStack.Delete(Item: TObject): Integer;
begin
  Result := IndexOfObject(Item);
  if Result < 0 then Exit;
  Lock(1); try
     inherited Delete(Result);
  finally Unlock(1) end;
end;

function TStrStack.Remove(Index: Integer): Boolean;
var d: TObject;
begin
  if (CheckIndex(Index) = -1) then Result := false
  else begin
    d := GetObject(Index);
    if Assigned(d) then begin
      if Index = ItemIndex then ItemIndex := -1;
      Delete(Index);
      d.Free;
    end;
    Result := true;
  end;
end;

function TStrStack.Remove(Item: TObject): Integer;
begin
  Result := IndexOfObject(Item);
  if Result = -1 then Exit;
  if not Remove(Result) then Result := -1;
end;

function TStrStack.PopObj: TObject;
begin
  if Boolean(Count) then Result := nil else
  begin
    Result := LastItem;
    Delete(Count-1);
  end ;
end;

function TStrStack.ShiftObj: TObject;
begin
  if not Boolean(Count) then Result := nil else
  begin
    Result := FirstItem;
    Delete(Count-1);
  end ;
end;

function TStrStack.Push(S: String; AObject: TObject): String;
begin
  Result := S;
  Lock(1); try
     AddObject(Result, AObject);
  finally Unlock(1) end;    
end;

function TStrStack.Push(R: Extended; AObject: TObject): String;
begin
   Result := Push(FloatToStr(R), AObject);
end;

function TStrStack.UnShift(S: String; AObject: TObject): String;
begin
  Result := S;
  Lock(1); try
     InsertObject(0, Result, AObject);
  finally Unlock(1) end;
end;

function TStrStack.UnShift(R: Extended; AObject: TObject): String;
begin
  Result := UnShift(FloatToStr(R), AObject);
end;

function TStrStack.Pop: String;
begin
  if Boolean(Count) then begin
    Result := LastStr;
    Delete(Count-1);
  end else Result := '';
end;

function TStrStack.PopReal: Extended;
begin
  Result := LastFlt;
  Delete(Count-1);
end;

function TStrStack.PopInt: Integer;
begin
  Result := LastInt;
  Delete(Count-1);
end;

function TStrStack.Shift: String;
begin
  Result := FirstStr;
  Delete(0);
end;

function TStrStack.ShiftReal: Extended;
begin
  Result := FirstFlt;
  Delete(0);
end;

function TStrStack.ShiftInt: Integer;
begin
  Result := FirstInt;
  Delete(0);
end;

function TStrStack.GetB(Index: byte): Boolean;
begin
  Result := (Index<Fb.Size) and Fb[Index];
end;

procedure TStrStack.SetB(Index: byte; const Value: Boolean);
var res: boolean;
begin
  res := Fb.Size <= Index; // Resize required
  if res and not Value or not res and (Value=Fb[Index]) then Exit;
  Lock; try
    if res then Fb.Size := Index+1;
    Fb[Index] := Value;
  finally Unlock end;
end;


function TStrStack.Get(Index: Integer): String;
begin
  CheckIndex(Index);
  Result := inherited Get(Index);
end;

procedure TStrStack.Put(Index: Integer; const S: String);
begin
  CheckIndex(Index);
  Lock(1); try
    inherited Put(Index, S);
  finally Unlock(1) end;
end;

function TStrStack.GetByt(Index, Pos: Integer): Byte;
begin
  Result := Byte(GetChr(Index, Pos));
end;

function TStrStack.GetChr(Index, Pos: Integer): Char;
var s: string;
begin
  if CheckIndex(Index, false) < 0 then s := '' else s := inherited Get(Index);
  if Pos < 0 then System.Inc(Pos, Length(s));
  System.Inc(Pos);
  if (Pos <= 0) or (Pos > Length(s)) then Result := #0
  else Result := s[Pos];
end;

function TStrStack.GetBit(Index, Pos: Integer): Boolean;
var b: Byte;
begin
  b := Byte(GetChr(Index, Pos shr 3));
  Result := (b and (1 shl (Pos and 7))) <> 0;
end;

function TStrStack.GetStr(Index: Integer): String;
begin
  if CheckIndex(Index, false) < 0 then Result := ''
  else Result := inherited Get(Index);
end;

function TStrStack.GetFlt(Index: Integer): Extended;
begin
  Result := StrToNr(GetStr(Index));
end;

function TStrStack.GetInt(Index: Integer): Int64;
begin
  Result := StrToIntNr(GetStr(Index));
end;

procedure TStrStack.SetChr(Index, Pos: Integer; const Value: Char);
var s: string;
    i: integer;
begin
  if Index > Count then Exit;
  BeginUpdate;
  if Index = Count then begin
    Count := Index+1;
    s := '';
  end else s := inherited Get(Index);

  i := Length(s);
  if Pos < 0 then System.Inc(Pos, i);
  System.Inc(Pos);
  if (Pos <= 0) then Error(@SList2IndexError, Pos);
  if (Pos <= i) then s[Pos] := Value
  else begin
    SetLength(s, Pos);
    FillMemory(PChar(s)+i, Pos-i, 0);
    s[Pos] := Value;
  end;
  Lock(1); try inherited Put(Index, s); finally Unlock(1) end;
  EndUpdate;
end;

procedure TStrStack.SetByt(Index, Pos: Integer; const Value: Byte);
begin
  SetChr(Index, Pos, Char(Value));
end;

procedure TStrStack.SetBit(Index, Pos: Integer; const Value: Boolean);
var i: integer;
    m: word;
    s: String;
begin
  if Index > Count then Exit;
  BeginUpdate;
  if Index = Count then begin
    Count := Index+1;
    s := '';
  end else s := inherited Get(Index);

  m := Byte(Value) shl (Pos and 7);
  Pos := (Pos shr 3) + 1;
  i := Length(s);
  if Pos <= i then s[Pos] := Char(Byte(s[Pos]) and (not m) or m)
  else begin
    SetLength(s, Pos);
    FillMemory(PChar(s)+i, Pos-i, 0);
    s[Pos] := Char(m);
  end;
  Lock(1); try inherited Put(Index, s); finally Unlock(1) end;
  EndUpdate;
end;

procedure TStrStack.SetStr(Index: Integer; const Value: String);
begin
  if Index > Count then Exit;
  BeginUpdate;
  if Index = Count then InsertObject(Count, Value, nil)
                   else Put(Index, Value);
  EndUpdate;
end;

procedure TStrStack.SetFlt(Index: Integer; const Value: Extended);
begin
  SetStr(Index, FloatToStr(Value));
end;

procedure TStrStack.SetInt(Index: Integer; const Value: Int64);
begin
  SetStr(Index, IntToStr(Value));
end;

procedure TStrStack.WriteToMemo;
begin
  if not Assigned(FMemo) then Exit;
  FMemo.Lines.Append(StringReplace(Trim(Text),#13#10, ', ', [rfReplaceAll]));
end;

procedure TStrStack.ToMemo;
begin
  TThread.Synchronize(nil, WriteToMemo);
end;

procedure TStrStack.SetMemo(const Value: TCustomMemo);
begin
  Lock; try
    FMemo := Value;
  finally Unlock end;
end;

function TStrStack.GetItemIndex: Integer;
begin
  if FItemIndex >= Count then FItemIndex := -1;
  Result := FItemIndex;
end;

procedure TStrStack.SetItemIndex(Index: Integer);
begin
   if FItemIndex = Index then Exit;

   if Assigned(OnDeselect) and (GetItemIndex > -1)
      then OnDeselect(Self);

   if (0 > Index) or (Index >= Count) then Index := -1;

   Lock; try FItemIndex := Index; finally Unlock end;

   if (Index >= 0) and Assigned(OnSelect)
      then OnSelect(Self);
end;

procedure TStrStack.SetSelItem(const Value: TObject);
begin
  if Value = nil then ItemIndex := -1 else
  ItemIndex := IndexOfObject(Value);
end;

function TStrStack.GetSelItem: TObject;
begin
  if (0 <= FItemIndex) and (FItemIndex < Count) then
    Result := GetObject(FItemIndex)
  else Result := nil;
end;

function TStrStack.CompStr(Index1, Index2: Integer): Integer;
begin
  Result := CompareStrings(Get(Index1), Get(Index2));
end;

function TStrStack.CompNumbers(Index1, Index2: Integer): Integer;
var r1,r2: Extended;
begin
   r1 := GetFlt(Index1);
   r2 := GetFlt(Index2);
   if r1 < r2 then Result := -1 else
   if r1 > r2 then Result :=  1 else
                   Result :=  0;
end;

  function StringListCompareNumbers(List: TStringList; Index1, Index2: Integer): Integer;
  begin
    Result := TStrStack(List).CompNumbers(Index1, Index2);
  end;
  function StringListCompareNumbersI(List: TStringList; Index1, Index2: Integer): Integer;
  begin
    Result := -TStrStack(List).CompNumbers(Index1, Index2);
  end;

procedure TStrStack.SortNumbers(Dir: Integer);
var i: Integer;
begin
  if not Boolean(Count) then Exit;
  i := ItemIndex;
  Lock(1); try
   ItemIndex := -1;
   if Dir < 0 then CustomSort(StringListCompareNumbersI)    // Desscending
              else CustomSort(StringListCompareNumbers);    // Asscending
   ItemIndex := i;
  finally Unlock(1) end;
end;

function TStrStack.CheckIndex;
begin
  if Index < 0 then System.Inc(Index, Count);
  if (Index < 0) or (Index >= Count) then
     Result := -1 else Result := Index;
  if raise_ and (Result < 0)
     then Error(@SListIndexError, Index);
end;

procedure TStrStack.Clear;
begin
  if inherited GetCount = 0 then Exit;
  Lock(1); try
    inherited Clear;
  finally Unlock(1) end;
end;

procedure TStrStack.Lock;
begin
   if Update <> 0 then BeginUpdate; // BeginUpdate poate kema un eveniment din alt fi de executie
   EnterCriticalSection(FLock);
end;

procedure TStrStack.UnLock;
begin
   LeaveCriticalSection(FLock);
   if Update <> 0 then EndUpdate;
end;

function TStrStack.Ints: TArrayInt64;
var i: integer;
begin
  i := Count;
  SetLength(Result, i);
  while Boolean(i) do begin
    System.Dec(i);
    Result[i] := StrToIntNr(inherited Get(i));
  end;
end;

procedure TStrStack.SetMirror;
var p: TObject;
begin
  p := GetStrings(Value);
  if (p = Self) or (FMirror = p) then Exit;
  Changing;
  Lock; try FMirror := TStrings(p); finally Unlock end;
  if Assigned(p) then begin
     if Value is TCustomEdit then
       if not Assigned(TMemo(Value).OnChange) then
          TMemo(Value).OnChange := OnMirrorChanged;
     if Value is TCustomCombo then
       if not Assigned(TComboBox(Value).OnChange) then
          TComboBox(Value).OnChange := OnMirrorChanged;
  end;
  Changed;
end;

procedure TStrStack.SetMirrorCall(const Value: Boolean);
begin
  if Value = FMirrorCall then Exit;
  Lock; try FMirrorCall := Value; finally Unlock end;
end;

procedure TStrStack.OnMirrorChanged(AMirror: TObject);
var p: TStrings;
    e: TNotifyEvent;
begin
  if MirrorCall then Exit;
  p := GetStrings(AMirror);
  if (p <> FMirror) and Assigned(p) then begin
     e := OnMirrorChanged;
     if AMirror is TCustomEdit then
       if @e = @TMemo(AMirror).OnChange then TMemo(AMirror).OnChange := nil;
     if AMirror is TCustomCombo then
       if @TComboBox(AMirror).OnChange = @e then TComboBox(AMirror).OnChange := nil;
     Exit;
  end;
  MirrorCall := true;
  Assign(p);
  MirrorCall := false;
end;

procedure TStrStack.ToMirror;
begin
  if not MirrorCall and Assigned(FMirror) and
     (not (FMirror is TStrings) or not Equals(TStrings(FMirror))) then
  begin
     TThread.Synchronize(nil, WriteToMirror);
  end;
end;

procedure TStrStack.WriteToMirror;
begin
  if not Assigned(FMirror) then Exit;
  MirrorCall := true; // Changed sets it to FALSE
  FMirror.Assign(Self);
end;

procedure TStrStack.Changed;
begin
  if UpdateCount <> 0 then Exit;
  ToMirror;
  inherited Changed;
  MirrorCall := false;
end;

function TStrStack.Sum: Extended;
var i: integer;
begin
  Result := 0;
  i := Count;
  while i > 0 do begin System.Dec(i); Result := Result + Flt[i]; end;
end;

function TStrStack.SumInt: int64;
var i: integer;
begin
  Result := 0;
  i := Count;
  while i > 0 do begin System.Dec(i); System.Inc(Result, Int[i]); end;
end;

procedure TStrStack.Assign(Source: TPersistent);
begin
  if (Source = Self) then Exit;
  if (Source is TStrings) and Equals(TStrings(Source)) then Exit;
  Lock(1); try
    if not Assigned(Source) then Clear else
    inherited Assign(Source)
  finally UnLock(1); end;
end;

procedure TStrStack.InsertItem; begin Lock(1); try inherited finally UnLock(1) end; end;
procedure TStrStack.SetTextStr; begin Lock(1); try inherited finally Unlock(1) end; end;

procedure TStrStack.CustomSort(Compare: TStringListSortCompare);
begin
  if Sorted then Exit;
  Lock(1); try inherited finally UnLock(1) end;
end;

procedure TStrStack.Exchange(Index1, Index2: Integer);
begin
  if CheckIndex(Index1) = CheckIndex(Index2) then Exit;
  Lock(1); try inherited finally UnLock(1) end;
end;

function TStrStack.GetCount: Integer;
begin
   Result := inherited GetCount;
end;

function TStrStack.GetSelStr: PChar;
begin
   if ItemIndex < 0 then Result := nil
   else Result := PChar(inherited Get(ItemIndex));
end;

procedure TStrStack.SetSelStr(const Value: PChar);
begin
   if ItemIndex < 0 then Exit;
   Put(ItemIndex, Value);
end;

function TStrStack.GetSelInt: Int64;
begin
   if ItemIndex < 0 then Result := 0
   else Result := StrToIntNr(inherited Get(ItemIndex));
end;

procedure TStrStack.SetSelInt(const Value: Int64);
begin
   if ItemIndex < 0 then Exit;
   Put(ItemIndex, IntToStr(Value));
end;

function TStrStack.DecFirst(Val: Extended): Int64;
begin
   Result := Dec(0, Val);
end;

function TStrStack.DecLast(Val: Extended): Int64;
begin
   Result := Dec(-1, Val);
end;

function TStrStack.IncFirst(Val: Extended): Int64;
begin
   Result := Inc(0, Val);
end;

function TStrStack.IncLast(Val: Extended): Int64;
begin
   Result := Inc(-1, Val);
end;

function TStrStack.Dec(Idx: integer; Val: Extended): Int64;
var v: Extended;
begin
    v := Flt[Idx];
    v := v - Val;
    Flt[Idx] := v;
    Result := Floor(v);
end;

function TStrStack.Inc(Idx: integer; Val: Extended): Int64;
var v: Extended;
begin
    v := Flt[Idx];
    v := v + Val;
    Flt[Idx] := v;
    Result := Floor(v);
end;

end.

