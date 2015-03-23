UNIT uTBread;

interface

//Verfasser Janek Reichardt (14-09-19)
//Bearbeitung: Ibrahim Hammad (14-12-09);
//Die Klasse Tbread ist ein Typ von Minions
//Veränderung von J.C. (6.11.14)   -Speed überarbeitet

uses uTMinion, uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils;

type
  Tbread = class(Tminion)
  public
  constructor create( _Name: string; _default : boolean); override;
  end;



implementation

//+---------------------------------------------------------------------
//|         Tbread: Methodendefinition
//+---------------------------------------------------------------------

constructor TBread.create( _Name: string; _default : boolean);
begin
 inherited create(_name,_default);
 lastmid:=0;
 armor:=0;
 cost:=30;
 Dmg:=1;
 life:=300;
 currentLife:=life;
 value:=8;
 movespeed:=0.3;
 icon:=g_Texturemanager.UseTexture('Bread.png');
end;

end.
