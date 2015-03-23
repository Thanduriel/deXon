unit uTComManager;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * Der TComManager ist ein Wrapper für Netzwerkkomunikation.
 * Er übersetzt Nachrichten aus dem Netzwerk in verarbeitbare Befehle und anders herum. 
 *
 * Veränderungen: Robert Jendersie (27.11.14) send() und recieve() Funktionalität
 * 								   (12.02.14) Anpassung an neue Netzwerkklasse
 *								   (12.04.14) execute() Funktionalität hinzugefügt
 *}

interface

uses uTNetwork, uTMap, uTPlayer, uTMinionManager, uTFactory, uTTower, uTMinion;

type
	gameMsg = class
	public
		player : byte;
		id : byte; 
		posX : byte;
		posY : byte;
		
		constructor create(_id : byte; _posX : byte = 0; _posY : byte = 0); overload;
		//fast constructor to recieve msg
		constructor create(); overload;
	end;
	
	TComManager = class
	public
		{* create() *********************************** 
		 * nimmt Besitz der network
		 *}
		constructor create(_network : TNetwork; _maps : array of TMap; _player : array of TPlayer; _minionManager : array of TMinionManager);
		destructor destroy();
	
		procedure send( _msg : gameMsg);
		
		procedure process(_deltaTime : real);
		
	private
		network : TNetwork;
		
		//pointers to game objects handled by the mainState
		//needed to execute player input
		maps : array[0..1] of TMap;
		player : array[0..1] of TPlayer;
		minionManager : array[0..1] of TMinionManager;
		
		msgBuf : array of gameMsg;
		bufCount : integer;
		
		procedure execute(_msg : gameMsg);
		
		procedure receive(_str : string);
	end;

implementation

constructor gameMsg.create(_id : byte; _posX : byte; _posY : byte);
begin
	//minion spawn happens for the enemy; tower for self
	//player := _id > 127 ? 0 : 1;
	if(_id > 127) then player := 0
	else player := 1;
	id := _id;
	posX := _posX;
	posY := _posY;
end;

constructor gameMsg.create();
begin
end;

constructor TComManager.create(_network : TNetwork; _maps : array of TMap; _player : array of TPlayer; _minionManager : array of TMinionManager);
begin
	inherited create;
	
	network := _network;
	network.OnReceive := receive;
{	maps[0] := _maps[0]; maps[1] := _maps[1];
	player[0] := _player[0]; player[1] := _player[1];
	minionManager[0] := _minionManager[0]; minionManager[1] := _minionManager[1];}
	move(_maps[0], maps[0], sizeof(TMap) * 2);
	move(_player[0], player[0], sizeof(TPlayer) * 2);
	move(_minionManager[0], minionManager[0], sizeof(TMinionManager) * 2);
	
	//custom management to prevent memory allocation
	setLength(msgBuf, 10);
	bufCount := 0;
end;

procedure TComManager.process(_deltaTime : real);
var strMsg : string;
var msg : gameMsg;
var i : integer;
begin
	//read messages recieved
	for i := 0 to bufCount - 1 do begin
		execute(msgBuf[i]);
		msgBuf[i].free();
	end;
	bufCount := 0;
end;

procedure TComManager.send( _msg : gameMsg);
var strMsg : string;
begin
	//run command on client
	execute(_msg);
	
	//for the opponent, its an enemys cmd, thus invert
	_msg.player := integer(not boolean(_msg.player));
	
	//but msg into a string
	setLength(strMsg, 4);
	strMsg[1] := char(_msg.player);
	strMsg[2] := char(_msg.id);
	strMsg[3] := char(_msg.posX);
	strMsg[4] := char(_msg.posY);	
	//setLength(strMsg, gameMsg.InstanceSize); //sizeof
	//move(_msg, strMsg[1], gameMsg.InstanceSize); //sizeof
	network.Send(strMsg);
	
	//msg is not needed anymore
	_msg.free();
end;


procedure TComManager.execute(_msg : gameMsg);
var x, y : real;
	tower : TTower;
	minion : TMinion;
	mM : TMinionManager;
begin
	//tower id
	if(_msg.id > 127) then 
	begin
		//place tower
		//extract the location in screen space
		x := Maps[_msg.player].Grid[_msg.posX,_msg.posY].x;
		y := Maps[_msg.player].Grid[_msg.posX,_msg.posY].y;
		tower := g_factory.createTower(_msg.id, x, y);
		
		//check cost
		if(tower.cost > player[_msg.player].getGold()) then
		begin
			tower.free();
			exit;
		end;
		
		//substract money
		player[_msg.player].decreasegold(tower.cost);
		
		mM := Maps[_msg.player].Grid[_msg.posX,_msg.posY].minionManager;
		//put a new tower in the map
		Maps[_msg.player].Grid[_msg.posX,_msg.posY].free();
		//take the minionManager from any other hex
		tower.minionManager := mM;
		Maps[_msg.player].Grid[_msg.posX,_msg.posY] := tower;
		
	end
	//minion id
	else begin
		minion := g_factory.createMinion(_msg.id);
		
		//check cost; 
		if(minion.cost > player[integer(not boolean(_msg.player))].getGold()) then
		begin
			minion.free();
			exit;
		end;
		
		minionManager[_msg.player].add(minion);
		//substract money from the other player
		player[integer(not boolean(_msg.player))].decreasegold(minion.cost);
	end;
end;

procedure TComManager.receive(_str : string);
begin
	//enlaging with factor 2; 1.5 could be better here
	if(bufCount > high(msgBuf)) then setlength(msgBuf, length(msgBuf) * 2);
	//translate the msg
	msgBuf[bufCount] := gameMsg.create();
	//put the msg in the buffer
	msgBuf[bufCount].player := byte(_str[1]);
	msgBuf[bufCount].id := byte(_str[2]);
	msgBuf[bufCount].posX := byte(_str[3]);
	msgBuf[bufCount].posY := byte(_str[4]);	
	//move(_str[1], msgBuf[bufCount], gameMsg.InstanceSize); //sizeof()
	inc(bufCount);
end;

destructor TComManager.destroy();
var i : integer;
begin
	//has ownership of the network
	network.endGame(false);
	
	//make shure that the buffer is cleared
	for i:= 0 to bufCount - 1 do msgBuf[i].free();
end;

end.
