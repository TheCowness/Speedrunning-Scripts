

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
		
		gui.text(10,90,'Hits: '..wins)
		gui.text(10,100,'Misses: '..losses)
		if(wins + losses ~= 0) then
			gui.text(10,110,'Hit Rate: '..(math.floor(1000 * wins / (wins + losses))/10).."%")
		end
		gui.text(10,120,'Runs: '..runs..' ('..(math.floor(1000 * runs / (wins + losses + runs))/10)..'%)')
		gui.text(10,130,'Sleeps: '..sleeps..' ('..(math.floor(1000 * sleeps / (wins))/10)..'%)')
	end
end

while true do
	state = savestate.object(save_state_slot);
	savestate.load(state);
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF));
	memory.writebyte(0x0013,math.random(0xFF));
	memory.writebyte(0x050D,math.random(0xFF));
	
		
	for i=1,5 do
		Wait(math.random(5)+1);
		joypad.write(1,{A=true});
		Wait(1);
		joypad.write(1,{A=false});
	end
	
	Wait(100)
	
	if memory.readbyte(0x727E) == 3 then
		wins = wins + 1
	elseif memory.readbyte(0x727E) == 4 then
		losses = losses + 1
	else
		runs = runs + 1
	end
	
	--Asleep or paralyzed, respectively
	if memory.readbyte(0x7279) == 1 or memory.readbyte(0x727A) == 0xE0 then
		sleeps = sleeps + 1
	end
		
		
	
	Wait(1)
end
























