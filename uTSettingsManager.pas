unit uTSettingsManager;

interface

uses SysUtils;

type
	Setting = record
		key : string;
		value : string;
	end;
	
  TSettingsManager = class
	public
		constructor Create(_name : string);
		destructor destroy(); override;
		
		procedure setValue(_key: string; _value : string); overload;
		procedure setValue(_key: string; _value : integer); overload;
		
		function getValue(_key : string) : string; overload;
		function getValueInt(_key : string) : integer; overload;
	private
		name : string;
		settings : array of Setting;
		settingsCount : integer;
		
		procedure add(_key : string; _value : string);
  end;
  
// settings singleton
var
	g_settingsManager : TSettingsManager;
  
implementation
        
constructor TSettingsManager.Create(_name : string);
var fileHndl : TextFile;
	str : string;
	i : integer;
begin
	inherited Create();
  
	name := _name;
	settingsCount := 0;
	setLength( settings, 16);
	//read file
	AssignFile(fileHndl, _name);//'settings.txt'
	reset(fileHndl);
	
	while not Eof(fileHndl) do
	begin	
		ReadLn(fileHndl, str);
		
		//search for the ' '
		i := 1;
		// $20 = ' '
		while( (i < length(str)) and (str[i] <> #32)) do
			inc(i);
		
		add(copy(str, 1, i - 1), copy(str, i + 1, length(str) - i));
   end;
   
   CloseFile(fileHndl);
end;

destructor TSettingsManager.Destroy();
var fileHndl : TextFile;
	i : integer;
begin
	//save settings to file
	AssignFile(fileHndl, name);
	ReWrite(fileHndl);
	
	for i := 0 to settingsCount - 1 do
	begin
		write(fileHndl, settings[i].key);
		write(fileHndl, ' ');
		write(fileHndl, settings[i].value);
		writeln(fileHndl);
	end;

	CloseFile(fileHndl);
	
  inherited Destroy();
end;      

procedure TSettingsManager.setValue(_key: string; _value : string);
var i : integer;
begin
	//look whether it exists already
	for i := 0 to settingsCount - 1 do 
		if(settings[i].key = _key) then
		begin
			settings[i].value := _value;
			exit;
		end;
	begin
	end;
	//not found, add new key
	add(_key, _value);
end;

procedure TSettingsManager.setValue(_key: string; _value : integer);
begin
	setValue(_key, IntToStr(_value));
end;

function TSettingsManager.getValue(_key: string) : string;
var i : integer;
begin
	for i := 0 to settingsCount - 1 do 
		if(settings[i].key = _key) then
		begin
			result := settings[i].value;
			exit;
		end;
	result := '';
end;

function TSettingsManager.getValueInt(_key: string) : integer;
begin
	result := StrToInt(getValue(_key));
end;

procedure TSettingsManager.add(_key: string; _value : string);
begin
	//expand when necessary
	if(settingsCount > High(settings) ) then
		setLength(settings, settingsCount * 2);
	
	settings[settingsCount].key := _key;
	settings[settingsCount].value := _value;
	
	inc(settingsCount);
end;

end.