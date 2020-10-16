--This script will run through the first two rounds of Necrosaro with different stats to see if Cristo casts Increase or not.

--Important memory addresses:
--Current HP Lower, Current HP Higher, Current MP Lower, Current MP Higher, Level, Str, Agi, Vit, Int, Luck, ???, Max HP Lower, Max HP Upper, Max MP Lower, Max MP Upper, 
--0x60B6 Ragnar
--0x60D4 Alena
--0x6002 Hero
--0x6020 Cristo

__Ragnar = 0x60B6
__Alena  = 0x60D4
__Hero   = 0x6002
__Cristo = 0x6020

__hp1 = 0x0
__hp2 = 0x1
__mp1 = 0x2
__mp2 = 0x3
__str = 0x5
__agi = 0x6
__vit = 0x7
__int = 0x8
__lck = 0x9
__maxhp1 = 0xB
__maxhp2 = 0xC
__maxmp1 = 0xD
__maxmp2 = 0xE

__RagnarDefense = 0x7213
__AlenaDefense  = 0x721D
__HeroDefense   = 0x7227
__CristoDefense = 0x7231

__Tactic = 0x615B
-- 0 Normal
-- 1 Save MP
-- 2 Offensive
-- 3 Defensive
-- 4 Try Out
-- 5 Use No MP

--Defense values of the armor these characters have equipped
__RagnarArmor = 45
__AlenaArmor  = 36
__HeroArmor   = 70
__CristoArmor = 38

emu.speedmode("turbo")

save_state_slot = 1
_status = ''
trials = 10
trial = 0
__increases = 0
__uppers = 0

input_array = {}
input_file = io.open("DW4NecrosaroStats_In.csv","r")
io.input(input_file)
ctr = 0
input_line = io.read() --First line is headers
input_line = io.read()
while input_line ~= '' and input_line ~= nil do
	ctr = ctr + 1
	input_array[ctr] = {}
	ctr2 = 0
	--io.write('LINE\n')
	--io.write(input_line..'\n')
	for i in string.gmatch(input_line, '[^,%s]+') do
		if i ~= nil then
			ctr2 = ctr2 + 1
			input_array[ctr][ctr2] = i
			--io.write(i..'\n')
		end
	end
	input_line = io.read()
end
io.close(input_file)

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'Status: '.._status)
		gui.text(10,20,'Trial: '..trial..'/'..trials)
		gui.text(10,30,'Input Line: '..(ctr+1))
		gui.text(127,80,memory.readbyte(0x727E) + memory.readbyte(0x727F) * 256) --Enemy's HP
		gui.text(40,60, memory.readbyte(0x7213) + memory.readbyte(0x7214) * 256) --Ragnar Armor
		gui.text(80,60, memory.readbyte(0x721D) + memory.readbyte(0x721E) * 256) --Alena Armor
		gui.text(120,60,memory.readbyte(0x7227) + memory.readbyte(0x7228) * 256) --Hero Armor
		gui.text(160,60,memory.readbyte(0x7231) + memory.readbyte(0x7232) * 256) --Cristo Armor
		gui.text(10,40,'Increases: '..__increases)
		gui.text(10,50,'Uppers: '..__uppers)
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

