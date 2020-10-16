--Script results:
--Alena 6, Cristo 6, Brey 5, Metal Slime 4 HP: 99/1000 wins (9.9%)
--Alena 6, Cristo 6, Brey 5, Metal Slime 4 HP, Brey w/ Venomous Dagger: 130/1000 wins (13%)

emu.speedmode("maximum");

wins = 0
losses = 0
runs = 0 -- actually runs + crits but whatever
sleeps = 0
save_state_slot = 10

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(120,75,memory.readbyte(0x727E) + memory.readbyte(0x727F) * 256)
		
		gui.text(10,90,'Wins: '..wins)
		gui.text(10,100,'Losses: '..losses)
		gui.text(10,110,'Total: '..(wins+losses))
		if(wins + losses ~= 0) then
			gui.text(10,120,'Win Rate: '..(math.floor(1000 * wins / (wins + losses))/10).."%")
		end
	end
end

while wins + losses < 1000 do
	state = savestate.object(save_state_slot);
	savestate.load(state);
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF));
	memory.writebyte(0x0013,math.random(0xFF));
	memory.writebyte(0x050D,math.random(0xFF));
	Wait(10)
	savestate.save(state)
	savestate.persist(state)
	
	while memory.readbyte(0x727E) ~= 0 do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(1)
	end
	
	--Check for Alena's EXP changing
	_exp = memory.readbyte(0x60E3)
	for i = 0,150 do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(1)
	end
	if _exp ~= memory.readbyte(0x60E3) then
		wins = wins + 1
	else
		losses = losses + 1
	end
	
	Wait(1)
end

while true do
	Wait(1)
end






















