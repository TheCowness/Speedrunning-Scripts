--To run this script, get a Save State in slot 1 that has someone ready to cast Vivify on Ragnar

emu.speedmode("maximum")

wins = 0
losses = 0
save_state_slot = 1

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
		gui.text(10,90,'Revivals: '..wins)
		gui.text(10,100,'Failures: '..losses)
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
	
	--Press A a few times
	for i=1,5 do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(math.random(5)+1)
	end
	
	--Wait three seconds
	Wait(180)
	
	--Check Ragnar's HP and see if he revived
	lifecount = 0
	if(memory.readbyte(HP_Addresses["Ragnar"]) ~= 0) then
		lifecount = lifecount + 1
	end
	
	
	Wait(1)
	
	if lifecount == 0 then
		losses = losses + 1
	else
		wins = wins + 1
	end
	
	Wait(1)
end