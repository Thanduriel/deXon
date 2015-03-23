unit uTParticle;
//Klassen: TParticle, TParticleElement
//Benötigt uTRenderer.pas, uTTexture.pas, uTTextureManager.pas

//Erstellt am: Di, 25.11.14 von Manuel
//bis Mi, 26.11.14 - von Manuel - erste Version. ReduceParticles muss noch
//                            implementiert werden. Die Werte, die an TParticle
//                            bei Init übergeben werden, müssen noch etwas
//                            angepasst werden.
//Do, 27.11.14 (1) - von Manuel - ReduceParticles implementiert.  
//Do, 27.11.14 (2) - von Manuel - Diffusion direction wird nun auch
//                            berücksichtigt.
//Fr, 28.11.14 - von Manuel - Geschwindigkeits- und Beschleunigungswerte
//                            entsprechen nun der Dokumentation.   
//Sa, 29.11.14 - von Manuel - JETZT entsprechen Geschwindigkeits- und
//                            Beschleunigungswerte der Dokumentation. (Hatte
//                            die Werte versehentlich durch 2 geteilt anstatt
//                            mit zwei multipliziert.
//Sa, 06.12.14 - von Manuel - Korrektur der Partikelentfernungswahrscheinlich-
//                            keitsberechnung.  
//Nacht zu Di, 09.12.14 - von Manuel - Kommentare hinzugefügt.

interface              

uses
  Windows, SysUtils, Math, Graphics, uTRenderer, uTTexture, uTTextureManager;

type
  TVec2 = Array[0..1] of GLfloat;
  TParticleElement = class(TObject)
    public
      constructor Create();
      destructor Destroy(); reintroduce;
      procedure Init(_x, _y : GLfloat; _vel_x, _vel_y : GLfloat;
        _acc_x, _acc_y : GLfloat; _att : real);
      procedure UpdateValues(_renderer : TRenderer; _dtime : real);
      procedure Render(_renderer : TRenderer; _tex : TTexture);
      function GetElapsedTime() : real;
    private
      m_source_x, m_source_y : GLfloat;
        //Hier ist das Partikel entstanden.
      m_time_elapsed : real;
      m_x, m_y : GLfloat;
      m_adv_eq_x, m_adv_eq_y : boolean;
        //gibt an, ob die erweiterte Gleichung für die Positionsberechnung
        //genutzt werden soll (mit Berücksichtigung des Widerstandes).
      m_ax, m_bx, m_cx, m_ay, m_by, m_cy : real;
        //das sind Parameter für die Gleichung, abhängig davon, welche genutzt
        //werden soll.
  end;
  TParticle = class(TObject)
    public
      constructor Create();
      destructor Destroy(); reintroduce;
      procedure Init(_x, _y : GLfloat; _tex : TTexture;
        _num : integer;
        _diffusion_min_velocity, _diffusion_max_velocity : real;
        _attenuation : real;
        _diffusion_direction_x, _diffusion_direction_y : GLfloat;
        _diffusion_direction_forcing : real;
        _source_velocity_x, _source_velocity_y : GLfloat;
        _start_velocity_x, _start_velocity_y : GLfloat;
        _abs_acceleration_x, _abs_acceleration_y : GLfloat;
        _emitation_duration : real;
        _min_particle_duration, _max_particle_duration : real);
        //siehe uTParticleManager.pas für die Dokumentation
      procedure Render(_dtime : real; _renderer : TRenderer);
      procedure ReduceParticles(_fraction : real);
      function GetParticleNum() : integer;
      function IsEmpty() : boolean;
    private
      m_particles : Array of TParticleElement;
      m_x, m_y : GLfloat;
      m_tex : TTexture;
      m_num, m_actual_num : integer;
      m_dif_min_vel, m_dif_max_vel : real;
      m_att : real;
      m_dif_dir_center : real;
      m_dif_dir_forcing : real;
      m_source_vel_x, m_source_vel_y : real;
      m_part_start_vel_x, m_part_start_vel_y : real;
      m_part_acc_x, m_part_acc_y : real;
      m_emitation_dur, m_elapsed_time : real;
      m_min_part_dur, m_max_part_dur : real;
      m_next_index_to_create, m_next_min_index_to_delete, m_next_max_index_to_delete : integer;
  end;

implementation

constructor TParticleElement.Create();
begin
  inherited Create();
  m_time_elapsed := 0.0;
end;   

procedure TParticleElement.Init(_x, _y : GLfloat; _vel_x, _vel_y : GLfloat;
        _acc_x, _acc_y : GLfloat; _att : real);
