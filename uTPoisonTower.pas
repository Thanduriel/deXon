{###################################################
Verfasser: Julius C.
#####################################################}


UNIT uTPoisonTower;

interface


uses uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils, uTTower, uTSoundsystem;

type
  TPoisonTower = class(TTower)
   public
    constructor create(_x,_y:real);
    function getname : string;
   end;

implementation

//+---------------------------------------------------------------------
//|         TTurminator: Methodendefinition
//+---------------------------------------------------------------------
constructor TPoisonTower.create(_x,_y:real);  //gute Reichweite, viel Schaden, sehr langsam
begin
inherited create(_x,_y);
name := 'PoisonTower';
effect:= 3;   //poison
cost:= 1000;
dmg:= 200;
area_rad:= 1;
attack_length := 1.7;
effect_duration:= 5;
projectile_rad:= 0.1;
range:= 0.06;
sound := g_soundsystem.loadsound('taser.wav');
tex:= g_Texturemanager.UseTexture('graphics/Tower/Poisontower/Poisontower.png');
end;

function TPoisonTower.getname : string;
begin
 result:= name;
end;

end.
