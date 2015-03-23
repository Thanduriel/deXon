unit uTParticleManager;                 
//Klassen: TParticleManager
//Benötigt uTRenderer.pas, uTParticle.pas, uTTexture.pas

//Erstellt am: Di, 25.11.14 von Manuel
//Di, 25.11.14 - von Manuel - erste Version.
//Fr, 28.11.14 - von Manuel - Kleinigkeiten in der Dokumentation verbessert.
//So, 14.12.14 - von Manuel - GetParticleSourceNum hinzugefügt.

interface
                                 
uses
  uTParticle, uTRenderer, uTTexture;

type
  TVec2 = uTParticle.TVec2;
  TParticleManager = class(TObject)
    public
      constructor Create();
      destructor Destroy(); reintroduce;
      procedure AddParticleEffect(_x, _y : GLfloat; _tex : TTexture;
        _num : integer;
        _diffusion_min_velocity, _diffusion_max_velocity : real;
        _attenuation : real;
        _diffusion_direction : TVec2; _diffusion_direction_forcing : real;
        _source_velocity : TVec2;
        _start_velocity : TVec2; _abs_acceleration : TVec2;
        _emitation_duration : real;
        _min_particle_duration, _max_particle_duration : real); overload;
      procedure AddParticleEffect(_x, _y : GLfloat; _tex : TTexture;
        _num : integer;
        _diffusion_min_velocity, _diffusion_max_velocity : real;
        _attenuation : real;
        _diffusion_direction_x, _diffusion_direction_y : GLfloat;
        _diffusion_direction_forcing : real;
        _source_velocity_x, _source_velocity_y : GLfloat;
        _start_velocity_x, _start_velocity_y : GLfloat;
        _abs_acceleration_x, _abs_acceleration_y : GLfloat;
        _emitation_duration : real;
        _min_particle_duration, _max_particle_duration : real); overload;
        //fügt einen Partikeleffekt an der Position (_x|_y) mit der Textur _tex
        //hinzu. Dabei werden _num Partikel gezeichnet. Die anderen Parameter
        //haben die folgenden Bedeutungen:
        //_diffusion_min_velocity - Die Geschwindigkeit, mit der sich die
        //  langsamsten Partikel von der Quelle entfernen. (in
        //  Bildschirmbreiten/Sekunde)    
        //_diffusion_max_velocity - Die Geschwindigkeit, mit der sich die
        //  schnellsten Partikel von der Quelle entfernen. (in
        //  Bildschirmbreiten/Sekunde)
        //_attenuation - Die Dämpfung der Geschwindigkeit, d.h. nach einer
        //  Sekunde ist die Geschwindigkeit um diesen Teil kleiner.
        //_diffusion_direction - gibt an, in welche Richtung sich die Partikel
        //  von der Quelle aus hauptsächlich ausbreiten.
        //_diffusion_direction_forcing - (zwischen 0.0 und 1.0) - gibt an, wie
        //  stark die Partikel in diese Richtung gebündelt werden.
        //_source_velocity - Die Geschwindigkeit des Emitters (der Quelle) (in
        //  Bildschirmbreiten/Sekunde)
        //_start_velocity - Die Anfangsgeschwindigkeit der Partikel (in
        //  Bildschirmbreiten/Sekunde)
        //_abs_acceleration - Die Beschleunigung der Partikel (Feuer steigt zum
        //  Beispiel immer nach oben) (in Bildschirmbreiten/Sekunde^2)
        //_emitation_duration - gibt an, wie lange Partikel ausgesendet werden
        //  sollen (0, wenn nur eine einzige plötzliche Aussendung statt-
        //  findet). (in Sekunden)
        //_min_particle_duration - gibt an, wann die ersten Partikel wieder
        //  verschwinden (in Sekunden)  
        //_max_particle_duration - gibt an, wann die letzten Partikel wieder
        //  verschwinden (in Sekunden)
      procedure Render(_dtime : real; _renderer : TRenderer);
        //rendert alle Partikel
      procedure ReduceParticles(_fraction : real);
        //sorgt dafür, dass ein bestimmter Anteil von Partikeln gelöscht wird.
        //Die Methode kann genutzt werden, um die Framerate zu erhöhen, wenn
        //diese durch zu viele Partikel zu tief fällt.
        //_fraction gibt an, wie groß dieser Anteil ist.
      function GetParticleNum() : integer;
        //gibt die Anzahl der Partikel zurück.
      function GetParticleSourceNum() : integer;
        //gibt die Anzahl der Partikelsender zurück.
      procedure KillAllParticles();
        //löscht alle Partikel-Effekte
    private
      m_particles : Array of TParticle;
  end;

