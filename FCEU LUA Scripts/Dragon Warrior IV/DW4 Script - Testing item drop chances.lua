--Giant Bantam: 300/10000 (3.00%)		(1/32?)
--Lilypa: 150/10300 (1.45%)				(1/64?)
--Mad Clown: 83/18650 (0.44%)			(1/128?)
--Armor Scorpion: 27/7650 (0.35%)		(1/256?)

--To run this script, get a Save State in slot 1 that is standing somewhere you can find metals (enemies with <8 HP) and hasn't found a battle since its last reset.

emu.speedmode("maximum")

save_state_slot = 1
framecounter = 0
items_found = 0
items_not_found = 0


function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10, 'Drops: '..items_found)
		gui.text(10,20, 'Kills: '..(items_found + items_not_found))
		gui.text(10,30, 'Rate: '..(math.floor(items_found * 10000 / (items_found + items_not_found))/100)..'%')
		framecounter = framecounter + 1
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
	framecounter = 0
	
	--Hero's EXP
	while memory.readbyte(0x6011) == 0x78 do
		joypad.write(1,{A=true})
		Wait(1)
	end
	framecounter = 0
	while framecounter ~= 240 do
		joypad.write(1,{A=true})
		Wait(1)
	end
	
	if memory.readbyte(0x601B) ~= 0xFF then
		items_found = items_found + 1
	else
		items_not_found = items_not_found + 1
	end
	
	Wait(1)
end