begin
  m_source_x := _x;
  m_source_y := _y;
  m_x := _x;
  m_y := _y;
  //Die Parameter für die Berechnung der Position werden hier bestimmt. Diese
  //verändern sich nicht, weshalb man sie nur ein einziges Mal bestimmen muss
  //und die Performance weniger drunter leidet.
  if((_att < 0.001) or (_vel_x = _acc_x / _att)) then begin
    m_adv_eq_x := false;
    m_ax := (_acc_x - _att * _vel_x) / 2;
    m_bx := _vel_x;
    m_cx := 0;
  end else begin
    m_adv_eq_x := true;
    m_cx := _acc_x / _att;
    m_ax := _vel_x - m_cx;
    m_bx := (_acc_x - _att * _vel_x) / m_ax;
    m_ax := m_ax / m_bx;
  end;    
  if((_att < 0.001) or (_vel_y = _acc_y / _att)) then begin
    m_adv_eq_y := false;
    m_ay := (_acc_y - _att * _vel_y) / 2;
    m_by := _vel_y;
    m_cy := 0;
  end else begin
    m_adv_eq_y := true;
    m_cy := _acc_y / _att;
    m_ay := _vel_y - m_cy;
    m_by := (_acc_y - _att * _vel_y) / m_ay;
    m_ay := m_ay / m_by;
  end;
end;

destructor TParticleElement.Destroy();
begin
  inherited Destroy();
end;

procedure TParticleElement.UpdateValues(_renderer : TRenderer; _dtime : real);
begin
  //Positionsberechnung (Herleitung in der Belegarbeit):
  m_time_elapsed := m_time_elapsed + _dtime;
  if(m_adv_eq_x) then begin
    m_x := m_source_x + m_ax * (exp(m_bx * m_time_elapsed) - 1.0) + m_cx * m_time_elapsed;
  end else begin
    m_x := m_source_x + m_ax * m_time_elapsed * m_time_elapsed + m_bx * m_time_elapsed;
  end;                    
  if(m_adv_eq_y) then begin      
    m_y := m_source_y * _renderer.GetHeight() / _renderer.GetWidth() + m_ay * (exp(m_by * m_time_elapsed) - 1.0) + m_cy * m_time_elapsed;
  end else begin
    m_y := m_source_y * _renderer.GetHeight() / _renderer.GetWidth() + m_ay * m_time_elapsed * m_time_elapsed + m_by * m_time_elapsed;
  end;
end;

procedure TParticleElement.Render(_renderer : TRenderer; _tex : TTexture);
begin
  _renderer.DrawTexture(m_x, m_y * _renderer.GetWidth / _renderer.GetHeight(),
    _tex, 0.01, 0.01, true);
end;   

function TParticleElement.GetElapsedTime() : real;
begin
  result := m_time_elapsed;
end;

constructor TParticle.Create();    
begin
  inherited Create();   
  SetLength(m_particles, 0);
  m_tex := nil;
  m_actual_num := 0;
end;

destructor TParticle.Destroy();
var
  i : integer;
begin
  if(m_tex <> nil) then begin
    g_texturemanager.UnuseTexture(m_tex);
  end;
  for i := 0 to Length(m_particles) - 1 do begin
    if(m_particles[i] <> nil) then
      m_particles[i].Destroy();
  end;
  SetLength(m_particles, 0);
  inherited Destroy();
end;

procedure TParticle.Init(_x, _y : GLfloat; _tex : TTexture;
        _num : integer;
        _diffusion_min_velocity, _diffusion_max_velocity : real;
        _attenuation : real;
        _diffusion_direction_x, _diffusion_direction_y : GLfloat;
        _diffusion_direction_forcing : real;
        _source_velocity_x, _source_velocity_y : GLfloat;
        _start_velocity_x, _start_velocity_y : GLfloat;
        _abs_acceleration_x, _abs_acceleration_y : GLfloat;
        _emitation_duration : real;
        _min_particle_duration, _max_particle_duration : real);
var
  i : integer;
begin
  m_x := _x;
  m_y := _y;
  m_tex := _tex;
  g_texturemanager.UseTexture(_tex);
  m_num := _num;
  m_dif_min_vel := _diffusion_min_velocity * 2;
  m_dif_max_vel := _diffusion_max_velocity * 2;
  m_att := _attenuation;
  if((_diffusion_direction_x = 0) and (_diffusion_direction_y = 0)) then begin
    m_dif_dir_forcing := 0.0;
    m_dif_dir_center := 0.0;
  end else begin
    m_dif_dir_forcing := _diffusion_direction_forcing;
    m_dif_dir_center := arccos(
      abs(_diffusion_direction_x)
      /
      sqrt(_diffusion_direction_x * _diffusion_direction_x + _diffusion_direction_y * _diffusion_direction_y)
      );
  end;
  m_source_vel_x := _source_velocity_x * 2;
  m_source_vel_y := _source_velocity_y * 2;
  m_part_start_vel_x := _start_velocity_x * 2;
  m_part_start_vel_y := _start_velocity_y * 2;
  m_part_acc_x := _abs_acceleration_x * 2;
  m_part_acc_y := _abs_acceleration_y * 2;
  m_emitation_dur := _emitation_duration;
  m_min_part_dur := _min_particle_duration;
  m_max_part_dur := _max_particle_duration;
  m_next_index_to_create := 0;
  m_next_min_index_to_delete := 0;
  m_next_max_index_to_delete := 0;
  m_elapsed_time := 0.0;
  SetLength(m_particles, _num);
  for i := 0 to _num - 1 do begin
    m_particles[i] := nil;
  end;
