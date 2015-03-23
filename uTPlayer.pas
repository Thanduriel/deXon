{
Verfasser: Dimitri Janzen (14-09-18);
Bearbeitung: Dimitri Janzen (14-09-18);
Beschreibung der Klasse(n):
Die Klasse „TPlayer“ ist der Spieler und verwaltet .
Beschreibung der Veränderung:
D.J, 14-09-18: Funktionen wurden überarbeitet. [...]}



UNIT uTPlayer;

interface

//--------------------  ggf Uses-Liste einfügen !  --------------------
//uses uTForm1;

type
  TPlayer = class

  protected //Attribute
    gold : integer;
    Name : string;

  public //Methoden
    constructor create (playername: string); virtual;
    destructor destroy (Player: TPlayer); virtual;
    procedure increasegold (newgold: integer);
    procedure decreasegold (amount: integer);
    function getgold: integer;
   end;
var Player: TPlayer;
 //   Form: TTestform;
implementation

//+---------------------------------------------------------------------
//|         TPlayer: Methodendefinition 
//+---------------------------------------------------------------------

//-------- create (public) ---------------------------------------------
constructor TPlayer.create (playername: string);

begin
  inherited create;
  Gold := 0;
  Name := playername;   // so muss das editfeld heißen.
end;

//-------- destroy (public) --------------------------------------------
destructor TPlayer.destroy (Player: TPlayer);
begin
  inherited destroy;
end;

procedure TPlayer.increasegold (newgold: integer);
begin
 gold:=gold + newgold;
end;

procedure TPlayer.decreasegold (amount: integer);
begin
 gold := gold - amount;
end;

function Tplayer.getgold: integer;
begin
 result:=gold;
end;


// Das ist Malte. Malte wird vom Compiler ignoriert.
end.



//// test: gold anzeigen und erhöhen bzw. verringern, name anzeigen
