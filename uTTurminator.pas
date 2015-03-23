{###################################################
Verfasser: Dimitri Janzen (14-11-25);
Bearbeitung: Dimitri Janzen (14-11-25); Ibrahim Hammad (14-12-09);
Beschreibung der Klasse(n):
Die Klasse „TTurminator“ ist ein Erbe (Slytherins haha) TTowers und stellt
eine Art der Türme dar. Die Werte wurden willkürlich ausgewählt.
#####################################################}



UNIT uTTurminator;

interface


uses uTTexture, uTTextureManager, Messages, Controls, Forms, Dialogs, Windows, SysUtils, uTTower, uTSoundsystem;

type
  TTurminator = class(TTower)
   public
    constructor create(_x,_y:real);
    function getname : string;
   end;

implementation

//+---------------------------------------------------------------------
//|         TTurminator: Methodendefinition
//+---------------------------------------------------------------------
constructor TTurminator.create(_x,_y:real);  // wenig Schaden, guter Effekt, günstig, mittlere Schnelligkeit, halbwegs gute Reichweite
                                             ///////////////////////////////
begin                                        //        _______________    //
inherited create(_x,_y);                     //       [   ___________|    //
name := 'Turminator';                        //      /  /_(_/             //
effect:= 4; //fire                           //     /  /                  //
cost:= 450;                                  //    /__/                   //
dmg:= 80;                                   ///////////////////////////////
area_rad:= 1;
attack_length := 1;
effect_duration:= 5;
projectile_rad:= 0.1;
range:= 0.03;
sound := g_soundsystem.loadsound('phaser.wav');
tex:= g_Texturemanager.UseTexture('graphics/Tower/Turminator/Turminator.png');
end;

function TTurminator.getname : string;
begin
 result:= name;
end;

end.

// Das ist Malte. Malte wird vom Compiler ignoriert.
