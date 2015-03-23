unit uTOptionState;
//Klassen: TOptionState

//Erstellt am: Di, 09.12.14 von Manuel
//bis So, 14.12.14 - von Manuel - erste Version.
//Mi, 17.12.14 - von Manuel - vorerst fertig.

interface

uses
  SysUtils, uTGameState, uTGameButton, uTRenderer, uTTextureManager, uTTexture,
  uTSoundsystem, uTGameTrackBar;

type
  TOptionState = class(TGameState)
    public
      constructor Create();
      destructor Destory(); reintroduce; 
      procedure Process(_dtime : real); override;
      procedure Render(_dtime : real; _renderer : TRenderer); override;
    private
      procedure OnButtonUndoChanges();
      procedure SetCurrentValuesToUIValues();
    private
      m_bkgnd_tex : TTexture;
      m_old_volume : single;
      m_track_bar_volume : TGameTrackBar;
  end;
  
implementation
        
constructor TOptionState.Create();
begin
  inherited Create();
  m_bkgnd_tex := g_texturemanager.UseTexture('background_blank.png');
  m_old_volume := g_soundsystem.GetVolume();
  
  m_track_bar_volume := TGameTrackBar.Create(0.0, 0.0, 0.5, 0.05, 0.03, 0.05, 0.03, 0.08, nil, 0, 100, 0, 'ui/GameTrackBar', '.tga');
  
  addButton(TGameButton.create(-0.7, -0.6, 0.3, 0.075, OnButtonUndoChanges, 'Button' , 'reset'));
  addButton(TGameButton.create(0.1, -0.6, 0.3, 0.075, finalize, 'Button' , 'ok'));
  
  addTrackBar(m_track_bar_volume);
  SetCurrentValuesToUIValues();
end;

destructor TOptionState.Destory();
begin
  g_texturemanager.UnuseTexture(m_bkgnd_tex);
  inherited Destroy();
end;      

procedure TOptionState.Process(_dtime : real);
begin
  inherited Process(_dtime);
  g_soundsystem.SetVolume(m_track_bar_volume.GetCurrentValue()/100);
end;

procedure TOptionState.Render(_dtime : real; _renderer : TRenderer);
begin
  _renderer.DrawTexture(-1.0, -1.0, m_bkgnd_tex, 1.0, 1.0, false);
  inherited render(_dtime, _renderer);      
  _renderer.DrawTextEx(-0.56, 0.12, 'Lautstärke: ' + IntToStr(m_track_bar_volume.GetCurrentValue) + '%', 0.07, false, 0.0, 1.0, 1.0, 1.0);
end;

procedure TOptionState.OnButtonUndoChanges();
begin
  g_soundsystem.SetVolume(m_old_volume);
  SetCurrentValuesToUIValues();
end;        

procedure TOptionState.SetCurrentValuesToUIValues();
begin
  m_track_bar_volume.SetCurrentValue(round(g_soundsystem.GetVolume()*100))
end;

end.