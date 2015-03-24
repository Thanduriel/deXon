unit uTNetwork;
{ ***************************************************
 * Verfasser: Markus Blechschmidt
 *
 * Beschreibung der Klasse:
 * TNetwork ist für die gesamte Netzwerkkommunikation verantwortlich.
 * Es gibt Funktionen zur Aufnahme und zum Beenden eines Spiels.
 * Nachrichten werden durch Send übermittel und über eine Eventfuktion übergeben.
 
 * Veränderungen: Markus Blechschmidt(09.12.14) try except behandlung von riskanten stellen
 * 				  Robert J. (08.12.14) ExtractString mit eigener Variante ersetzt um mit delpi strings zu arbeiten
 *				  Markus B. (12.12.14) Startanfrage verändert
 *}

interface

uses
  Windows, stdctrls, SysUtils, Forms, ScktComp, Winsock, classes, Dialogs;
  
type
  TPC = class
  public
    IPaddr : TStringList;
    Name   : string;
    Ready  : boolean;
  end;

  TLAN = array of TPC;

  TNetwork = class
  //Object functions
  constructor Create(_port : integer{; _output: TMemo});
  destructor Free();
  //Interface
  function GetLocIP(): string;
  function GetLocName(): string;

  function Scan({_output: TLabel}): TLAN;
  procedure Send(_msg: String);

  procedure EnterLobby();
  procedure LeaveLobby();

  function AskForGame(_index: integer): boolean; overload;
  function AskForGame(_index: integer; _msg: string): boolean; overload;
  procedure EndGame(_answer: boolean);
  //ClientSocket Event Functions
  procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
  procedure ClientSocketError(Sender: TObject;Socket: TCustomWinSocket;
    ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  procedure ClientSocketDisconnect(Sender: TObject;
    Socket: TCustomWinSocket);
  procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
  //ServerSocket Event Functions
  procedure ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
  procedure ServerClientConnect(Sender: TObject; Socket: TCustomWinSocket);
  procedure ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket;
    ErrorEvent: TErrorEvent;var ErrorCode: Integer);
  //Utility
  function GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
  public
    OnReceive : procedure (_text: string) of object;
    OnStartGame : procedure () of object;
    OnEndGame : procedure () of object;
  private
    LAN    : TLAN;
    port   : integer;
    Client : TClientSocket;
    Server : TServerSocket;
    LocName: String;
    LocIP, PartnerIP: TStringList;
    //MOutput: TMemo;
    InLobby, InGame: boolean;
  end;

implementation
//
////Class Functions
//
constructor TNetwork.Create(_port : integer{; _output: TMemo});
var
  Host, IP, Err: string;
begin
  //MOutput:=_output;
  LocIP:=TStringList.Create;
  PartnerIP:=TStringList.Create;
  if GetIPFromHost(Host, IP, Err) then begin//ermitteln der eigenen IP und Hostname
    LocName:= Host;
    /////////Teile ip adresse auf////
    try
      ExtractStrings(['.'], [], PChar(IP), LocIP);
    finally
    end;
    //ShowMessage(LocIP[0]+'.'+LocIP[1]+'.'+LocIP[2]+'.'+LocIP[3]);
  end;

  port   := _port;
  Client := TClientSocket.Create(nil);//Erstellen der Sockets
  Server := TServerSocket.Create(nil);
  Client.Port:=port;//Zuweisen des Ports
  Server.Port:=port;

  Client.OnConnect:=ClientSocketConnect;//Zuweisend er Eventfunktionen
  Client.OnRead:= ClientSocketRead;
  Client.OnError:= ClientSocketError;
  Client.OnDisconnect:= ClientSocketDisconnect;

  Server.OnClientConnect:=ServerClientConnect;
  Server.OnClientRead:=ServerClientRead;
  Server.OnClientError:=ServerSocketClientError;

  Server.Open;//Server öffnen
  
  InLobby:=false;
end;

destructor TNetwork.Free();
begin
  EndGame(false);
  Server.Free;//Sockets löschen
  Client.free;
end;


//
////Interface
//


function TNetwork.GetLocIP(): string;
begin
  result:=LocIP[0]+'.'+LocIP[1]+'.'+LocIP[2]+'.'+LocIP[3];//IP aus den vier "bytes" zusammensetzen.
