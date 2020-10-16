
--emu.speedmode("maximum");

file = 1;
--name = 48*(61*61*61)+53*61*61+48*61+12; --Loto
name = 12*61*61+45*61+3; --ClL
--name = 1
seedAFF5_found = 0;
seed5FEA_found = 0;
x = 0
y = 0
names_checked = 0

OutputFileName = 'DW2SeedSearchResults.txt';
Letters = {
	{'A','B','C','D','E','F','G','H','I','J','K'},
	{'L','M','N','O','P','Q','R','S','T','U','V'},
	{'W','X','Y','Z',"'",',','.',';','..','>',' '},
	{'a','b','c','d','e','f','g','h','i','j','k'},
	{'l','m','n','o','p','q','r','s','t','u','v'},
	{'w','x','y','z','!','?','BA','CK','E','N','D'}
};
Letter_Values = {
	0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E,
	0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
	0x3A, 0x3B, 0x3C, 0x3D, 0x5F, 0x69, 0x6B, 0x70, 0x75, 0x63, 0x60,
	0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14,
	0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
	0x20, 0x21, 0x22, 0x23, 0x6F, 0x6E
};
PrinceNames = {'Bran','Glynn','Talint','Numor','Lars','Orfeo','Artho','Esgar'}
PrinceNamesLen = {4,5,6,5,4,5,5,5}
Prince = ''
PrincessNames = {'Varia','Elani','Ollisa','Roz','Kailin','Peta','Illyth','Gwen'}
PrincessNamesLen = {5,5,6,3,6,4,6,4}
Princess = ''
a = ''
b = ''
c = ''


function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
		gui.text(10,10,"Current Name: "..name);
		gui.text(10,20,"Names checked: "..names_checked);
		if seedAFF5_found ~= 0 then
			gui.text(10,30,'Found AFF5');
		end
		if seed5FEA_found ~= 0 then
			gui.text(10,40,'Found 5FEA');
		end
		gui.text(10,50,'Prince: '..Prince);
		gui.text(10,60,'Princess: '..Princess);
		--gui.text(10,70,'a: '..a);
		--gui.text(10,80,'b: '..b);
		--gui.text(10,90,'c: '..c);
	end;
end;


while name <= 61*61*61*61 do
	--Save state should be on the name entry screen
	state = savestate.object(1);
	savestate.load(state);
	
	--Check what party names we'll get from this name.  We need Roz and either Bran or Lars.
	_namesum = 0
	_partynamelen = 13
	while _partynamelen > 12 and name <= 61*61*61*61 do
		_namesum = 0
		_tmpname = name
		ctr = 0
		--Add up the first four letters in the hero's name
		while _tmpname > 0 and ctr < 4 do
			_namesum = _namesum + Letter_Values[(_tmpname - 1)%61 + 1]
			_tmpname = math.floor(_tmpname/61)
			ctr = ctr + 1
		end
		HeroNameLen = ctr
		while ctr < 4 do
			_namesum = _namesum + 0x60 --Pad name with spaces
			ctr = ctr + 1
		end
		--Do some Black Magic on the name to figure out the others' names
		_namesum = _namesum + 0x180
		while _namesum >= 0x100 do
			_namesum = _namesum + 0x001
			_namesum = _namesum - 0x100
		end
		_partynamelen = PrinceNamesLen[AND(_namesum,0x7)+1] + PrincessNamesLen[AND((AND(_namesum,0x38)/8),0x7)+1] + HeroNameLen
		Prince = PrinceNames[AND(_namesum,0x7)+1]
		Princess = PrincessNames[AND((AND(_namesum,0x38)/8),0x7)+1]
		
		--If we don't have good names, check the next one!
		if _partynamelen > 12 then
			name = name + 1
		end
		Wait(1)
	end
	
	--Now we need to input a name... (x = 0,0xA; y=0,0x5)
	--								 6x11; bottom row has only six
	_tmpname = name;
	_name = '';
	while _tmpname > 0 do
		_letter = (_tmpname-1) % 61;
		x = (_letter % 11);
		y = math.floor(_letter / 11);
		
		--Move the cursor up/down
		while memory.readbyte(0x0083) > y do
			joypad.set(1,{up=true});
			Wait(2);
		end;
		while memory.readbyte(0x0083) < y do
			joypad.set(1,{down=true});
			Wait(2);
		end;
		
		--Move the cursor left/right
		while memory.readbyte(0x0082) > x do
			joypad.set(1,{left=true});
			Wait(2);
		end;
		while memory.readbyte(0x0082) < x do
			joypad.set(1,{right=true});
			Wait(2);
		end;
		
		Wait(4);
		_name = _name..Letters[math.floor(_letter / 11) + 1][_letter % 11 + 1];
		joypad.set(1,{A=true});
		Wait(20);
		_tmpname = math.floor(_tmpname / 61);
	end;
	--Hit "End"
	while memory.readbyte(0x0082) < 0x9 do
		joypad.set(1,{right=true});
		Wait(2);
	end;
	while memory.readbyte(0x0083) < 0x5 do
		joypad.set(1,{down=true});
		Wait(2);
	end;
	Wait(4);
	joypad.set(1,{A=true});
	Wait(22);
	
	
	--Pick a message speed
	joypad.set(1,{up=true});
	Wait(4);
	joypad.set(1,{A=true});
	Wait(20);
	
	--Sanity check: Did we get the prince/princess names we expected? (0x24 = A in Dragon Warrior, 65 = A in ASCII)
	sanity = 1
	if string.sub(PrinceNames[AND(_namesum,0x7)+1],1,1) ~= string.char(memory.readbyte(0x700D) - 0x24 + 65) then
		sanity = 1000
		while sanity > 1 do
			gui.text(80,80,"WRONG PRINCE NAME: "..string.sub(PrinceNames[AND(_namesum,0x7)+1],1,1).."/"..string.char(memory.readbyte(0x700D) - 0x24 + 65));
			Wait(1)
			sanity = sanity - 1
		end
		sanity = 0
	end
	if string.sub(PrincessNames[AND(math.floor(_namesum/8),0x7)+1],1,1) ~= string.char(memory.readbyte(0x7011) - 0x24 + 65) then
		sanity = 1000
		while sanity > 1 do
			gui.text(80,90,"WRONG PRINCESS NAME: "..string.sub(PrincessNames[AND(math.floor(_namesum/8),0x7)+1],1,1).."/"..string.char(memory.readbyte(0x7011) - 0x24 + 65));
			Wait(1)
			sanity = sanity - 1
		end
		sanity = 0
	end
	
	--Did we set a new seed?
	seed = memory.readbyte(0x0033)*0x100 + memory.readbyte(0x0032);
	if seed == 0x5FEA then
		--Output the results!
		outfile = io.open(OutputFileName,"a");
		io.output(outfile);
		io.write('Seed 5FEA: '.._name..'/'..Prince..'/'..Princess..' '..sanity );
		io.write("\n");
		io.close(outfile);
		seed5FEA_found = 1
	end;
	if seed == 0xAFF5 then
		--Output the results!
		outfile = io.open(OutputFileName,"a");
		io.output(outfile);
		io.write('Seed AFF5: '.._name..'/'..Prince..'/'..Princess..' '..sanity );
		io.write("\n");
		io.close(outfile);
		seedAFF5_found = 1
	end;
	
	name = name + 1;
	names_checked = names_checked + 1;
end;
