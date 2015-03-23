UNIT uTMap;
{
Verfasser:                     Katja Holzinger und Julius Coburger;
Beschreibung der Klasse:       Die Klasse „TMap“ besteht aus Hexagonen und dient als Fachklasse für das Spielfeld.
Beschreibung der Veränderung:  K. H. : Erstellen der Unit
Unit bearbeitet: K. H. und J. C. (mehrere Blöcke)
Unit bearbeitet: J. C. (13.10.2014)
Unit bearbeitet: J. C. (16.10.2014)
Pathfinding bearbeitet: J.C. (04.11.2014)
Bugs im Pathfinding behoben : J.C.
// J.C. path besteht nur aus koordinaten
Veränderung der Unit : J.C. (04-12-14)
}

interface


uses  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uTHexagon, uTRenderer, uTBase, uTSpawn, uTMinion, uTMinionmanager;

type

  TMap = class
  public //Attribute
    Grid : Array[0..16,0..20] of THexagon ;     // Spalte|Zeile
    Path : TPath;
    x:real; //koordiaten der Map
    y:real;
    Base:TBase;
    Spawn:TSpawn;
    BaseX,BaseY,SpawnX,SpawnY:Integer; //Koordinaten im Raster der Map

  public //Methoden
    constructor Create (_DatName: String; _cx, _cy:real; _minionManager : TMinionManager); virtual;
    procedure Pathfinding; virtual;
    procedure Process (_deltaTime: real); virtual;
    procedure Render (_dTime: real; _Renderer: TRenderer); virtual;

   end;


implementation



//+---------------------------------------------------------------------
//|         TMap: Methodendefinition
//+---------------------------------------------------------------------

//-------- Create (public) ---------------------------------------------
constructor TMap.Create (_DatName: String; _cx , _cy:real; _minionManager : TMinionManager);
var
   map: file;
   buf: array[0..356] of  Byte;
   rec: array[0..356] of  Byte;
   i,o,s,b:Integer;
   bx,by:real;
begin
  inherited create;

  x:= _cx;
  y:= _cy;

  Assignfile(map, _DatName);

{rewrite(map,1); // DAMIT kann man eine map createn (.map-Datei)
  for s:= 0 to 356 do begin
  rec[s]:=random(2);
  end;
  rec[168]:=2;
  rec[188]:=3;
  BlockWrite(map, rec, 357); }


  reset(map,1);
  Blockread(map, buf[0],357);
  closefile(map);

  o:=0;

  for i:= 0 to length(buf)-1 do
  begin

   o:= i div 21;
   b:= i-(o*21);


   bx:= x +(o+0.65)*(1/20);  //X-Verschiebung

  if odd(o) then                  //Y-Verschiebung
    by:=(((1/13)*(b+0.6))*-1)-(1/26)+y+1.5
  else
    by:=(((1/13)*(b+0.6))*-1)+y+1.5;


  case buf[i] of
    0:  Grid[o,b]:=THexagon.Create(bx,by,false);
    1:  Grid[o,b]:=THexagon.Create(bx,by,true);

    2:
      begin
        SpawnX:=o;SpawnY:=b;
        Spawn:=TSpawn.Create(bx,by);
        Grid[o,b]:=Spawn;
      end;

    3:
      begin
        BaseX:=o;BaseY:=b;
        Base:= TBase.Create(bx,by);
		//only the base needs the minionManager
        Grid[o,b]:= Base;
      end;
  end;
  Grid[o,b].minionManager := _minionManager;



end;


end;

//-------- Pathfinding (public) ----------------------------------------     von J.C.
procedure TMap.Pathfinding;
var ShortestPath: array of THexagon;

type
TListhex = record    //Element der Openlist
  akt    :THexagon;  //Hexagon der aktuellen Feldes
  value  :integer;   //Wert := bisherige Kosten + Kosten für nächstes Feld + geschätzte Kosten zum Ziel
  old    :THexagon;  //Vorheriges Hexagon
  kosts  :integer;   //Kosten bis zu diesem Hexagon (bisherige Kosten)
  x,y    :Integer;   //Koordinaten im Raster
