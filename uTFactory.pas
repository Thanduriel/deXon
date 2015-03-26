unit uTFactory;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * Die TFactory konstruiert Minions und Turrents mittels Ids.
 *
 * Veränderungen: Robert Jendersie (07.12.14) create Functionen erstellt
 *}

interface

uses uTMinion, uTTower, uTStandardTower, uTPoisonTower, uTTurminator, uTCityWok,
	uTBread, uTHerpes, uTear, utturtle, utkaisersoze;

type

	TFactory = class
	public
		function createMinion(_id : byte; _Name: string = 'noname'; _default : boolean = true) : TMinion;
		function createTower(_id : byte; _x, _y : real) : TTower;
	
	end;

var g_factory : TFactory;
	
implementation

function TFactory.createMinion(_id : byte; _Name: string; _default : boolean) : TMinion;
begin
	case _id of
		10 : result := TBread.create(_name, _default);
		11 : result := THerpes.create(_name, _default);
		12 : result := TEar.create(_name, _default);
		13 : result := TTurtle.create(_name, _default);
		14 : result := Tkaisersoze.create(_name, _default);
	end;
end;

function TFactory.createTower(_id : byte; _x, _y : real) : TTower;
begin
	case _id of
		128 : result := TStandardTower.create(_x, _y);
		129 : result := TPoisonTower.create(_x, _y);
		130 : result := TTurminator.create(_x, _y);
		131 : result := TCityWok.create(_x, _y);
	end;
end;

end.