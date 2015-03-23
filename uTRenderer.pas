unit uTRenderer;
//Klassen: TRenderer
//Records: TFontChar
//Benötigt dglOpenGL.pas, uTTexture.pas

//Erstellt am: Fr, 19.09.14 von Manuel
//bis Di, 23.09.14 - von Manuel - erste Version: Textausgabe ist noch nicht
//                            möglich.
//Mo, 29.09.14 - von Manuel - TFontChar hinzugefügt, Textausgabe implementiert,
//                            DrawTextEx hinzugefügt.
//Di, 30.09.14 - von Manuel - Textausgabe sollte nun auch an den Schul-PCs in
//                            A308 funktionieren.
//So, 05.10.14 - von Manuel - Jetzt sollte die Textausgabe in der Schule aber
//                            wirklich funktionieren.
//Mi, 08.10.14 - von Manuel - TTextureManager eingebunden.
//Do, 09.10.14 - von Manuel - TTextureManager wieder excluded. (Wer eine
//                            deutsche Übersetzung für "exclude" findet (das
//                            Gegenteil von "einbinden"), meldet sich bitte.
//Di, 18.11.14 - von Manuel - Elemente werden nun, wenn keine Z-Änderung
//                            explizit angefordert wurde, auch aufeinander
//                            gezeichnet.
//Di, 25.11.14 (1) - von Manuel - GetZ hinzugefügt.
//Di, 25.11.14 (2) - von Manuel - GLfloat hinzugefügt.    
//Mo, 01.12.14 - von Manuel - Alle PChar außerhalb von MessageBox zu PAnsiChar
//                            geändert, um Kompatibiltät mit Delphi-Compilern
//                            aus diesem Jahrtausend zu gewährleisten.
//Nacht zu Di, 09.12.14 - von Manuel - Kommentare hinzugefügt.

interface

uses
  Windows, SysUtils, Graphics, dglOpenGL, uTTexture;

