--This script will run through the Endor tournament with different stats.
--It requires a save state that has Alena standing one step south of the arena stairs with five herbs at the END of her inventory.
--She should also have 26 agility

emu.speedmode("turbo")

wins = 0
losses = 0
save_state_slot = 1
_status = ''
hp_min = 72
hp_start = hp_min
hp_max = 92
str_min = 46
str_start = str_min
str_max = 48
--hp_min = 252
--hp_max = 254
--str_min = 250
--str_max = 254
trials = 10000
results = {}
_hp = 0
_str = 0
_trial = 0
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
		gui.text(10,20,'HP: '..memory.readbyte(0x60D4)..'/'.._hp)
		gui.text(10,30,'Str: '.._str)
		gui.text(10,40,'Trial: '.._trial..'/'..trials)
		_herbs = 0
		for j = 0,4 do
			if memory.readbyte(0x60E9 + j) == 0x53 then
				_herbs = _herbs + 1
			end
		end
		gui.text(10,50,'Herbs: '.._herbs)
		gui.text(10,60,'Current Score: '..results[_hp][_str][1]..':'..(results[_hp][_str][2]+results[_hp][_str][3]+results[_hp][_str][4]+results[_hp][_str][5]+results[_hp][_str][6]))
		gui.text(120,75,memory.readbyte(0x727E) + memory.readbyte(0x727F) * 256) --Enemy's HP
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
	
	--Set Alena's HP and strength
	memory.writebyte(0x60D4,hp)
	memory.writebyte(0x60DF,hp)
	memory.writebyte(0x60D9,str)
	memory.writebyte(0x60DA,26)
	
	--Set enemy 1 HP to zero so I can track when the first fight starts.
	memory.writebyte(0x727E,0)
	memory.writebyte(0x727F,0)
	
	boss_died_to = 0
	
	_status = 'Entering Arena'
	--Hold Up to enter the arena
	while memory.readbyte(0x45) ~= 0x09 do
		joypad.write(1,{up=true});
		Wait(1);
	end
	joypad.write(1,{up=false});
	
	_status = 'Mashing until Hun'
	--Mash A until Hun's HP registers
	while memory.readbyte(0x727E) == 0 do
		PressA()
		Wait(1)
	end
	
	---------------------------------------------------
	
	_status = 'Fighting Hun'
	_ctr = 0
	while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do --Enemy HP, lower byte of Alena's HP
		while memory.readbyte(0x00) ~= 3 and memory.readbyte(0x01) ~= 14 and (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do
			Wait(1)
			_ctr = _ctr + 1
			if _ctr > 300 then
				PressB()
				_ctr = 0
			end
		end
		for i = 0,20 do
			PressA()
			Wait(1)
		end
	end
	
	if memory.readbyte(0x60D4) == 0 then
		_status = 'Died to Hun (LOL)'
		--Lol you died to Hun, idiot
		boss_died_to = 1
	else
		Wait(20)
		_status = 'Herbing'
		while (memory.readbyte(0x60D4) < (memory.readbyte(0x60DF) - 10) and memory.readbyte(0x60E9) == 0x53) do
			PressA()
			Wait(1)
		end
		_status = 'Waiting for Roric'
		while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 90) do
			PressB()
			Wait(1)
		end
		
		---------------------------------------------------
		
		_status = 'Fighting Roric'
		_ctr = 0
		while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do --Enemy HP, lower byte of Alena's HP
			while memory.readbyte(0x00) ~= 3 and memory.readbyte(0x01) ~= 14 and (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do
				Wait(1)
				_ctr = _ctr + 1
				if _ctr > 300 then
					PressB()
					_ctr = 0
				end
			end
			--If under 30 HP and Roric is over {FoRmUlAiC} HP and you have an herb, use it.
			--I base this on a quick observation that Roric dealt 13-16 damage when I had 27 agility
			if memory.readbyte(0x60D4) <= 30 and memory.readbyte(0x727E) > (str / 2 - 13) and memory.readbyte(0x60E9) == 0x53 then
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressDown()
				Wait(1)
				PressA()
				Wait(10)
				PressA()
				Wait(10)
			else
				for i = 0,20 do
					PressA()
					Wait(1)
				end
			end
		end
		
		if memory.readbyte(0x60D4) == 0 then
			_status = 'Died to Roric'
			boss_died_to = 2
		else
			_status = 'Collecting Herb'
			while (memory.readbyte(0x727E) + memory.readbyte(0x727F) == 0) do
				PressB()
				Wait(1)
			end
			_status = 'Herbing'
			while (memory.readbyte(0x60D4) < (memory.readbyte(0x60DF) - 20) and memory.readbyte(0x60E9) == 0x53) do
				PressA()
				Wait(1)
			end
			_status = 'Waiting for Vivian'
			while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 90) do
				PressB()
				Wait(1)
			end
			
			---------------------------------------------------
			
			_status = 'Fighting Vivian'
			_ctr = 0
			while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do --Enemy HP, lower byte of Alena's HP
				while memory.readbyte(0x00) ~= 3 and memory.readbyte(0x01) ~= 14 and (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do
					Wait(1)
					_ctr = _ctr + 1
					if _ctr > 300 then
						PressB()
						_ctr = 0
					end
				end
				--I don't think I'm going to bother coding parry strats; they don't really save your HP/herbs; just perhaps a little time
				for i = 0,20 do
					PressA()
					Wait(1)
				end
			end
			
			if memory.readbyte(0x60D4) == 0 then
				_status = 'Died to Vivian'
				boss_died_to = 3
			else
				_status = 'Collecting Herb'
				while (memory.readbyte(0x727E) + memory.readbyte(0x727F) == 0) do
					PressB()
					Wait(1)
				end
				_status = 'Herbing'
				while (memory.readbyte(0x60D4) < (memory.readbyte(0x60DF) - 10) and memory.readbyte(0x60E9) == 0x53) do
					PressA()
					Wait(1)
				end
				_status = 'Waiting for Sampson'
				while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 90) do
					PressB()
					Wait(1)
				end
				
				---------------------------------------------------
				
				_status = 'Fighting Sampson'
				_ctr = 0
				while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do --Enemy HP, lower byte of Alena's HP
					while memory.readbyte(0x00) ~= 3 and memory.readbyte(0x01) ~= 14 and (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do
						Wait(1)
						_ctr = _ctr + 1
						if _ctr > 300 then
							PressB()
							_ctr = 0
						end
					end
					--If under 20 HP and Sampson is over {FoRmUlAiC} HP and you have an herb, use it.
					--Also, if missing 30+ HP and Sampson is under 45, and you have an herb, use it.
					--Alena's faster than Sampson, so assume she'll go first.
					if ((memory.readbyte(0x60D4) <= 20 and memory.readbyte(0x727E) > (str / 2 - 8)) or (memory.readbyte(0x60D4) <= (memory.readbyte(0x60DF) - 30) and memory.readbyte(0x727E) > 45)) and memory.readbyte(0x60E9) == 0x53 then
						PressDown()
						Wait(1)
						PressDown()
						Wait(1)
						PressDown()
						Wait(1)
						PressA()
						Wait(10)
						PressDown()
						Wait(1)
						PressDown()
						Wait(1)
						PressDown()
						Wait(1)
						PressA()
						Wait(10)
						PressA()
						Wait(10)
					else
						for i = 0,20 do
							PressA()
							Wait(1)
						end
					end
				end
				
				if memory.readbyte(0x60D4) == 0 then
					_status = 'Died to Sampson'
					boss_died_to = 4
				else
					_status = 'Collecting Herb'
					while (memory.readbyte(0x727E) + memory.readbyte(0x727F) == 0) do
						PressB()
						Wait(1)
					end
					_status = 'Herbing'
					while (memory.readbyte(0x60D4) < (memory.readbyte(0x60DF) - 20) and memory.readbyte(0x60E9) == 0x53) do
						PressA()
						Wait(1)
					end
					_status = 'Waiting for Linguar'
					while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 55) do
						PressB()
						Wait(1)
					end
					
					---------------------------------------------------
					
					_status = 'Fighting Linguar'
					_ctr = 0
					--Mash B until Linguar is done splitting
					while memory.readbyte(0x728C) == 0 do
						PressB()
						Wait(1)
					end
					Wait(60)
					--Until any Linguars hit zero HP, their MP stops being 255, or Alena's HP hits zero
					while (memory.readbyte(0x727E) ~= 0 and memory.readbyte(0x728C) ~= 0 and memory.readbyte(0x729A) ~= 0 and memory.readbyte(0x72A8) ~= 0 and memory.readbyte(0x7280) == 0xFF and memory.readbyte(0x728E) == 0xFF and memory.readbyte(0x729C) == 0xFF and memory.readbyte(0x72AA) == 0xFF) and memory.readbyte(0x60D4) ~= 0 do
						while memory.readbyte(0x00) ~= 3 and memory.readbyte(0x01) ~= 14 and (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and memory.readbyte(0x60D4) ~= 0 do
						_status = 'Fighting Linguar - Waiting for prompt'
							Wait(1)
							_ctr = _ctr + 1
							if _ctr > 300 then
								PressB()
								_ctr = 0
							end
						end
						_status = 'Fighting Linguar - Inputting...'
						Wait(180)
						if memory.readbyte(0x60D4) <= (memory.readbyte(0x60DF) - 40) and memory.readbyte(0x60E9) == 0x53 then
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressA()
							Wait(20)
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressA()
							Wait(10)
							PressA()
							Wait(60)
						--727A = C8 when A powers up; 7288, 7296, 72A4 for B-D.
						--If Alena can take the hit and Linguar B is powering up, OR if she CAN'T take hit and A is powering up, hit B
						elseif (memory.readbyte(0x60D4) > (memory.readbyte(0x60DF) - 40) and (memory.readbyte(0x7288) == 0xC8 or memory.readbyte(0x7288) == 0xCC)) or (memory.readbyte(0x60D4) <= (memory.readbyte(0x60DF) - 40) and memory.readbyte(0x727A) == 0xC8 or memory.readbyte(0x727A) == 0xCC) then
							PressA()
							Wait(20)
							PressDown()
							Wait(1)
							PressA()
							Wait(60)
						--If Alena can take the hit and Linguar C is powering up, hit C
						elseif memory.readbyte(0x60D4) > (memory.readbyte(0x60DF) - 40) and (memory.readbyte(0x7296) == 0xC8 or memory.readbyte(0x7296) == 0xCC) then
							PressA()
							Wait(20)
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressA()
							Wait(60)
						--If Alena can take the hit and Linguar D is powering up, hit D
						elseif memory.readbyte(0x60D4) > (memory.readbyte(0x60DF) - 40) and (memory.readbyte(0x72A4) == 0xC8 or memory.readbyte(0x72A4) == 0xCC) then
							PressA()
							Wait(20)
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressDown()
							Wait(1)
							PressA()
							Wait(60)
						else --Else, ALWAYS A
							for i = 0,30 do
								PressA()
								Wait(1)
							end
							Wait(30)
						end
					end
					
					if memory.readbyte(0x60D4) == 0 then
						_status = 'Died to Linguar'
						boss_died_to = 5
					end
				end
			end
		end
	end
	
	results[hp][str][boss_died_to+1] = results[hp][str][boss_died_to+1] + 1
	
	if trial == trials then
		outfile = io.open("DW4TournamentStats.csv","a+")
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