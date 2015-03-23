unit uTGameTrackBar;
//Klassen: TGameTrackBar

//Erstellt am: Di, 09.12.14 von Manuel
//bis So, 14.12.14 - von Manuel - erste Version.

interface

uses
  uTRenderer, uTTextureManager, uTTexture;

type                     
  TCallbackProcedure = procedure() of object;
  TGameTrackBar = class(TObject)
    public
      //   ___                                           ___
      //  |   |               ___                       |   |               A
      //  |   |              |   |                      |   |     A         |
      //  |   |--------------|   |----------------------|   |     |         |
      //  |   |              |   |                      |   | A   |         |
      //  |   |              |   |(x|y)<-- Mitte        |   | | h | rect_h  | edge_h
      //  |   |              |   |                      |   | V   |         |
      //  |   |--------------|   |----------------------|   |     |         |
      //  |   |              |___|                      |   |     V         |
      //  |___|                                         |___|               V       .
      //       <------------------ w ------------------>
      //   <->                <->
      //   edge_w             rect_w
      //
      constructor Create(_x, _y, _w, _h, _edge_w, _edge_h, _rect_w, _rect_h
        : GLfloat; _onchange : TCallbackProcedure; _min, _max, _val : integer;
        _texname, _tex_file_extension : string);
        //tex_file_extension mit Punkt. Der Rest ist selbsterklärend oder der
        //Skizze zu entnehmen.
      destructor Destory(); reintroduce;
      function GetXPos() : GLfloat;
      function GetYPos() : GLfloat;
      function GetWidth() : GLfloat;
      function GetHeight() : GLfloat;
      function GetEdgeWidth() : GLfloat;
      function GetEdgeHeight() : GLfloat; 
      function GetRectWidth() : GLfloat;
      function GetRectHeight() : GLfloat;
      function GetMinValue() : integer;
      function GetMaxValue() : integer;
      procedure SetCurrentValue(_val : integer);
      function GetCurrentValue() : integer;
      procedure MouseEnter(_x_pos : GLfloat);
      procedure MouseMove(_x_pos : GLfloat);
      procedure MouseLeave();
      procedure MouseDown();
      procedure MouseUp();
        //Die Angabe _x_pos ist die relative Mausposition zur Breite des
        //Reglers. -1.0 ist der linke Rand (rechts von der linken Kante), 1.0
        //ist rechts (links von der rechten Kante)
      procedure Render(_dtime: real; _renderer: TRenderer);
    private
      procedure SetRectPos();
      procedure Change();
    private
      m_x, m_y, m_w, m_h, m_edge_w, m_edge_h, m_rect_w, m_rect_h : GLfloat;
      m_mouse_pos_x : GLfloat;
      m_onchange : TCallbackProcedure;
      m_min, m_max, m_val : integer;
      m_tex_l_edge, m_tex_r_edge, m_tex_rect, m_tex_rect_down, m_tex_rect_over, m_tex_line : TTexture;
      m_mouse_is_down, m_mouse_is_over : boolean;
  end;

const
  c_gametrackbar_tex_edge_l_name = 'LeftEdge';
  c_gametrackbar_tex_edge_r_name = 'RightEdge';
  c_gametrackbar_tex_rect_name = 'Rect';       
  c_gametrackbar_tex_rect_down_name = 'RectDown';
  c_gametrackbar_tex_rect_over_name = 'RectOver';
  c_gametrackbar_tex_line_name = 'Line';

implementation

constructor TGameTrackBar.Create(_x, _y, _w, _h, _edge_w, _edge_h, _rect_w, _rect_h : GLfloat;
        _onchange : TCallbackProcedure; _min, _max, _val : integer;
        _texname, _tex_file_extension : string);
begin
  m_mouse_is_down := false;
  m_mouse_is_over := false;
  m_x := _x;
  m_y := _y;
  m_w := _w;
  m_h := _h;
  m_edge_w := _edge_w;
  m_edge_h := _edge_h;
  m_rect_w := _rect_w;
  m_rect_h := _rect_h;
  m_onchange := _onchange;
  m_min := _min;
  m_max := _max;
  m_val := _val;
  if(m_val < m_min) then m_val := m_min;
  if(m_val > m_max) then m_val := m_max;
  m_tex_l_edge := nil;
  m_tex_r_edge := nil;
  m_tex_rect := nil;
  m_tex_line := nil;
  m_tex_l_edge := g_texturemanager.UseTexture(_texname + c_gametrackbar_tex_edge_l_name + _tex_file_extension, true);
  m_tex_r_edge := g_texturemanager.UseTexture(_texname + c_gametrackbar_tex_edge_r_name + _tex_file_extension, true);
  m_tex_rect := g_texturemanager.UseTexture(_texname + c_gametrackbar_tex_rect_name + _tex_file_extension, true);
  m_tex_rect_down := g_texturemanager.UseTexture(_texname + c_gametrackbar_tex_rect_down_name + _tex_file_extension, true);
  m_tex_rect_over := g_texturemanager.UseTexture(_texname + c_gametrackbar_tex_rect_over_name + _tex_file_extension, true);
  m_tex_line := g_texturemanager.UseTexture(_texname + c_gametrackbar_tex_line_name + _tex_file_extension, true);
