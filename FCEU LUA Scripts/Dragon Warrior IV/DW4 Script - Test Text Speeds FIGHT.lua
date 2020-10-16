--This script begins with a save state awaiting battle input.
--It will mash A until the battle is won and record the number of frames it takes to win.

--Results:
--PARTY			ENEMIES						Frames/Win		NOTES
--Hero			Bengal + Lethal Armor		1527			Turbo A, MS 1
--Hero			Bengal + Lethal Armor		1384			Turbo A, MS 8
--Hero			Bengal + Lethal Armor		1528			6 Hz mashing, MS 1
--Hero			Bengal + Lethal Armor		1614			6 Hz mashing, MS 8
--Tal/Stro/Laur	Elefrover x2				 605			Turbo A, MS 1, Laurent casts Firebal a lot
--Tal/Stro/Laur	Elefrover x2				 578			Turbo A, MS 8, Laurent casts Firebal a lot
--Tal/Stro/Laur	Elefrover x2				 619			6 Hz mashing, MS 1, Laurent casts Firebal a lot
--Tal/Stro/Laur	Elefrover x2				 645			6 Hz mashing, MS 8, Laurent casts Firebal a lot


emu.speedmode("turbo");

wins = 0
losses = 0
save_state_slot = 7


framecounter = 0
mashing_frequency = 1 --Wait this many frames after releasing A before pressing it again.  Use 1 or 9 for 30hz turbo or 6hz respectively.

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'Frames: '..framecounter)
		gui.text(10,20,'Wins: '..wins)
		gui.text(10,30,'Frames/Win: '..math.floor(framecounter / wins))
		if wins < 100 then
			framecounter = framecounter + 1
		end
	end
end

while wins < 100 do
	state = savestate.object(save_state_slot);
	savestate.load(state);
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF));
	memory.writebyte(0x0013,math.random(0xFF));
	memory.writebyte(0x050D,math.random(0xFF));
	Wait(10)
	savestate.save(state)
	savestate.persist(state)
	
	
	monsterlifecount = 1
	while monsterlifecount > 0 do
		
		for i=1,5 do
			joypad.write(1,{A=true});
			Wait(1);
			joypad.write(1,{A=false});
			Wait(mashing_frequency);
		end
		
		--Count living monsters
		monsterlifecount = 0
		for i = 0,7 do
			if(memory.readbyte(0x727E + 0xd * i) + memory.readbyte(0x727F + 0xd * i) ~= 0) then
				monsterlifecount = monsterlifecount + 1
			end
		end
		
		Wait(1)
	end
	
	wins = wins + 1
	
	Wait(1)
end
while true do
	Wait(1)
end