var
  g_particlemanager : TParticleManager;

implementation

constructor TParticleManager.Create();
begin
  inherited Create();
  SetLength(m_particles, 0);
end;

destructor TParticleManager.Destroy();
begin
  KillAllParticles();
  inherited Destroy();
end;
       
procedure TParticleManager.AddParticleEffect(_x, _y : GLfloat; _tex : TTexture;
        _num : integer;
        _diffusion_min_velocity, _diffusion_max_velocity : real;
        _attenuation : real;
        _diffusion_direction : TVec2; _diffusion_direction_forcing : real;
        _source_velocity : TVec2;
        _start_velocity : TVec2; _abs_acceleration : TVec2;
        _emitation_duration : real;
        _min_particle_duration, _max_particle_duration : real);
begin
  AddParticleEffect(_x, _y, _tex, _num, _diffusion_min_velocity,
    _diffusion_max_velocity, _attenuation, _diffusion_direction[0],
    _diffusion_direction[1], _diffusion_direction_forcing, _source_velocity[0],
    _source_velocity[1], _start_velocity[0], _start_velocity[1],
    _abs_acceleration[0], _abs_acceleration[1], _emitation_duration,
    _min_particle_duration, _max_particle_duration);
end;

procedure TParticleManager.AddParticleEffect(_x, _y : GLfloat; _tex : TTexture;
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
  l : integer;
begin
  l := Length(m_particles);
  SetLength(m_particles, l + 1);
  m_particles[l] := TParticle.Create();
  m_particles[l].Init(_x, _y, _tex, _num, _diffusion_min_velocity,
    _diffusion_max_velocity, _attenuation, _diffusion_direction_x,
    _diffusion_direction_y, _diffusion_direction_forcing, _source_velocity_x,
    _source_velocity_y, _start_velocity_x, _start_velocity_y,
    _abs_acceleration_x, _abs_acceleration_y, _emitation_duration,
    _min_particle_duration, _max_particle_duration);
end;

procedure TParticleManager.Render(_dtime : real; _renderer : TRenderer);
var
  i, j : integer;
begin
  _renderer.SetAlpha(1.0);
  for i := 0 to Length(m_particles) - 1 do begin
    m_particles[i].Render(_dtime, _renderer);
  end;
  //Nun wird überprüft, wie viele Partikelsysteme leer sind (d.h. alle Partikel
  //dieses Systems sind bereits verschwunden) und diese werden entsprechend
  //gelöscht.
  j := 0;
  for i := 0 to Length(m_particles) - 1 do begin
    if(m_particles[i].IsEmpty()) then begin
      m_particles[i].Destroy();
      m_particles[i] := nil;
    end;
    if(i <> j) then begin
      m_particles[j] := m_particles[i];
      m_particles[i] := nil;
    end; 
    while((m_particles[j] <> nil) and (j <= i)) do
      inc(j);
  end;
  SetLength(m_particles, j);
end;     

procedure TParticleManager.ReduceParticles(_fraction : real);
var
  i : integer;
begin
  for i := 0 to Length(m_particles) - 1 do begin
    m_particles[i].ReduceParticles(_fraction);
  end;
end;

procedure TParticleManager.KillAllParticles();
var
  i : integer;
begin
  for i := 0 to Length(m_particles) - 1 do begin
    m_particles[i].Destroy();
  end;
  SetLength(m_particles, 0);
end;

function TParticleManager.GetParticleNum() : integer;
var
  i : integer;
begin
  result := 0;
  for i := 0 to Length(m_particles) - 1 do begin
    result := result + m_particles[i].GetParticleNum();
  end;
end;
   
function TParticleManager.GetParticleSourceNum() : integer;
begin
  result := Length(m_particles);
end;

end.
