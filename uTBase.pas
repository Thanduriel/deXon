UNIT uTBase;

//Verfasser: Julius Coburger (14-09-18)
//Beschreibung der Klasse: Klasse der Basis, welche von
//der Klasse THexagon abgeleitet wird.

//Veränderung von J.C.   OnMove wird jetzt in Process verarbeitet (04-12-14)

interface

uses uTHexagon,uTRenderer,uTTextureManager, uTMinionmanager;

type
  TBase = class(THexagon)

  public //Attribute
    livepoints : integer;

  public //Methoden
    constructor create(_x,_y:real);
    procedure Process (_deltaTime: real); override;
    procedure Render (_deltaTime: real; _renderer: TRenderer); override;
  
  private

   end;

implementation

//+---------------------------------------------------------------------
//|         TBase: Methodendefinition
//+---------------------------------------------------------------------

constructor TBase.create(_x,_y:real);
begin
  x:=_x;
  y:=_y;
  solid:=false;
  livepoints := 100;
  tex:=g_texturemanager.UseTexture('graphics/base.png');
end;


//-------- Process (public) --------------------------------------------
procedure TBase.Process (_deltaTime: real);
var i:integer;
begin
  if minionmanager <> nil then begin
  for i:= 0 to length(minionmanager.minions) -1 do      //überprüft, ob minion auf der base ist
  begin
     if (minionmanager.Minions[i].lastmid = length(minionmanager.Minions[i].path)-1) and (minionmanager.minions[i].dead=false) then
     begin
       livepoints:=livepoints - minionmanager.minions[i].dmg;
      minionmanager.Minions[i].dead:=true;
     end;
  end;
  end;
end;

//-------- Render (public) ---------------------------------------------
procedure TBase.Render (_deltaTime: real; _renderer: TRenderer);
var cx,cy:real;
begin
  cx:= 1/30;
  cy:= cx * 1.15;
  _renderer.SetZ(0.9);
  _renderer.DrawHexBorder( x, y, cx, cy, 0.001, 0, 0, 0);
  _renderer.DrawHexTex( x, y, cx, cy,tex);
  _renderer.drawcolor(x-0.065,y-0.12,0.064*(livepoints/100),0.02,1, 0.1,0.2); // zeichnet roten Lebesbalken unter die Base
  _renderer.SetZ(0.6);
end;

end.
