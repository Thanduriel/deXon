unit uTTexture;      
//Klassen: TTexture
//Benötigt dglOpenGL.pas und zur Laufzeit dexon_lib.dll!

//Erstellt am: Do, 18.09.14 von Manuel
//bis Di, 23.09.14 - von Manuel - erste Version: Bis jetzt könnten nur Bitmaps
//                            geladen werden - aber nicht auf den Schul-PCs,
//                            Funktion deshalb entfernt.
//Do, 25.09.14 - von Manuel - Bitmaps werden nun geladen.
//Mo, 29.09.14 - von Manuel - PNG-Dateien können nun geladen werden.  
//Di, 30.09.14 - von Manuel - Quellcode aufgeräumt.
//So, 05.10.14 - von Manuel - Größe von PNG-Dateien wird ebenfalls gespeichert.
//                            Warnung wird ausgegeben, wenn eine Textur nicht
//                            OpenGL-1.1-konform ist.
//Mo, 06.10.14 - von Manuel - Existenzprüfung vor dem Laden einer Datei.
//Mi, 08.10.14 - von Manuel - Unnötige uses-Einträge entfernt, mysteriösen Feh-
//                            ler behoben, Compiler-Warnungen behoben.
//Fr, 24.10.14 - von Manuel - In LoadFromFile ein paar Anpassungen an für die
//                            Veränderungen der DLL vorgenommen.
//Do, 14.11.14 - von Manuel - Defaulttexture hinzugefügt.
//Di, 25.11.14 - von Manuel - GLuint hinzugefügt.
//Sa, 29.11.14 - von Manuel - DLL umbenannt.
//Mo, 01.12.14 - von Manuel - Alle PChar außerhalb von MessageBox zu PAnsiChar
//                            geändert, um Kompatibiltät mit Delphi-Compilern
//                            aus diesem Jahrtausend zu gewährleisten.
//Nacht zu Di, 09.12.14 - von Manuel - Kommentar hinzugefügt.
//So, 14.12.14 - von Manuel - Nun kann zwischen GL_NEAREST und GL_LINEAR
//                            ausgewählt werden.
//Mo, 15.12.14 - von Manuel - (Änderung betrifft nur dexon_lib.dll) TGA-Dateien
//                            können nun geladen werden.

interface

uses
  Windows, SysUtils, dglOpenGL;

type              
  GLuint = dglOpenGL.GLuint;
  TTexture = class
    public             
      constructor Create(); overload;
      constructor Create(_nearest_filter : boolean); overload;
      destructor Destroy(); reintroduce; virtual;
      procedure LoadFromFile(_path : string); virtual;
        //lädt eine Textur aus der Datei mit dem Pfad "_path". Kann diese Datei
        //nicht geladen werden, so wird eine Fehlermeldung ausgegeben.
        //Unterstützte Dateiformate:
        //.bmp (16-, 24- oder 32-Bit; unkomprimiert),
        //.png,
        //.tga (24- oder 32-Bit; unkomprimiert)
        //(Welche Dateiformate unterstützt werden, hängt allein von
        //dexon_lib.dll ab.)
        //An den Schul-PCs in A308 können nur Texturen geladen werden, die
        //maximal die Größe 1024x1024 haben und deren Breite und Höhe jeweils
        //Zweierpotenzen sind.
      function GetTexID() : GLuint;
        //gibt den Wert zurück, der in OpenGL die Textur repräsentiert; nur für
        //TRenderer von Bedeutung.
      function GetWidth() : integer;
        //gibt die Breite der Textur (in Pixel) zurück
      function GetHeight() : integer;
        //gibt die Höhe der Textur (in Pixel) zurück
    protected
      function DimensionsArePowOf2() : boolean;
        //gibt zurück, ob die Dimensionen der Textur Zweierpotenzen sind.
    private
      procedure Initialize(_filter : GLint);
    protected
      m_texid : GLuint;
      m_w, m_h : integer;
  end;

const
  c_default_tex_color : array[0..3] of GLubyte = (255, 0, 0, 220);
    //Standardtextur

implementation    

