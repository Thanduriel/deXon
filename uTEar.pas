UNIT uTEar;

interface

//Verfasser J.R.
//Die Klasse TEar ist ein schneller aber stark gepanzerter Minion

uses uTMinion, uTTexture, uTTextureManager;

type
  TEar = class(Tminion)
  public
  constructor create( _Name: string; _default : boolean); override;
  end;



implementation

//+---------------------------------------------------------------------
//|         Tbread: Methodendefinition
//+---------------------------------------------------------------------

constructor TEar.create( _Name: string; _default : boolean);
begin
 inherited create(_name,_default);
 lastmid:=0;
 armor:=12;
 cost:=150;
 Dmg:=25;
 life:=3;
 currentLife:=life;
 value:=130;
 movespeed:=1.6;
 icon:=g_Texturemanager.UseTexture('Ear.png');
end;

end.
