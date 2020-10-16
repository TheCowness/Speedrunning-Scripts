--This script will run through the Endor tournament with different stats.
--It requires a save state that has Alena standing one step south of the arena stairs with five herbs at the END of her inventory.
--She should also have 26 agility

emu.speedmode("turbo")

wins = 0
losses = 0
save_state_slot = 1
_status = ''
hp_min = 40
hp_start = hp_min
hp_max = 64 --56 HP is high for level 6, 64 is high for level 7
str_min = 18
str_start = str_min
str_max = 26 --22 str is high for level 6, 26 is high for level 7
--hp_min = 252
--hp_max = 254
--str_min = 250
--str_max = 254
trials = 1000
results = {}
_hp = 0
_str = 0
_trial = 0
_herbs = 0
_a_and_pray = 0 --Set to 1 to disable logic and just ATTACK
for hp = hp_min,hp_max do
	if hp % 2 == 0 then
		results[hp] = {}
		for str = str_min,str_max do
			if str % 2 == 0 then
				results[hp][str] = {}
				for i = 1,6 do
					results[hp][str][i] = 0
				end
			end
		end
	end
end

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'Status: '.._status) --Enemy's HP
		gui.text(10,20,'HP: '..memory.readbyte(0x60B6)..'/'.._hp)
		gui.text(10,30,'Str: '.._str)
		gui.text(10,40,'Trial: '.._trial..'/'..trials)
		_herbs = 0
		for j = 0,7 do
			if memory.readbyte(0x60C8 + j) == 0x53 then
				_herbs = _herbs + 1
			end
		end
		gui.text(10,50,'Herbs: '.._herbs)
		gui.text(10,60,'Current Score: '..results[_hp][_str][1]..':'..(results[_hp][_str][2]+results[_hp][_str][3]+results[_hp][_str][4]+results[_hp][_str][5]+results[_hp][_str][6]))
		gui.text(100,85,memory.readbyte(0x727E) + memory.readbyte(0x727F) * 256)
		gui.text(145,85,memory.readbyte(0x728C) + memory.readbyte(0x728D) * 256)
		if (memory.readbyte(0x728C) <= 11 and memory.readbyte(0x728C) ~= 0) then
			gui.text(145,100,">:(");
		end;
	end
end

function PressA()
	joypad.write(1,{A=true});
	Wait(1);
	joypad.write(1,{A=false});
end
function PressB()
	joypad.write(1,{B=true});
	Wait(1);
	joypad.write(1,{B=false});
end
function PressDown()
	joypad.write(1,{down=true});
	Wait(1);
	joypad.write(1,{down=false});
end
function PressUp()
	joypad.write(1,{up=true});
	Wait(1);
	joypad.write(1,{up=false});
end