end;

function TNetwork.GetLocName(): string;
begin
  result:=LocName;
end;

procedure TNetwork.EnterLobby();
begin
  InLobby:=true;
  //if not InGame then InLobby:=true;//Lobby nur betretber, wenn nicht im Spiel
end;

procedure TNetwork.LeaveLobby();
begin
  InLobby:=false;
end;

function TNetwork.Scan({_output: TLabel}): TLAN;
var
  i, ind: Integer;
  time : Cardinal;
  Dummy: TClientSocket;
  lastreceive: string;
begin
  SetLength(LAN, 0);                              //Vorhandenes LAN array Löschen
  ind:=0;
  //currIP:=LocIP;
  for i:=1 to 254 do begin                        //Annahme: IP Mask: 255.255.255.0,
                                                  //daher Scan in x.y.z.1-254

    if i<>StrToInt(LocIP[3]) then begin           //Eigen IP überspringen
      Dummy:=TClientSocket.create(nil);           //Dummy Socket erstellen
      Dummy.port:=port;                           //Port Zuweisen
      Dummy.Address:=LocIP[0]+'.'+                //IP Adresse Zuweisen
                     LocIP[1]+'.'+
                     LocIP[2]+'.'+
                     IntToStr(i);
      //_output.Caption:=Dummy.Address;
      Dummy.Open;                                 //Dummy versuchen zu öffnen

      time := GetTickCount;
      while (not Dummy.Active) and 
            ((GetTickCount-time)<10)do            //entweder mit erfolg geöffnet oder Abbruch nach 10 ms
        Application.ProcessMessages;

      if Dummy.Active then begin                  //Wenn verbindung erfolgreich, Verbindung in Array aufnehmen
        SetLength(LAN, length(LAN)+1);            //Array um 1 erhöhen
        LAN[ind]:=TPC.Create;                     //PC Objekt erstellen und an Array anfügen
        Lan[ind].IPaddr:=TStringList.Create;      //IP Adresse übergeben
        LAN[ind].IPaddr.Add(LocIP[0]);
        LAN[ind].IPaddr.Add(LocIP[1]);
        LAN[ind].IPaddr.Add(LocIP[2]);
        LAN[ind].IPaddr.Add(IntToStr(i));
        LAN[ind].Name:=Dummy.Socket.RemoteHost;   //Hostnamen übergeben

        Dummy.Socket.SendText('?lobby;');         //Verfügbarkeit zum Spiel erfragen
        lastreceive := Client.Socket.ReceiveText;
        time := GetTickCount;
        while  (lastreceive= '') and 
               ((GetTickCount-time)<1) do begin   //1 ms auf Antwort warten
          Application.ProcessMessages;
          lastreceive := Dummy.Socket.ReceiveText;
        end;
        if lastreceive = '!yes;' then             //Verfügbarkeit zum Spiel eintragen
          LAN[ind].Ready:= true
        else
          LAN[ind].Ready:= false;

        inc(ind);
      end;
      Dummy.close;                                //Dummy schließen und löschen
      Dummy.Free;
    end;
  end;
  //_output.Caption:='idle';
  Result:=LAN;                                    //gefülltes LAN Array zurückgeben
end;

procedure TNetwork.Send(_msg: String);
begin
  if InGame then
    Client.Socket.SendText(_msg+';'); //Nachricht mit nachgestelltem ";" versenden
end;

function TNetwork.AskForGame(_index: integer): boolean;
var
  lastreceive: string;
  time: Cardinal;
