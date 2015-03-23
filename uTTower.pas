UNIT uTTower;

interface

//Verfasser Janek Reichardt (22.11.2014)
//Die Klasse TTower bildet die Die Grundklasse aller Turmtypen

// Beheben von Bugs - J.C.

uses uThexagon, uTRenderer, uTTexture,Messages, Controls, Forms, Dialogs, SysUtils, uTProjectile, uTMinionmanager, uTSoundsystem;

type
  TTower = class(THexagon)

  public //Attribut
	effect: byte;
	area_rad: real;
	effect_duration:real;
	projectile_rad:real;
       	sound:TSound;
    name: String;
    dmg: integer;
    cost: integer;
    range: real;
    attack_length: real;
    lastshot: real;
    projectiles: Array of TProjectile;

  public //Methoden
    constructor create(_x,_y:real); virtual ;
    procedure Process (_deltaTime: real);  override;
    procedure Render (_deltaTime: real; _renderer: TRenderer); override;
   end;

implementation

constructor TTower.create(_x,_y:real);
begin
   inherited create(_x,_y,true);
end;

//-------- Process (public) --------------------------------------------
procedure TTower.Process (_deltaTime: real);
var i,n,p:integer;

procedure DeletProjectile(_projectile:TProjectile); //löscht ein Projektil
var ex:TProjectile;
    o:Integer;
    changed:boolean;
begin
  ex:=projectiles[length(projectiles)-1];
  changed:=false;
  for o:= 0 to length(projectiles)-1 do begin
    if (projectiles[o].x =_projectile.x) and (projectiles[o].y =_projectile.y) and(projectiles[o].aim =_projectile.aim) and(projectiles[o].arrived =_projectile.arrived) and(changed=false) then
    begin                        
      projectiles[o]:=ex;  //Tauscht letztes Element mit dem zu löschendem Element
      setlength(projectiles, length(projectiles)-1);
      changed:=true;       // Es wird nur einmal getauscht
    end;
  end;
end;

begin

  if minionmanager <> nil then begin

  if not (minionmanager.ready) then
    lastshot:=lastshot+_deltaTime
  else
    lastshot:=attack_length; //nachladen für nächste runde

  if lastshot > attack_length then
    lastshot:=attack_length;  // kann nur 1 mal laden !


 { if length(_minionmanager.minions) = 0 then
    setlength(projectiles,0);}

  for i:=0 to length(MinionManager.Minions)-1  do
  begin
    if ((13* range)>=(sqrt(sqr(x - MinionManager.Minions[i].position[0])+sqr(y - MinionManager.Minions[i].position[1])))) and (minionmanager.minions[i].dead=false)  then begin
    //überprüft ob Minion in Reichweite ist
      if (lastshot)>=(attack_length) then
      begin
        setlength(projectiles,length(projectiles)+1);
        lastshot:=lastshot-attack_length;
        projectiles[length(projectiles)-1]:=Tprojectile.create(x,y,MinionManager.Minions[i]);  //überprüft ob wieder ein Angriff möglich ist und erzeugt ein Projektil
        g_soundsystem.PlaySoundOnce(sound,0.8,0)
      end;
    end;
  end;

  for i:=0 to length(projectiles)-1 do
  begin
    projectiles[i].Process(_deltaTime);
  end;

  for i:=0 to length(projectiles)-1 do
  begin
    if projectiles[i].arrived=true then
    begin                              //Minions in Explosionsrange suchen
	  for n:=0 to length(Minionmanager.Minions)-1 do begin
	    if projectile_Rad>=sqrt(sqr(projectiles[i].x-MinionManager.Minions[n].position[0])+sqr(projectiles[i].y-MinionManager.Minions[n].position[1]))  then
	    begin
	      MinionManager.Minions[n].currentlife:=MinionManager.Minions[n].currentlife-dmg;
		  case effect of
		  1: MinionManager.Minions[n].current_effects[0]:=effect_duration;
 		  2: MinionManager.Minions[n].current_effects[1]:=effect_duration;
		  3: MinionManager.Minions[n].current_effects[2]:=effect_duration;
		  4: MinionManager.Minions[n].current_effects[3]:=effect_duration;
                  end;
	    end;
            if (projectile_Rad = 0) and (projectiles[i].aim = MinionManager.Minions[n]) then
              begin
	      MinionManager.Minions[n].currentlife:=MinionManager.Minions[n].currentlife-dmg;
		  case effect of
		  1: MinionManager.Minions[n].current_effects[0]:=effect_duration;
 		  2: MinionManager.Minions[n].current_effects[1]:=effect_duration;
		  3: MinionManager.Minions[n].current_effects[2]:=effect_duration;
		  4: MinionManager.Minions[n].current_effects[3]:=effect_duration;
                  end;
	    end;
      	  end;
    end;
  end;


  p:=0;
  while not (p=length(projectiles)) do
  begin
    if projectiles[p].arrived then
    DeletProjectile(projectiles[p]) else
    inc(p);
  end;
  end;

end;

//-------- Render (public) ---------------------------------------------
procedure TTower.Render (_deltaTime: real; _renderer: TRenderer);
var i:integer;
    cx,cy:real;
begin
  inherited render(_deltaTime, _renderer);
    cx:= 1/30;
    cy:= cx * 1.15;
    _renderer.DrawHexTex( x, y, cx, cy,tex);

  for i:= 0 to length(projectiles)-1 do
    projectiles[i].render(_deltaTime, _renderer);
end;


end.
