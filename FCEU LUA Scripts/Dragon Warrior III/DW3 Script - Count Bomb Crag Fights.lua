-- LUA Script for finding a metal slime fight in Dragon Warrior III
-- This line of text last updated 06/26/2018 by TheCowness

-- This script screws with the RNG, takes a step, checks to see if it ran into a bunch of bombcrags, and repeats.




--  S P E E D R U N B O Y S
emu.speedmode("maximum")

--Initialize these variables
four_crags = 0
total_fights = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,20,four_crags..'/'..total_fights..' ('..(math.floor((four_crags*10000)/total_fights)/100)..'%)')
	end
end

while true do
	state = savestate.object(1);
	savestate.load(state);
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x001C,math.random(0xFF));
	memory.writebyte(0x001D,math.random(0xFF));
	memory.writebyte(0x00A4,math.random(0xFF));
	memory.writebyte(0x6A68,math.random(0xFF));
	
	--Walk back and forth until you're in battle
	while memory.readbyte(0x047d) == 0x78 do
		while memory.readbyte(0x047d) == 0x78 and memory.readbyte(0x0100) < 0x62 do
			joypad.set(1,{right=true})
			Wait(1)
		end
		while memory.readbyte(0x047d) == 0x78 and memory.readbyte(0x0100) > 0x60 do
			joypad.set(1,{left=true})
			Wait(1)
		end
	end
	--We're in a battle.  Hooray.
	while memory.readbyte(0x0500) == 0 do
		Wait(1)
	end
	Wait(200)
	--Check which enemies you ran into
	slimes = 0
	for i=0,7 do
		--Technically doesn't check the upper HP byte, but we aren't fighting bombcrags here.
		--jk we're fighting bombcrags here, so let's check the upper byte only
		if memory.readbyte(0x0501+(2*i)) == 1 then
			slimes = slimes + 1
		end
	end
	if slimes == 4 then
		four_crags = four_crags + 1
	end
	total_fights = total_fights + 1
	
	--Obligatory "wait" command in case we get stuck doing nothing in this loop
	Wait(1)
end