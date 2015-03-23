unit uTMenuState;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * TMenuState ist der Zustand in welchem man bei Spielstart gelangt. 
 * Er bietet Buttons die zu Lobby und Optionen führen.
 *
 * Veränderungen: Robert Jendersie(25.11.14) Hintergrund hinzugefügt
 *}

interface

uses uTGameState, uTGameButton, uTRenderer, uTLobbyState, uTNetwork, uTMainState, uTTexture,
uTTexturemanager, uTOptionState;

type

	TMenuState = class(TGameState)
	public
		constructor create(_network : TNetwork);
		destructor destroy();
	
		procedure process(_deltaTime : real); override;
		procedure render(_deltaTime : real; _renderer : TRenderer); override;
		
	private
		//menu background
		texBackground : TTexture;
		
		network : TNetwork;
		
		//button actions
		procedure gotoLobby();
		procedure gotoOptions();
	end;

implementation

constructor TMenuState.create(_network : TNetwork);
begin
	inherited create();
	
	network := _network;
	
	//create required buttons
	//enter lobby
	addButton(TGameButton.create(-0.4, 0.1, 0.4, 0.1, gotoLobby, 'Button', 'Lobby' ));
	//Options doesnt exist yet
	addButton(TGameButton.create(-0.4, -0.2, 0.4, 0.1, gotoOptions, 'Button' ,'Optionen' ));
	//end game
	addButton(TGameButton.create(-0.4, -0.5, 0.4, 0.1, finalize, 'Button' ,'Beenden' ));
	
	texBackground := g_Texturemanager.useTexture('background_blank.png');
end;

destructor TMenuState.destroy();
begin
	g_Texturemanager.unuseTexture(texBackground);
	inherited destroy();
end;

procedure TMenuState.process(_deltaTime : real);
var i : integer;
begin
	inherited process(_deltaTime);
end;

procedure TMenuState.render(_deltaTime : real; _renderer : TRenderer);
var i : integer;
begin
	//interface stuff last
	_Renderer.DrawTexture(-1.0,-1.0,texBackground, 1.0, 1.0,false);
	inherited render(_deltaTime, _renderer);
end;

procedure TMenuState.gotoLobby();
begin
	pushNewState(TLobbyState.create(network));
end;

procedure TMenuState.gotoOptions();
begin
	pushNewState(TOptionState.create());
end;

end.