end;

procedure TParticle.Render(_dtime : real; _renderer : TRenderer);
var
  i, last_index_to_create, last_min_index_to_delete : integer;
  dir : real;
  dif_vel : GLfloat;
begin    
  //Partikel hinzufügen:
  m_x := m_x + _dtime * m_source_vel_x;    
  m_y := m_y + _dtime * m_source_vel_y;
  m_elapsed_time := m_elapsed_time + _dtime;
  if(m_next_index_to_create < m_num) then begin
    last_index_to_create := m_next_index_to_create;
    if(m_emitation_dur <= 0.001) then begin
      m_next_index_to_create := m_num;
    end else begin
      m_next_index_to_create := round(m_num * m_elapsed_time / m_emitation_dur);
      if(m_next_index_to_create > m_num) then
        m_next_index_to_create := m_num;
    end;
    for i := last_index_to_create to m_next_index_to_create - 1 do begin
      m_particles[i] := TParticleElement.Create();
      inc(m_actual_num);
      dir := random(628)/100 * (1.0 - m_dif_dir_forcing) + m_dif_dir_center;
      dif_vel := random(Round((m_dif_max_vel - m_dif_min_vel) * 100)) / 100 + m_dif_min_vel;
      m_particles[i].Init(m_x, m_y,
        m_source_vel_x + m_part_start_vel_x + cos(dir) * dif_vel,
        m_source_vel_x + m_part_start_vel_y + sin(dir) * dif_vel,
        m_part_acc_x, m_part_acc_y, m_att); //TODO (die vorletzten beiden Werte)
    end;
  end;
  //Partikel löschen:
  if(m_next_min_index_to_delete < m_num) then begin
    last_min_index_to_delete := m_next_min_index_to_delete;
    if(m_emitation_dur > 0.001) then begin
      m_next_min_index_to_delete := round(m_num * (m_elapsed_time - m_max_part_dur) / m_emitation_dur);
      m_next_max_index_to_delete := round(m_num * (m_elapsed_time - m_min_part_dur) / m_emitation_dur);
    end else begin
      m_next_min_index_to_delete := round(m_num * (m_elapsed_time - m_max_part_dur) / 0.001);
      m_next_max_index_to_delete := round(m_num * (m_elapsed_time - m_min_part_dur) / 0.001);
    end;
    if(m_next_min_index_to_delete < 0) then m_next_min_index_to_delete := 0;
    if(m_next_max_index_to_delete < 0) then m_next_max_index_to_delete := 0;
    if(m_next_min_index_to_delete > m_num) then m_next_min_index_to_delete := m_num;
    if(m_next_max_index_to_delete > m_num) then m_next_max_index_to_delete := m_num;
    for i := last_min_index_to_delete to m_next_min_index_to_delete - 1 do begin
      if(m_particles[i] <> nil) then begin
        m_particles[i].Destroy();
        m_particles[i] := nil;
        dec(m_actual_num);
      end;
    end;
    if ((m_max_part_dur - m_min_part_dur) > 0.001) then for i := m_next_min_index_to_delete to m_next_max_index_to_delete - 1 do begin
      //Wenn es der Zufall so will: Partikel löschen (Herleitung der Wahrscheinlichkeit in der Belegarbeit):
      if(m_particles[i] <> nil) and (random(100000) < round(( _dtime / (m_max_part_dur - m_particles[i].GetElapsedTime()) ) * 100000)) then begin
        m_particles[i].Destroy();
        m_particles[i] := nil;
        dec(m_actual_num);
      end;
    end;
  end;
  //Partikel rendern:
  for i := 0 to Length(m_particles) - 1 do begin
    if(m_particles[i] <> nil) then begin
      m_particles[i].UpdateValues(_renderer, _dtime);
      m_particles[i].Render(_renderer, m_tex);
    end;
  end;
end;

procedure TParticle.ReduceParticles(_fraction : real);    
var
  i : integer;
begin
  //Zufällig ein paar Partikel löschen:
  for i := 0 to m_num - 1 do begin
    if((m_particles[i] <> nil) and (random(100) < _fraction * 100)) then begin
      m_particles[i].Destroy();
      m_particles[i] := nil;
      dec(m_actual_num);
    end;
  end;
end;

function TParticle.GetParticleNum() : integer;       
begin
  result := m_actual_num;
end;

function TParticle.IsEmpty() : boolean;
begin
  result := m_next_min_index_to_delete >= m_num;
end;

end.
