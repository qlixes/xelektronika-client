unit udetail;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids;

type

  { TForm2 }

  TForm2 = class(TForm)
    sgDetail: TStringGrid;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgDetailPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private
    { private declarations }
  public
    { public declarations }
    procedure setHost(AHost:String);
    procedure setToken(AToken:String);
    procedure setTrmstId(AId:Integer);
  end;

var
  Form2: TForm2;

implementation

uses
  broker;

var
  FJSONWebservice:TJSONWebservices;
  FJSONGrid:TJSONGrid;
  FId:Integer;
  FToken:String;

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  FJSONWebservice:=TJSONWebservices.Create;
  FJSONGrid:=TJSONGrid.Create;
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  inherited Destroy;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  FJSONWebservice.setJSONRequest(FToken);
  if FJSONWebservice.Status then begin
    FJSONWebservice.getDetail(Fid);
    FJSONGrid.getJSONArrays(FJSONWebservice.JSONArray);
    FJSONGrid.setStringGrid(sgDetail);
    FJSONGrid.writeToGrid;
  end
  else
    self.Close;
end;

procedure TForm2.sgDetailPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  if (aRow > 1) and (aRow mod 2 = 0) then
    sgDetail.Canvas.Brush.Color:=clHighlight
end;

procedure TForm2.setHost(AHost: String);
begin
  FJSONWebservice.setHost(AHost);
end;

procedure TForm2.setToken(AToken: String);
begin
  FToken:=AToken;
end;

procedure TForm2.setTrmstId(AId: Integer);
begin
  FId:=AId;
end;

end.

