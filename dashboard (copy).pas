unit dashboard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, Forms, Controls,
  Graphics, Dialogs, Grids, ComCtrls, Menus, StdCtrls, ExtCtrls, Buttons,
  EditBtn, IdHTTP, IniFiles;

const
  DS = '/';

type

  { TForm1 }

  TForm1 = class(TForm)
    btnTransaksiXLS: TBitBtn;
    btnFirst2: TBitBtn;
    btnLast2: TBitBtn;
    btnNext2: TBitBtn;
    btnPrevious2: TBitBtn;
    btnRefresh1: TBitBtn;
    btnFirst1: TBitBtn;
    btnPrevious1: TBitBtn;
    btnNext1: TBitBtn;
    btnLast1: TBitBtn;
    btnExit: TButton;
    btnLogin: TButton;
    btnRefresh2: TBitBtn;
    Chart1: TChart;
    chbShowDetail: TCheckBox;
    chbShowPayment: TCheckBox;
    cbTransaksi: TComboBox;
    cbLokasi: TComboBox;
    dtStart: TDateEdit;
    dtEnd: TDateEdit;
    edNoInvoices: TEdit;
    edSearch: TEdit;
    edPage1: TEdit;
    edPage2: TEdit;
    edUsername: TEdit;
    edPassword: TEdit;
    FHTTP: TIdHTTP;
    MainMenu1: TMainMenu;
    iUser: TMenuItem;
    iLogout: TMenuItem;
    iStok: TMenuItem;
    iTransaksi: TMenuItem;
    Memo2: TMemo;
    iAbout: TMenuItem;
    PageControl1: TPageControl;
    rgStok: TRadioGroup;
    sgTransaksi1: TStringGrid;
    StatusBar1: TStatusBar;
    sgTransaksi: TStringGrid;
    Timer1: TTimer;
    tsStok: TTabSheet;
    tsTransaksi: TTabSheet;
    tsLogin: TTabSheet;
    procedure btnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
  private
    FHost, FLogin, FTransaksi, FStok, FStore:String;
    { private declarations }
    FConfig:TIniFile;
    FRequest:TStringStream;
    FResponse, FHTTPResponse:String;
    procedure CustomStatusBar(var AStatusBar:TStatusBar);
    procedure setLoginRequestBody(const username, password: String);
    procedure setTokenRequestBody(const token:String);
    procedure postToURL(const AURL:String); // with request.args.get()
    function jsonToList(const AJson:String):TStringList;
  public
    { public declarations }
    property Host:String read FHost;
    property ResponseBody:String read FResponse;
    property ResponseHTTP:String read FHTTPResponse;
  end;

var
  Form1: TForm1;
  counter:integer;

implementation

uses
  IdURI, fpjson, jsonparser;

var
  jsonObject:TJSONObject;

function parseTojsonObject(AjsonStr:String):TJSONObject;
begin
  result:=TJSONObject(GetJSON(AjsonStr));
end;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FConfig:=TIniFile.Create(ChangeFileExt(Application.ExeName, '.cfg'));
  FHost:='http://'+FConfig.ReadString('appdesktop', 'host', 'localhost:5000');
  CustomStatusBar(StatusBar1);
  StatusBar1.Panels.Items[0].Text:=FHost;
end;

procedure TForm1.iAboutClick(Sender: TObject);
begin
  ShowMessage('developer : Anton <qlixess@gmail.com>');
end;

procedure TForm1.btnLoginClick(Sender: TObject);
begin
  setLoginRequestBody(edUsername.Text, edPassword.Text);
  postToURL(FHost+'/login');
  StatusBar1.Panels.Items[1].Text:=FResponse;
  tsStok.TabVisible:=True;
  tsTransaksi.TabVisible:=True;
  tsLogin.TabVisible:=False;
end;

procedure TForm1.CustomStatusBar(var AStatusBar: TStatusBar);
var
  maxWidth:Integer;
begin
  maxWidth:=Form1.Width div AStatusBar.Panels.Count;
  for counter:=0 to AStatusBar.Panels.Count-1 do begin
    AStatusBar.Panels.Items[counter].Width:=maxWidth;
  end;
end;

procedure TForm1.setLoginRequestBody(const username, password: String);
begin
  try
    FRequest:=TStringStream.Create('{"username":"'+username
      +'","password":"'+password+'"}');
  except
    on E: EIdHTTPProtocolException do begin
        ShowMessage(E.Message);
        ShowMessage(E.ErrorMessage);
    end;
  end;
end;

procedure TForm1.setTokenRequestBody(const token: String);
begin
  try
    FRequest:=TStringStream.Create(token);
  except
    on E: EIdHTTPProtocolException do begin
      ShowMessage(E.Message);
      ShowMessage(E.ErrorMessage);
    end;
  end;
end;

procedure TForm1.postToURL(const AURL: String);
begin
  try
    FHTTP.Request.Accept:='application/json';
    FHTTP.Request.ContentType:='application/json';
    FResponse:=FHTTP.Post(TIdURI.URLEncode(AURL), FRequest);
    StatusBar1.Panels.Items[1].Text:=FResponse;
    FHTTPResponse:=FHTTP.ResponseText;
  except
    on E: EIdHTTPProtocolException do begin
      ShowMessage(E.Message);
    end;
  end;
end;

function TForm1.jsonToList(const AJson: String): TStringList;
begin
end;

end.

{
// this exception class covers the HTTP protocol errors; you may read the
    // response code using ErrorCode property of the exception object, or the
    // same you can read from the ResponseCode property of the TIdHTTP object
    on E: EIdHTTPProtocolException do
      ShowMessage('Indy raised a protocol error!' + sLineBreak +
        'HTTP status code: ' + IntToStr(E.ErrorCode) + sLineBreak +
        'Error message' + E.Message);
    // this exception class covers the cases when the server side closes the
    // connection with a client in a "peaceful" way
    on E: EIdConnClosedGracefully do
      ShowMessage('Indy reports, that connection was closed gracefully!');
    // this exception class covers all the low level socket exceptions
    on E: EIdSocketError do
      ShowMessage('Indy raised a socket error!' + sLineBreak +
        'Error code: ' + IntToStr(E.LastError) + sLineBreak +
        'Error message' + E.Message);
    // this exception class covers all exceptions thrown by Indy library
    on E: EIdException do
      ShowMessage('Indy raised an exception!' + sLineBreak +
        'Exception class: ' + E.ClassName + sLineBreak +
        'Error message: ' + E.Message);
    // this exception class is a base Delphi exception class and covers here
    // all exceptions different from those listed above
    on E: Exception do
      ShowMessage('A non-Indy related exception has been raised!');
  end;
  on E: EIdHTTPProtocolException do begin
    ShowMessage(E.Message);
    ShowMessage(E.ErrorMessage);
  end;
  on E: Exception do
     ShowMessage(E.Message);
}