type
  GLfloat = dglOpenGL.GLfloat;
  TFontChar = record
    //repräsentiert ein Zeichen für die Textausgabe.
      c : char;
      relLeft, relRight, relTop, relBottom : GLfloat;
        //relative Positionen in der FontTextur
      absWidth : integer; //absolute Breite in Pixel
  end;
  TRenderer = class
    public
      //Alle Positionen sind die relativen Positionen zur Mitte der Zeichen-
      //oberfläche, die Ränder haben immer die Koordinate +/- 1.0;
      //alle Breiten, Höhen, Dicken und Textgrößen sind relativ zur
      //Bildschirmbreite bzw. -höhe:
      //+----------------------------------------+
      //|(-1,1)            (0,1)            (1,1)|
      //|                                        |
      //|                 (0,0.5)                |
      //|                                        |
      //|(-1,0)            (0,0)            (1,0)|
      //|                                        |
      //|                                        |
      //|                                        |
      //|(-1,-1)           (0,-1)          (1,-1)|
      //+----------------------------------------+
      // <------- 0.5 ------>
      // <------------------ 1 ----------------->
      //                     <- 0.25 ->
      //Alle Farbwerte sind ebenfalls relativ (Werte zwischen 0.0 und 1.0).
      constructor Create(_w, _h: integer; _dc: HDC);
        //erzeugt eine Instanz dieser Klasse. _w ist die Breite und _h ist die
        //Höhe des Clients. _dc ist der Device Context, der Ort, wo das Bild
        //gezeichnet werden soll.
      destructor Destroy(); reintroduce;
      procedure ResizeClient(_w, _h : integer);
        //Die Größe des Clients wird aktualisiert.
      procedure DrawText(_x, _y: GLfloat; _text: string; _size: GLfloat);
        //zeichnet einen Text an die Position (_x;_y). Diese Position ist dann
        //der untere linke Eckpunkt des Textfeldes. _size ist die Höhe des
        //Textes
      procedure DrawTextEx(_x, _y: GLfloat; _text: string; _size: GLfloat;
        _centered : bool; _max_width : GLfloat; _r, _g, _b : GLfloat);
        //Wie DrawText - _centered gibt an, ob der Text zentriert werden soll.
        //Wenn dem so ist, so ist die _x Position die Mitte des Textes.
        //Außerdem kann durch _max_width eine maximale Breite für den Text
        //angegeben werden (0.0 -> keine Breite festgelegt).
      procedure DrawTexture(_x, _y: GLfloat; _tex: TTexture;
        _w: GLfloat; _h: GLfloat; _keepRatio: bool);
        //zeichnet ein Rechteck mit einer Textur an die Position (_x;_y). Diese
        //Position ist dann der untere linke Eckpunkt der Textur. _w ist die
        //Breite und _h ist die Höhe der Textur auf der Oberfläche.
        //Bei _keepRatio = true wird das Seitenverhältnis beibehalten - _w ist
        //dabei ausschlaggebend. (Verwendung von _keepRatio nicht empfohlen)
      procedure DrawHexTex(_ctr_x, _ctr_y, _w, _h : GLfloat; _tex : TTexture);
        //zeichnet eine Textur in ein Hexagon an die Position (_ctr_x, _ctr_y).
        //Diese Position ist dann die Mitte des Hexagons. _w ist die Breite und
        //_h ist die Höhe des Hexagons. Das Hexagon ist so gedreht, dass es zwei
        //zur x-Achse parallele Seiten hat          real
      procedure DrawHexBorder(_ctr_x, _ctr_y, _w, _h, _th : GLfloat;
        _r, _g, _b : GLfloat);
        //zeichnet einen Rand um ein Hexagon ensprechend DrawHexTex. _th ist die
        //Dicke der Linie.         
      procedure DrawColor(_x, _y, _w, _h: GLfloat; _r, _g, _b : GLfloat);
        //zeichnet ein einfarbiges Rechteck an die Position (_x;_y). Diese
        //Position ist dann der untere linke Eckpunkt des Rechtecks. _w ist die
        //Breite und _h ist die Höhe des Rechtecks auf der Oberfläche.
      procedure SetAlpha(_a : GLfloat);
        //setzt den Alpha-Wert (Transparenz) für die Objekte, die gezeichnet
        //werden.
        //Vorsicht: Wenn, nachdem ein transparentes Objekt gezeichnet wurde,
        //ein Objekt dahinter gezeichnet wird, ist es nicht sichtbar.
      procedure SetZ(_z : GLfloat);
        //setzt die z-Position (quasi die Ebene), auf der gezeichnet werden
        //soll (1 >= z > 0; 1 - vorne, 0.1 - hinten).
      function GetZ() : GLfloat;
        //gibt die aktuelle gesetzte z-Position zurück.
      procedure StartRender();
        //startet einen neuen Rendervorgang.
      procedure FinalizeFrame();
        //schließt den Rendervorgang ab, das Bild wird auf der Oberfläche an-
        //gezeigt.
      function GetWidth() : integer;
        //gibt die gespeicherte Breite des Clients (in Pixel) zurück
      function GetHeight() : integer;
        //gibt die gespeicherte Höhe des Clients (in Pixel) zurück
    private
      m_dc : HDC; //Device Context
      m_rc : HGLRC; //Render Context
      m_w, m_h : integer; //Breite und Höhe des Frames
      m_a, m_z : GLfloat; //Aktuell gesetzter Transparenz- und Z-Wert
      m_fonttex : GLuint;
        //die Textur, die alle Zeichen enthält, die mit der Textausgabe
        //ausgegeben werden können
      m_fontchars : Array of TFontChar;
        //die Daten zu allen Zeichen dieser Textur
  end;

const
  c_alphabetfirstindex = 32;
    //gibt an, welches Zeichen bei der Textausgabe das erste Zeichen ist, was
    //ausgegeben werden kann. (ANSI-Code)
  c_fontheight = 56;
    //gibt die Höhe eines Zeichens in der Fonttextur an (in Pixel). Je höher der
    //Wert, desto schärfer der Text.
  c_fonttexvertgap = 16;
    //gibt die Größe der vertikalen Lücke zwischen den Zeilen in der Fonttextur
    //an (in Pixel).
  c_fontname = 'Arial';
    //der Name der Font, die für die Textausgabe benutzt werden soll.

implementation

constructor TRenderer.Create(_w: integer; _h: integer; _dc: HDC);
var
  fontbmp : TBitmap;
    //Hier werden erstmal alle Zeichen für die Textausgabe draufgeschrieben, um
    //es dann OpenGL zu übergeben.
  i, j, temp_w, biggest_w, temp_h, temp_t, temp_l : integer;
  //    width   width      height  top     left
  imagedata : Array of GLubyte;