function DLLloadTexFromFile(_path : PAnsiChar; _tex : GLuint; var _w : integer; var _h : integer; var _error_msg : PAnsiChar) : boolean; cdecl;
external 'dexon_lib.dll' name 'loadTexFromFile';
  //lädt eine Textur aus einer Datei:
  //_path - Dateipfad (Input)
  //_tex - TexturID in OpenGL (Input)
  //_w - Breite der Textur (Output)
  //_h - Höhe der Textur (Output)
  //_error_msg - Fehlermeldung, wenn die Textur nicht geladen werden konnte (Output)

constructor TTexture.Create();
begin
  inherited Create();
  Initialize(GL_LINEAR);
end;        

constructor TTexture.Create(_nearest_filter : boolean);
begin
  inherited Create();
  if(_nearest_filter) then
    Initialize(GL_NEAREST)
  else    
    Initialize(GL_LINEAR);
end;

procedure TTexture.Initialize(_filter : GLint);
begin
  m_w := 1;
  m_h := 1;
  glEnable(GL_TEXTURE_2D);
  glGenTextures(1, @m_texid);
  glBindTexture(GL_TEXTURE_2D, m_texid);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _filter);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _filter);
  //Standardtextur laden:
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE,
    @(c_default_tex_color[0]));
  glBindTexture(GL_TEXTURE_2D, 0);
end;

destructor TTexture.Destroy();
begin
  glBindTexture(GL_TEXTURE_2D, 0);
  glDeleteTextures(1, @m_texid);
  inherited Destroy();
end;

procedure TTexture.LoadFromFile(_path : string);
var
  error_msg : PAnsiChar;
begin
  if not FileExists(_path) then begin
    MessageBoxA(0, PChar('Die Texturdatei konnte nicht gefunden werden:' + #13 + _path), PChar('Fehler!'), MB_ICONERROR);  
    exit;
  end;
  if not DLLloadTexFromFile(PAnsiChar(_path), m_texid, m_w, m_h, error_msg) then begin
    MessageBoxA(0, PChar('Die Texturdatei konnte nicht geladen werden:' + #13 + _path + #13 + error_msg), PChar('Fehler!'), MB_ICONERROR);
    exit;
  end;

  if(m_w>1024) or (m_h>1024) then begin
    if(DimensionsArePowOf2()) then begin
      MessageBoxA(0, PChar('Die Textur "' + _path + '" hat die Maße ' + IntToStr(m_w) + 'x' + IntToStr(m_h) + '.' + #13 +
      'Auf manchen PCs könnte es zu Problemen bei der Texturanzeige kommen, wenn eine Textur größer als 1024x1024 ist.'),
      PChar('Warnung!'), MB_ICONWARNING);
    end else begin
      MessageBoxA(0, PChar('Die Textur "' + _path + '" hat die Maße ' + IntToStr(m_w) + 'x' + IntToStr(m_h) + '.' + #13 +
      'Auf manchen PCs könnte es zu Problemen bei der Texturanzeige kommen, wenn eine Textur größer als 1024x1024 ist oder Breite oder Höhe der Textur keine Zweierpotenzen sind.'),
      PChar('Warnung!'), MB_ICONWARNING);
    end;
  end else if(not DimensionsArePowOf2()) then begin
    MessageBoxA(0, PChar('Die Textur "' + _path + '" hat die Maße ' + IntToStr(m_w) + 'x' + IntToStr(m_h) + '.' + #13 +
    'Auf manchen PCs könnte es zu Problemen bei der Texturanzeige kommen, wenn die Breite oder die Höhe der Textur keine Zweierpotenz ist.'),
    PChar('Warnung!'), MB_ICONWARNING);
  end;
end;
       
function TTexture.DimensionsArePowOf2() : boolean;
var
  i : integer;
begin
  result := true;
  i := 1;
  while(i<m_w) do begin
    i := i * 2;
  end; 
  if(i>m_w) then result := false;
  i := 1;
  while(i<m_h) do begin
    i := i * 2;
  end; 
  if(i>m_h) then result := false;
end;

function TTexture.GetTexID() : GLuint;
begin
  result := m_texid;
end;    

function TTexture.GetWidth() : integer;
begin
  result := m_w;
end;

function TTexture.GetHeight() : integer;
begin
  result := m_h;
end;

end.