end;

var Openlist:  array of TListHex;
    Closelist: array of TListHex;

function Comparelisthex(_hex1,_hex2:TListhex):boolean ;       //Vergleciht, ob 2 Listhex-Elemente gleich sind
begin
  result:=false;
  if _hex1.akt = _hex2.akt then
  if _hex1.value = _hex2.value then
  if _hex1.old = _hex2.old then
  if _hex1.kosts = _hex2.kosts then
  if _hex1.x = _hex2.x then
  if _hex1.y = _hex2.y then
    result:=true;
end;

procedure SortOpenlist;                //Wird mit Bubblesort sortiert (Algorithmus aus 1. Semester verwendet)
procedure tausche(_i1,_i2:cardinal);
var ex:TListhex;
begin
  ex:=Openlist[_i1];
  Openlist[_i1]:=Openlist[_i2];
  Openlist[_i2]:=ex;
end;
var i , o : integer;
    getauscht:boolean;
begin
 i := length(Openlist) -2;
 repeat
   getauscht:=false;
   for o := 0 to i do  begin
     if Openlist[o].value > Openlist[o+1].value then
       begin
         tausche(o, o+1);
         getauscht:=true;
       end;
     end;
     dec(i);
  until (i<0) or not getauscht;
end;

procedure SortCloselist;                //Wird mit Bubblesort sortiert (Algorithmus aus 1. Semester verwendet)
procedure tausche(_i1,_i2:cardinal);
var ex:TListhex;
begin
  ex:=Closelist[_i1];
  Closelist[_i1]:=Closelist[_i2];
  Closelist[_i2]:=ex;
end;
var i , o : integer;
    getauscht:boolean;
begin
 i := length(Closelist) -2 ;
 repeat
   getauscht:=false;
   for o := 0 to i do  begin
     if Closelist[o].value < Closelist[o+1].value then
       begin
         tausche(o, o+1);
         getauscht:=true;
       end;
     end;
     dec(i);
  until (i<0) or not getauscht;
end;

function BaseIn:Boolean; //Gibt true zutück, wenn die Base in der closelist ist
var i: Integer;
begin
  result:=false;
  for i:= 0 to length(Closelist)-1 do
    begin
      if (Closelist[i].x = baseX) and (Closelist[i].y =BaseY) then
        result:= true;
      end;
end;

function CloseListIn(_x1,_x2:integer):boolean; //Gibt true zutück, wenn ein element in der Closelist die koordinaten besitzt
var i: Integer;
begin
  result:=false;
  for i:= 0 to length(Closelist)-1 do
    begin
      if (Closelist[i].x = _x1) and (Closelist[i].y =_x2) then
        result:= true;
      end;
end;

procedure nexthex(_x, _y:integer);
var cx,cy:integer;
begin
  cx:=_x; cy:=_y;

  if _x < BaseX then
    inc(cx);
  if _x > BaseX then
    dec(cx);

  if _x = cx then
  begin
    if _y < BaseY then
      inc(cy);
    if _y > BaseY then
      dec(cy);
  end;
  setlength(ShortestPath,length(ShortestPath)+1);
  ShortestPath[length(ShortestPath)-1]:=Grid[cx,cy];

  if (cx<>BaseX) or (cy<>BaseY) then
    nexthex(cx,cy);
end;

procedure CreateListHex(_akt,_old:THexagon; _kosts,_x,_y:integer); //Erzeugt ein Element einer Liste unf fügt es der Openlist hinzu
var hex:TListHex;
begin
  Hex.akt:=_akt;
  Hex.old:=_old;
  Hex.kosts:=_kosts;
  Hex.x:=_x;
  Hex.y:=_y;

  setlength(ShortestPath,0);
  nexthex(Hex.x,Hex.y);

  Hex.value:=Hex.kosts+length(ShortestPath);

  setlength(Openlist,length(Openlist)+1);
  Openlist[length(Openlist)-1]:= hex;

