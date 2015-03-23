unit uTTextureManager;
//Klassen: TTextureManager
//Records: TTexManagerElement
//Benötigt uTTexture.pas

//Erstellt am: Mi, 08.10.14 von Manuel
//Mi, 08.10.14 - von Manuel - erste Version.
//Do, 09.10.14 (1) - von Manuel - globale Variable hinzugefügt
//Do, 09.10.14 (2) - von Manuel - Parameter von UnuseTexture und DeleteTexture
//                            kann nun auch eine Textur sein.
//Di, 18.11.14 (1) - von Manuel - LoadTexture(_file_path: string) hinzugefügt.
//Di, 18.11.14 (2) - von Manuel - Standardcontentunterordnerpfadkonstante
//                            hinzugefügt.
//Di, 25.11.14 - von Manuel - UseTexture(_tex) hinzugefügt.   
//Nacht zu Di, 09.12.14 - von Manuel - Kommentar hinzugefügt.
//So, 14.12.14 (1) - von Manuel - Nun kann zwischen GL_NEAREST und GL_LINEAR
//                            ausgewählt werden. DeleteTexture(_file_path) und
//                            UnuseTexture(_file_path) entfernt. Methoden
//                            hinzugefügt, die zurückgeben, wie oft was geladen
//                            und genutzt wurde.
//So, 14.12.14 (2) - von Manuel - Fehler behoben, der dazu führte, dass jede
//                            Textur immerwieder neu geladen wurde und der
//                            Texturemanager seinen Zweck nicht erfüllte.

interface     

uses
  SysUtils, uTTexture;

type
  TTexManagerElement = record
    use_num : integer; //wie oft wird diese Textur genutzt
    tex : TTexture;
    path : string;
    nearest_filter : boolean;
  end;
  TTextureManager = class
    public
      constructor Create();
      destructor Destroy(); reintroduce;
      procedure LoadTexture(_file_path : string); overload;
      procedure LoadTexture(_file_path : string; _nearest_filter : boolean); overload;
        //lädt eine Textur aus einer Datei, ohne dass sie sofort benutzt wird.
        //Wartezeiten während des Spiels, die durch das Nachladen von Texturen
        //bei der ersten Benutzung entstehen würden, können somit vermieden
        //werden.
      function UseTexture(_file_path : string) : TTexture; overload;
      function UseTexture(_file_path : string; _nearest_filter : boolean) : TTexture; overload;
        //gibt die Texture mit dem Pfad zurück, nachdem sie ggf. geladen wurde.
        //Wird die Textur nicht mehr gebraucht, ist UnuseTexture aufzurufen!
        //Darf nicht innerhalb von Render-Methoden aufgerufen werden!  
      procedure UseTexture(_tex : TTexture); overload;
        //wenn man eine Textur z.B. an ein anderes Objekt übergibt und man dann
        //keine Kontrolle mehr darüber hat, ob dieses Objekt die Textur noch
        //brauch (z.B. ParticleManager), so kann in diesem Objekt diese Methode
        //aufgerufen werden, sodass das Objekt nicht versehentlich gelöscht
        //werden kann.
      procedure UnuseTexture(_tex : TTexture); overload;
        //ist aufzurufen, wenn eine Textur nicht mehr gebraucht wird.
        //Darf nicht innerhalb von Render-Methoden aufgerufen werden!
      procedure DeleteTexture(_tex : TTexture); overload;
        //löscht die Textur, wenn sie nicht mehr gebraucht wird.
      procedure DeleteAllTextures();
        //löscht alle Texturen, die nicht mehr gebraucht werden.
      function GetTextureNum() : integer;
        //gibt an, wie viele Texturen geladen sind.
      function GetUseNum() : integer; overload;
        //gibt an, wie oft Texturen benutzt werden.
      function GetUseNum(_tex : TTexture) : integer; overload;
      function GetUseNum(_file_path : string; _nearest_filter : boolean) : integer; overload;
        //gibt an, wie oft eine bestimmte Textur benutzt wird.
      function GetMostCommonlyUsedTextures(_num : integer) : string;
        //gibt die _num am häufigsten benutzten Texturen mit ihren Dateinamen
        //zurück (mit Zeilenumbruch getrennt).              
      function GetNegativelyUsedTextures(_num : integer) : string;
        //gibt _num Texturen zurück, bei denen die Anzahl der Nutzungen negativ
        //sind.
    private
      function LoadTexAndGetIndex(_file_path : string; _nearest_filter : boolean) : integer;
      function GetTexIndex(_file_path : string; _nearest_filter : boolean) : integer; overload;
      function GetTexIndex(_tex : TTexture) : integer; overload;
    private
      m_texs : Array of TTexManagerElement;
  end;
  