for hp = hp_min,hp_max do
	if hp % 4 == 0 then
		for str = str_min,str_max do
			if str % 2 == 0 then
				if hp >= hp_start and (hp > hp_start or str >= str_start) then
					for trial = 1,trials do
	_hp = hp
	_str = str
	_trial = trial
	_status = 'Initializing...'
	_ctr = 0
	
	state = savestate.object(save_state_slot)
	savestate.load(state)
	Wait(math.random(0x03)+5)
	savestate.save(state)
	savestate.persist(state)
	--Throw random values into the random RNG seed (two bytes) and the counter
	--memory.writebyte(0x0012,math.random(0xFF))
	--memory.writebyte(0x0013,math.random(0xFF))
	--memory.writebyte(0x050D,math.random(0xFF))
	
	--Set Ragnar's HP and strength
	memory.writebyte(0x60B6,hp)
	memory.writebyte(0x60C1,hp) --max
	memory.writebyte(0x60BB,str)
	memory.writebyte(0x60BC,7) --agi
	
	--Set enemy 1 HP to zero so I can track when the first fight starts.
	memory.writebyte(0x727E,0)
	memory.writebyte(0x727F,0)
	
	boss_died_to = 0
	
	_status = 'Mashing until Shadow'
	--Mash A until Shadow's HP registers
	while memory.readbyte(0x727E) == 0 do
		PressA()
		Wait(1)
	end
	
	---------------------------------------------------
	
	_status = 'Fighting Shadow'
	_ctr = 0
	while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60B6) ~= 0 do --Enemy HP, lower byte of Alena's HP
		while memory.readbyte(0x00) ~= 3 and memory.readbyte(0x01) ~= 14 and (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60B6) ~= 0 do
			Wait(1)
			_ctr = _ctr + 1
			if _ctr > 300 then
				PressB()
				_ctr = 0
			end
		end
		if memory.readbyte(0x728C) + memory.readbyte(0x728D) ~= 0 then
			_status = 'Eyeball is still alive'
			PressA()
			Wait(6)
			PressDown()
			Wait(1)
			PressA()
			Wait(10)
		else
			--Shadow only
			if
				_a_and_pray == 0 and
				_herbs >= 1 and
				memory.readbyte(0x6112) >= 3 and  --Healie has MP
				memory.readbyte(0x6110) >= 17 and --Healie too high to get healed
				memory.readbyte(0x6110) <= 23     --Healie low enough to get owned
			then
				_status = 'Herbing Healie'
				--Menu to Item
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
				--Menu to next page
				PressUp()
				Wait(1)
				PressA()
				Wait(10)
				--Menu to Herb (Item 5) (Pressing down an extra time just because)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
				--Menu to Healie
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
			elseif
				_a_and_pray == 0 and
				_herbs >= 1 and
				(memory.readbyte(0x6112) < 3 or --Healie has no MP
				memory.readbyte(0x6110) == 0) and --OR Healie is dead as hell
				memory.readbyte(0x60B6) <= 20 --Ragman low enough to get owned
			then
				_status = 'Herbing the Ragman'
				--Menu to Item
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
				--Menu to next page
				PressUp()
				Wait(1)
				PressA()
				Wait(10)
				--Menu to Herb (Item 5) (Pressing down an extra time just because)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
				--Menu to RAGNAR
				PressA()
				Wait(10)
			elseif
				_a_and_pray == 0 and
				memory.readbyte(0x6112) >= 3 and --Healie has MP
				memory.readbyte(0x6110) > 0 and --Healie is alive
				memory.readbyte(0x60B6) <= 18 and
				memory.readbyte(0x60B6) <= 0.4 * memory.readbyte(0x60C1)
			then
				_status = 'Parrying'
				--If Healie has MP and Ragnar is low on health, parry.
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(1)
			else
				_status = 'Gettum'
				for i = 0,20 do
					PressA()
					Wait(1)
				end
			end
		end
	end
	
	if memory.readbyte(0x60B6) == 0 then
		if memory.readbyte(0x728C) + memory.readbyte(0x728D) ~= 0 then
			_status = 'Died to Eyeball (Healie pls)'
			boss_died_to = 1
		else
			if memory.readbyte(0x727E) + memory.readbyte(0x727F) * 256 >= 60 then
				_status = 'Died to Shadow'
				boss_died_to = 2
			else
				_status = 'Died to Shadow but it was close!'
				boss_died_to = 3
			end
		end
	end
	
	results[hp][str][boss_died_to+1] = results[hp][str][boss_died_to+1] + 1
	
	if trial == trials then
		outfile = io.open("DW4ShadowStats.csv","a+")
		io.output(outfile)
		io.write(hp..","..str..","..results[hp][str][1]..","..results[hp][str][2]..","..results[hp][str][3]..","..results[hp][str][4]..","..results[hp][str][5]..","..results[hp][str][6]..'\n')
		io.close(outfile)
	end
	
	Wait(1)
					end
				end
			end
		end
	end
end

while true do
	Wait(1)
end