end;

function onmove(_x,_y:integer):boolean;     //gibt true zutück, wenn es begehbar ist
begin
  result:=true;
  if (_x < 17) and (_x > -1) and (_y < 21) and (_y > -1) then
    begin
      if  (Grid[_x,_y].solid) then result:=false;
      if  (CloselistIn(_x,_y)) then result:=false;
    end;
end;

procedure addneighbour(_hex:TListhex); // fügt alle Nachbarn des Hexagons der Openlist hinzu
begin

  if odd(_hex.x) then
  begin                //x ist ungerade

    if (_hex.y > 0) and OnMove(_hex.x,_hex.y-1) then  //oben
      CreateListHex(Grid[_hex.x,_hex.y-1],_hex.akt,_hex.kosts+1,_hex.x,_hex.y-1);

    if (_hex.y < 21) and OnMove(_hex.x,_hex.y+1) then  //unten
      CreateListHex(Grid[_hex.x,_hex.y+1],_hex.akt,_hex.kosts+1,_hex.x,_hex.y+1);

    if (_hex.y < 21) and OnMove(_hex.x-1,_hex.y+1) and (_hex.x > 0) then  //links-unten
      CreateListHex(Grid[_hex.x-1,_hex.y+1],_hex.akt,_hex.kosts+1,_hex.x-1,_hex.y+1);

    if (_hex.x > 0) and OnMove(_hex.x-1,_hex.y) then  //links-oben
      CreateListHex(Grid[_hex.x-1,_hex.y],_hex.akt,_hex.kosts+1,_hex.x-1,_hex.y);

    if (_hex.y < 21) and OnMove(_hex.x+1,_hex.y+1) and (_hex.x < 16) then  //recht-unten
      CreateListHex(Grid[_hex.x+1,_hex.y+1],_hex.akt,_hex.kosts+1,_hex.x+1,_hex.y+1);

    if (_hex.x < 16) and OnMove(_hex.x+1,_hex.y) then  //recht-oben
      CreateListHex(Grid[_hex.x+1,_hex.y],_hex.akt,_hex.kosts+1,_hex.x+1,_hex.y);

  end
  else
  begin                //x ist gerade

    if (_hex.y > 0) and OnMove(_hex.x,_hex.y-1) then  //oben
      CreateListHex(Grid[_hex.x,_hex.y-1],_hex.akt,_hex.kosts+1,_hex.x,_hex.y-1);

    if (_hex.y < 21) and OnMove(_hex.x,_hex.y+1) then  //unten
      CreateListHex(Grid[_hex.x,_hex.y+1],_hex.akt,_hex.kosts+1,_hex.x,_hex.y+1);

    if (_hex.x > 0) and OnMove(_hex.x-1,_hex.y) then  //links-unten
      CreateListHex(Grid[_hex.x-1,_hex.y],_hex.akt,_hex.kosts+1,_hex.x-1,_hex.y);

    if (_hex.y > 0) and (_hex.x > 0) and OnMove(_hex.x-1,_hex.y-1) then  //links-oben
      CreateListHex(Grid[_hex.x-1,_hex.y-1],_hex.akt,_hex.kosts+1,_hex.x-1,_hex.y-1);

    if (_hex.y > 0) and (_hex.x < 16) and OnMove(_hex.x+1,_hex.y-1) then  //recht-oben
      CreateListHex(Grid[_hex.x+1,_hex.y-1],_hex.akt,_hex.kosts+1,_hex.x+1,_hex.y-1);

    if (_hex.x < 16) and OnMove(_hex.x+1,_hex.y) then  //recht-unten
      CreateListHex(Grid[_hex.x+1,_hex.y],_hex.akt,_hex.kosts+1,_hex.x+1,_hex.y);
  end;
