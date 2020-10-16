-- I'm starting to think I might have a problem.
-- This outputs a massive text file, and if it works, you should just reference the text file instead of the script

emu.speedmode("maximum");

file = 1;
name = 1;
message_speed = 1;
gender = 0;
seeds_found = 0;
results = {{},{},{}};
for i=1,3 do
	for j=1,65536 do
		results[i][j] = {'',0,''};
	end;
end;
OutputFileName = 'Results.txt';
Letters = {
	{'A','B','C','D','E','F','G','H','I','J','K'},
	{'L','M','N','O','P','Q','R','S','T','U','V'},
	{'W','X','Y','Z','-',"'",'!','?','(',')',' '},
	{'a','b','c','d','e','f','g','h','i','j','k'},
	{'l','m','n','o','p','q','r','s','t','u','v'},
	{'w','x','y','z',',','.','BA','CK','E','N','D'}
};

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
		gui.text(10,10,"Current File: "..file);
		gui.text(10,20,"Current Name: "..name);
		gui.text(10,30,"Seeds Found: "..seeds_found);
		--gui.text(10,40,"Seed: "..DEC_HEX(memory.readbyte(0x001D)*0x100 + memory.readbyte(0x001C)));
		--gui.text(10,40,"0x1234: "..DEC_HEX(0x1234));
	end;
end;

function DEC_HEX(IN)
    Base = 16;
	Values = "0123456789ABCDEF";
	OUT = "";
	Digit = 0;
	I = 0;
	digits = 0;
    while IN>0 do
        I=I+1;
		Digit=math.mod(IN,Base)+1;
        IN=math.floor(IN/Base);
        OUT=string.sub(Values,Digit,Digit)..OUT;
		digits = digits + 1;
    end;
	while digits < 4 do
		OUT = '0'..OUT;
		digits = digits + 1;
	end;
    return OUT;
end;



while file <= 3 do
	state = savestate.object(1);
	savestate.load(state);
	
	--Save state needs to be on the file select menu (After select "Begin a New Quest")
	for i = 2,file do
		joypad.set(1,{down=true});
		Wait(5);
	end;
	
	joypad.set(1,{A=true});
	Wait(20);
	
	--Now we need to input a name... (x = 0x5,0x19; y=0xA,0x14) (Both every-other only)
	--								 6x11; bottom row has only six
	_tmpname = name;
	_name = '';
	while _tmpname > 0 do
		_letter = (_tmpname-1) % 61;
		x = (_letter % 11) * 2 + 0x5;
		y = math.floor(_letter / 11) * 2 + 0xA;
		
		--Move the cursor left/right
		while memory.readbyte(0x0004) > x do
			joypad.set(1,{left=true});
			Wait(2);
		end;
		while memory.readbyte(0x0004) < x do
			joypad.set(1,{right=true});
			Wait(2);
		end;
		
		--Move the cursor up/down
		while memory.readbyte(0x0005) > y do
			joypad.set(1,{up=true});
			Wait(2);
		end;
		while memory.readbyte(0x0005) < y do
			joypad.set(1,{down=true});
			Wait(2);
		end;
		
		_name = _name..Letters[math.floor(_letter / 11) + 1][_letter % 11 + 1];
		joypad.set(1,{A=true});
		Wait(20);
		_tmpname = math.floor(_tmpname / 61);
	end;
	--Hit "End"
	while memory.readbyte(0x0004) < 0x17 do
		joypad.set(1,{right=true});
		Wait(2);
	end;
	while memory.readbyte(0x0005) < 0x14 do
		joypad.set(1,{down=true});
		Wait(2);
	end;
	joypad.set(1,{A=true});
	Wait(20);
	
	
	--Pick a gender
	if gender == 1 then
		joypad.set(1,{down=true});
		Wait(2);
	end;
	joypad.set(1,{A=true});
	Wait(20);
	
	
	--Pick a message speed
	while memory.readbyte(0x0004) > message_speed * 2 + 7 do --0x09 = MS 1
		joypad.set(1,{left=true});
		Wait(2);
	end;
	while memory.readbyte(0x0004) < message_speed * 2 + 7 do --0x09 = MS 1
		joypad.set(1,{right=true});
		Wait(2);
	end;
	joypad.set(1,{A=true});
	Wait(25);
	
	
	--Did we set a new seed?
	seed = memory.readbyte(0x001D)*0x100 + memory.readbyte(0x001C) + 1;
	if results[file][seed][2] == 0 then
		results[file][seed][1] = _name;
		results[file][seed][2] = message_speed;
		if gender == 0 then
			results[file][seed][3] = 'M';
		else
			results[file][seed][3] = 'F';
		end;
		seeds_found = seeds_found + 1;
		
		--Output the results!
		outfile = io.open("UnsortedResults.txt","a");
		io.output(outfile);
		io.write('File '..file..', Seed '..DEC_HEX(seed)..': "'..results[file][seed][1]..'" MS'..results[file][seed][2]..' '..results[file][seed][3] );
		io.write("\n");
		io.close(outfile);
	end;
	
	--Update flags
	if gender == 1 then
		gender = 0;
		if message_speed == 8 then
			message_speed = 1;
			name = name + 1;
		else
			message_speed = message_speed + 1;
		end;
	else
		gender = 1;
	end;
	
	if seeds_found >= 65536 * file or name >= 8 * 61 then
		file = file + 1;
		name = 1;
	end;
end;

--Output the results!
outfile = io.open(OutputFileName,"a");
io.output(outfile);
io.write(os.date());
io.write("\n\n");
for i=1,3 do
	for j=1,65536 do
		if results[i][j][2] ~= 0 then
			io.write('File '..i..', Seed '..DEC_HEX(j-1)..': "'..results[i][j][1]..'" MS'..results[i][j][2]..' '..results[i][j][3] );
			io.write("\n");
		end;
	end;
	io.write("\n\n");
end;
io.close(outfile);