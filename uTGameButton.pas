UNIT uTGameButton;
{
Verfasser:                     Katja Holzinger (14-10-08);
Beschreibung der Klasse:       Die Klasse „TButton“ dient zur Verabeitung von Button klicks und mouseover.
Beschreibung der Veränderung:  K. H. (14-10-08): Erstellen der Unit
							   Robert J.(17-10-14): dynamische Texturauswahl
}

interface

//--------------------  ggf Uses-Liste einfügen !  --------------------
uses uTrenderer, dglOpenGL,uTTexturemanager, uTTexture ;

type
  TMouseUp = procedure() of object;
  TMouseEnter = Procedure() of object;
  TMouseLeave = Procedure() of Object;
  TMouseDown = Procedure() of object;
  TMouseMove = Procedure() of object;
  TGameButton = class

  public //Methoden
  x: real;
  y: real;
  w: real;
  h: real;
  state: integer;
  Popuptext:string;
  Caption:string;
  OnMouseUp: TmouseUp;
  onMOuseEnter: TMouseEnter;
  onMouseLeave:TMouseLEave;
  onMousedown: TMousedown;
  onMouseMove: TMouseMove;
  constructor create (_x: GLfloat; _y: GLfloat; _w: GLfloat; _h: GLfloat; _onMouseUp: TMouseUp; _texName : string;_caption : string = '');
  destructor destroy ();
  procedure MouseMove; virtual;
//  procedure Popup ; virtual;
  procedure MouseEnter; virtual;
  procedure MouseLeave; virtual;
  procedure MouseDown; virtual;
  procedure MouseUp;
  procedure render(_dTime: real; _Renderer: TRenderer);
  
  private
	texDefault : TTexture;
	texOver : TTexture;
	texDown : TTexture;
end;


// Timer:TTimer;

implementation

//+---------------------------------------------------------------------
//|         TButton: Methodendefinition
//+---------------------------------------------------------------------

//-------- create (public) ---------------------------------------------
constructor TGameButton.create (_x: GLfloat; _y: GLfloat; _w: GLfloat; _h: GLfloat; _onMouseUp: TMouseUp; _texName,_caption : string);
begin
 inherited create();
 x:= _x;
 y:= _y;
 w:= _w;
 h:= _h;
 caption:=_caption;
texDefault := g_Texturemanager.useTexture(_texName + '.png');
texOver    := g_Texturemanager.useTexture(_texName + 'Over.png');
texDown    := g_Texturemanager.useTexture(_texName + 'Down.png');

onMouseUp := _onMouseUp;

// Timer:=TTimer.create;
// Timer.enabled:=false;
end;

destructor TGameButton.destroy();
begin
	g_textureManager.UnuseTexture(texDefault);
	g_textureManager.UnuseTexture(texOver);
	g_textureManager.UnuseTexture(texDown);
end;

//-------- OnMouseMove (public) ----------------------------------------
{procedure TGameButton.OnMouseMove;
begin

end;  }

//-------- Popup (public) ----------------------------------------------
{procedure TGameButton.Popup;
begin
  if state=2 then
  begin

  end;
end; }

procedure TGameButton.render(_dTime: real; _Renderer: TRenderer);
begin

_Renderer.setz(0.5);
case state of
0: _Renderer.DrawTexture(x,y,texDefault,w,h,true);
1: _Renderer.DrawTexture(x,y,texDown,w,h,true);
2: begin
    _Renderer.DrawTexture(x,y,texOver,w,h,true);
   end;
end;
_Renderer.setz(0.9);
_Renderer.DrawTextEX(x+w,y+h/2,caption,h*0.8,true,w,0.7,0.7,0.7);
end;

procedure TGameButton.MouseDown;
begin
//	if(Onmousedown <> nil) then
//		Onmousedown;
  state:=1;
end;

procedure TGameButton.MouseEnter;
begin
//	if(Onmousedown <> nil) then
//		OnMouseEnter;
  state:=2;
end;

procedure TGameButton.MouseLeave;
begin
//	if(Onmousedown <> nil) then
//		OnmouseLeave;
  state:=0;
end;

procedure TGameButton.MouseUp;
begin
  OnmouseUp;
  state:=0;
end;

procedure TGameButton.MouseMove;
begin
  OnmouseMove;
end;
end.
