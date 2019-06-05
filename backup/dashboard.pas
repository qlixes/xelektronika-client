unit dashboard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, Grids, ComCtrls, Menus, StdCtrls, ExtCtrls, Buttons,
  EditBtn, IdHTTP, IniFiles, broker, strutils;

const
  DS = '/';

type

  { TForm1 }

  TForm1 = class(TForm)
    btnExit: TBitBtn;
    btnLogin: TBitBtn;
    btnRefresh2: TBitBtn;
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
    iAbout: TMenuItem;
    PageControl1: TPageControl;
    rgStok: TRadioGroup;
    sgStok: TStringGrid;
    StatusBar1: TStatusBar;
    sgTransaksi: TStringGrid;
    tsDefault: TTabSheet;
    Timer1: TTimer;
    tsStok: TTabSheet;
    tsTransaksi: TTabSheet;
    tsLogin: TTabSheet;
    procedure btnExitClick(Sender: TObject);
    procedure btnFirst1Click(Sender: TObject);
    procedure btnLast1Click(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnNext1Click(Sender: TObject);
    procedure btnPrevious1Click(Sender: TObject);
    procedure btnRefresh1Click(Sender: TObject);
    procedure btnRefresh2Click(Sender: TObject);
    procedure dtEndEditingDone(Sender: TObject);
    procedure dtStartEditingDone(Sender: TObject);
    procedure edPage1EditingDone(Sender: TObject);
    procedure edSearchEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure iLogoutClick(Sender: TObject);
    procedure iStokClick(Sender: TObject);
    procedure iTransaksiClick(Sender: TObject);
    procedure sgStokPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure sgTransaksiClick(Sender: TObject);
    procedure sgTransaksiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
    procedure tsLoginShow(Sender: TObject);
    procedure tsStokShow(Sender: TObject);
    procedure tsTransaksiShow(Sender: TObject);
  private
    { private declarations }
    FConfig:TIniFile;
    function URLTranslate(AURL:String):String;
  public
    { public declarations }
    procedure CustomStatusBar(var AStatusBar: TStatusBar);
  end;

var
  Form1: TForm1;
  counter:integer;

implementation

uses
  ucompuxui, udetail;

var
  FJSONGrid:TJSONGrid;
  FJSONWebservice:TJSONWebservices;
  FUXUI:TDefCompUXUI;
  frmDetail:TForm2;

function checkCheckBoxValue(var ACheckBox:TCheckBox):Integer;
begin
  if ACheckBox.Checked then
    result:=1
  else
    result:=0;
end;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //FConfig:=TIniFile.Create(ChangeFileExt(Application.ExeName, '.cfg'));
  ////FHost:='http://'+FConfig.ReadString('appdesktop', 'host', 'localhost:5000');
  ////FBroker:=TBroker.Create;
  ////FBroker.setHost('http://'+FConfig.ReadString('appdesktop', 'host', 'localhost:5000'));;
  //FJSONWebservice:=TJSONWebservices.Create;
  //FJSONWebservice.setHost('http:'+URLTranslate(FConfig.ReadString('appdesktop','url','localhost:5000'))
  //  +':'+FConfig.ReadString('appdesktop','port','5000'));
  ////FJSONWebservice.setHost('http://'+FConfig.ReadString('appdesktop', 'host', 'localhost:5000'));
  FJSONGrid:=TJSONGrid.Create;
  FUXUI:=TDefCompUXUI.Create;
  FUXUI.getBtnDoorIn(btnLogin); FUXUI.getBtnDoorOut(btnExit);
  CustomStatusBar(StatusBar1);
  ////StatusBar1.Panels.Items[0].Text:='http://'+FConfig.ReadString('appdesktop', 'host', 'localhost:5000');
  //StatusBar1.Panels.Items[0].Text:=FJSONWebservice.Host;
end;

procedure TForm1.iAboutClick(Sender: TObject);
begin
  MessageDlg('developer : Anton <qlixess@gmail.com>', mtInformation, [mbOK], 0);
end;

procedure TForm1.iLogoutClick(Sender: TObject);
begin
  tslogin.TabVisible:=True;
  tsLogin.Show;
end;

procedure TForm1.iStokClick(Sender: TObject);
begin
  tsStok.TabVisible:=True;
  tsTransaksi.TabVisible:=False;
  tsLogin.TabVisible:=False;
  tsDefault.tabVisible:=False;
end;

procedure TForm1.iTransaksiClick(Sender: TObject);
begin
  tsTransaksi.TabVisible:=True;
  tsStok.TabVisible:=False;
  tsLogin.TabVisible:=False;
  tsDefault.tabVisible:=False;
end;

procedure TForm1.sgStokPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  if (aRow > 1) and (aRow mod 2 = 0) then
    sgStok.Canvas.Brush.Color:=clYellow;
end;

procedure TForm1.sgTransaksiClick(Sender: TObject);
begin
  if (chbShowDetail.Checked) and (sgTransaksi.Cells[0,1] <> '') then begin
    frmDetail:=TForm2.Create(self);
    frmDetail.setHost(FJSONWebservice.Host);
    frmDetail.setToken(FJSONWebservice.responseToken);
    frmDetail.setTrmstId(strtoint(sgTransaksi.Cells[0, sgTransaksi.row]));
    frmDetail.Show;
  end;
end;

procedure TForm1.sgTransaksiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  if (aRow > 1) and (aRow mod 2 = 0) then
    sgTransaksi.Canvas.Brush.Color:=clYellow;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels.Items[1].Text:=FormatDateTime('dd/MM/yyyy HH:mm:ss', now());
end;

procedure TForm1.tsLoginShow(Sender: TObject);
begin
  iTransaksi.Visible:=False;
  iStok.Visible:=False;
  iUser.Visible:=False;
  tsDefault.tabvisible:=False;
  tsTransaksi.tabvisible:=False;
  tsStok.tabvisible:=False;
end;

procedure TForm1.tsStokShow(Sender: TObject);
begin
  with FUXUI do begin
    getBtnRefresh(btnRefresh2);
    getBtnFirst(btnFirst2);
    getBtnNext(btnNext2);
    getBtnPrevious(btnPrevious2);
    getBtnLast(btnLast2);
  end;
end;

procedure TForm1.tsTransaksiShow(Sender: TObject);
begin
  with FUXUI do begin
    getBtnRefresh(btnRefresh1);
    getBtnFirst(btnFirst1);
    getBtnNext(btnNext1);
    getBtnPrevious(btnPrevious1);
    getBtnLast(btnLast1);
    getBtnExcels(btnTransaksiXLS);
  end;
  dtStart.Text:=FConfig.ReadString('history','startdate', DateToStr(now()));
  dtEnd.Text:=FConfig.ReadString('history','enddate', DateToStr(now()));
  // fill on transaction name
  FJSONWebservice.setJSONRequest(FJSONWebservice.responseToken);
  if FJSONWebservice.Status then begin
    FJSONWebservice.getRoot;
    cbTransaksi.Items:=FJSONWebservice.getTxAliasStrList;
    FJSONWebservice.getStore();
    cbLokasi.Items:=FJSONWebservice.getItemsStrList('store');
  end
  else
    tsLogin.show;
  //else begin
  //  ShowMessage('Your session has expired.');
  //  tsLogin.Show;
  //end;
end;

function TForm1.URLTranslate(AURL: String): String;
var
  strList:TStringList;
  FDest:String;
begin
  strList:=TStringList.Create;
  FDest:=FJSONWebservice.httpRedirect('http://'+AURL);
  ExtractStrings([':'],[],PChar(FDest), strList);
  try
    result:=strList[1];
  except
    result:=strList[0];
  end;
end;

procedure TForm1.btnLoginClick(Sender: TObject);
begin
  FJSONWebservice.setJSONRequest(Format('{"username":"%s","password":"%s"}', [edUsername.Text, edPassword.Text]));
  if FJSONWebservice.Status then begin
    //FJSONWebservice.httpPost('/login');
    FJSONWebservice.getLogin;
    if FJSONWebservice.Status then begin
      FJSONWebservice.getToken(FJSONWebservice.responseBody); // register token
      iTransaksi.Visible:=True;
      iStok.Visible:=True;
      iUser.Visible:=True;
      tsLogin.TabVisible:=False;
      tsDefault.tabVisible:=True;
      tsDefault.Show;
    end
  end
  else
    tsLogin.show;
  //else begin
  //  ShowMessage('Your session has expired.');
  //  tsLogin.Show;
  //end;
end;

procedure TForm1.btnNext1Click(Sender: TObject);
begin
  if (FJSONWebservice.getResPages > FJSONWebservice.getResPage) then
    FJSONWebservice.setPage(strtoint(edpage1.Text)+1);
  btnRefresh1.Click;
end;

procedure TForm1.btnPrevious1Click(Sender: TObject);
begin
  if (FJSONWebservice.getResPage > 1) then
    FJSONWebservice.setPage(strtoint(edPage1.Text)-1);
  btnRefresh1.Click;
end;

procedure TForm1.btnRefresh1Click(Sender: TObject);
begin
  // kirim token
  FJSONWebservice.setJSONRequest(FJSONWebservice.responseToken);
  if FJSONWebservice.Status then begin
    FJSONGrid.setStringGrid(sgTransaksi);
    if cbTransaksi.Text <> '' then begin
      FJSONWebservice.getTransaksi(cbTransaksi.Text, dtStart.Date, dtEnd.Date, cbLokasi.Text,
        edNoInvoices.Text, checkCheckBoxValue(chbShowPayment));
      FJSONGrid.getJSONArrays(FJSONWebservice.JSONArray);
      FJSONGrid.writeToGrid;
      edPage1.Text:=inttostr(FJSONWebservice.getResPage);
      edPage1.Enabled:=True;
      btnFirst1.Enabled:=True;
      btnNext1.Enabled:=True;
      btnPrevious1.Enabled:=True;
      btnLast1.Enabled:=True;
    end
    else
      ShowMessage('Please select at least 1 transaction.');
  end
  else
    tsLogin.show;
  //else begin
  //  ShowMessage('Your session has expired.');
  //  tsLogin.Show;
  //end;
end;

procedure TForm1.btnRefresh2Click(Sender: TObject);
begin
  FJSONWebservice.setJSONRequest(FJSONWebservice.responseToken);
  if FJSONWebservice.Status then begin
    FJSONWebservice.getStok();
    FJSONGrid.getJSONArrays(FJSONWebservice.JSONArray);
    FJSONGrid.writeToGrid;
  end
  else
    tsLogin.Show;
  //else begin
  //  ShowMessage('Your session has expired.');
  //  tsLogin.Show;
  //end;
end;

procedure TForm1.dtEndEditingDone(Sender: TObject);
begin
  FConfig.WriteString('history','enddate', FormatDateTime('dd/MM/yyyy', dtEnd.Date));
end;

procedure TForm1.dtStartEditingDone(Sender: TObject);
begin
  FConfig.WriteString('history','startdate', FormatDateTime('dd/MM/yyyy', dtStart.Date));
end;

procedure TForm1.edPage1EditingDone(Sender: TObject);
begin
  FJSONWebservice.setPage(strtoint(edPage1.Text));
  if (FJSONWebservice.getResPages > strtoint(edPage1.Text)) then
    btnRefresh1.Click;
end;

procedure TForm1.edSearchEditingDone(Sender: TObject);
begin
  FJSONWebservice.setJSONRequest(FJSONWebservice.responseToken);
  // 20170924
  if FJSONWebservice.Status then begin
    if rgStok.ItemIndex = 0 then // nostok
      FJSONWebservice.getStok(edSearch.Text, '')
    else
      FJSONWebservice.getStok('', edSearch.Text);
    FJSONGrid.setStringGrid(sgStok);
    FJSONGrid.getJSONArrays(FJSONWebservice.JSONArray);
    FJSONGrid.writeToGrid;
  end;
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  FJSONWebservice.Destroy;
  Application.Terminate;
end;

procedure TForm1.btnFirst1Click(Sender: TObject);
begin
  FJSONWebservice.setPage();
  btnRefresh1.Click;
end;

procedure TForm1.btnLast1Click(Sender: TObject);
begin
  FJSONWebservice.setPage(FJSONWebservice.getResPages);
  btnRefresh1.Click;
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