begin
  if (_index < Length(LAN)) and                 //Spiel nur anfragbar, wenn man nicht bereits in Spiel ist
     InLobby then begin
    Client.Close;                               //Client vorsorgehalber schließen
    LeaveLobby;                                 //Lobby verlassen
    Client.Address:=LAN[_index].IPaddr[0]+'.'+  //IP Adresse setzen
                    LAN[_index].IPaddr[1]+'.'+
                    LAN[_index].IPaddr[2]+'.'+
                    LAN[_index].IPaddr[3];

    Client.Open;                                 //Client versuchen zu öffnen
    time:= GetTickCount;
    While (not Client.Active) and                //Entweder Erfolg oder nach 1s abbrechen
          ((GetTickCount-time)<1000) do
      Application.ProcessMessages;

    if Client.Active then begin
      Client.Socket.SendText('?game;');          //Spiel Anfragen
      lastreceive := Client.Socket.ReceiveText;
      while  lastreceive= '' do begin
        lastreceive := Client.Socket.ReceiveText;//Warten auf echo
        Application.ProcessMessages;             //kurz zeit geben;
      end;

      if lastreceive = '!yes;' then begin        //Bei Erfolg:
        PartnerIP:=LAN[_index].IPaddr;           //Partner festlegen
        InGame:=true;                            //In  Spielstatus übergehen
        result:=true;
        OnStartGame;                             //Spielstart Eventfunktion aufrufen
      end
      else begin                                 //Sonst misserfolg Melden und in Ausganszustand gehen
        result:=false;
        EnterLobby;
      end;
    end
    else begin
      result:=false;
      EnterLobby;
    end;
  end
  else result:=false;
end;

function TNetwork.AskForGame(_index: integer; _msg: string): boolean;
var
  lastreceive: string;
  time: Cardinal;
begin
  if (_index < Length(LAN)) and                 //Spiel nur anfragbar, wenn man nicht bereits in Spiel ist
     InLobby then begin
    Client.Close;                               //Client vorsorgehalber schließen
    LeaveLobby;                                 //Lobby verlassen
    Client.Address:=LAN[_index].IPaddr[0]+'.'+  //IP Adresse setzen
                    LAN[_index].IPaddr[1]+'.'+
                    LAN[_index].IPaddr[2]+'.'+
                    LAN[_index].IPaddr[3];

    Client.Open;                                 //Client versuchen zu öffnen
    time:= GetTickCount;
    While (not Client.Active) and                //Entweder Erfolg oder nach 1s abbrechen
          ((GetTickCount-time)<1000) do
      Application.ProcessMessages;

    if Client.Active then begin
      Client.Socket.SendText('?game'+_msg+';');//Spiel Anfragen
      lastreceive := Client.Socket.ReceiveText;
      time:= GetTickCount;
      while  (lastreceive= '') and                //Entweder Erfolg oder nach 1s abbrechen
        ((GetTickCount-time)<10000) do begin
        lastreceive := Client.Socket.ReceiveText;//Warten auf echo
        Application.ProcessMessages;             //kurz zeit geben;
      end;

      if lastreceive = '!yes;' then begin        //Bei Erfolg:
        PartnerIP:=LAN[_index].IPaddr;           //Partner festlegen
        InGame:=true;                            //In  Spielstatus übergehen
        result:=true;
        OnStartGame;                             //Spielstart Eventfunktion aufrufen
      end
      else begin                                 //Sonst misserfolg Melden und in Ausganszustand gehen
        if lastreceive <> '!no;' then
          ShowMessage('No reaction :-(');
        result:=false;
        EnterLobby;
        Client.Close;
      end;
    end
    else begin
      result:=false;
      EnterLobby;
      Client.Close;
    end;
  end
  else result:=false;
end;

procedure TNetwork.EndGame(_answer: boolean);
var
  time: cardinal;
begin
  if not _answer then               //Wenn man nicht der Antwortende ist,
    Client.Socket.SendText('!end;');//dem Partner das beenden Melden
  time:=GetTickCount;
  while time-GetTickCount < 50 do   //50ms warten
    Application.ProcessMessages;
  Client.Close;
  PartnerIP:=nil;
  InGame:=False;
  EnterLobby;                       //Lobby wieder betreten
  if(assigned(onEndGame)) then
    OnEndGame;                        //Ende Eventfunktion aufrufen
end;


//
////ClientSocket Event Functions
//


procedure TNetwork.ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  //ShowMessage('Y');
end;

procedure TNetwork.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  case ErrorCode of
    10053 : begin//Verbindungsabbruch	
      if Ingame then begin
	    ShowMessage('Network Error');
        ErrorCode:=0;
        EndGame(true);
        OnEndGame();
	  end;
    end;
    10060 : begin//Connection timed out
      ErrorCode:=0;
      ShowMessage('Timeout');
    end;
    10061 : begin//Connection refused
      ErrorCode:=0;
      ShowMessage('Refused');
    end;
  else
  end;
end;

procedure TNetwork.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin end;
procedure TNetwork.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
begin end;


