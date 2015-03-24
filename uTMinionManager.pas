UNIT uTMinionManager;

interface

//--------------------  ggf Uses-Liste einfügen !  --------------------
{Verfasser: Alexander Z.
 Datum: 24.9.14
 Beschreibung der Klasse: Verwaltet die erste Welle
                                    -regelt die anzahl der minions in der welle
                                    -sagt dén minions, dass sie rendern, processen sollen
                                    -löscht die minions aus dem array

//Veränderung von J.C. (6.11.14)
//Veränderung von J.C. (12.11.14) Minions laufen jetzt versetzt ein - Minions sterben, wenn sie auf Base treten - Minions machen Schaden
//	 			Robert J.(18.11.14) Minionspawn auf deltaTime umgestellt
//						 (05.12.14) ExtraMinions-Add-Mechanik hinzugefügt
//						 (06.12.14) korrekte Pathübergabe bei Wave Start
// Veränderung: man kann minions hinzufügen (J.C. und D.J.)
//Veränderung von J.C.   minions können abgeschossen werden, kollision mit base wird in TBase abgefragt
}
uses  SysUtils, Dialogs, StdCtrls, uTminion, uTRenderer, Windows, uTRandomGenerator,
uTBread, uTHerpes, uTear, utturtle, utkaisersoze;

const SPAWNDELAY = 1.0;

const MINIONTYPECOUNT = 5;

const
    MINIONVALUE : array[0..(MINIONTYPECOUNT - 1)] of cardinal =
    (
      8, 200, 300, 400, 1000
    ) ;

type
  TMinionManager = class

  public //Attribute
    ExtraMinions : Array of TMinion; //erstmal nicht benutzt.
    Minions : Array of TMinion;
    WaveNr : Integer;
    ready : boolean;
    money:integer;


  public //Methoden
	constructor create(_seed : cardinal);
	destructor destroy();
	
    procedure Process (_dtime: real); virtual;
    procedure ClearWave ; virtual; //leert array
    procedure Render (_dTime: real; _Renderer: TRenderer); virtual;
    procedure NewWave (_Path:TPath ); virtual;

	procedure add(_minion : TMinion);
  private
    //minionspawn
    spawnTime : real;
	spawnCount : integer;
	
	//minions counters
	standardCount : integer;
	extraCount : integer;
	
	//rng
	//use only for wave spawn
	rng : TRandomGenerator;
   end;


implementation

//+---------------------------------------------------------------------
//|         TMinionManager: Methodendefinition
//+---------------------------------------------------------------------

constructor TMinionManager.create(_seed : cardinal);
begin
	rng := TRandomGenerator.create(_seed);
end;

destructor TMinionManager.destroy();
begin
	rng.free();
end;

//-------- Process (public) --------------------------------------------
procedure TMinionManager.Process (_dtime: real);
var
  i,o: integer;
  alldead: boolean;
begin
  money:=0;
  
  spawnTime := spawnTime + _dtime;
  //time is up to spawn the next minion
  for i:= 0 to length(minions)-1 do
  begin
    if (spawnTime > SPAWNDELAY) and (spawnCount < length(minions)) then
      begin
        minions[spawnCount].process(_dtime);
        inc(spawnCount);
		spawnTime := 0.0;
      end;
   end;

   if minions <> nil then
     for o:= 0 to spawnCount -1 do
       minions[o].process(_dtime);

  alldead:=true;

  for i:= 0 to length(minions)-1 do
  begin

  if (Minions[i].currentlife<=0) and (minions[i].deaD=false) then   //falls ein Minion abgeschossen wurde: er stirbt + es gibt geld
  begin
    Minions[i].dead:=true;
    money:= money+ minions[i].value;
  end;
     

  if minions[i].dead = false then
  begin
    alldead:= false;
    break;
   end;
   end;

  if alldead then
    begin
      ready:= true;
   end;
   
//sagt jedem minion im array, dass es processen soll
//wenn funktioniert:
//public attribut finish
//1 ebene höher. sagt, ob alle tot
//guckt ob für beiden minion manager für spieler alle tot. wenn ja, dann clear
//durch jedes feld durch, gucken ob tot. wenn alle, dann. geht erstmal davon aus, dass alle tot
//ready:= true
end;

//-------- RemoveMinion (public) ---------------------------------------
procedure TMinionManager.ClearWave;
var i:integer;
begin

  for i:= 0 to length(minions)-1 do
      minions[i].free ;
end;

//-------- Render (public) ---------------------------------------------
procedure TMinionManager.Render (_dTime: real; _Renderer: TRenderer);
var i:integer;
begin
  for i:= 0 to length(minions)-1 do    begin
      minions[i].render(_dTime, _Renderer);

      end;
end;

//-------- NewWave (public) --------------------------------------------
procedure TMinionManager.NewWave (_Path: TPath);
var i, rn, o : integer;
novalue:boolean;
    value:real;
	procedure addStd(_minion : TMinion);
	begin
		//see add()
		if(standardCount > high(minions)) then
		setlength(minions, length(minions) * 2 + 1);
		
	minions[standardCount] := _minion;
	
	inc(standardCount);
	end;
begin
  value:= sqr(wavenr) * 2 +10;

  standardCount := 0;
  
  while value >=8 do
  begin
    //search the highest possible minion
	for i := 0 to MINIONTYPECOUNT - 1 do 
	begin
		if( MINIONVALUE[i] <= value ) then break;
	end;
	
	if(MINIONTYPECOUNT = i) then dec(i);
	
	rn := rng.get(i);
		
	case rn of
	  0 : addStd(TBread.create('noname',false));
	  1 : addStd(THerpes.create('noname',false));
	  2 : addStd(TEar.create('noname',false));
	  3 : addStd(TTurtle.create('noname',false));
	  4 : addStd(TKaisersoze.create('B.O.S.S.',false));
	end;  
	
	value := value - MINIONVALUE[i];
  end;




  //instant spawn first minion after the call to newWave
  spawnTime := SPAWNDELAY;
  ready:=false;
  setlength(minions,standardCount + extraCount);
  
  //put in extraMinions so that they are handled like the regular ones
  //order is preserved
  for i := 0 to extraCount - 1 do
	minions[high(minions) - i] := extraMinions[extraCount - 1 - i];
	
    spawnCount:=0;
	//give every minion the current path
	for i:= 0 to high(minions)  do
		minions[i].setPath(_path);
		
	extraCount := 0;
	standardCount := 0;
//  Spawn.start(minions);
//  Spawn.start(extraMinions);
end;

procedure TMinionManager.add(_minion : TMinion);
begin
	//reallocation with enlarging factor 2 + absolute amount because 0*2=0
	if(extraCount > high(extraMinions)) then
		setlength(extraMinions, length(extraMinions) * 2 + 1);
		
	extraMinions[extraCount] := _minion;
	
	inc(extraCount);
end;

end.



