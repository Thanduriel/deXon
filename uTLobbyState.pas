UNIT uTLobbyState;
{
Verfasser:                     Katja Holzinger (14-10-08);
Beschreibung der Klasse:       Die Klasse „TLobbyState“ dient zur Darstellung der Lobby, alle aktiven Computer werden angezeigt
                               und Spiele können gestartet werden.
Beschreibung der Veränderung:  K. H. (14-10-16): Erstellen der Unit

}
interface

//--------------------  ggf Uses-Liste einfügen !  --------------------
uses uTNetwork, uTGameState, uTGameButton, uTRenderer, Dialogs, uTMainState, uTTexture, uTTexturemanager,
     Windows, stdctrls, Forms, SysUtils;


type
  TLobbyState = class(TGameState)

  private //Attribute
    Pings : Array of integer;
    IPAdresses : Array of string;
    Names : Array of string;
    PlayerStats : Array of string;
    Network:TNetwork;
    Lan: TLan;
    select: byte;

    texBackground : TTexture;
    Map: string;
    Gold: integer;
	waveSeed : cardinal;
    Live: integer;

  public //Attribute
    OwnName : string;

     //Objektbeziehungen:
        // hatTButton (n) of TButton;

  public //Methoden
	//takes ownership of the lobby
    constructor create(_Network: TNetwork);
	destructor destroy;
    procedure render(_deltaTime : real; _renderer : TRenderer); override;
    procedure StartGame;
    procedure refresh;
    procedure selup;
    procedure seldown;
    procedure receive(_text: string);
    procedure endgame;
    procedure beginGame;
    procedure SetMap1;
    procedure SetMap2;
    procedure SetGold1000;
    procedure SetGold1500;
   end;
   
   var
    renderer: TRenderer;

implementation

//+---------------------------------------------------------------------
//|         TLobbyState: Methodendefinition 
//+---------------------------------------------------------------------

constructor TLobbyState.create(_Network : TNetwork);
begin
inherited create();
  texBackground := g_Texturemanager.useTexture('BackgroundLobby.png');

  Network:=_Network;

  Network.OnReceive:=Receive;    //
  Network.OnStartGame:=BeginGame;//Eventfunktionen zuweisen
  Network.OnEndGame:=Endgame;    //

  Network.EnterLobby;
  select:=0;   //1. Nutzer ist makiert
  Lan:=Network.scan;   //255 PC's im Netzwerk werden gescannt, aktive werden in ein Array vom Typ TNetwork eingefügt
  addbutton(TGamebutton.create(+0.825, 0.4, 0.075, 0.075, selup, 'pfeiloben', '' ));   //Buttons zum wechseln der Auswahl werden erzeugt
  addbutton(TGamebutton.create(+0.825,0.2, 0.075, 0.075, seldown, 'pfeilunten', '' ));
//  addbutton(TGamebutton.create(+0.7, 0.76, 0.05, 0.05, refresh, 'button', '' ));         //Aktualisierungsbutten wird erzeugt
  addbutton(TGamebutton.create(0.55, -0.75, 0.2, 0.05, refresh, 'button', 'Refresh' ));         //Aktualisierungsbutten wird erzeugt
  addbutton(TGamebutton.create(0.55, -0.95, 0.2, 0.05, Startgame, 'button', 'Spiel' ));   // Spielstartbutton wird erzeugt
  addbutton(TGamebutton.create(-0.95, -0.75, 0.2, 0.05, Setmap1, 'button', 'Map1' ));   // Map1 wird gesetzt
  addbutton(TGamebutton.create(-0.5, -0.75, 0.2, 0.05, Setmap2, 'button', 'Map2' ));   // Map2 wird gesetzt
  addbutton(TGamebutton.create(-0.95, -0.95, 0.2, 0.05, SetGold1000, 'button', '1000 Gold' ));   // 1000 Gold wird gesetzt
  addbutton(TGamebutton.create(-0.5, -0.95, 0.2, 0.05, SetGold1500, 'button', '1500 Gold' ));   // 1500 Gold wird gesetzt
  map:='map1';
  gold:=1000;
end;

destructor TLobbystate.destroy;
begin

  Network.LeaveLobby;
  inherited destroy();
end;


procedure TLobbyState.render(_deltaTime : real; _renderer : TRenderer);
var i,o:integer;
ip:string;
r : real;
begin

_Renderer.DrawTexture(-1.0,-1.0,texBackground, 1.0, 1.0,false);

