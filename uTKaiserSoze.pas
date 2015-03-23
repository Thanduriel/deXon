UNIT uTKaiserSoze;

interface

//Verfasser Alexander Zoubarev(14-11-28)
//Die Klasse TKaiserSoze ist ein Typ von Minions

uses uTMinion, uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils;

type
  TKaiserSoze = class(Tminion)
  public
  constructor create(_Name: string; _default : boolean); override;
  end;



implementation

//+---------------------------------------------------------------------
//|         TKaiserSoze: Methodendefinition
//+---------------------------------------------------------------------

constructor TKaiserSoze.create(_Name: string; _default : boolean);
begin
 inherited create(_name,_default);
 lastmid:=0;
 armor:=15;
 //cost:=1000;
 Dmg:=100;
 life:=250;
 currentLife:=life;
 value:=9999999999;
 movespeed:=0.1;
 icon:=g_Texturemanager.UseTexture('KaiserSoze.png');
end;

end.
