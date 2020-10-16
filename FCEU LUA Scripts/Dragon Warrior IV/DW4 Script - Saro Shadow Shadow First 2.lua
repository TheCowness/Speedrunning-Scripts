

emu.speedmode("maximum");

wins = 0;
losses = 0;
closes = 0;
supercloses = 0;
runs = 0;

function Wait()
	emu.frameadvance();
	gui.text(100,85,memory.readbyte(0x727E));
	gui.text(145,85,memory.readbyte(0x728C));
	if (memory.readbyte(0x728C) <= 11 and memory.readbyte(0x728C) ~= 0) then
		gui.text(145,100,">:(");
	end;
	emu.message("Score: Ragnar "..wins.." - Shadow "..losses.." (Close: "..closes.."; SC: "..supercloses..")");
end

while true do
	state = savestate.object(3);
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
		
		joypad.write(1,{A=true});
		for i=0,10 do
			Wait();
		end;
		joypad.write(1,{A=false});
		
		for i=0,60 do
			Wait();
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
			if memory.readbyte(0x727E) == 0 then
				supercloses = supercloses + 1;
			end;
			losses = losses + 1;
		end;
		if memory.readbyte(0x60B6) ~= 0 then
			wins = wins + 1;
		end;
	end;
	
	Wait();
end;