var
  g_texturemanager : TTextureManager;

const
  c_contentfolderpath = './content/';

implementation

constructor TTextureManager.Create();
begin
  SetLength(m_texs, 0);
end;

destructor TTextureManager.Destroy();       
var
  i : integer;
begin
  for i := 0 to Length(m_texs) - 1 do begin
    m_texs[i].tex.Destroy();
  end;
end;
    
procedure TTextureManager.LoadTexture(_file_path : string);
begin
  LoadTexture(_file_path, false);
end;

procedure TTextureManager.LoadTexture(_file_path : string; _nearest_filter : boolean);
begin
  LoadTexAndGetIndex(_file_path, _nearest_filter);
end;

function TTextureManager.UseTexture(_file_path : string) : TTexture;
begin
  result := UseTexture(_file_path, false);
end;

function TTextureManager.UseTexture(_file_path : string; _nearest_filter : boolean) : TTexture;
var
  i : integer;
begin
  i := LoadTexAndGetIndex(_file_path, _nearest_filter);
  inc(m_texs[i].use_num);
  result := m_texs[i].tex;
end;

procedure TTextureManager.UseTexture(_tex : TTexture);
var
  i : integer; 
begin
  i := GetTexIndex(_tex);  
  if i >= 0 then
    inc(m_texs[i].use_num);
end;

procedure TTextureManager.UnuseTexture(_tex : TTexture);   
var
  i : integer; 
begin
  i := GetTexIndex(_tex);  
  if i >= 0 then
    dec(m_texs[i].use_num);
end;

procedure TTextureManager.DeleteTexture(_tex : TTexture);
var
  i : integer;
begin           
  i := GetTexIndex(_tex);
  if i >= 0 then
    if(m_texs[i].use_num <= 0) then m_texs[i].tex.Destroy();
end;

procedure TTextureManager.DeleteAllTextures();
var
  i : integer;
begin
  for i := 0 to Length(m_texs) - 1 do begin
    if(m_texs[i].use_num <= 0) then m_texs[i].tex.Destroy();
  end;
end;     

function TTextureManager.LoadTexAndGetIndex(_file_path : string; _nearest_filter : boolean) : integer;
var
  i : integer;
  t : TTexture;
begin
  _file_path := _file_path;
  //Prüfen, ob Textur vorhanden:
  i := GetTexIndex(_file_path, _nearest_filter);
  if(i < 0) then begin
    //Wenn nicht, dann hinzufügen:
    i := Length(m_texs);
    SetLength(m_texs, i+1);
    t := TTexture.Create(_nearest_filter);
    t.LoadFromFile(c_contentfolderpath + _file_path);
    m_texs[i].tex := t;
    m_texs[i].use_num := 0;
    m_texs[i].path := _file_path;
    m_texs[i].nearest_filter := _nearest_filter;
  end;
  result := i;
end;

function TTextureManager.GetTexIndex(_file_path : string; _nearest_filter : boolean) : integer;
var
  i : integer;