end;

procedure DeletListHex(_hex:TListhex); //löscht Element aus der Openlist
var ex,cl:TListHex;
    i:Integer;
    changed:boolean;
begin
  ex:=Openlist[length(Openlist)-1];
  changed:=false;
  for i:= 0 to length(Openlist)-1 do begin
    if (comparelisthex(Openlist[i],_hex)) and (changed=false) then
    begin
      cl:=openlist[i];                         //Tauscht letztes Element mit dem zu löschendem Element
      Openlist[i]:=ex;
      setlength(Openlist, length(openlist)-1);
      changed:=true;    // Es wird nur einmal getauscht
    end;
  end;
  if closelistin(cl.x,cl.y)=false then begin
  setlength(Closelist, Length(closelist)+1);
  Closelist[length(closelist)-1]:=cl; end;
end;

procedure addpath(_hex:THexagon);      //fügt hexagon zum path hinzu, und ruft sich dann selbst mit dem vorgänger auf --> es entsteht der path
var o:integer;
    changed:boolean;
begin
  setlength(Path,length(Path)+1);
  changed:=false;
  for o:= 0 to length(Closelist)-1 do
    begin
      if (_hex = Closelist[o].akt) and (changed=false) then
        begin
          Path[length(Path)-1,0]:= Closelist[o].akt.x;
          Path[length(Path)-1,1]:= Closelist[o].akt.y;
          changed:=true;
          if Closelist[o].old <> nil then
            addpath(Closelist[o].old);
      end;
    end;

end;

var i,p,k,d:integer;
    bsppath:array of array[0..1] of real;
begin


  CreateListHex(Grid[Spawnx,SpawnY],nil,0,Spawnx,SpawnY);    // fügt erstes Element der OpenList hinzu

{Schleife
1. Sortieren
2. Nachbarn des 1. Elements der Openlist in Openlíst einfügen
3. 1. Element der Openlist in Closelist packen

wenn openlist leer ist, gibt es keine weg
}

  while not Basein do
  begin


    SortOpenlist;
    addneighbour(Openlist[0]);
//    Sortcloselist;
    DeletListHex(Openlist[0]);

    if length(Openlist) = 0 then
      begin
        Setlength(Path,0);
        Exit;   //es gibt keinen Path --> procedur wird verlassen
      end;
  end;

 Setlength(Path,1);

 // path wird gebildet

 for i:= 0 to length(Closelist)-1 do
   if (Closelist[i].x = BaseX) and (Closelist[i].y = BaseY) then
     begin
       Path[0,0]:=Closelist[i].akt.x;
       Path[0,1]:=Closelist[i].akt.y;
       addpath(Closelist[i].old);
     end;

   setlength(bsppath,length(Path));

 //Path ist jetzt verkehrt herum im Array und muss noch geflippt werden

 for p:= 0 to length(Path)-1 do
   begin
     bsppath[p,0]:=path[p,0];
     bsppath[p,1]:=path[p,1];
   end;

 for k:= 0 to length(bsppath)-1 do
   begin
     path[k,0]:= bsppath[length(bsppath)-1-k,0];
     path[k,1]:= bsppath[length(bsppath)-1-k,1];
   end;


   setlength(Openlist,0);
   setlength(Closelist,0);


end;



//-------- Process (public) --------------------------------------------
procedure TMap.Process (_deltaTime: real);
var
  i,o:integer;
begin
  for o:= 0 to 20 do begin
  for i := 0 to 16 do begin
    Grid[i,o].process(_deltaTime);
    end;
  end;
end;

//-------- Render (public) ---------------------------------------------
procedure TMap.Render (_dTime: real; _Renderer: TRenderer);
var
  i,o:integer;
begin                                     //rendert jeders einzelen Hexagon
  for o:= 0 to 20 do begin
  for i := 0 to 16 do begin
    Grid[i,o].render(_dTime,_renderer);
    end;
  end;

end;
end.
