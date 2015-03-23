UNIT uTMinion;

interface

//Verfasser Janek Reichardt (14-09-19)
//Die Klasse TMinion bildet die Die Grundklasse aller Miniontypen
//
//Janek Reichardt (14-10-7)
//fertigstellen des Testprogramms und fixen von Fehlern
//Veränderung von J.C. (6.11.14)
//Robert Jendersie (05.12.14)
//path-Übergabe aus Konstruktor entfernt
//Veränderung von J.C.
//Veränderung von J.C. können nur rendern, wenn sie nicht tot sind ( nur lebende sind sichtbar)

uses  uTRenderer, uTTexture,Messages, Controls, Forms, Dialogs, SysUtils, uTTexturemanager;

type
  TKoo = array[0..1] of real;
  Tpath = array of TKoo;

  Tminion = class

  public //Attribute
  lastmid: integer;
    name : string;
    current_effects:array of real;
    currentmovespeed:real;
    default : boolean;
    dead: boolean;
    position : TKoo;
    armor : integer;
    cost : integer;
    Dmg : Integer;
    life : integer;
    CurrentLife: integer;
    value : integer;
    movespeed : real;
   // deathSound : TSound;
    Path: Tpath;
    Icon:TTexture;
	
  public //Methoden
    constructor create(_Name: string; _default : boolean); virtual ;
	destructor destroy();
    procedure Process (_deltaTime: real);
    procedure Render (_deltaTime: real; _renderer: TRenderer);
    procedure SetPath (_Path :  TPath);
   // function currentHex : THexagon;
   end;

implementation

//+---------------------------------------------------------------------
//|         Tminion: Methodendefinition
//+---------------------------------------------------------------------

constructor Tminion.create(_Name: string;_default : boolean);
var i:integer;
begin
	inherited create;
	name:=_Name;
	default:=_default;
	dead:=false;
        lastmid:=0;
		position[0] := 2.0;
		position[1] := 2.0;
        setlength(Current_effects,4);
        for i:= 0 to 3 do       //hat beim Erzeugen keine effeckte
          current_effects[i]:=0;
end;

destructor TMinion.destroy();
begin
	g_textureManager.unuseTexture(icon);
end;

//-------- Process (public) --------------------------------------------
procedure Tminion.Process (_deltaTime: real);//bewegt Minion entsprechend seiner Geschwindigkeit in Richtung des nÃ¤chsten Hexagonmittelpunkt
var dif, xdif, ydif, xspeed, yspeed : real;
i:integer;
begin
  currentmovespeed:=movespeed;

  for i := 0 to 3 do
  begin
  if current_effects[i] > 0 then
     case i of
       0:  currentmovespeed:=movespeed*0.8;
       1:  currentmovespeed:=0;
       2:  currentlife:= currentlife - round((life * 0.05 * _deltatime));   //bringt nichts, da immer auf 0 gerundet  (wenn leben unter 500)
       3:  currentlife:= currentlife - round((life * 0.10 * _deltatime));   // ab 500 Lifpoints richtet es verheerenden schaden an
     end;
     current_effects[i]:= current_effects[i] - _deltaTime;
  end;

  if (lastmid<>length(Path)-1) and (dead=false) then
  begin
    xdif:=Path[(lastmid+1),0]-position[0]; //Abstand zwischen Minion und nächstem Mittelpunkt in X-Richtung
    ydif:=Path[(lastmid+1),1]-position[1]; //Abstand zwischen Minion und nächstem Mittelpunkt in y-Richtung
    dif:=sqrt(sqr(xdif)+sqr(ydif));
    xspeed:=(xdif/dif)*currentmovespeed; // Geschwindigkeitskomponenten berechnen
    yspeed:=(ydif/dif)*currentmovespeed;
    position[0]:=position[0]+_deltaTime*xspeed;// neue Position berechnen
    position[1]:=position[1]+_deltaTime*yspeed;

    if (xdif=0) then
      begin
    if ((ydif>0) and (position[1]>Path[lastmid+1,1])) or ((ydif<0) and (position[1]<Path[lastmid+1,1])) then //Ausgangsposition links von Ziel, danach rechts oder erst rechts dann links
      inc(lastmid);
      end
    else
    if ((xdif>0) and (position[0]>Path[lastmid+1,0])) or ((xdif<0) and (position[0]<Path[lastmid+1,0])) then //Ausgangsposition links von Ziel, danach rechts oder erst rechts dann links
      inc(lastmid);
    end;
end;

//-------- Render (public) ---------------------------------------------
procedure Tminion.Render (_deltaTime: real; _renderer: TRenderer);
begin
  if not dead then                //wird nur gezeichnet,wenn sie leben
  begin
  _renderer.drawTexture(position[0]-0.032,position[1]-0.05,Icon,0.040,0.040,true); //zeichnetBild des MInions an entsprechende Stelle
  _renderer.drawcolor(position[0]-0.032,position[1]+0.12,0.064*(currentLife/Life),0.02,1, 0.1,0.2); // zeichnet roten Lebesbalken Ã¼ber Minion
  end;
end;

//-------- SetPath (public) --------------------------------------------
procedure Tminion.SetPath (_Path : TPath);
var i:integer;
begin
 setlength(Path,length(_path));
  for i:=0 to (length(_path)-1) do
    begin
      Path[i,0] := _Path[i,0];
      Path[i,1] := _Path[i,1];
    end;
	//set position to the beginning of the path
	position := _path[0];
end;


end.
