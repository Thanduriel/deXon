program dexon;

uses
  Forms,
  uTGame in 'uTGame.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TGame, Form1);
  Application.OnIdle := Form1.run;
  Application.Run;
end.