begin                  
  _file_path := _file_path;
  result := -1;
  for i := 0 to Length(m_texs) - 1 do begin
    if ((m_texs[i].nearest_filter = _nearest_filter)
       and
       ((m_texs[i].path = _file_path) or
       (m_texs[i].path = './' + _file_path) or 
       (m_texs[i].path = '.\' + _file_path) or
       ('.\' + m_texs[i].path = _file_path) or
       ('./' + m_texs[i].path = _file_path))) then begin
      result := i;
      break;
    end;
  end;
end;  

function TTextureManager.GetTexIndex(_tex : TTexture) : integer;
var
  i : integer;
begin
  result := -1;
  for i := 0 to Length(m_texs) - 1 do begin
    if(m_texs[i].tex = _tex) then
      result := i;
  end;
end;    

function TTextureManager.GetTextureNum() : integer;
begin
  result := Length(m_texs);
end;

function TTextureManager.GetUseNum() : integer;
var
  i : integer;
begin
  result := 0;
  for i := 0 to Length(m_texs) - 1 do begin
    if(m_texs[i].use_num > 0) then begin
      result := result + m_texs[i].use_num;
    end;
  end;
end;

function TTextureManager.GetUseNum(_tex : TTexture) : integer;
var
  i : integer;
begin
  i := GetTexIndex(_tex);
  if(i < 0) then
    result := 0
  else
    result := m_texs[i].use_num;
end;

function TTextureManager.GetUseNum(_file_path : string; _nearest_filter : boolean) : integer;
var
  i : integer;
begin
  i := GetTexIndex(_file_path, _nearest_filter);
  if(i < 0) then
    result := 0
  else
    result := m_texs[i].use_num;
end;
     
function TTextureManager.GetMostCommonlyUsedTextures(_num : integer) : string;
var
  i, j, k : integer;
  ind : Array of integer;
  not_already_in : boolean;
begin
  SetLength(ind, _num);
  for i := 0 to _num - 1 do begin
    ind[i] := -1;
    if i < Length(m_texs) then begin
      for j := 0 to Length(m_texs) - 1 do begin
        not_already_in := true;
        for k := 0 to i - 1 do begin
          if(ind[k] = j) then not_already_in := false;
        end;
        if(not_already_in) then begin
          if(ind[i] < 0) then
            ind[i] := j
          else begin
            if(m_texs[ind[i]].use_num < m_texs[j].use_num) then   
              ind[i] := j;
          end;
        end;
      end;
    end;
  end;
  result := '';
  for i := 0 to _num - 1 do begin
    if(ind[i] < 0) then begin
      result := result + #13;
    end else begin
      result := result + m_texs[ind[i]].path + ' (' + IntToStr(m_texs[ind[i]].use_num) + ')' + #13;
    end;
  end;
  SetLength(result, Length(result) - 1); //letzten Zeilenumbruch entfernen
end;

function TTextureManager.GetNegativelyUsedTextures(_num : integer) : string;  
var
  i, j, k : integer;
  ind : Array of integer;
  not_already_in : boolean;
begin
  SetLength(ind, _num);
  for i := 0 to _num - 1 do begin
    ind[i] := -1;
    if i < Length(m_texs) then begin
      for j := 0 to Length(m_texs) - 1 do begin
        not_already_in := true;
        for k := 0 to i - 1 do begin
          if(ind[k] = j) then not_already_in := false;
        end;
        if(not_already_in) then begin
          if(ind[i] < 0) then
            ind[i] := j
          else begin
            if(m_texs[ind[i]].use_num > m_texs[j].use_num) then   
              ind[i] := j;
          end;
        end;
      end;
    end;
  end;
  result := '';
  for i := 0 to _num - 1 do begin
    if(m_texs[ind[i]].use_num >= 0) then begin
      ind[i] := -1;
    end;
    if(ind[i] < 0) then begin
      result := result + #13;
    end else begin
      result := result + m_texs[ind[i]].path + ' (' + IntToStr(m_texs[ind[i]].use_num) + ')' + #13;
    end;
  end;   
  SetLength(result, Length(result) - 1); //letzten Zeilenumbruch entfernen
end;


end.