begin
  inherited Create;
  //Initialisieren der Attribute und von OpenGL:
  m_fonttex := 0;
  m_a := 1.0;
  m_z := 0.999;
  m_w := _w;
  m_h := _h;
  m_dc := _dc;
  m_rc := CreateRenderingContext(m_dc,          //Device Context
                                [opDoubleBuffered], //Optionen
                                32,          //ColorBits
                                24,          //ZBits
                                0,           //StencilBits
                                0,           //AccumBits
                                0,           //AuxBuffers
                                0);          //Layer
  ActivateRenderingContext(m_dc, m_rc);
  glClearColor(0.7, 0.7, 0.7, 1.0);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  //Font initialisieren:
  //Zuerst erstellen wir ein Bitmap, auf dem alle Zeichen gezeichnet werden.
  fontbmp := TBitmap.Create();
  fontbmp.Pixelformat := pf24bit;
  fontbmp.Width := 256;
  fontbmp.Height := (c_fontheight + c_fonttexvertgap) * 8;
  fontbmp.canvas.Font.Color := $FFFFFF;
  fontbmp.canvas.Font.Height := c_fontheight;
  fontbmp.canvas.Font.Name := c_fontname;
  SetLength(m_fontchars, 256 - c_alphabetfirstindex);
  temp_w := 0;    
  biggest_w := 0;
  //D.h. zuerst bestimmen wir die Breite von jedem Zeichen, um die nötige Breite
  //dieses Bitmaps zu ermitteln.
  for i := 0 to 255 - c_alphabetfirstindex do begin  
    if((i + 1) mod ((255 - c_alphabetfirstindex) div 8)) = 0 then begin
      if (temp_w > biggest_w) then begin
        biggest_w := temp_w;
      end;
      temp_w := 0;
    end;
    m_fontchars[i].c := CHR(i+c_alphabetfirstindex);
    m_fontchars[i].absWidth := fontbmp.Canvas.TextWidth(m_fontchars[i].c);
    temp_w := temp_w + m_fontchars[i].absWidth + 4;
  end;   
  temp_w := biggest_w;
  i := 1;
  //Die Breite des Bitmaps muss bestimmt werden; diese muss eine Zweierpotenz
  //sein:
  while i < temp_w do begin
    i := i * 2;
  end;
  temp_w := i;
  //Höhe des Bitmaps festlegen:
  temp_h := 1;
  while temp_h < ((c_fontheight + c_fonttexvertgap) * 8 + c_fonttexvertgap) do begin
    temp_h := temp_h * 2;
  end;
  //Das temporäre Bitmap löschen und ein neues erstellen; nun werden die Zeichen
  //gezeichnet:
  fontbmp.Destroy();
  fontbmp := TBitmap.Create();
  fontbmp.Pixelformat := pf24bit;
  fontbmp.Width := temp_w;
  fontbmp.Height := temp_h;
  fontbmp.canvas.Font.Color := $FFFFFF;
  fontbmp.canvas.Font.Height := c_fontheight;
  fontbmp.canvas.Font.Name := c_fontname;
  fontbmp.canvas.Brush.Color := $000000;
  fontbmp.canvas.brush.Style := bsSolid;
  fontbmp.canvas.rectangle(0, 0, temp_w, temp_h);
  temp_l := 0;
  temp_t := 0;
  //Dann werden alle Zeichen weiß auf schwarz gezeichnet und die Positionen in
  //m_fontchars gespeichert
  for i := 0 to 255 - c_alphabetfirstindex do begin
    if((i + 1) mod ((255 - c_alphabetfirstindex) div 8)) = 0 then begin
      temp_l := 0;
      temp_t := temp_t + c_fontheight + c_fonttexvertgap;
    end;
    fontbmp.canvas.TextOut(temp_l, temp_t, m_fontchars[i].c);
    m_fontchars[i].relleft := temp_l/temp_w;
    m_fontchars[i].relright := (temp_l + m_fontchars[i].absWidth)/temp_w;
    m_fontchars[i].reltop := (temp_t + c_fontheight)/temp_h;
    m_fontchars[i].relbottom := temp_t/temp_h;
    temp_l := temp_l + m_fontchars[i].absWidth + 4;
  end;
  SetLength(imagedata, temp_w*temp_h*4);
  //Die Bitmap-Daten werden jetzt für OpenGL in ein anderes Format gebracht:
  //weiß -> intransparent, schwarz -> transparent
  for i := 0 to temp_w - 1 do begin
    for j := 0 to temp_h - 1 do begin
      imagedata[(i+j*temp_w)*4] := 255; //Blau
      imagedata[(i+j*temp_w)*4+1] := 255; //Grün
      imagedata[(i+j*temp_w)*4+2] := 255; //Rot
      imagedata[(i+j*temp_w)*4+3] := fontbmp.Canvas.Pixels[i,j] mod 256; //Alpha
    end;
  end;
  //Nun muss das Bitmap gelöscht und die Daten an OpenGL gesandt werden:
  fontbmp.Destroy();
  glEnable(GL_TEXTURE_2D);  
  glGenTextures(1, @m_fonttex);
  glBindTexture(GL_TEXTURE_2D, m_fonttex);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  if(temp_w>1024) or (temp_h>1024) then begin
    MessageBoxA(0, PChar('Die Font-Bitmap hat die Maße ' + IntToStr(temp_w) + 'x' + IntToStr(temp_h) + '.' + #13 +
    'Auf manchen PCs könnte es zu Problemen bei der Textdarstellung kommen, wenn die Bitmap größer als 1024x1024 ist.'), PChar('Warnung!'), MB_ICONWARNING);
  end;
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, temp_w, temp_h, 0, GL_BGRA, GL_UNSIGNED_BYTE, imagedata);
  glBindTexture(GL_TEXTURE_2D, 0);