//
////ServerSocket Event Funktions
//


procedure TNetwork.ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  msg: string;
  incoming: TStringList;
  i, j: Integer;
begin
  msg:=Socket.ReceiveText;
  incoming:=TStringlist.Create;
  
  j := 1;
  //delpi string goes from 1 to n
  for i := 1 to length(msg) do 
  begin
	//delimeter ';'
	if(msg[i] = ';') then
	begin
		incoming.append(copy(msg, j, i - j));
		//save start of the next substring
		j := i + 1;
	end;
  end;
  //put in the rest
  if j < length(msg) then incoming.append(copy(msg, j, i - j));        //Nachrichten separieren

  for i:=0 to incoming.Count-1 do
    case incoming[i][1] of
      '?': begin                                         //Anfrage                               
        //ShowMessage('Empfangen: '+incoming[i]);
        if incoming[i] = '?lobby' then
          if InLobby then Socket.SendText('!yes;')
          else Socket.SendText('!no;');
        if (Copy(incoming[i], 0, 5) = '?game') then
          if InLobby then
            if MessageDlg('Enter drücken, um ein Spiel zu beginnen mit '//Spieler fragen, ob er spielen will
			   +Socket.RemoteHost+' bei folgenden Parametern: '+Copy(incoming[i], 6, length(incoming[i])-5)+' sonst Esc', mtCustom, mbOKCancel, 0) = 1 then begin
              try			  
			    OnReceive(incoming[i]);
				
                Socket.SendText('!yes;');
                LeaveLobby;                                      //Spiel beginnen
                InGame:=true;
                Client.Address:=Socket.RemoteAddress;
                Client.Open;
                ExtractStrings(['.'], [], PChar(Socket.RemoteAddress), PartnerIP);
                //MOutput.Lines.Add('Began game with ' + Client.Socket.RemoteHost+'; '+PartnerIP[0]+'.'+PartnerIP[1]+'.'+PartnerIP[2]+'.'+PartnerIP[3]);
                OnStartGame;
              except
                InGame:=false;
                EnterLobby;
                ShowMessage('request withdrawn :-(');
              end;
            end
            else
              Socket.SendText('!no;')
          else
            Socket.SendText('!no;');
        end;
      '!':begin
        //ShowMessage(incoming[i]);
        if incoming[i] = '!end' then begin //Spiel beenden
          EndGame(true);
        end;
      end;
    else
      OnReceive(incoming[i]);
    end;

  incoming.Free;
end;

procedure TNetwork.ServerClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin;
  //ShowMessage('ServerClientConnect');
  //Application.ProcessMessages;
end;

procedure TNetwork.ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket;
    ErrorEvent: TErrorEvent;var ErrorCode: Integer);
begin
  case ErrorCode of
    10053 : begin//Verbindungsabbruch	
      if Ingame then begin
	    ShowMessage('Network Error');
        ErrorCode:=0;
        EndGame(true);
        OnEndGame();
	  end;
    end;
  else
  end;
end;

//
////Utitlity
//


//////Funktion zum erfahren der eigenen IP//////////////////////////////////////
function TNetwork.GetIPFromHost//http://delphi.about.com/od/networking/l/aa103100a.htm
(var HostName, IPaddr, WSAErr: string): Boolean;
type
  Name = array[0..100] of Char;
  PName = ^Name;
var
  HEnt: pHostEnt;
  HName: PName;
  WSAData: TWSAData;
  i: Integer;
begin
  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then begin
    WSAErr := 'Winsock is not responding."';
    Exit;
  end;
  IPaddr := '';
  New(HName);
  if GetHostName(HName^, SizeOf(Name)) = 0 then
  begin
    HostName := StrPas(HName^);
    HEnt := GetHostByName(HName^);
    for i := 0 to HEnt^.h_length - 1 do
     IPaddr :=
      Concat(IPaddr,
      IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
    SetLength(IPaddr, Length(IPaddr) - 1);
    Result := True;
  end
  else begin
   case WSAGetLastError of
    WSANOTINITIALISED:WSAErr:='WSANotInitialised';
    WSAENETDOWN      :WSAErr:='WSAENetDown';
    WSAEINPROGRESS   :WSAErr:='WSAEInProgress';
   end;
  end;
  Dispose(HName);
  WSACleanup;
end;

end.
