unit uCustomBitBtn;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Buttons, LResources, Graphics;

type

  { TUCustomBitBtn }

  TUCustomBitBtn = class(TBitBtn)
  protected
    FPicture:TPicture;
  public
    constructor Create;
  end;

  { TUCustomBitBtn }

  TRefreshBitBtn = class(TUCustomBitBtn)
  public
    constructor Create;
  end;

implementation

{ TUCustomBitBtn }

constructor TUCustomBitBtn.Create;
begin
  inherited Create(nil);
  FPicture:=TPicture.Create;
end;

{ TUCustomBitBtn }

constructor TRefreshBitBtn.Create;
begin
  inherited Create;
  FPicture.LoadFromLazarusResource('Arrow-Refresh');
  self.Glyph.Assign(FPicture.Bitmap);
  self.Caption:='Refresh';
end;

initialization
  {$I appdesktop.lrs}

end.

