UNIT uTHexagon;
{
Verfasser:                     Katja Holzinger und Julius Coburger (25-09-19);
Beschreibung der Klasse:       Die Klasse „THexagon“ verwaltet ein Hexagon.
Beschreibung der Veränderung:  K. H. und J.C. (25-09-19): Erstellen der Unit
Methoden verändert: J.C. (07-10-14)
Veränderung der Unit : J.C. (04-12-14)
}

interface

uses  uTRenderer, uTTexture, uTTextureManager, uTMinionmanager;

type
  THexagon = class

  

  public //Attribute
    solid : boolean;
    
    active:boolean;    //active ist true, wenn man auf es geklickt hat
    x : real;          //Mitte des Hexagons
    y : real;
    tex: TTexture;
    Minionmanager:TMinionmanager;

     

  public //Methoden
    constructor create(_x,_y:real; _s:boolean); virtual;
 //   procedure OnMove; virtual;
    procedure Process (_deltaTime: real); virtual;
    procedure Render (_deltaTime: real; _renderer: TRenderer); virtual;

   end;


implementation


//+---------------------------------------------------------------------
//|         THexagon: Methodendefinition 
//+---------------------------------------------------------------------

constructor THexagon.create(_x,_y:real; _s:boolean);
begin
  inherited create;
  x:=_x;
  y:=_y;
  solid:=_s ;
  active:=false;
  tex:=g_texturemanager.UseTexture('graphics/tex.png');
end;

{//-------- OnMove (public) ---------------------------------------------
procedure THexagon.OnMove;
begin

end; }

//-------- Process (public) --------------------------------------------
procedure THexagon.Process (_deltaTime: real);
begin

end;

//-------- Render (public) ---------------------------------------------
procedure THexagon.Render (_deltaTime: real; _renderer: TRenderer);
var cx,cy:real;
begin
  _renderer.SetZ(0.1);
  cx:= 1/30;
  cy:= cx * 1.15;
  _renderer.DrawHexBorder( x, y, cx, cy, 0.002, 0, 0, 0);
  
 if solid then
  begin
    _renderer.DrawHexTex( x, y, cx, cy,tex);  // für Maps mit unbegehbaren Feldern
  end;

  _renderer.SetZ(0.6);
end;


end.
