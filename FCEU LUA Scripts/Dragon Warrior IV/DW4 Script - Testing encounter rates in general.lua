emu.speedmode("maximum")

save_state_slot = 5
encounters = 0
trials = 0
EncRate = 0


function Wait(number)
	--Actually a "wait counter" but all waits are for one frame except for the one where I want to delay to show the frame counter
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10, 'Encounters: '..encounters..'/'..trials..' ('..(math.floor(encounters*10000/trials)/100)..'%)')
		gui.text(10,20, 'Theoretical Rate: '..(math.floor(EncRate*10000/256)/100)..'%)')
		--gui.text(10,30, 'Frame Counter: '..framecounter)
	end
end

while trials < 10000 do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	--Throw random values into the random RNG seed (two bytes) and the counter and the thing next to the counter
	memory.writebyte(0x0012,math.random(0xFF))
	memory.writebyte(0x0013,math.random(0xFF))
	memory.writebyte(0x050D,math.random(0xFF))
	memory.writebyte(0x050C,math.random(0xFF))
	Wait(math.random(0x0F))
	savestate.save(state)
	framecounter = 0
	
	--Coordinates are {0x42},{0x43}
	starting_loc = memory.readbyte(0x43)
	--for i=0,36 do --more than enough frames to take two steps
	for i=0,46 do --more than enough frames to take two steps in swamp
		joypad.write(1,{down=true})
		Wait(1)
		if EncRate == 0 then
			EncRate = memory.readbyte(0x0E)
		end
		if memory.readbyte(0x43) == starting_loc + 2 then
			break
		end
	end
	if memory.readbyte(0x43) == starting_loc + 1 then
		encounters = encounters + 1
	end
	
	--while memory.readbyte(0x43) ~= 0x69 do
	--	joypad.write(1,{down=true})
	--	Wait(1)
	--end
	--if EncRate == 0 then
	--	EncRate = memory.readbyte(0x0E)
	--end
	--for i=0,100 do
	--	Wait(1)
	--	-- 0x07 => 0 doesn't work for sea encounters...
	--	--if memory.readbyte(0x7) == 0 then
	--	if memory.readbyte(0x8) == 0 then
	--		encounters = encounters + 1
	--		Wait(300)
	--		break
	--	end
	--end
	
	trials = trials + 1
	
	Wait(1)
end
while true do
	Wait(1)
end