end;

destructor TRenderer.Destroy();
begin
  if(m_fonttex <> 0) then begin
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, @m_fonttex);
  end;
  SetLength(m_fontchars, 0);    
  DeactivateRenderingContext();
  DestroyRenderingContext(m_rc);
  inherited Destroy;
end;     

procedure TRenderer.ResizeClient(_w, _h : integer);
begin
  m_w := _w;
  m_h := _h;
end;

procedure TRenderer.DrawText(_x, _y: GLfloat; _text: string; _size: GLfloat);
begin
  DrawTextEx(_x, _y, _text, _size, false, 0.0, 0.0, 0.0, 0.0);
end;
            
procedure TRenderer.DrawTextEx(_x, _y: GLfloat; _text: string; _size: GLfloat; _centered : bool; _max_width : GLfloat; _r, _g, _b : GLfloat);
var
  i, j, cur_ind : integer;
  cur_left, cur_right, cur_top, cur_btm, cur_texleft, cur_texright, cur_textop, cur_texbtm,
    //Die jeweiligen aktuellen Positionen im Client und in der Textur
  widthcorrection, totalwidth, new_x : GLfloat;
begin
  m_z := m_z - 0.00001;
  glBindTexture(GL_TEXTURE_2D, 0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, m_fonttex);
  _max_width := _max_width * 2.0;
  new_x := _x;     
  widthcorrection := 2.0*_size*m_h/m_w/c_fontheight;
  if(_centered or (_max_width > 0.00001)) then begin
    totalwidth := 0.0;
    for i := 1 to Length(_text) do begin  
      cur_ind := ORD(_text[i])-c_alphabetfirstindex; 
      if(cur_ind < 0) then cur_ind := 0;
      totalwidth := totalwidth + m_fontchars[cur_ind].absWidth * widthcorrection;
      if(_text[i] = #13) then break;
    end;
    if(totalwidth > _max_width) and (_max_width > 0.00001) then begin
      widthcorrection := widthcorrection * _max_width / totalwidth;
      totalwidth := _max_width;
    end;
    if(_centered) then begin
      new_x := _x - totalwidth / 2.0;
    end;
  end;
  glColor4f(_r, _g, _b, m_a);
  cur_right := new_x;
  cur_top := _y + _size*2.0;
  cur_btm := _y;
  for i := 1 to Length(_text) do begin
    if(_text[i] = #13) then begin
      new_x := _x;             
      widthcorrection := 2.0*_size*m_h/m_w/c_fontheight;
      if(_centered or (_max_width > 0.00001)) then begin
        totalwidth := 0.0;
        for j := i + 1 to Length(_text) do begin
          cur_ind := ORD(_text[j])-c_alphabetfirstindex;
          if(cur_ind < 0) then cur_ind := 0;
          totalwidth := totalwidth + m_fontchars[cur_ind].absWidth * widthcorrection;
          if(_text[j] = #13) then break;
        end;
        if(totalwidth > _max_width) and (_max_width > 0.00001) then begin
          widthcorrection := widthcorrection * _max_width / totalwidth;
          totalwidth := _max_width;
        end;
        if(_centered) then begin
          new_x := _x - totalwidth / 2.0;
        end;
      end;
      cur_top := cur_btm;
      cur_btm := cur_btm - _size*2.0;
      cur_right := new_x;
    end else begin
      cur_ind := ORD(_text[i])-c_alphabetfirstindex;
      if(cur_ind < 0) then cur_ind := 0;
      cur_left := cur_right;
      cur_right := cur_left + m_fontchars[cur_ind].absWidth * widthcorrection;
      cur_texleft := m_fontchars[cur_ind].relLeft;
      cur_texright := m_fontchars[cur_ind].relRight;
      cur_textop := m_fontchars[cur_ind].relTop;
      cur_texbtm := m_fontchars[cur_ind].relBottom;
      glBegin(GL_QUADS);
        glTexCoord2f(cur_texleft,cur_textop); glVertex3f(cur_left, cur_btm, m_z);
        glTexCoord2f(cur_texright,cur_textop); glVertex3f(cur_right, cur_btm, m_z);
        glTexCoord2f(cur_texright,cur_texbtm); glVertex3f(cur_right, cur_top, m_z);
        glTexCoord2f(cur_texleft,cur_texbtm); glVertex3f(cur_left, cur_top, m_z);
      glEnd();
    end;
  end;
  glBindTexture(GL_TEXTURE_2D, 0);
end;


procedure TRenderer.DrawTexture(_x, _y: GLfloat; _tex: TTexture;
_w: GLfloat; _h: GLfloat; _keepRatio: bool);
begin                           
  m_z := m_z - 0.00001;
  glColor4f(1.0, 1.0, 1.0, m_a);
  if(_keepRatio) then begin
    _h := _tex.GetHeight() / _tex.GetWidth() * _w *  m_w/m_h;
  end;
  glBindTexture(GL_TEXTURE_2D, 0);      
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, _tex.GetTexID());
  glBegin(GL_QUADS);
    glTexCoord2f(0.0,1.0); glVertex3f(_x, _y, m_z);
    glTexCoord2f(1.0,1.0); glVertex3f(_x+_w*2, _y, m_z);
    glTexCoord2f(1.0,0.0); glVertex3f(_x+_w*2, _y+_h*2, m_z);
    glTexCoord2f(0.0,0.0); glVertex3f(_x, _y+_h*2, m_z);
  glEnd();
  glBindTexture(GL_TEXTURE_2D, 0);
end;        

procedure TRenderer.DrawHexTex(_ctr_x, _ctr_y, _w, _h : GLfloat; _tex : TTexture);
begin           
  m_z := m_z - 0.00001;
  glColor4f(1.0, 1.0, 1.0, m_a);
  glBindTexture(GL_TEXTURE_2D, 0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, _tex.GetTexID());
  glBegin(GL_QUADS);
    //Das Hexagon wird horizontal mittig in zwei Vierecke geteilt.
    glTexCoord2f(0.75,0.0); glVertex3f(_ctr_x+_w/2, _ctr_y+_h, m_z);
    glTexCoord2f(0.25,0.0); glVertex3f(_ctr_x-_w/2, _ctr_y+_h, m_z);
    glTexCoord2f(0.0,0.5); glVertex3f(_ctr_x-_w, _ctr_y, m_z);
    glTexCoord2f(1.0,0.5); glVertex3f(_ctr_x+_w, _ctr_y, m_z);
    glTexCoord2f(1.0,0.5); glVertex3f(_ctr_x+_w, _ctr_y, m_z);
    glTexCoord2f(0.0,0.5); glVertex3f(_ctr_x-_w, _ctr_y, m_z);
    glTexCoord2f(0.25,1.0); glVertex3f(_ctr_x-_w/2, _ctr_y-_h, m_z);
    glTexCoord2f(0.75,1.0); glVertex3f(_ctr_x+_w/2, _ctr_y-_h, m_z);
  glEnd();
  glBindTexture(GL_TEXTURE_2D, 0);
end;   

procedure TRenderer.DrawHexBorder(_ctr_x, _ctr_y, _w, _h, _th : GLfloat; _r, _g, _b : GLfloat);
var
  p : Array [0..5] of Array [0..1] of GLfloat;
  s6, c6, z : GLfloat; //s6 = sin(60 Grad) * Dicke; c6 = cos(60 Grad) * Dicke;
begin        
  m_z := m_z - 0.00001;
  s6 := 0.86602540378 * _th;
  c6 := 0.5 * _th;
  z := m_z - 0.001; //Der Rand ist stets vor dem Hexagon.
  glColor4f(_r, _g, _b, m_a);
  p[0][0] := _ctr_x-_w;    p[0][1] := _ctr_y;    //links
  p[1][0] := _ctr_x-_w/2;  p[1][1] := _ctr_y+_h; //oben links
  p[2][0] := _ctr_x+_w/2;  p[2][1] := _ctr_y+_h; //oben rechts
  p[3][0] := _ctr_x+_w;    p[3][1] := _ctr_y;    //rechts
  p[4][0] := _ctr_x+_w/2;  p[4][1] := _ctr_y-_h; //unten rechts
  p[5][0] := _ctr_x-_w/2;  p[5][1] := _ctr_y-_h; //unten links
  glBegin(GL_QUADS); //Jede Kante wird durch ein Viereck dargestellt.
    glVertex3f(p[0][0]-_th, p[0][1], z); glVertex3f(p[0][0]+_th, p[0][1], z);
    glVertex3f(p[1][0]+c6, p[1][1]-s6, z); glVertex3f(p[1][0]-c6, p[1][1]+s6, z);
    glVertex3f(p[1][0]-c6, p[1][1]+s6, z); glVertex3f(p[1][0]+c6, p[1][1]-s6, z);
    glVertex3f(p[2][0]-c6, p[2][1]-s6, z); glVertex3f(p[2][0]+c6, p[2][1]+s6, z);
    glVertex3f(p[2][0]+c6, p[2][1]+s6, z); glVertex3f(p[2][0]-c6, p[2][1]-s6, z);
    glVertex3f(p[3][0]-_th, p[3][1], z); glVertex3f(p[3][0]+_th, p[3][1], z);
    glVertex3f(p[3][0]+_th, p[3][1], z); glVertex3f(p[3][0]-_th, p[3][1], z);
    glVertex3f(p[4][0]-c6, p[4][1]+s6, z); glVertex3f(p[4][0]+c6, p[4][1]-s6, z);
    glVertex3f(p[4][0]+c6, p[4][1]-s6, z); glVertex3f(p[4][0]-c6, p[4][1]+s6, z);
    glVertex3f(p[5][0]+c6, p[5][1]+s6, z); glVertex3f(p[5][0]-c6, p[5][1]-s6, z);
    glVertex3f(p[5][0]-c6, p[5][1]-s6, z); glVertex3f(p[5][0]+c6, p[5][1]+s6, z);
    glVertex3f(p[0][0]+_th, p[0][1], z); glVertex3f(p[0][0]-_th, p[0][1], z);
  glEnd();
end;

procedure TRenderer.DrawColor(_x, _y, _w, _h: GLfloat; _r, _g, _b : GLfloat);
begin           
  m_z := m_z - 0.00001;
  glColor4f(_r, _g, _b, m_a);
  glBegin(GL_QUADS);
    glVertex3f(_x, _y, m_z);
    glVertex3f(_x+_w*2, _y, m_z);
    glVertex3f(_x+_w*2, _y+_h*2, m_z);
    glVertex3f(_x, _y+_h*2, m_z);
  glEnd();
end;       
         
procedure TRenderer.SetAlpha(_a : GLfloat);
begin
  m_a := _a;
end;

procedure TRenderer.SetZ(_z : GLfloat);
begin
  m_z := (1.0 - _z) / 3 + 0.1;
end;

function TRenderer.GetZ() : GLfloat;
begin
  result := 1.3 - 3 * m_z;
end;

procedure TRenderer.StartRender();
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glViewport(0,0,m_w,m_h);
  glOrtho(0,m_w,0,m_h,0,128);
  glLoadIdentity();      
  m_a := 1.0;
  m_z := 0.999;
end;

procedure TRenderer.FinalizeFrame();
begin           
  SwapBuffers(m_dc);
end;        

function TRenderer.GetWidth() : integer;
begin
  result := m_w;
end;

function TRenderer.GetHeight() : integer;
begin
  result := m_h;
end;

end.
