--2019 07 17 - TheCowness - Think this script wants a save state that's about to attack Linguar?  The results of this script are that Linguar has a flat 25% chance of being in each slot, baby.
emu.speedmode("maximum")

letters = {'A','B','C','D'}
linguars_found = {0,0,0,0,0,0,0,0,0,0}
total_linguars = 0
save_state_slot = 1

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		for i=1,4 do
			gui.text(10,10+10*(i-1), (i-1)..': '..linguars_found[i]..' ('..(math.floor((linguars_found[i]/total_linguars)*10000)/100)..'%)')
		end
		gui.text(10,50,'Total: '..total_linguars)
	end
end

while true do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	--Throw random values into the random RNG seed (two bytes) and the counter and the thing next to the counter
	memory.writebyte(0x0012,math.random(0xFF))
	memory.writebyte(0x0013,math.random(0xFF))
	memory.writebyte(0x050D,math.random(0xFF))
	memory.writebyte(0x050C,math.random(0xFF))
	
	--Think this holds A's chosen attack or something.  Wait for it to be set, then wait for it to revert to F7
	while memory.readbyte(0x7324) == 0xF7 do
		joypad.write(1,{A=true})
		Wait(1)
	end
	while memory.readbyte(0x7324) ~= 0xF7 do
		Wait(1)
	end
	
	Wait(5)
	
	
	--blah = 0 --Uncomment these to stop the script when you find a metal
	for i=1,4 do
		if (memory.readbyte(0x727A + (0xe*(i-1))) == 0xC0) then
			linguars_found[i] = linguars_found[i] + 1
		end
	end
	total_linguars = total_linguars + 1
	
end