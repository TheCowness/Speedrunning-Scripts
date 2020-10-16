--To run this script, get a Save State in slot 1 that is standing somewhere you can find metals (enemies with <8 HP) and hasn't found a battle since its last reset.

emu.speedmode("maximum")

metals_found = {0,0,0,0,0,0,0,0,0,0}
total_metals = 0
save_state_slot = 10
blah = 0

--Memory addresses for each character (Find them yourself, if you need more)
HP_Addresses = {
	Panon = 0x6110,
	Ragnar = 0x60B6,
	Hero = 0x6002,
	Alena = 0x60D4,
	Cristo = 0x6020
}

framecounter = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		for i=1,9 do
			gui.text(10,10*i, (i-1)..': '..metals_found[i]..' ('..(math.floor((metals_found[i]/total_metals)*10000)/100)..'%)')
			gui.text(10,100, 'Blah: '..blah..' '..(math.floor((blah/metals_found[2])*10000)/100)..'%')
		end
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
	Wait(math.random(0x0F))
	savestate.save(state)
	
	while (memory.readbyte(0x7279) ~= 0 and memory.readbyte(0x727B) ~= 0 and memory.readbyte(0x727C) ~= 0) do
		for i=0,32 do
			joypad.write(1,{left=true})
			Wait(1)
		end
		for i=0,32 do
			joypad.write(1,{right=true})
			Wait(1)
		end
	end
	
	Wait(5)
	
	ctr = 0
	--blah = 0 --Uncomment these to stop the script when you find a metal
	for i=0,7 do
		if (memory.readbyte(0x727E + (0xe*i)) + (memory.readbyte(0x727F + (0xe*i)) * 256) ~= 0 and
		    memory.readbyte(0x727E + (0xe*i)) + (memory.readbyte(0x727F + (0xe*i)) * 256) < 8) then
			ctr = ctr + 1
			blah = 1
			--if memory.readbyte(0x727E + (0xe*i)) + (memory.readbyte(0x727F + (0xe*i)) * 256) < 4 then
				--blah = blah + 1
			--end
		end
	end
	if blah == 1 then
		break
	end
	metals_found[ctr+1] = metals_found[ctr+1] + 1
	total_metals = total_metals + 1
	
	Wait(1)
end