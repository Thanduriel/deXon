{
Verfasser: Dimitri Janzen (14-10-09)
Bearbeitung: Dimitri Janzen (14-10-09);
			 Robert J. (14-12-09) Fehler in start() beseitigt;
Beschreibung der Klasse(n):
Die Klasse „TSpawn“ hat im Prinzip eine essentielle Funktion, die
nach Bekommen eines Arrays of Minions die eigenen Koordinaten auf die Minions .
}
UNIT uTSpawn;

interface

//--------------------  ggf Uses-Liste einfügen !  --------------------

uses uTHexagon, uTMinion, uTRenderer, uTTextureManager;

type
  TSpawn = class(THexagon)

  public //Methoden
    function start (Wave: Array of TMinion) : boolean; virtual;
    constructor create(_x,_y:real);
    destructor destroy;
    function getx: real; // zur Überprüfung
    function gety: real; // zur Überprüfung
    procedure Process (_deltaTime: real); override;
    procedure Render (_deltaTime: real; _renderer: TRenderer); override;
   end;
   
 var spawn: TSpawn;
 hexagon: THexagon;


implementation

//+---------------------------------------------------------------------
//|         TSpawn: Methodendefinition
//+---------------------------------------------------------------------

constructor TSpawn.create(_x,_y:real);
begin
  x:=_x;
  y:=_y;
  solid:=false;
  tex:=g_texturemanager.UseTexture('spawn3.png');
end;

//-------- start (public) ----------------------------------------------
function TSpawn.start (Wave: Array of TMinion) : boolean;
var i: integer;
    spawnpos: array of real;
begin
  setlength(spawnpos,2);
  spawnpos[0]:= x;      //Koordinaten des Spawnpunkts
  spawnpos[1]:= y;      //Koordinaten des Spawnpunkts
    for i:=0 to high(wave) do //für jeden Minion des übergebenen Arrays
     with wave[i] do
       begin
         position[0]:= spawnpos[0];  //Übertragung der Koordinaten auf Minions
         position[1]:= spawnpos[1];  //Übertragung der Koordinaten auf Minions
       end;
    result:=true;

end;

function TSpawn.getx: real;      //Testzwecke
begin
 result:=x;
end;

function tspawn.gety: real;      //Testzwecke
begin
result:=y;
end;


destructor TSpawn.destroy;
begin
inherited destroy;
end;

//-------- Process (public) --------------------------------------------
procedure TSpawn.Process (_deltaTime: real);
begin
  //hier ggf. Code ergänzen
end;

procedure TSpawn.Render (_deltaTime: real; _renderer: TRenderer);
var cx,cy:real;
begin
  cx:= 1/30;
  cy:= cx * 1.15;
  _renderer.DrawHexBorder( x, y, cx, cy, 0.001, 0, 0, 0);
  _renderer.DrawHexTex( x, y, cx, cy,tex);
end;

end.