inherited render(_deltaTime, _renderer);
   renderer:=_renderer;
    ip:=Network.GetLocIP();
   _renderer.DrawTextEx(-0.95   ,0.815,'Eigene IP: '+ ip  ,0.05, false,0.0, 0.75, 0.75, 0.25);  //Eigene IP-Adresse wird angezeigt
   r:=0;
  _renderer.DrawTextEx(-0.95   ,0.62,'Name'  ,0.05, false,0.0, r, 0, 0);       //Tabellenkopf wird angezeigt
  _renderer.DrawTextEx(-0.37,0.62,'IP'    ,0.05, false,0.0, r, 0, 0);
  _renderer.DrawTextEx( 0.25,0.62,'Ready?',0.05, false,0.0, r, 0, 0);

  if length(Lan) <> 0 then begin                                       //Netzwerk durchlauf -> Tabelle ausgeben
    for i:= 0 to length(Lan)-1 do begin
      if select = i then r:=1 else r:=0;    //Wenn die Zeile ausgewählt wird, ist die Zeile rot
      _renderer.DrawTextEx(-0.95,i*-0.1+0.48,Lan[i].name,0.05, false,0.25, r, 0, 0); //Name wird gezeichnet
      ip:=Lan[i].IPaddr[0]+'.'+Lan[i].IPaddr[1]+'.'+Lan[i].IPaddr[2]+'.'+Lan[i].IPaddr[3];
      _renderer.DrawTextEx(-0.37,i*-0.1+0.48,ip,0.05, false,0.0, r, 0, 0); //IP Adresse wird gezeichnet
      if Lan[i].ready  then begin    // Anzeigen ob der Computer gerade in der Lobby ist
        _renderer.DrawTextEx(0.25,i*-0.1+0.48,'Ready',0.05, false,0.0, r, 0, 0); //Computer ist bereit
      end
      else
        _renderer.DrawTextEx(0.25,i*-0.1+0.48,'Busy',0.05, false,0.0, r, 0, 0); //Computer ist nicht bereit
    end;

  end;
end;

procedure TLobbyState.Startgame;
var
s: string;
i: integer;
begin
	//structure of the message:
	// <str gold>,<string mapName>, <str waveSeed>, <human readably msg>
 randomize();
 waveSeed := Random($00FFFFFF);
 s:='Map: ' +map+', Gold: '+inttostr(gold) + ', Waveseed: ' + inttostr(waveSeed) + ',';
 for i:= 0 to length(Lan)-1 do
  if select = i then     //Sucht den ausgeählten Client
  begin
      Network.AskforGame(i, s); //Übergibt der Lobby die ausgewählte IP
	  break;
  end;
end;

procedure TLobbyState.refresh; //Netzwerk wird gescant und neu gerendert.
begin
 Lan:=Network.scan;
 render(10,renderer);
end;

procedure TLobbystate.selup;    //Prozedur um die ausgewählte Zeile nach oben zu verschieben, wird durch Buttononclick ausgeführt
begin
   if select>0 then dec(select)
end;

procedure TLobbystate.seldown;  //Prozedur um die ausgewählte Zeile nach unten zu verschieben, wird durch Buttononclick ausgeführt
var
i: integer;
begin
   i:=length(Lan)-1;
   if i>select then inc(select)
   
end;

procedure TLobbystate.Receive(_text: string);//Empfangene nachricht verabeiten
var str : array[0..2] of string;
var i : integer;
var beginInd, endInd : integer; 
begin
 //parse the string
 //init end since begin is set to end
 endInd := 0;
 //three params
 for i := 0 to 2 do
 begin
  beginInd := endInd;
  while(_text[beginInd] <> ':') do inc(beginInd);
	  //jump over the white space
	  beginInd := beginInd + 2;
	  
	  endInd := beginInd;
	  //index of the ',', char count is correct
	  while(_text[endInd] <> ',') do inc(endInd);
	  
	  str[i] := Copy(_text, beginInd, endInd - beginInd);
  end;
  map := str[0];
  gold := strtoint(str[1]);
  waveSeed := strtoint(str[2]);
// showmessage(_text);
end;

procedure TLobbystate.Endgame();//Spiel wird beendet
begin
 Network.EnterLobby;
end;

procedure TLobbystate.BeginGame();//Spiel wird gestartet
var
  time : cardinal;
  Main : TMainState;
begin
  Main := TMainState.create(Network, map, gold, waveSeed);
  time := GetTickCount;
  while (GetTickCount-time)<5000 do Application.ProcessMessages;
  pushNewState(Main); //Lobbystate geht in den Mainstate über
end;

procedure TLobbystate.SetMap1();//Map1 wird gesetzt
begin
  Map:='map1';
end;

procedure TLobbystate.SetMap2();//Map2 wird gesetzt
begin
  Map:='map2';
end;

procedure TLobbystate.SetGold1000();//1000 Gold wird gesetzt
begin
  Gold:=1000;
end;

procedure TLobbystate.SetGold1500();//1000 Gold wird gesetzt
begin
  Gold:=1500;
end;

end.
