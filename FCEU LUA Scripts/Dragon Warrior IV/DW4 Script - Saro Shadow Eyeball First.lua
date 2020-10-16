--Load save state 2, assumed to be the start of the Saro's Shadow battle
--Wait for a random amount of frames for RNG purposes
--If the battle isn't over... (Else GOTO 8)
--Wait for a shorter random amount of frames
--press A, down, A
--If the battle isn't over, wait for the command menu to pop back up
--GOTO 3
--Output the score

emu.speedmode("maximum");

wins = 0;
losses = 0;
closes = 0;
eyeballs = 0;
runs = 0;

function Wait()
	emu.frameadvance();
	gui.text(100,85,memory.readbyte(0x727E));
	gui.text(145,85,memory.readbyte(0x728C));
	if (memory.readbyte(0x728C) <= 11 and memory.readbyte(0x728C) ~= 0) then
		gui.text(145,100,">:(");
	end;
	emu.message("Score: Ragnar "..wins.." - Shadow "..losses.." (Close: "..closes.."; Far: "..eyeballs..")");
end

while true do
	state = savestate.object(2);
	savestate.load(state);
	rando = math.random(600);
	--emu.message("Waiting for "..rando.." frames");
	
	invalid = 0;
	
	for i=0,rando do
		Wait();
	end;
	
	while (memory.readbyte(0x727E) ~= 0 or memory.readbyte(0x728C) ~= 0) and memory.readbyte(0x60B6) ~= 0 do
		for i=0,80+math.random(20) do
			Wait();
		end;
		
		if(memory.readbyte(1) == 22) then
			invalid = 1;
			break;
		end;
		joypad.write(1,{A=true});
		for i=0,10 do
			Wait();
		end;
		joypad.write(1,{A=false});
		
		for i=0,40 do
			Wait();
		end;
		
		joypad.write(1,{down=true});
		for i=0,10 do
			Wait();
		end;
		joypad.write(1,{down=false});
		
		for i=0,40 do
			Wait();
		end;
		
		--Run is currently selected, and we do NOT want to do this... attempt to correct by pressing B... zzzz
		if(memory.readbyte(1) == 22) then
			--Try to recover once
			joypad.write(1,{B=true});
			for i=0,10 do
				Wait();
			end;
			joypad.write(1,{B=false});
		
			for i=0,80 do
				Wait();
			end;
			if(memory.readbyte(1) == 22) then
				--Couldn't recover; just break.
				invalid = 1;
				break;
			end;
			--If we did recover (by pressing B), restart the turn.
		else
			joypad.write(1,{A=true});
			for i=0,10 do
				Wait();
			end;
			joypad.write(1,{A=false});
			
			for i=0,40 do
				Wait();
			end;
			
			--Wait while not on this menu AND Shadow or Eyeball are alive AND Ragnar is alive 
			while (memory.readbyte(0) ~= 3 or memory.readbyte(1) ~= 20) and ((memory.readbyte(0x727E) ~= 0 or memory.readbyte(0x728C) ~= 0) and memory.readbyte(0x60B6) ~= 0) do
				Wait();
			end;
			
		end;
		Wait();
		
	end;
	emu.message("ded");
		
	for i=0,400 do
		Wait();
	end;
	
	--Throw this out; ran on accident
	if(invalid == 1) then
		runs = runs + 1;
	else
		--Who won?
		if (memory.readbyte(0x727E) ~= 0 or memory.readbyte(0x728C) ~= 0) then
			if memory.readbyte(0x727E) <= 80 then
				closes = closes + 1;
			end;
			if memory.readbyte(0x728C) > 0 then
				eyeballs = eyeballs + 1;
			end;
			losses = losses + 1;
		end;
		if memory.readbyte(0x60B6) ~= 0 then
			wins = wins + 1;
		end;
	end;
	
	Wait();
end;