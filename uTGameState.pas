unit uTGameState;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * TGameState ist ein Zustand in dem sich das Spiel befindet. 
 * Er kontrolliert die aktuelle grafische Repräsentation sowie die laufende Logik.
 *
 * Veränderungen: 09.10 Robert J. Implementation MouseCollision
 *				  16.10 Robert J. Fehlerbehebung
 *                19.10 Fehlerbehebung Mousecollision und aspectRatio; Mausklick
 *				  04.12 Mausklick Event virtual und Änderung Zugriffsrechte mouseLoc auf protected
 *}

interface

uses uTRenderer, uTGameButton, uTTexture, uTTextureManager, uTGameTrackBar;

type

	TGameState = class
	public
		constructor create();
		destructor destroy();

		procedure process(_deltaTime : real); virtual;
		procedure render(_deltaTime : real; _renderer : TRenderer); virtual;

		procedure finalize();

		procedure pushNewState(_state : TGameState);
		
		//mouse collision detection
		procedure addButton(_btn : TGameButton);
		procedure addTrackBar(_trackbar : TGameTrackBar); //ADDED BY MANUEL
		
		procedure mouseMove(_x, _y : real);
		procedure mouseDown(); virtual;
		procedure mouseUp(); virtual;

    procedure updateAspectRatio(_aspectRatio : real);
	public	
		finalized : boolean;
        newState : TGameState;
		
	protected
		//cursor stuff
		mouseX : real;
		mouseY : real;
		
	private
    //button managment
		buttons : array of TGameButton;
		//focused button in previous action
		prevBtn : TGameButton;
		
		mouseTex : TTexture;
		
		trackbars : array of TGameTrackBar; //ADDED BY MANUEL
		prevTrackBar : TGameTrackBar;       //ADDED BY MANUEL

    //
		aspectRatio : real;
	end;

implementation

constructor TGameState.create();
begin
	finalized := false;
	prevBtn := nil;
	prevTrackBar := nil;                        //ADDED BY MANUEL
	mouseTex := g_textureManager.useTexture('cursor.png');
end;

destructor TGameState.destroy();
var i : integer;
begin
	for i:= 0 to length(buttons) - 1 do
		buttons[i].destroy();
	for i:= 0 to length(trackbars) - 1 do  //ADDED BY MANUEL
		trackbars[i].destroy();        //ADDED BY MANUEL
end;

procedure TGameState.process(_deltaTime : real);
begin
end;

procedure TGameState.render(_deltaTime : real; _renderer : TRenderer);
var i : integer;
begin
  //temporal ugly solution
  //remove as soon as there is an alternative
  aspectRatio := _renderer.GetWidth() / _renderer.GetHeight();

	for i:= 0 to length(buttons) - 1 do
	begin
		buttons[i].render(_deltaTime, _renderer);
	end;
	
	for i:= 0 to length(trackbars) - 1 do                //ADDED BY MANUEL
	begin                                                //ADDED BY MANUEL
		trackbars[i].render(_deltaTime, _renderer);  //ADDED BY MANUEL
	end;                                                 //ADDED BY MANUEL
	
	//render the cursor
	_renderer.setZ(1.0);
	_renderer.DrawTexture(mouseX, mouseY - 0.05 * aspectRatio , mouseTex, 0.025, 0.025, true);
end;

procedure TGameState.finalize();
begin
	finalized := true;
end;

procedure TGameState.pushNewState(_state : TGameState);
begin
     newState := _state;
end;

procedure TGameState.addButton(_btn : TGameButton);
var len : integer;
begin
	len := length(buttons);
	setlength(buttons, len + 1);
	buttons[len] := _btn;
	
end;

procedure TGameState.addTrackBar(_trackbar : TGameTrackBar); //ADDED BY MANUEL
var len : integer;                                           //ADDED BY MANUEL
begin                                                        //ADDED BY MANUEL
	len := length(trackbars);                            //ADDED BY MANUEL
	setlength(trackbars, len + 1);                       //ADDED BY MANUEL
	trackbars[len] := _trackbar;                         //ADDED BY MANUEL
end;                                                         //ADDED BY MANUEL

procedure TGameState.mouseMove(_x, _y : real);
var i : integer;
var posX, posY : real;
begin
	//save new pos
	mouseX := _x;
	mouseY := _y;

	//mouse collision
	//collision with hud elements
	for i:= 0 to length(buttons) - 1 do
	begin
    //calculate right upper corner
		posX := buttons[i].x + buttons[i].w * 2;
		posY := buttons[i].y + buttons[i].h * 2 * aspectRatio;
		if((buttons[i].x < mouseX) and (buttons[i].y < mouseY)
		and(posX > mouseX) and (posY > mouseY)) then
		begin
			//enter new element; leave old
			if(prevBtn <> buttons[i]) then
			begin
				if(prevBtn <> nil) then
				begin
					prevBtn.mouseLeave();
					prevBtn := nil;
				end;  
				if(prevTrackBar <> nil) then            //ADDED BY MANUEL
				begin                                   //ADDED BY MANUEL
					prevTrackBar.mouseLeave();      //ADDED BY MANUEL
					prevTrackBar := nil;            //ADDED BY MANUEL
				end;                                    //ADDED BY MANUEL
				buttons[i].mouseEnter();
				prevBtn := buttons[i];
			end;
      exit;
    end;
  end;    
  //leave element; enter free space
	if(prevBtn <> nil) then
	begin
		prevBtn.mouseLeave();
		prevBtn := nil;
	end;
  //trackbar collision
  for i := 0 to Length(trackbars) - 1 do begin                          //ADDED BY MANUEL...
    if(
        (mouseX > trackbars[i].GetXPos() - trackbars[i].GetWidth()) //left
    and (mouseY > trackbars[i].GetYPos() - trackbars[i].GetRectHeight()) //down
    and (mouseX < trackbars[i].GetXPos() + trackbars[i].GetWidth()) //right
    and (mouseY < trackbars[i].GetYPos() + trackbars[i].GetRectHeight()) //up
    ) then
    begin
      if(prevTrackBar <> trackbars[i]) then begin
        if(prevTrackBar <> nil) then
        begin
          prevTrackBar.mouseLeave();
          prevTrackBar := nil;
        end;
        trackbars[i].MouseEnter((mouseX - trackbars[i].GetXPos()) / trackbars[i].GetWidth());
        prevTrackBar := trackbars[i];
      end else begin
        prevTrackBar.MouseMove((mouseX - prevTrackBar.GetXPos()) / prevTrackBar.GetWidth());
      end;
      exit;
    end;
  end;
  if(prevTrackBar <> nil) then
  begin
    prevTrackBar.mouseLeave();
    prevTrackBar := nil;
  end;                                                                  //...ADDED BY MANUEL
end;

procedure TGameState.mouseDown;
begin
  if(prevBtn <> nil) then
    prevBtn.MouseDown();
  if(prevTrackbar <> nil) then                                //ADDED BY MANUEL
    prevTrackbar.MouseDown();                                 //ADDED BY MANUEL
end;

procedure TGameState.mouseUp;
begin
  if(prevBtn <> nil) then
    prevBtn.MouseUp();
  if(prevTrackbar <> nil) then                                //ADDED BY MANUEL
    prevTrackbar.MouseUp();                                   //ADDED BY MANUEL
end;

procedure TGameState.updateAspectRatio(_aspectRatio: Real);
begin
  aspectRatio := _aspectRatio;
end;

end.
