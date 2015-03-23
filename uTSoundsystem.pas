unit uTSoundsystem;
//Klassen: TSoundsystem
//Records: TSound, TSoundPlayback
//Benötigt zur Laufzeit dexon_lib.dll und, wenn nicht bereits auf dem Rechner
//  installiert, OpenAL32.dll (Groß- und Kleinschreibung nicht relevant)!

//Erstellt am: Fr, 28.11.14 von Manuel
//bis Mo, 01.12.14 - von Manuel - erste Version.

interface

uses
  Windows, SysUtils;

type
  TSound = record
      m_p : longword;
  end;
  TSoundPlayback = record
      m_p : longword;
      //(gilt auch für TSound:) m_p repräsentieren Indizen im Soundsystem. Der
      //Grund dafür, dass diese Objekte als record definiert wurden und nicht
      //mit "TSound = integer" liegt darin, dass man nicht versehentlich einem
      //TSound ein TSoundPlayback zuordnen können soll...
      //Werden sie als Klassen definiert kommt es bei der Frage, welches Objekt
      //TSoundPlayback löscht, zum Problem und definiert man es als record ist
      //alles public. Bei diesem Problem könnte ich mich jetzt wieder über
      //Delphi aufregen, in C++ gäbe es dieses Problem nicht...
  end;
  TSoundsystem = class
    public
      constructor Create();
      destructor Destroy(); reintroduce;
      procedure SetVolume(_vol : single);
        //setzt die Lautstärke für das Spiel. (Werte von 0.0 bis 1.0) Ist der
        //Ton ausgeschaltet, wird dieser wieder angeschaltet.
      function GetVolume() : single;
        //gibt die Lautstärke zurück
      procedure Mute();
        //Ton aus.
      procedure Unmute();
        //Ton an.
      procedure SetMuted(_val : boolean);
        //setzt, ob der Ton ausgeschaltet sein soll. (Hat den Vorteil gegenüber
        //SetVolume(0.0), dass das Objekt sich die letzte Lautstärke merkt.)
      function GetMuted() : boolean;
        //gibt zurück, ob der Ton ausgeschaltet ist.
      function LoadSound(_file_path : string) : TSound;
        //lädt eine Audiodatei aus dem Pfad _file_path und gibt diesen Sound
        //zurück. Kann die Datei nicht geladen werden, wird eine Fehlermeldung
        //ausgegeben.
        //Unterstützte Dateiformate:
        //.wav (PCM-Kodierung)
        //Wenn der Parameter _balance in den anderen Methoden eine Auswirkung
        //haben soll, muss es sich bei der Audiodatei um eine mit Mono-Spur
        //handeln.   
        //(Welche Dateiformate unterstützt werden, hängt allein von
        //dexon_lib.dll ab.)
      procedure UnloadSound(_sound : TSound);
        //löscht den Sound _sound wieder aus dem Arbeitsspeicher, wenn er nicht
        //mehr gebraucht wird.
      procedure DeleteAllSounds();
        //löscht alle Sounds, die nicht mehr gebraucht werden.
      function PlaySoundOnce(_sound : TSound; _vol, _balance : single)
        : TSoundPlayback;
        //spielt einen Sound genau einmal ab. _vol ist relativ. _balance ist
        //-1.0 für den linken und 1.0 für den rechten Lautsprecher
      function StartSoundLoop(_sound : TSound; _vol, _balance : single;
        _fade_in : boolean; _fade_in_duration : single) : TSoundPlayback;
        //beginnt eine Schleife mit einem Sound _sound abzuspielen. Mit
        //_fade_in ist es möglich, dass der Sound am Anfang leise ist, und dann
        //nach _fade_in_duration die angegebene Lautstärke erreicht (linear)
        //(_fade_in_duration wird ignoriert, wenn _fade_in = false). Die
        //Wiedergabe muss mit StopPlayback oder StopPlaybackRepeat beendet
        //werden, ansonsten startet die Soundwiedergabe nach dem Abspielen
        //wieder von vorn, und dann wieder, und dann wieder, und dann wieder...
        //_vol ist relativ. _balance ist -1.0 für den linken und 1.0 für den
        //rechten Lautsprecher
      procedure StopPlayback(_playback : TSoundPlayback; _fade_out : boolean;
        _fade_out_duration : single);
        //bricht die Wiedergabe eines Sounds ab. Analog zu StartSoundLoop ist es
        //möglich, dass der Sound langsam ausgeblendet wird und nicht abrupt
        //abbricht (das gilt auch für die Sounds, die mit PlaySoundOnce
        //gestartet wurden).
      procedure StopPlaybackRepeat(_playback : TSoundPlayback);
        //ein Sound, der als Schleife wiedergegeben wurde, wird ab sofort nicht
        //mehr wiederholt.
      procedure StopAllPlaybacks(_fade_out : boolean; _fade_out_duration
        : single);
        //bricht alle Wiedergaben ab.
      procedure SetPlaybackVolume(_playback : TSoundPlayback; _vol, _balance
        : single);
        //während der Soundwiedergabe kann die Lautstärke des Sounds hiermit
        //verändert werden. _vol ist relativ. _balance ist -1.0 für den linken
        //und 1.0 für den rechten Lautsprecher
      function IsStillPlaying(_playback : TSoundPlayback) : boolean;
        //gibt zurück, ob eine Wiedergabe noch läuft.
      function GetSoundNum() : longword;
        //gibt zurück, wie viele Audiodateien derzeit geladen sind. 
      function GetPlaybackNum() : longword;
        //gibt zurück, wie viele Sounds derzeit wiedergegeben werden.
      procedure EnableUncriticalErrorMessages();
        //(für das Debuggen) führt dazu, dass auch Fehler bei der Wiedergabe
        //oder bei dem Löschen von Sounds ausgegeben werden; sollte für das
        //fertige Spiel nicht verwendet werden.
      procedure SetStereoEffect(_effect : single);
        //(zwischen 0.0 und 1.0) setzt wie stark der Stereo-Effekt ist.
      procedure Frame(_dtime : single);
        //ist in jedem Frame aufzurufen, um abgelaufene Playbacks zu entfernen
        //und um FadeIns und FadeOuts zu ermöglichen.
      //Eine Art 'Soundmanager' wie der Texturemanager ist bereits in der dll
      //enthalten, d.h. es ist nicht notwendig, darauf zu achten, ob ein Sound
      //mehrmals geladen wird und dadurch zu viel Arbeitsspeicher benötigt.
    private
      m_vol : single;
      m_stereo_effect : single;
      m_muted : boolean;
      m_uncritical_errors : boolean;
  end;

