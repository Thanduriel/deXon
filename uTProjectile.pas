UNIT uTProjectile;

interface

//Verfasser Janek Reichardt (14-09-19)
//Die Klasse TProjectile beschreibt die Projektile, die von den Türmen benutzt werden


uses uThexagon, uTRenderer, uTTexture,Messages, Controls, Forms, Dialogs, SysUtils, uTMinion,uTTextureManager, uTParticleManager;

type
  TProjectile = class

  public //Attribute
    x:real;
    y:real;
    aim: TMinion;
    icon:TTexture;
    arrived:boolean;

  public //Methoden
    constructor create(_x,_y:real;_aim:TMinion);
	destructor destroy();
    procedure Process (_deltaTime: real);
    procedure Render (_deltaTime: real; _renderer: TRenderer);
   // function currentHex : THexagon;
   end;

implementation

constructor TProjectile.create(_x,_y:real;_aim:TMinion);
begin
  inherited create;
  x:=_x;
  y:=_y;
  aim:=_aim;
  arrived:=false;
  icon:=g_texturemanager.UseTexture('graphics/tex.png');
end;

destructor TProjectile.destroy();
begin
	g_textureManager.unUseTexture(icon);
end;

//-------- Process (public) --------------------------------------------
procedure TProjectile.Process (_deltaTime: real);//bewegt Minion entsprechend seiner Geschwindigkeit in Richtung des nÃ¤chsten Hexagonmittelpunkt
var dif, xdif, ydif, xspeed, yspeed : real;
begin
  if (arrived=false) then
  begin
    xdif:=aim.Position[0]-x; //Abstand zwischen Projektil und dem Zielminion in x-Richtung
    ydif:=aim.Position[1]-y; //Abstand zwischen Projektil und dem Zielminion in y-Richtung
    dif:=sqrt(sqr(xdif)+sqr(ydif));
    xspeed:=(xdif/dif)*1; // Geschwindigkeitskomponenten berechnen
    yspeed:=(ydif/dif)*1;
    x:=x+_deltaTime*xspeed;// neue Position berechnen
    y:=y+_deltaTime*yspeed;
        if ((xdif>0) and (x>aim.Position[0])) or ((xdif<0) and (x<aim.position[0]))  //Ausgangsposition links von Ziel, danach rechts oder erst rechts dann links
     then arrived:=true
    else
    if ((ydif>0) and (y>aim.Position[1])) or ((ydif<0) and (y<aim.position[1]))
      then arrived:=true;
    
	//particle effect
	if(arrived) then 
	begin
											//pos
		g_particleManager.AddParticleEffect(aim.Position[0], aim.Position[1], 
			icon,16, //texture, amount
			0.15, 0.25, //min_dif_velocity, max_dif_velocity
			0.6, 0, 0,  //attenuation, dif_direction
			0, 0, 0, //_diffusion_direction_forcing, source_velocity
			0, 0, // start_velocity
			0, 0, 0,//abs_acceleration, emitation_duration
			0.2, 0.4); //min_particle_duration, max_particle_duration
	end;
  end;
end;

//-------- Render (public) ---------------------------------------------
procedure TProjectile.Render (_deltaTime: real; _renderer: TRenderer);
begin
  _renderer.drawTexture(x-0.005,y-0.005,Icon,0.010,0.010,true); //zeichnet Bild des Projectiles an entsprechende Stelle
end;

end.
