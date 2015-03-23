{###################################################
Verfasser: Julius C.
#####################################################}


UNIT uTStandardTower;

interface


uses uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils, uTTower, uTSoundsystem;

type
  TStandardTower = class(TTower)
   public
    constructor create(_x,_y:real);
    function getname : string;
   end;

implementation

//+---------------------------------------------------------------------
//|         TTurminator: Methodendefinition
//+---------------------------------------------------------------------
constructor TStandardTower.create(_x,_y:real);    // hohe Reichweite, langsam, kaum Schaden, kein Effekt
begin
inherited create(_x,_y);
name := 'Standardtower';
effect:= 5;   //kein Effekt
cost:= 200;
dmg:= 40;
area_rad:= 1;
attack_length := 1.3;
effect_duration:= 5;
projectile_rad:= 0;
range:= 0.09;
sound := g_soundsystem.loadsound('laser.wav');
tex:= g_Texturemanager.UseTexture('graphics/Tower/Standardtower/Standardtower.png');
end;

function TStandardTower.getname : string;
begin
 result:= name;
end;

end.
