unit uTMainState;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * TMainState ist der Zustand in dem das eigentliche Spiel läuft. 
 * Er kontrolliert die Map, Minions und Spieler.
 *
 * Veränderungen: Robert Jendersie(14.11.14) Formatierung in Ordnung gebracht(notepad++ empfohlen)
 *											 hinzufügen TLobby
 *								  (27.11.14) TComManager eingebunden 
 *								  (02.12.14) Hintergrund; Anpassungen der Oberfläche
 *								  (04.12.14) Ausbau und Verbesserungen von Minion und Towerausbildung
 *											 Anpassung an einheitliche Formatierung
 *								  (10.12.14) Anpassung Pfade; trainMinions()
 *}
//J.C: hinzufügen von minions, pause vor spawnen der minions, bauen von türmen
//J.R: hinzuf�gen von Sieg/Niederlage-nachricht

interface

uses uTGameState, uTMap, uTPlayer, uTMinionManager, uTRenderer, Sysutils, uTGameButton,
	uTNetwork, uTComManager, uTTexture, uTTexturemanager;

type

	TMainState = class(TGameState)
	public
		constructor create(_network : TNetwork; _map: string; _gold: integer);
		destructor destroy();
	
		procedure process(_deltaTime : real); override;
		procedure render(_deltaTime : real; _renderer : TRenderer); override;
		
		procedure mouseUp(); override;
		
	private
		//background
		texBackground : TTexture;

        //Victory/defeat message
        texVictory : TTexture;
        texDefeat : TTexture;

		//selected tower type indicator
		texSelectedType : TTexture;
		typeX : real;
		typeY : real;
		
	
		maps : array[0..1] of TMap;
		player : array[0..1] of TPlayer;
		minionManager : array[0..1] of TMinionManager;
		
		comManager : TComManager;
		
		//currently selected tower type to place
		curTowerType : byte;
		
        //button default proc
		procedure messages();
		
		//called on gameEnd caused by the opponent
		procedure evtEnd();
		
		//
		procedure trainMinion(_id : byte);
		{* placeTower() ************************************************
		 * tries to place a tower at the current mouse location
		 * takes into acount money and the placementstate
		 * handles networksynchro
		 *}
		procedure placeTower(_id : byte);
		
		//button events
		procedure tower01();
		procedure tower02();
		procedure tower03();
		procedure tower04();
		procedure tower05();
		
		procedure minion01();
		procedure minion02();
		procedure minion03();
		procedure minion04();
		procedure minion05();
	end;
	
	//global namespace; should be put into the class
	var Summe_d_time:real = 0;
    startwave:boolean; //gibt an, ob gerade gezeichnet wird

	abx:array of real;
	aby:array of real;

implementation

constructor TMainState.create(_network : TNetwork; _map: string; _gold: integer);
var i : integer;
begin
	inherited create;

	texBackground := g_Texturemanager.useTexture('BackgroundMain.png');
	texSelectedType := g_Texturemanager.useTexture('IconBorder.png');
	texVictory := g_Texturemanager.useTexture('Victorymsg.png');
	texDefeat := g_Texturemanager.useTexture('Defeatmsg.png');
	
    addButton(TGameButton.create(-0.7, 0.8, 0.05, 0.05, tower01  , 'graphics/tower/standardTower/standardTower'));
    addButton(TGameButton.create(-0.55, 0.8, 0.05, 0.05, tower02 , 'graphics/tower/PoisonTower/PoisonTower'));
    addButton(TGameButton.create(-0.4, 0.8, 0.05, 0.05, tower03 , 'graphics/tower/Turminator/Turminator'));
    addButton(TGameButton.create(-0.25, 0.8, 0.05, 0.05, tower04 , 'graphics/tower/citywok/citywok'));

    //addButton(TGameButton.create(0.75, 0.8, 0.05, 0.05, messages , 'minion'));
    addButton(TGameButton.create(0.6, 0.8, 0.05, 0.05, minion01 , 'bread'));
    addButton(TGameButton.create(0.45, 0.8, 0.05, 0.05, minion02 , 'herpes'));
    addButton(TGameButton.create(0.3, 0.8, 0.05, 0.05, minion03 , 'ear'));
    addButton(TGameButton.create(0.15, 0.8, 0.05, 0.05, minion04 , 'kaisersoze'));
    addButton(TGameButton.create(0, 0.8, 0.05, 0.05, minion05 , 'turtle'));


	for i := 0 to 1 do
	begin
		minionManager[i] := TMinionManager.create(42);
		maps[i] := TMap.create(_map+'.map', -0.981+i , -0.79, minionManager[i]);
		//share required data
//		minionManager[i].spawn := maps[i].spawn;
//		minionManager[i].base := maps[i].base;
		player[i] := TPlayer.create('player' + inttostr(i));
		player[i].increasegold(_gold);
	end;
	
	_network.onendgame := evtEnd;

	comManager := TComManager.create(_network, maps, player, minionManager);
	
	curTowerType := 0;
	
	typeX := 2;
	typeY := 2;
end;

destructor TMainState.destroy();
var i : integer;
begin
	g_Texturemanager.unuseTexture(texBackground);
	g_Texturemanager.unuseTexture(texSelectedType);
        g_Texturemanager.unuseTexture(texVictory);
        g_Texturemanager.unuseTexture(texDefeat);

	for i := 0 to 1 do
	begin
		maps[i].free();
		minionManager[i].free();
		player[i].free();
	end;
	
	comManager.free();
