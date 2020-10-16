--To run this script, get a Save State in slot 1 that is standing somewhere you can find metals (enemies with <8 HP) and hasn't found a battle since its last reset.

--emu.speedmode("maximum")

save_state_slot = 1
frames_before_turn = 0

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
		gui.text(10,10, 'Frames Before Turn: '..frames_before_turn)
	end
end

while true do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	--Throw random values into the random RNG seed (two bytes) and the counter and the thing next to the counter
	--memory.writebyte(0x0012,math.random(0xFF))
	--memory.writebyte(0x0013,math.random(0xFF))
	--memory.writebyte(0x050D,math.random(0xFF))
	--memory.writebyte(0x050C,math.random(0xFF))
	--Wait(math.random(0x0F))
	--savestate.save(state)
	
	for i=0,frames_before_turn do
		joypad.write(1,{right=true})
		Wait(1)
	end
	for i=0,64 do
		joypad.write(1,{right=true})
		joypad.write(1,{up=true})
		Wait(1)
	end
	
	Wait(120)
	
	frames_before_turn = frames_before_turn + 1
	
	Wait(1)
end