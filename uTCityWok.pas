{###################################################
Verfasser: Julius C.
#####################################################}


UNIT uTCityWok;

interface


uses uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils, uTTower, uTSoundsystem;

type
  TCityWok = class(TTower)
   public
    constructor create(_x,_y:real);
    function getname : string;
   end;

implementation

//+---------------------------------------------------------------------
//|         TCityWok: Methodendefinition
//+---------------------------------------------------------------------
constructor TCityWok.create(_x,_y:real); // langsam, wenig Schaden, mittlere Reichweite, guter Effekt, mittlere Kosten
begin
inherited create(_x,_y);
name := 'CityWok';
effect:= 1; //slow down  
cost:= 450;
dmg:= 50;
area_rad:= 1;
attack_length := 1.4;
effect_duration:= 5;
projectile_rad:= 0.1;
range:= 0.03;
sound := g_soundsystem.loadsound('laser.wav');
tex:= g_Texturemanager.UseTexture('graphics/Tower/CityWok/CityWok.png');
end;

function TCityWok.getname : string;
begin
 result:= name;
end;

end.


 