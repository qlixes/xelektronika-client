unit ucompuxui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Buttons, LResources;

type

  { TDefCompUXUI }

  TDefCompUXUI = class
  private
    FDateFormat: String;
    FBitBtn:TBitBtn;
    FPic:TPicture;
    FPng:TPortableNetworkGraphic;
  protected
    function getImageRes(AName:String):TBitmap;
  public
    constructor Create;
    //procedure setDateEdit(var ADateEdit: TDateEdit);
    procedure getBtnRefresh(var ABitBtn:TBitBtn);
    procedure getBtnFirst(var ABitBtn:TBitBtn);
    procedure getBtnLast(var ABitBtn:TBitBtn);
    procedure getBtnNext(var ABitBtn:TBitBtn);
    procedure getBtnPrevious(var ABitBtn:TBitBtn);
    procedure getBtnDoorIn(var ABitBtn:TBitBtn);
    procedure getBtnDoorOut(var ABitBtn:TBitBtn);
    procedure getBtnGoogleCustomSearch(var ABitBtn:TBitBtn);
    procedure getBtnExcels(var ABitBtn:TBitBtn);
  end;

implementation

{ TDefCompUXUI }

function TDefCompUXUI.getImageRes(AName: String): TBitmap;
begin
  try
    FPng.LoadFromLazarusResource(AName);
    FPic.PNG:=FPng;
  finally
    FPng.Clear;
  end;
  result:=FPic.Bitmap;
end;

constructor TDefCompUXUI.Create;
begin
  inherited Create;
  //FBitBtn:=TBitBtn.Create(nil);
  FPic:=TPicture.Create;
  FPng:=TPortableNetworkGraphic.Create;
end;

procedure TDefCompUXUI.getBtnRefresh(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Arrow-Refresh'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnFirst(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Resultset-First'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnLast(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Resultset-Last'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnNext(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Resultset-Next'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnPrevious(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Resultset-Previous'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnDoorIn(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  //FBitBtn.Height:=32;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Door-In'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnDoorOut(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  //FBitBtn.Height:=32;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Door-Out'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnGoogleCustomSearch(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='';
  FBitBtn.Glyph.Assign(getImageRes('Google-Custom-Search'));
  FPic.Clear;
end;

procedure TDefCompUXUI.getBtnExcels(var ABitBtn: TBitBtn);
begin
  FBitBtn:=ABitBtn;
  FBitBtn.Height:=36;
  FBitBtn.Caption:='Export';
  FBitBtn.Glyph.Assign(getImageRes('Page-White-Excel'));
  FPic.Clear;
end;

initialization
  {$I extico.lrs}

end.

