--To run this script, get a Save State in slot 1 that is standing somewhere you can find metals (enemies with <8 HP) and hasn't found a battle since its last reset.

emu.speedmode("maximum")

frames_required = {0,0,0,0,0,0,0,0,0,0}
monsters_found = {0,0,0,0,0,0,0,0,0,0}
steps_to_take = 0
save_state_slot = 3
framecounter = 0


function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		for i=1,9 do
			gui.text(10,10*i, (i-1)..': '..(math.floor((frames_required[i]/monsters_found[i])*100)/100)..' frames/enc ('..monsters_found[i]..' enc)')
		end
		framecounter = framecounter + 1
	end
end

while steps_to_take < 8 do
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
	
	i = 0
	--while (memory.readbyte(0x7279) ~= 0 and memory.readbyte(0x727B) ~= 0 and memory.readbyte(0x727C) ~= 0) do
	--while memory.readbyte(0xe) < 0x40 do
	while memory.readbyte(0x7) ~= 0 do
		if i < steps_to_take then
			if memory.readbyte(0x45) % 2 == 0 then
				joypad.write(1,{down=true})
				Wait(1)
				if memory.readbyte(0x45) % 2 == 1 then
					i = i + 1
				end
			else
				joypad.write(1,{up=true})
				Wait(1)
				if memory.readbyte(0x45) % 2 == 0 then
					i = i + 1
				end
			end
		else
			if memory.readbyte(0x44) % 2 == 0 then
				joypad.write(1,{left=true})
				Wait(1)
			else
				joypad.write(1,{right=true})
				Wait(1)
			end
		end
	end
	
	frames_required[steps_to_take+1] = frames_required[steps_to_take+1] + framecounter
	monsters_found[steps_to_take+1] = monsters_found[steps_to_take+1] + 1
	
	if monsters_found[steps_to_take+1] >= 1000 then
		steps_to_take = steps_to_take + 1
	end
	
	Wait(1)
end
while true do
	Wait(1)
end