end;

destructor TGameTrackBar.Destory();
begin
  g_texturemanager.UnuseTexture(m_tex_l_edge);
  g_texturemanager.UnuseTexture(m_tex_r_edge);
  g_texturemanager.UnuseTexture(m_tex_rect); 
  g_texturemanager.UnuseTexture(m_tex_rect_down);
  g_texturemanager.UnuseTexture(m_tex_rect_over);
  g_texturemanager.UnuseTexture(m_tex_line);
end;

function TGameTrackBar.GetXPos() : GLfloat;
begin
  result := m_x;
end;

function TGameTrackBar.GetYPos() : GLfloat;
begin
  result := m_y;
end;

function TGameTrackBar.GetWidth() : GLfloat;
begin
  result := m_w;
end;

function TGameTrackBar.GetHeight() : GLfloat;
begin
  result := m_h;
end;

function TGameTrackBar.GetEdgeWidth() : GLfloat;
begin
  result := m_edge_w;
end;

function TGameTrackBar.GetEdgeHeight() : GLfloat;
begin
  result := m_edge_h;
end;
             
function TGameTrackBar.GetRectWidth() : GLfloat;
begin
  result := m_rect_w;
end;

function TGameTrackBar.GetRectHeight() : GLfloat;
begin
  result := m_rect_h;
end;

function TGameTrackBar.GetMinValue() : integer;
begin
  result := m_min;
end;

function TGameTrackBar.GetMaxValue() : integer;
begin
  result := m_max;
end;             

procedure TGameTrackBar.SetCurrentValue(_val : integer);
begin
  m_val := _val;
  Change();
end;

function TGameTrackBar.GetCurrentValue() : integer;
begin
  result := m_val;
end;

procedure TGameTrackBar.MouseEnter(_x_pos : GLfloat);
begin                  
  m_mouse_pos_x := _x_pos;
  if(m_mouse_is_down) then
    SetRectPos();
  m_mouse_is_over := true;
end;

procedure TGameTrackBar.MouseMove(_x_pos : GLfloat);
begin                 
  m_mouse_pos_x := _x_pos;
  if(m_mouse_is_down) then
    SetRectPos();
end;

procedure TGameTrackBar.MouseLeave();
begin
  m_mouse_is_over := false;
end;

procedure TGameTrackBar.MouseDown();
begin
  m_mouse_is_down := true;
  SetRectPos();
end;

procedure TGameTrackBar.MouseUp();
begin
  m_mouse_is_down := false;
end;

procedure TGameTrackBar.Render(_dtime: real; _renderer: TRenderer);
var
  tex : TTexture;
begin
  //Linie:
  _renderer.DrawTexture(m_x - m_w,
                        m_y - m_h,
                        m_tex_line, m_w, m_h, false);
  //Kante links:
  _renderer.DrawTexture(m_x - m_w - m_edge_w * 2.0,
                        m_y - m_edge_h,
                        m_tex_l_edge, m_edge_w, m_edge_h, false);
  //Kante rechts:
  _renderer.DrawTexture(m_x + m_w,
                        m_y - m_edge_h,
                        m_tex_r_edge, m_edge_w, m_edge_h, false);
  //Rechteck:
  if(m_mouse_is_over) then begin
    if(m_mouse_is_down) then begin
      tex := m_tex_rect_down;
    end else begin
      tex := m_tex_rect_over;
    end;
  end else begin
    tex := m_tex_rect;
  end;
  _renderer.DrawTexture(m_x - m_w + (m_val - m_min) * (m_w-m_rect_w) * 2.0 / (m_max - m_min),
                        m_y - m_rect_h,
                        tex, m_rect_w, m_rect_h, false);
end;

procedure TGameTrackBar.SetRectPos();
begin
  if(m_mouse_pos_x) > 1.0 - m_rect_w / m_w then m_mouse_pos_x := 1.0 - m_rect_w / m_w;
  if(m_mouse_pos_x) < -1.0 + m_rect_w / m_w then m_mouse_pos_x := -1.0 + m_rect_w / m_w;
  m_val := round((m_mouse_pos_x * (1 + m_rect_w / m_w) / 2.0 + 0.5) * m_max) + m_min;
  Change();
end;

procedure TGameTrackBar.Change();
begin
  if(m_val > m_max) then m_val := m_max;
  if(m_val < m_min) then m_val := m_min;
  if(assigned(m_onchange)) then begin
    m_onchange();
  end;
end;

end.