end;

procedure TMainState.process(_deltaTime : real);
var i : integer;
begin
	for i := 0 to 1 do
	begin
		maps[i].process(_deltaTime);
		minionManager[i].process(_deltaTime);
		player[i].increasegold(minionmanager[i].money); //erhöht das Gold der Spieler
	end;
	
	//both waves have finished
	if(minionManager[0].ready and minionManager[1].ready) then
	begin
		Summe_d_time:= Summe_d_time+_deltatime;
		if summe_d_time > 10 then       // Pause zwischen Waves
			startwave:=true
		else startwave:=false;

		//create a new wave
		if startwave then
		begin
			for i := 0 to 1 do
			begin
				minionManager[i].clearWave();
				maps[i].pathFinding();
				minionManager[i].newWave(maps[i].path);
				summe_d_time:=0;
			end;
		end;
	end;
	
	//check winning conditions
	if Maps[0].base.livepoints <= 0 then
		finalized:=true;

	if Maps[1].base.livepoints <= 0 then
		finalized:=true;
    
	//process players input
	comManager.process(_deltaTime);
	
	//mouse collision
	inherited process(_deltaTime);
end;

procedure TMainState.render(_deltaTime : real; _renderer : TRenderer);
var i : integer;
begin
	_renderer.DrawTexture(-1.0,-1.0,texBackground, 1.0, 1.0,false);
	_renderer.DrawTexture(typeX, typeY, texSelectedType, 0.05, 0.05,true);
	
	
	for i := 0 to 1 do
	begin
		maps[i].render(_deltaTime, _renderer);
		minionManager[i].render(_deltaTime, _renderer);
	end;
	//update hud elements
	//interface stuff last
	inherited render(_deltaTime, _renderer);
	
	//display important player information
	_Renderer.Drawtext(-0.9, 0.86, 'Geld:'+ inttostr(Player[0].getgold) ,0.035);
	_Renderer.Drawtext(-0.9, 0.8, 'Leben:'+ inttostr(Maps[0].base.livepoints),0.035);
	_Renderer.Drawtext(0.72, 0.82, 'Leben:' + inttostr(Maps[1].base.livepoints), 0.035);

        //show victory/defeat message
	if Maps[0].base.livepoints <= 0 then
           begin
             _renderer.SetZ(1);
	     _renderer.drawTexture(-0.5,-0.25,texDefeat,0.5,0.25,true);
           end;
	if Maps[1].base.livepoints <= 0 then
           begin
             _renderer.setZ(1);
             _renderer.drawTexture(-0.5,-0.25,texVictory,0.5,0.25,true);
           end;
end;

procedure TMainState.mouseUp();
begin
	//mouse collision
	inherited mouseUp();
	
	//does nothing when the cursor is not in the right pos
	//so no checks need to be made
	placeTower(curTowerType);
end;

procedure TMainstate.messages();
begin
//nothing should happen here for now
end;

procedure TMainState.evtEnd();
begin
	finalize();
end;

procedure TMainState.placeTower(_id : byte);
var msg : gameMsg;
	bx,by:integer;
begin
	if(_id = 0) then exit;
	//calculate hexagon hit
	bx:=round(((mouseX-maps[0].x)*20)-0.65);

	if bx < 0 then bx:=bx*-1;

	if odd(bx) then
		by:=round(((mouseY-1.5+(1/26)-maps[0].y)*13*-1)-0.6)
	else
		by:=round(((mouseY-1.5-maps[0].y)*13*-1)-0.6);

//	if by < 0 then by:=by*-1;
	
	//location exists
	//build phase is running and the space is available
	if (bx>-1) and (bx<17) and (by>-1) and (by<22)
	and(minionManager[0].ready) and not startwave and not Maps[0].Grid[bx,by].solid then
	begin
		//check whether the placement would block the way
		//simulate a tower at this location
		maps[0].Grid[bx,by].solid := true;
		maps[0].pathFinding();
		if (maps[0].path) = nil then
		begin
			//recover old state
			Maps[0].Grid[bx,by].solid := false;
                        maps[0].pathFinding();
			exit;
		end;
		
		Maps[0].Grid[bx,by].solid := false;
		
		msg := gameMsg.create(_id, bx, by);
		comManager.send(msg);
//		Maps[0].Grid[bx,by].active:=true;
    end;

end;

procedure TMainState.trainMinion(_id : byte);
var msg : gameMsg;
begin
	if((minionManager[0].ready) and not startwave) then
	begin
		msg := gameMsg.create(_id);
		comManager.send(msg);
	end;
end;

procedure TMainState.tower01();
begin
	curTowerType := 128;
	typeX := -0.7;
	typeY := 0.8;
end;

procedure TMainState.tower02();
begin
	curTowerType := 129;
	typeX := -0.55;
	typeY := 0.8;
end;

procedure TMainState.tower03();
begin
	curTowerType := 130;
	typeX := -0.4;
	typeY := 0.8;
end;

procedure TMainState.tower04();
begin
	curTowerType := 131;
	typeX := -0.25;
	typeY := 0.8;
end;

procedure TMainState.tower05();
begin
end;

procedure TMainState.minion01();
begin
	trainMinion(10);
end;

procedure TMainState.minion02();
begin
	trainMinion(11);
end;

procedure TMainState.minion03();
begin
	trainMinion(12);
end;

procedure TMainState.minion04();
begin
	trainMinion(13);
end;

procedure TMainState.minion05();
begin
	trainMinion(14);
end;
end.