var
  g_soundsystem : TSoundsystem;

const
  c_audiocontentfolderpath = './content/audio/';

implementation

function DLLSound_Initialize(var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_initialize';

procedure DLLSound_Finalize(); cdecl;
external 'dexon_lib.dll' name 'SoundManager_finalize';

procedure DLLSound_SetVol(_vol : single); cdecl;
external 'dexon_lib.dll' name 'SoundManager_setVol';

function DLLSound_LoadSound(_path : PAnsiChar; var _sound : TSound; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_loadSound';

function DLLSound_UnloadSound(_sound : TSound; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_unloadSound';

procedure DLLSound_DeleteAllSounds(); cdecl;
external 'dexon_lib.dll' name 'SoundManager_deleteAllSounds';

function DLLSound_PlaySoundOnce(_sound : TSound; _vol, _balance : single; var _playing_id : TSoundPlayback; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_playSoundOnce';

function DLLSound_StartSoundLoop(_sound : TSound; _vol, _balance : single; var _playing_id : TSoundPlayback; _fade_in : boolean; _fade_in_duration : single; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_startSoundLoop';

function DLLSound_StopPlayback(_playing_id : TSoundPlayback; _fade_out : boolean; _fade_out_duration : single; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_stopPlayback';

function DLLSound_StopPlaybackRepeat(_playing_id : TSoundPlayback; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_stopPlaybackRepeat';     

procedure DLLSound_StopAllPlaybacks(_fade_out : boolean; _fade_out_duration : single); cdecl;
external 'dexon_lib.dll' name 'SoundManager_stopAllPlaybacks';

function DLLSound_SetPlaybackVolume(_playing_id : TSoundPlayback; _vol, _balance : single; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_setPlaybackVolume';

function DLLSound_IsStillPlaying(_playing_id : TSoundPlayback) : boolean; cdecl;
external 'dexon_lib.dll' name 'SoundManager_isStillPlaying';

function DLLSound_GetSoundNum() : longword; cdecl;
external 'dexon_lib.dll' name 'SoundManager_getSoundNum';    

function DLLSound_GetPlaybackNum() : longword; cdecl;
external 'dexon_lib.dll' name 'SoundManager_getPlaybackNum';

procedure DLLSound_Frame(_dtime : single); cdecl;
external 'dexon_lib.dll' name 'SoundManager_frame';

constructor TSoundsystem.Create();
var
  error_msg : PAnsiChar;
begin
  inherited Create();
  if(DLLSound_Initialize(error_msg)) then begin
    SetVolume(1.0);
  end else begin
    MessageBoxA(0, PChar('Das Soundsystem konnte nicht initialisiert werden:' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;        
  m_uncritical_errors := false;
  m_stereo_effect := 1.0;
end;

destructor TSoundsystem.Destroy();
begin
  DLLSound_Finalize();
  inherited Destroy();
end;

procedure TSoundsystem.SetVolume(_vol : single);
begin
  m_vol := _vol;
  m_muted := false;
  DLLSound_SetVol(m_vol);
end;

function TSoundsystem.GetVolume() : single;
begin
  result := m_vol;
end;
           
procedure TSoundsystem.Mute();
begin
  m_muted := true;
  DLLSound_SetVol(0.0);
end;

procedure TSoundsystem.Unmute();
begin            
  m_muted := false;
  DLLSound_SetVol(m_vol);
end;

procedure TSoundsystem.SetMuted(_val : boolean);
begin
  m_muted := _val;
  if(m_muted) then begin
    DLLSound_SetVol(0.0);
  end else begin
    DLLSound_SetVol(m_vol);
  end;
end;

function TSoundsystem.GetMuted() : boolean;
begin
  result := m_muted;
end;

function TSoundsystem.LoadSound(_file_path : string) : TSound;     
var
  error_msg : PAnsiChar;
begin
  if(not DLLSound_LoadSound(PAnsiChar(c_audiocontentfolderpath + _file_path), result, error_msg)) then begin
      //Ob die Datei existiert, wird erst danach überprüft, da ansonsten die
      //Meldung jedes Mal kommt, wenn diese Audiodatei geladen wird.
    if not FileExists(c_audiocontentfolderpath + _file_path) then begin
      MessageBoxA(0, PChar('Die Audiodatei konnte nicht gefunden werden:' + #13 + c_audiocontentfolderpath + _file_path), PChar('Fehler!'), MB_ICONERROR);
      exit;
    end else begin
      MessageBoxA(0, PChar('Die Audiodatei konnte nicht geladen werden:' + #13 + c_audiocontentfolderpath + _file_path + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
    end;
  end;
end;

procedure TSoundsystem.UnloadSound(_sound : TSound);  
var
  error_msg : PAnsiChar;
begin
  if (not DLLSound_UnloadSound(_sound, error_msg)) and (m_uncritical_errors) then begin
      MessageBoxA(0, PChar('Die Audiodatei konnte nicht gelöscht:' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;
end;

procedure TSoundsystem.DeleteAllSounds();
begin
  DLLSound_DeleteAllSounds();           
end;

function TSoundsystem.PlaySoundOnce(_sound : TSound; _vol, _balance : single)
        : TSoundPlayback;
var
  error_msg : PAnsiChar;
begin
  if (not DLLSound_PlaySoundOnce(_sound, _vol, _balance * m_stereo_effect, result, error_msg)) and (m_uncritical_errors) then begin
      MessageBoxA(0, PChar('Die Audiodatei konnte nicht abgespielt werden:' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;
end;

function TSoundsystem.StartSoundLoop(_sound : TSound; _vol, _balance : single;
        _fade_in : boolean; _fade_in_duration : single)
        : TSoundPlayback;       
var
  error_msg : PAnsiChar;
begin
  if (not DLLSound_StartSoundLoop(_sound, _vol, _balance * m_stereo_effect, result, _fade_in, _fade_in_duration, error_msg)) and (m_uncritical_errors) then begin
      MessageBoxA(0, PChar('Die Audiodatei konnte nicht abgespielt werden (Schleife):' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;
end;

procedure TSoundsystem.StopPlayback(_playback : TSoundPlayback; _fade_out
        : boolean; _fade_out_duration : single);     
var
  error_msg : PAnsiChar;
begin
  if (not DLLSound_StopPlayback(_playback, _fade_out, _fade_out_duration, error_msg)) and (m_uncritical_errors) then begin
      MessageBoxA(0, PChar('Die Wiedergabe konnte nicht beendet werden:' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;
end;

procedure TSoundsystem.StopPlaybackRepeat(_playback : TSoundPlayback);
var
  error_msg : PAnsiChar;
begin
  if (not DLLSound_StopPlaybackRepeat(_playback, error_msg)) and (m_uncritical_errors) then begin
      MessageBoxA(0, PChar('Die Wiedergabeschleife konnte nicht beendet werden:' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;
end;

procedure TSoundsystem.StopAllPlaybacks(_fade_out : boolean; _fade_out_duration
        : single);
begin
  DLLSound_StopAllPlaybacks(_fade_out, _fade_out_duration);
end;

procedure TSoundsystem.SetPlaybackVolume(_playback : TSoundPlayback; _vol,
  _balance : single);  
var
  error_msg : PAnsiChar;
begin
  if (not DLLSound_SetPlaybackVolume(_playback, _vol, _balance * m_stereo_effect, error_msg)) and (m_uncritical_errors) then begin
      MessageBoxA(0, PChar('Die Lautstärke für die Wiedergabe konnte nicht gesetzt werden:' + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
  end;
end;        

function TSoundsystem.IsStillPlaying(_playback : TSoundPlayback) : boolean;
begin
  result := DLLSound_IsStillPlaying(_playback);
end;
                       
function TSoundsystem.GetSoundNum() : longword;
begin
  result := DLLSound_GetSoundNum();
end;

function TSoundsystem.GetPlaybackNum() : longword;
begin
  result := DLLSound_GetPlaybackNum();
end;

procedure TSoundsystem.EnableUncriticalErrorMessages();
begin
  m_uncritical_errors := true;
end;        

procedure TSoundsystem.SetStereoEffect(_effect : single);
begin
  m_stereo_effect := _effect;
end;

procedure TSoundsystem.Frame(_dtime : single);
begin
  DLLSound_Frame(_dtime);
end;

end.
