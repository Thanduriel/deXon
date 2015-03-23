UNIT uTTurtle;

//Verfasser J.C.
//Die Klasse TTurtle ist ein Typ von Minions

interface

uses uTMinion, uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils;

type
  Tturtle = class(Tminion)
  public
    constructor create(_Name: string; _default : boolean); override;
  end;



implementation

//+---------------------------------------------------------------------
//|         THerpes: Methodendefinition
//+---------------------------------------------------------------------

constructor Tturtle.create(_Name: string; _default : boolean);
begin
 inherited create(_name,_default);
 lastmid:=0;
 armor:=0;
 cost:=300;
 Dmg:=30;
 life:=500;
 currentLife:=life;
 value:=200;
 movespeed:=0.2;
 icon:=g_Texturemanager.UseTexture('TTurtle.png');
end;

end.
