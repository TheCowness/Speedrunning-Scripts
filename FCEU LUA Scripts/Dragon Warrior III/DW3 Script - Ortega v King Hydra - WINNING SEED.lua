-- LUA Script for testing the Ortega x King Hydra fight in Dragon Warrior III
-- This line of text last updated 05/04/2016 by TheCowness

-- To use this, you need a save state in slot one that is already on the "Look! A hero is fighting a monster alone!" text.
-- You can be a little later (on the black screen), but make sure you don't see Ortega's battle sprite yet.  RNG affects their starting HP.




--  S P E E D R U N B O Y S
--emu.speedmode("maximum");

--Initialize this value
RNG = 1296;
ctr = 7;
discard = 5;
ortega_wins = 0;
hydra_wins = 0;
high_score = 550;

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
		gui.text(80,70,memory.readbyte(0x500) + memory.readbyte(0x501) * 256); --Ortega HP
		gui.text(152,70,memory.readbyte(0x502) + memory.readbyte(0x503) * 256); --Hydra HP
		gui.text(10,10,'RNG: '..RNG..'/65536');
		gui.text(10,20,'Counter: '..ctr..'/256');
		gui.text(10,30,'Discard: '..discard..'/16');
		gui.text(50,50,'VISITOR '..ortega_wins..'       '..hydra_wins..' HOME');
		if high_score ~= 0 then --Lowest Hydra's HP has ever gotten
			gui.text(160,10,'HIGH SCORE: '..high_score);
		end
	end
end

--Try literally every possibility (estimated completion: the year 4058)
while RNG <= 0xFFFF do
	state = savestate.object(1)
	savestate.load(state)
	
	memory.writebyte(0x001C,RNG%256)
	memory.writebyte(0x001D,math.floor(RNG/256))
	memory.writebyte(0x00A4,ctr)
	memory.writebyte(0x6A68,discard)
	memory.writebyte(0x06DD,7) --Set the message speed to 8
	
	--Wait...
	Wait(60)
	for i=0,60 do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(1)
	end

	--Wait until one of them dies...
	while (memory.readbyte(0x500) + memory.readbyte(0x501) ~= 0) and (memory.readbyte(0x502) + memory.readbyte(0x503) ~= 0) do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(1)
		if high_score ~= 0 and high_score > memory.readbyte(0x502) + memory.readbyte(0x503) * 256 then
			high_score = memory.readbyte(0x502) + memory.readbyte(0x503) * 256
		end
	end
	
	--See who won
	if(memory.readbyte(0x500) + memory.readbyte(0x501) == 0) then
		hydra_wins = hydra_wins + 1
	else
		ortega_wins = ortega_wins + 1
		--Oh my god he actually won.  But I missed it, because I died two hundred years ago.  Log the seeds in a file.
		outfile = io.open("Ortega v King Hydra Victories.txt","a")
		io.output(outfile);
		io.write("RNG Seed: "..RNG)
		io.write("\n")
		io.write("Counter: "..ctr)
		io.write("\n")
		io.write("Discard Counter: "..discard)
		io.write("\n")
		io.write("\n")
		io.close(outfile)
	end
	
	discard = discard + 1
	if(discard == 16) then
		discard = 0
		ctr = ctr + 1
		if ctr == 256 then
			ctr = 0
			RNG = RNG + 1
		end
	end
	
	
	--Obligatory "wait" command in case we get stuck doing nothing in this loop
	Wait(1)
end