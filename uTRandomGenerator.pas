unit uTRandomGenerator;

{ ***************************************************
 * Verfasser: Robert Jendersie
 *
 * Beschreibung der Klasse:
 * Die TFactory konstruiert Minions und Turrents mittels Ids.
 *
 * Veränderungen: Robert Jendersie
 *}

interface

//uses

type

	TRandomGenerator = class
	public
		constructor create( _seed : cardinal);
		function get() : cardinal; overload;
		function get(_max : cardinal) : cardinal; overload;
	
	private
		m_a : cardinal;
		
	end;


	
implementation

	constructor TRandomGenerator.create(_seed : cardinal);
	begin
		m_a := _seed;
	end;

	function TRandomGenerator.get() : cardinal;
	begin 
		m_a := m_a xor (m_a shl 13);
		m_a := m_a xor (m_a shr 17);
		m_a := m_a xor (m_a shl 5);
		result := m_a;
	end;
	
	function TRandomGenerator.get(_max : cardinal) : cardinal;
	begin 
		result := get() mod (_max+1);
	end;
	
	
	

end.