ctr = 1
while input_array[ctr] ~= nil do
	__RagnarDefense_RatioTotal = 0
	__AlenaDefense_RatioTotal  = 0
	__HeroDefense_RatioTotal   = 0
	__CristoDefense_RatioTotal = 0
	__increases = 0
	__uppers = 0
	for trial = 1,trials do
		_status = 'Initializing...'
		
		state = savestate.object(save_state_slot)
		savestate.load(state)
		
		Wait(math.random(0x03)+5)
		savestate.save(state)
		savestate.persist(state)
		--Throw random values into the random RNG seed (two bytes) and the counter
		--memory.writebyte(0x0012,math.random(0xFF))
		--memory.writebyte(0x0013,math.random(0xFF))
		--memory.writebyte(0x050D,math.random(0xFF))
		
		--Modify character stats based on input file
		memory.writebyte(__Ragnar + __hp1,(input_array[ctr][1]) % 256)
		memory.writebyte(__Ragnar + __hp2,math.floor((input_array[ctr][1]) / 256))
		memory.writebyte(__Ragnar + __mp1,input_array[ctr][2] % 256)
		memory.writebyte(__Ragnar + __mp2,math.floor(input_array[ctr][2] / 256))
		memory.writebyte(__Ragnar + __maxhp1,input_array[ctr][1] % 256)
		memory.writebyte(__Ragnar + __maxhp2,math.floor(input_array[ctr][1] / 256))
		memory.writebyte(__Ragnar + __maxmp1,input_array[ctr][2] % 256)
		memory.writebyte(__Ragnar + __maxmp2,math.floor(input_array[ctr][2] / 256))
		memory.writebyte(__Ragnar + __str,input_array[ctr][3] % 256)
		memory.writebyte(__Ragnar + __agi,input_array[ctr][4] % 256)
		memory.writebyte(__Ragnar + __vit,input_array[ctr][5] % 256)
		memory.writebyte(__Ragnar + __int,input_array[ctr][6] % 256)
		memory.writebyte(__Ragnar + __lck,input_array[ctr][7] % 256)
		
		memory.writebyte(__Alena + __hp1,(input_array[ctr][8]) % 256)
		memory.writebyte(__Alena + __hp2,math.floor((input_array[ctr][8]) / 256))
		memory.writebyte(__Alena  + __mp1,input_array[ctr][9] % 256)
		memory.writebyte(__Alena  + __mp2,math.floor(input_array[ctr][9] / 256))
		memory.writebyte(__Alena  + __maxhp1,input_array[ctr][8] % 256)
		memory.writebyte(__Alena  + __maxhp2,math.floor(input_array[ctr][8] / 256))
		memory.writebyte(__Alena  + __maxmp1,input_array[ctr][9] % 256)
		memory.writebyte(__Alena  + __maxmp2,math.floor(input_array[ctr][9] / 256))
		memory.writebyte(__Alena  + __str,input_array[ctr][10] % 256)
		memory.writebyte(__Alena  + __agi,input_array[ctr][11] % 256)
		memory.writebyte(__Alena  + __vit,input_array[ctr][12] % 256)
		memory.writebyte(__Alena  + __int,input_array[ctr][13] % 256)
		memory.writebyte(__Alena  + __lck,input_array[ctr][14] % 256)
		
		memory.writebyte(__Hero + __hp1,(input_array[ctr][15]) % 256)
		memory.writebyte(__Hero + __hp2,math.floor((input_array[ctr][15]) / 256))
		memory.writebyte(__Hero   + __mp1,input_array[ctr][16] % 256)
		memory.writebyte(__Hero   + __mp2,math.floor(input_array[ctr][16] / 256))
		memory.writebyte(__Hero   + __maxhp1,input_array[ctr][15] % 256)
		memory.writebyte(__Hero   + __maxhp2,math.floor(input_array[ctr][15] / 256))
		memory.writebyte(__Hero   + __maxmp1,input_array[ctr][16] % 256)
		memory.writebyte(__Hero   + __maxmp2,math.floor(input_array[ctr][16] / 256))
		memory.writebyte(__Hero   + __str,input_array[ctr][17] % 256)
		memory.writebyte(__Hero   + __agi,input_array[ctr][18] % 256)
		memory.writebyte(__Hero   + __vit,input_array[ctr][19] % 256)
		memory.writebyte(__Hero   + __int,input_array[ctr][20] % 256)
		memory.writebyte(__Hero   + __lck,input_array[ctr][21] % 256)
		
		memory.writebyte(__Cristo + __hp1,(input_array[ctr][22]) % 256)
		memory.writebyte(__Cristo + __hp2,math.floor((input_array[ctr][22]) / 256))
		memory.writebyte(__Cristo + __mp1,input_array[ctr][23] % 256)
		memory.writebyte(__Cristo + __mp2,math.floor(input_array[ctr][23] / 256))
		memory.writebyte(__Cristo + __maxhp1,input_array[ctr][22] % 256)
		memory.writebyte(__Cristo + __maxhp2,math.floor(input_array[ctr][22] / 256))
		memory.writebyte(__Cristo + __maxmp1,input_array[ctr][23] % 256)
		memory.writebyte(__Cristo + __maxmp2,math.floor(input_array[ctr][23] / 256))
		memory.writebyte(__Cristo + __str,input_array[ctr][24] % 256)
		memory.writebyte(__Cristo + __agi,input_array[ctr][25] % 256)
		memory.writebyte(__Cristo + __vit,input_array[ctr][26] % 256)
		memory.writebyte(__Cristo + __int,input_array[ctr][27] % 256)
		memory.writebyte(__Cristo + __lck,input_array[ctr][28] % 256)
		
		memory.writebyte(__Tactic,input_array[ctr][29] % 256)
		
		--Set enemy 1 HP to zero so I can track when the first fight starts.
		memory.writebyte(0x727E,0)
		memory.writebyte(0x727F,0)
		
		boss_died_to = 0
		
		_status = 'Mashing until Necrosaro'
		--Mash A until Necrosaro's HP registers
		while memory.readbyte(0x727E) == 0 do
			PressA()
			Wait(1)
		end
		
		Wait(math.random(60)+180)
		--Put Fendspell on Necrosaro
		memory.writebyte(0x7279,0x80)
		
		---------------------------------------------------
		
		__RagnarDefense_Start = memory.readbyte(0x7213) + memory.readbyte(0x7214) * 256
		__AlenaDefense_Start  = memory.readbyte(0x721D) + memory.readbyte(0x721E) * 256
		__HeroDefense_Start   = memory.readbyte(0x7227) + memory.readbyte(0x7228) * 256
		__CristoDefense_Start = memory.readbyte(0x7231) + memory.readbyte(0x7232) * 256
		
		_status = 'Fighting Necrosaro'
		while memory.readbyte(0x6E81) < 2 do
			PressA()
			Wait(1)
			memory.writebyte(__Ragnar + __hp1, memory.readbyte(__Ragnar + __maxhp1))
			memory.writebyte(__Ragnar + __hp2, memory.readbyte(__Ragnar + __maxhp2))
			memory.writebyte(__Alena  + __hp1, memory.readbyte(__Alena  + __maxhp1))
			memory.writebyte(__Alena  + __hp2, memory.readbyte(__Alena  + __maxhp2))
			memory.writebyte(__Hero   + __hp1, memory.readbyte(__Hero   + __maxhp1))
			memory.writebyte(__Hero   + __hp2, memory.readbyte(__Hero   + __maxhp2))
			memory.writebyte(__Cristo + __hp1, memory.readbyte(__Cristo + __maxhp1))
			memory.writebyte(__Cristo + __hp2, memory.readbyte(__Cristo + __maxhp2))
			memory.writebyte(__Ragnar + __hp1,(input_array[ctr][1]/2) % 256)
			memory.writebyte(__Ragnar + __hp2,math.floor((input_array[ctr][1] / 2) / 256))
			--memory.writebyte(__Alena + __hp1,(input_array[ctr][8]/2) % 256)
			--memory.writebyte(__Alena + __hp2,math.floor((input_array[ctr][8] / 2) / 256))
			--memory.writebyte(__Hero + __hp1,(input_array[ctr][15]/2) % 256)
			--memory.writebyte(__Hero + __hp2,math.floor((input_array[ctr][15] / 2) / 256))
			--memory.writebyte(__Cristo + __hp1,(input_array[ctr][22]/2) % 256)
			--memory.writebyte(__Cristo + __hp2,math.floor((input_array[ctr][22] / 2) / 256))
		end
		
		__RagnarDefense_End = memory.readbyte(0x7213) + memory.readbyte(0x7214) * 256
		__AlenaDefense_End  = memory.readbyte(0x721D) + memory.readbyte(0x721E) * 256
		__HeroDefense_End   = memory.readbyte(0x7227) + memory.readbyte(0x7228) * 256
		__CristoDefense_End = memory.readbyte(0x7231) + memory.readbyte(0x7232) * 256
		
		__RagnarDefense_Ratio = __RagnarDefense_End / __RagnarDefense_Start
		__AlenaDefense_Ratio  = __AlenaDefense_End  / __AlenaDefense_Start
		__HeroDefense_Ratio   = __HeroDefense_End   / __HeroDefense_Start
		__CristoDefense_Ratio = __CristoDefense_End / __CristoDefense_Start
		
		--Check ratios to determine how many Increases and how many Uppers were cast
		--Record somehow?  What is my goal here?
		--Increase adds 100% of your base defense, Upper adds 150%.
		if __RagnarDefense_Ratio > 1 and __AlenaDefense_Ratio > 1 and __HeroDefense_Ratio > 1 and __CristoDefense_Ratio > 1 then
			if __RagnarDefense_Ratio == 3 then
				__increases = __increases + 2
			else
				__increases = __increases + 1
				if __RagnarDefense_Ratio > 3 or __AlenaDefense_Ratio > 3 or __HeroDefense_Ratio > 3 or __CristoDefense_Ratio > 3 then
					__uppers = __uppers + 1
				end
			end
		else
			if __RagnarDefense_Ratio + __AlenaDefense_Ratio + __HeroDefense_Ratio + __CristoDefense_Ratio > 6 then
				__uppers = __uppers + 2
			elseif __RagnarDefense_Ratio + __AlenaDefense_Ratio + __HeroDefense_Ratio + __CristoDefense_Ratio > 4 then
				__uppers = __uppers + 1
			end
		end
		__RagnarDefense_RatioTotal = __RagnarDefense_RatioTotal + math.floor(__RagnarDefense_Ratio * 10)/10
		__AlenaDefense_RatioTotal  = __AlenaDefense_RatioTotal  + math.floor(__AlenaDefense_Ratio  * 10)/10
		__HeroDefense_RatioTotal   = __HeroDefense_RatioTotal   + math.floor(__HeroDefense_Ratio   * 10)/10
		__CristoDefense_RatioTotal = __CristoDefense_RatioTotal + math.floor(__CristoDefense_Ratio * 10)/10
	end
	output_file = io.open("DW4NecrosaroStats_Out.csv","a+")
	io.output(output_file)
	io.write(__uppers..','..__increases..','..__RagnarDefense_RatioTotal..','..__AlenaDefense_RatioTotal..','..__HeroDefense_RatioTotal..','..__CristoDefense_RatioTotal..'\n')
	io.close(output_file)
	ctr = ctr + 1
end

while true do
	Wait(1)
end