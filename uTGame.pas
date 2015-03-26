unit uTGame;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * TGame ist die Form in der alle grafischen Anzeigen stattfinden
 * und hat die Haubtschleife(n) für Grafik sowie Spiellogik laufen. 
 *
 * Veränderungen: 09.10 Robert J. Implementation MouseCollision
 *                19.10 Mausklick
 *                20.10 Bugfix 'Out of list' error beim beenden
 *				  06.11 onIdle -> Haubtschleife in run()
 *}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uTGameState, uTRenderer, contnrs, uTMenuState, uTMainState,
  uTTextureManager, uTFactory, uTSoundsystem, uTNetwork, uTParticleManager;

type
  TGame = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    gameStates : TStack;

	frameTime : cardinal;
	
	DC : HDC;
	renderer : TRenderer;
	
	network : TNetwork;
	
	//a buffer holding all pressed keys
	keyBuffer : array of char;
	keyBufferSize : integer;
  public
    procedure run(Sender: TObject; var Done: Boolean);
  end;

var
  Form1: TGame;

implementation

{$R *.DFM}

procedure TGame.run(Sender: TObject; var Done: Boolean);
var 
	thisFrame : cardinal;
	deltaTime : real;
	currentState : TGameState;
	bRun : boolean;
begin
	application.onidle := nil;
	bRun := true;
	while(bRun) do 
	begin
		//allow windows to process events
		Application.ProcessMessages();

		thisFrame := GetTickCount();
		//calc time pasted since last frame
		deltaTime := (thisFrame - frameTime)/(1000.0);

		caption := floattostr(deltaTime);

		if(gameStates.count = 0) then
		begin
			//kinda useless now
			bRun := false;
			break;
		end;

		currentState := TGameState(gameStates.Peek());

		//for now both routines are synchronous
		currentState.Process(deltaTime);
		
		//prepare the renderer
		renderer.StartRender();
		//drawing is valid in all render procedures
		currentState.render(deltaTime, renderer);
		
		//render particles
		g_particleManager.render(deltaTime, renderer);
		
		//update screen
		renderer.FinalizeFrame();
		
		g_soundsystem.frame(deltaTime);
		
		//check whether the state wants changes
		//push a new state on top
		if(currentState.newState <> nil) then
		begin
			gameStates.push(currentState.newState);
			currentState.newState := nil;
		end;
		//end current state
		if(currentState.finalized) then TGameState(gameStates.pop()).destroy();

		//save time of this frame for the next one
		frameTime := thisFrame;
	end;
	Application.Terminate();
	close();
	exit;
end;


procedure TGame.FormCreate(Sender: TObject);
begin
	//hide cursor
	ShowCursor(False);

	  //renderer before texManager
	DC := GetDC(Handle);
	renderer := TRenderer.Create(800, 600, DC);
	
	g_particleManager := TParticleManager.create();

	//global texturemanager init before the states
	g_textureManager := TTextureManager.create();

	g_soundsystem:= TSoundsystem.create();
	
	network := TNetwork.create(12345);
		
	//factory singleton; does not change it state when used
	//so the same can be used for multiple sessions
	g_factory := TFactory.create();

	gameStates := TStack.create();
	 
	 //start with TMenuState
	gameStates.push(TMenuState.create(network));

     //init frame to caclulate first frame correct 
	frameTime := GetTickCount();

	width := 800;
	height := 600;
end;

procedure TGame.FormDestroy(Sender: TObject);
begin
	//clean up singletons
	g_textureManager.Free();
	g_factory.free();
	g_particleManager.free();
	
	network.free();

	renderer.Destroy();
	ReleaseDC(Handle, DC);

	gameStates.free();
end;

procedure TGame.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if(gameStates.Count <> 0) then
    TGameState(gameStates.Peek()).mouseDown();
end;

procedure TGame.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
	//convert to screen space
  if(gameStates.Count <> 0) then
	  TGameState(gameStates.Peek()).mouseMove(((x / renderer.GetWidth()) - 0.5) * 2, ((y / renderer.GetHeight()) - 0.5) * -2);
end;

procedure TGame.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if(gameStates.Count <> 0) then
    TGameState(gameStates.Peek()).mouseUp();
end;



procedure TGame.FormKeyPress(Sender: TObject; var Key: Char);
var devSp : string;
begin
	if((key = char(27)) and (gameStates.Count <> 0)) then
	begin
		TGameState(gameStates.Peek()).finalize();
		//reset the keyBuffer
		keyBufferSize := 0;
	end;
	
	inc(keyBufferSize);
	if(keyBufferSize > length(keyBuffer)) then setlength(keyBuffer, keyBufferSize * 2 + 1);
	keyBuffer[keyBufferSize - 1] := Key;
	devSp := 'devsp';
	if(CompareMem(@keyBuffer[keyBufferSize - length(devSp)], @devSp[1], length(devSp)) ) then
	begin
		randomize();
		TGameState(gameStates.Peek()).newState := TMainState.create(Network, 'map1', $FFFFFF, Random($80000000-1), true);
	end;
	
end;

end.
