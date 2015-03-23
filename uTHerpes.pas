UNIT uTHerpes;

//Verfasser J.C.
//Die Klasse THerpes ist ein Typ von Minions

interface

uses uTMinion, uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils;

type
  Therpes = class(Tminion)
  public
    constructor create( _Name: string; _default : boolean); override;
  end;



implementation

//+---------------------------------------------------------------------
//|         THerpes: Methodendefinition
//+---------------------------------------------------------------------

constructor Therpes.create( _Name: string; _default : boolean);
begin
 inherited create(_name,_default);
 lastmid:=0;
 armor:=0;
 cost:=200;
 Dmg:=20;
 life:=1700;
 currentLife:=life;
 value:=200;
 movespeed:=0.14;
 icon:=g_Texturemanager.UseTexture('Herpes.png');
end;

end.
