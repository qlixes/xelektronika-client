unit broker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdHTTP, IdURI, fpjson, jsonparser,
  Dialogs, Grids, Graphics, Controls;

{
 TODO : - change from JSONRequest to StrStreamRequest
        - adding any result with status error or not
}

const
  VERSION = '0.1';

type

  { TBroker }

  TBroker = class
  private
    FHTTP:TIdHTTP;
    FAddress:String;
    FJSONRequest:TStringStream;
    FResponseBody:String;
    FResponseHttp:String;
    FStatus: Boolean;
    FToken:String;
    FHost:String;
    FJSONArray:TJSONArray;
    FConnected:Boolean;
    procedure RedirectProc(Sender: TObject; var dest: string;
      var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
  protected
    FPage:Integer;
    procedure getJSONArray(const jsonStr:String); // return [ {}, {} ]
    function getJSONParser:TJSONParser;
    procedure httpPost(const AUrl:String);
    //procedure httpGet(const AUrl:String);
    //procedure httpPatch(const AUrl:String);
    //procedure httpDelete(const AUrl:String);
  public
    constructor Create;
    destructor Destroy;
    procedure setPage(const APage:Integer = 1);
    procedure setHost(AHost:String);
    procedure setJSONRequest(const ARequest:String);
    procedure getToken(const jsonStr:String);
    function httpRedirect(AURL:String):String;
  published
    // get hostname
    property Host:String read FHost;
    // check whether send/receive is success
    property Status:Boolean read FStatus;
    // result as response http
    property responseHttp:String read FResponseHttp;
    // result as response body
    property responseBody:String read FResponseBody;
    property responseToken:String read FToken;
    // get [ {}, {} ]
    property JSONArray:TJSONArray read FJSONArray;
    property Page:Integer read FPage;
    property Connected:Boolean read FConnected;
  end;

  { TJSONGrid }

  TJSONGrid = class
  private
    FStrGrid:TStringGrid;
    FJSONArray:TJSONArray;
    FStatus:Boolean;
    //FTextStyle:TTextStyle;
    procedure writeTitle(AJSONObject:TJSONObject);
    function setAlignRight:TTextStyle;
    function setAlignLeft:TTextStyle;
    function setAlignCenter:TTextStyle;
  protected
  public
    constructor Create;
    //procedure setDateTimeSeparator(const ADate:Char = '/'; ATime:Char = ':');
    //procedure setShortDateTime(const ADate:String = 'dd/MM/yyyy'; ATime:String = 'HH:mm:ss');
    procedure getJSONArrays(AJSONArray:TJSONArray);
    procedure setStringGrid(var AStrGrid:TStringGrid);
    //procedure writeGrid(jsonStr:String);
    procedure writeToGrid;
    property Status:Boolean read FStatus;
  end;

  { TJSONWebservices }

  TJSONWebservices = class(TBroker)
  private
    // result as
    FStrList:TStringList;
    //FDoc:TCSVDocument;
    //FXLS:TFPSpreadsheet;
  protected
  public
    procedure getLogin;
    procedure getRoot; // transaction name
    procedure getTransaksi(ATransaction:String; AStart, AEnd:TDateTime; AWithStore:String = ''; AWithInvoice: String = '';
      AShowPayment:SmallInt = 0);
    procedure getStore(const AidStore:Integer = -1;AStore:String = ''; AShowDetail:SmallInt = 0);
    procedure getStok (const ANoStok:String = ''; ANamaStok:String = '');
    procedure getDetail(AId:Integer);
    function getItemsStrList(AField:String):TStringList;
    function getNamesStrList(const AIndex:Integer = 0):TStringList;
    function getTxAliasStrList:TStringList;
    function getTxName(AAlias:String):String;
    function getResPage:Integer; //per halaman
    function getResPages:Integer; // total halaman
  end;

implementation

var
  counter, i, j:integer;
  FJSONObject:TJSONObject;
  //FJSONArray:TJSONArray;
  FParser:TJSONParser;

{ TJSONWebservices }

procedure TJSONWebservices.getLogin;
begin
  //setJSONRequest(responseToken);
  httpPost('/login');
  getJSONArray(responseBody);
end;

procedure TJSONWebservices.getRoot;
begin
  //post dengan token
  setJSONRequest(responseToken);
  httpPost('/');
  getJSONArray(responseBody);
end;

procedure TJSONWebservices.getTransaksi(ATransaction: String; AStart,
  AEnd: TDateTime; AWithStore: String; AWithInvoice: String;
  AShowPayment: SmallInt);
var
  FStart, FEnd, FWithStore, FWithInvoice, FShowPayment, FPath:String;
begin
  // fixed parameter
  FStart:='start='+FormatDateTime('yyyy-MM-dd', AStart);
  FEnd:='end='+FormatDateTime('yyyy-MM-dd', AEnd);
  FShowPayment:='payment='+inttostr(AShowPayment);
  FWithStore:='store='+Trim(AWithStore);
  FWithInvoice:='invoice='+Trim(AWithInvoice);
  FPath:=FStart+'&'+FEnd+'&'+FShowPayment;
  if AWithStore <> '' then
    FPath:=FPath+'&'+FWithStore;
  if AWithInvoice <> 'Invoices' then
    FPath:=FPath+'&'+FWithInvoice;
  setJSONRequest(responseToken);
  httpPost('/apps/'+getTxName(ATransaction)+'/'+IntToStr(Page)+'?'+FPath); // default apps/<transaksi>/1
  getJSONArray(responseBody);
end;

procedure TJSONWebservices.getStore(const AidStore: Integer; AStore: String;
  AShowDetail: SmallInt);
var
  FPath, FShowDetail, FStore, FIdStore:String;
begin
  FShowDetail:='show_detail='+IntToStr(AShowDetail);
  FIdStore:='id='+IntToStr(AIdStore);
  FStore:='store='+Trim(AStore);
  FPath:='?'+FShowDetail;
  if AIdStore >= 0 then
    FPath:=FPath+'&'+FIdStore;
  if AStore <> '' then
    FPath:=FPath+'&'+FStore;
  //setJSONRequest(responseToken);
  httpPost('/store'+FPath);
  getJSONArray(responseBody);
end;

procedure TJSONWebservices.getStok(const ANoStok: String; ANamaStok: String);
var
  FPath, FNoStok, FNamaStok:String;
begin
  FNoStok:='nostok='+Trim(ANoStok);
  FNamaStok:='namastok='+Trim(ANamaStok);
  if ANoStok <> '' then
    FPath:='?'+FNoStok;
  if ANamaStok <> '' then
    FPath:='?'+FNamaStok;
  //setJSONRequest(responseToken);
  httpPost('/stok'+FPath);
  getJSONArray(responseBody);
end;

procedure TJSONWebservices.getDetail(AId: Integer);
begin
  httpPost('/detail/'+inttostr(AId));
  getJSONArray(responseBody);
end;

function TJSONWebservices.getItemsStrList(AField: String): TStringList;
begin
  FStrList:=TStringList.Create;
  for counter:=0 to JSONArray.Count-1 do
    FStrList.Add(JSONArray.Objects[counter].Strings[AField]);
  result:=FStrList;
end;

function TJSONWebservices.getNamesStrList(const AIndex: Integer): TStringList;
begin
  FStrList:=TStringList.Create;
  for counter:=0 to JSONArray.Count-1 do
    FStrList.Add(JSONArray.Objects[counter].Names[AIndex]);
  result:=FStrList;
end;

function TJSONWebservices.getTxName(AAlias: String): String;
begin
  // as example TJSONObject.FindPath('$field[$id]').AsString
  // case { Field:[pos_val1, pos_val2]}
  //fStr:=AAlias+'[0]';
  getRoot; //DISINI YG REQUEST T_T
  //result:=FJSONArray.Objects[0].FindPath(fstr).AsString;
  result:=FJSONArray.Objects[0].Strings[AAlias];
end;

function TJSONWebservices.getResPage: Integer;
begin
  try
    FJSONObject:=getJSONParser.Parse as TJSONObject;
    //if (FJSONObject.Strings['page'] <> '') then
    result:=strtoint(FJSONObject.Strings['page'])
  except
    result:=1;
  end;
end;

function TJSONWebservices.getResPages: Integer;
begin
  try
    FJSONObject:=getJSONParser.Parse as TJSONObject;
    //if (FJSONObject.Strings['pages'] <> '') then
    result:=strtoint(FJSONObject.Strings['pages'])
  except
    result:=1;
  end;
end;

function TJSONWebservices.getTxAliasStrList: TStringList;
begin
  FStrList:=TStringList.Create;
  // only have 1 array object
  FJSONObject:=JSONArray.Objects[0];
  for counter:=0 to FJSONObject.Count-1 do //begin
    //fStr:=FJSONObject.Names[counter]+'[0]';
    //FStrList.Add(FJSONObject.FindPath(fStr).AsString);
    FStrList.Add(FJSONObject.Names[counter]);
  //end;
  result:=FStrList;
end;

{ TJSONGrid }

constructor TJSONGrid.Create;
begin
  inherited Create;
  FJSONArray:=TJSONArray.Create;
end;

procedure TJSONGrid.getJSONArrays(AJSONArray: TJSONArray);
begin
  FJSONArray:=AJSONArray;
end;

procedure TJSONGrid.writeTitle(AJSONObject: TJSONObject);
begin
  //FStrGrid.RowCount:=1;
  if AJSONObject.Count = 0 then
    FStrGrid.RowCount:=2
  else
    FStrGrid.ColCount:=AJSONObject.Count;
  for counter:=0 to AJSONObject.Count-1 do
    FStrGrid.Cells[counter, 0]:=UpperCase(AJSONObject.Names[counter]);
end;

function TJSONGrid.setAlignRight: TTextStyle;
var
  FTextStyle:TTextStyle;
begin
  FTextStyle:=FStrGrid.DefaultTextStyle;
  FTextStyle.Alignment:=taRightJustify;
  result:=FTextStyle;
end;

function TJSONGrid.setAlignLeft: TTextStyle;
var
  FTextStyle:TTextStyle;
begin
  FTextStyle:=FStrGrid.DefaultTextStyle;
  FTextStyle.Alignment:=taLeftJustify;
  result:=FTextStyle;
end;

function TJSONGrid.setAlignCenter: TTextStyle;
var
  FTextStyle:TTextStyle;
begin
  FTextStyle:=FStrGrid.DefaultTextStyle;
  FTextStyle.Alignment:=taCenter;
  result:=FTextStyle;
end;

procedure TJSONGrid.writeToGrid;
var
  FTotalNetto: Currency;
begin
  FStrGrid.BeginUpdate;
  if FJSONArray.Count = 0 then
    FStrGrid.RowCount:=2
  else
    begin
    FStrGrid.RowCount:=FJSONArray.Count+1; // +1 untuk title
    writeTitle(FJSONArray.Objects[0]); // ambil record=0 utk title
    for i:=0 to FJSONArray.Count-1 do begin
      FJSONObject:=FJSONArray.Objects[i];
      //FStrGrid.ColCount:=FJSONObject.Count;
      for j:=0 to FJSONObject.Count-1 do //begin
        case FJSONObject.Names[j] of
          'tgl','tglkirim': FStrGrid.Cells[j, i+1]:=FJSONObject.Items[j].AsString;
          'discrp0','discrp1','ppnrp','biayarp0','biayarp1','totalbruto','totalppn','totaldisc', 'hpp', 'totalhpp':FStrGrid.Cells[j, i+1]:=FormatCurr('#,##0.#0', FJSONObject.Items[j].AsFloat);
          'totalnetto': begin
            FStrGrid.Cells[j, i+1]:=FormatCurr('#,##0.#0', FJSONObject.Items[j].AsFloat);
            FTotalNetto:=FJSONObject.Items[j].AsFloat;
          end;
          'bayar': begin
            FStrGrid.Cells[j, i+1]:=FormatCurr('#,##0.#0', FJSONObject.Items[j].AsFloat);
            FStatus:=FTotalNetto = FJSONObject.Items[j].AsFloat;
            if not FStatus then FStrGrid.Canvas.Brush.Color:=clRed;
          end;
          'discpersen0', 'discpersen1', 'ppnpersen', 'sisa', 'banyaknya' : FStrGrid.Cells[j, i+1]:=FormatCurr('#,##0.#0', FJSONObject.Items[j].AsFloat);
          'nomor':FStrGrid.Cells[j, i+1]:=IntToStr(FJSONObject.Items[j].AsInt64);
        else
          FStrGrid.Cells[j, i+1]:=FJSONObject.Items[j].AsString;
        end;
      end;
    end;
  FStrGrid.AutoSizeColumns;
  FStrGrid.AutoAdjustColumns;
  FStrGrid.EndUpdate(True);
end;

procedure TJSONGrid.setStringGrid(var AStrGrid: TStringGrid);
begin
  FStrGrid:=AStrGrid;
end;

{ TBroker }

procedure TBroker.getJSONArray(const jsonStr: String);
begin
  FParser:=TJSONParser.Create(jsonStr);
  FJSONObject:=FParser.Parse as TJSONObject;
  FJSONArray:=FJSONObject.Arrays['result'];
end;

function TBroker.getJSONParser: TJSONParser;
begin
  result:=TJSONParser.Create(FResponseBody);
end;

constructor TBroker.Create;
begin
  inherited Create;
  FHttp:=TIdHTTP.Create;
  FPage:=1;
end;

destructor TBroker.Destroy;
begin
  inherited Destroy;
  FJSONRequest.Free;
  FHTTP.Free;
end;

procedure TBroker.setPage(const APage: Integer);
begin
  FPage:=APage;
end;

procedure TBroker.setHost(AHost: String);
begin
  FHost:=AHost;
end;

procedure TBroker.setJSONRequest(const ARequest: String);
begin
  try
    FJSONRequest:=TStringStream.Create(ARequest);
    FStatus:=True;
  except
    on E: EIdHTTPProtocolException do begin
      ShowMessage('Please logout then login again.');
      FStatus:=False;
      //ShowMessage(E.Message);
      //ShowMessage(E.ErrorMessage);
    end;
  end;
end;

procedure TBroker.httpPost(const AUrl: String);
begin
  //try
  if FStatus then begin
    FHTTP.Request.Accept:='application/json';
    FHTTP.Request.ContentType:='application/json';
    FHTTP.Request.AcceptCharSet:='utf-8';
    // check if URI is correct
    //ShowMessage('httppost='+TIdURI.URLEncode(FHost+AURL));
    FResponseBody:=FHTTP.Post(TIdURI.URLEncode(FHost+AURL), FJSONRequest);
    FResponseHttp:=FHTTP.ResponseText; //response
    FStatus:=True;
  end;
  //except
    //on E: EIdHTTPProtocolException do begin
      //ShowMessage(E.Message);
    //ShowMessage('Please login again.');
    //FStatus:=False;
    //Exit;
    //end;
  //end;
  //FJSONRequest.Free;
end;

{ Thanks to DNR <https://stackoverflow.com/users/1984211/dnr> }
procedure TBroker.RedirectProc(Sender: TObject; var dest: string;
  var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
begin
  FAddress := dest;
end;

// get session token after logged in
procedure TBroker.getToken(const jsonStr: String);
begin
  //FParser:=TJSONParser.Create(jsonStr);
  //FJSONObject:=FParser.Parse as TJSONObject;
  //FJSONArray:=FJSONObject.Arrays['result'];
  try
    getJSONArray(jsonStr);
  //FJSONObject:=FJSONArray.Objects[0]; // get {"token":""}
  //FToken:=FJSONObject.AsJSON;
    FToken:=FJSONArray.Objects[0].AsJSON;
    FStatus:=True;
  except
    //on E:Exception do
    //  ShowMessage(E.Message);
    ShowMessage('Your session has expired.');
    FStatus:=False;
  end;
end;

function TBroker.httpRedirect(AURL: String): String;
begin
  try
    with FHTTP do begin
      HandleRedirects:=True;
      OnRedirect:=@RedirectProc;
      Get(AURL);
    end;
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
  result:=FAddress
end;

end.

{
program Project1;

uses
  fpjson, jsonparser;

var
  s:String;
  Parser:TJSONParser;
  Arr:TJSONArray;
  i: integer;
begin
  s :=
  '['+
      '{"NAME":"Patricia","SEX":"Female","COUNTRY":"Wales; "},'+
      '{"NAME":"Pauline","SEX":"Female","COUNTRY":"Scotland; "},'+
      '{"NAME":"Quinterie","SEX":"Female","COUNTRY":"France; "},'+
      '{"NAME":"Salome","SEX":"Female","COUNTRY":"Israel; "},'+
      '{"NAME":"Sandra","SEX":"Female","COUNTRY":"Wales; "},'+
      '{"NAME":"Sigourney","SEX":"Female","COUNTRY":"England; "},'+
      '{"NAME":"Silvia","SEX":"Female","COUNTRY":"Scotland; "},'+
      '{"NAME":"Sonia","SEX":"Female","COUNTRY":"Italy; "},'+
      '{"NAME":"Veronica","SEX":"Female","COUNTRY":"Ireland; "},'+
      '{"NAME":"Viviane","SEX":"Female","COUNTRY":"France; "}'+
  ']';

  Parser:=TJSONParser.Create(s);
  Arr := Parser.Parse as TJSONArray;
  WriteLn('Array of ',Arr.Count);
  for i := 0 to Arr.Count - 1 do
  begin
    SubObj := Arr.Objects[i];
    WriteLn(i+1, ': ', SubObj.Strings['NAME'], ', ', SubObj.Strings['SEX'], ', ', SubObj.Strings['COUNTRY']);
  end;
  readln;
  //...etc
end.


procedure TJSONGrid.setStrGrid(var AStrGrid: TStringGrid);
begin
  FStrGrid:=AStrGrid;
  FStrGrid.BeginUpdate;
end;

function TJSONGrid.setJsonString(const AjsStr: String): TJSONObject;
begin
  FJsonData:=GetJSON(AjsStr);
  //FJsonObject:=TJSONObject(FJsonData);
end;

procedure TJSONGrid.setGridTitle(const AString: String); // {}
var
  i:integer;
begin
  FObjTitle:=TJSONObject(GetJSON(AString));
  for i:=0 to FObjTitle.Count-1 do
    FStrGrid.Cells[i, 0]:=FObjTitle.Names[i];
end;

procedure TJSONGrid.SetGridContent(const AString: String); // [{},{}]
var
  i,j:integer;
begin
  FParser:=TJSONParser.Create(AString);
  FJSONArray:=FParser.Parse as TJSONArray;
  for i:=0 to FJSONArray.Count-1 do begin
      FObjContent:=FJSONArray.Objects[i]; //baris
      for j:=0 to FObjContent.Count-1 do
          FStrGrid.Cells[i+1, j]:=FObjContent.Items[j].AsString;
  end;
end;


program project1;

uses
  fpjson, jsonparser;

var
  s:String;
  Parser:TJSONParser;
  Obj, SubObj:TJSONObject;
  Arr:TJSONArray;
  i: integer;
begin

  s :=
      '{'+
      '    "personaggi" : ['+
      '        {'+
      '            "val1" : "pippo",'+
      '            "val2" : "2014-11-18T10:25:38.486320Z",'+
      '            "val3" : 1,'+
      '            "val4" : 2'+
      '        },'+
      '        {'+
      '            "val1" : "pluto",'+
      '            "val2" : "2014-11-18T10:25:38.486320Z",'+
      '            "val3" : 1,'+
      '            "val4" : 2'+
      '        },'+
      '        {'+
      '            "val1" : "minni",'+
      '            "val2" : "2014-11-18T10:25:38.486320Z",'+
      '            "val3" : 1,'+
      '            "val4" : 2'+
      '        }'+
      '    ]'+
      '}  ';
  Parser:=TJSONParser.Create(s);
  Obj := Parser.Parse as TJSONObject;
  Arr := Obj.Arrays['personaggi'];
  WriteLn(Arr.Count);
  for i := 0 to Arr.Count - 1 do
  begin
    SubObj := Arr.Objects[i];
    WriteLn(SubObj.Strings['val1']);
    WriteLn(SubObj.Strings['val2']);
    WriteLn(SubObj.Strings['val3']);
    WriteLn(SubObj.Strings['val4']);
  end;
end.

}
