--This script begins with a save state awaiting battle input for a character whose second combat option is Run.
--It will attempt to run from the fight until success (or death?) and record the number of frames it takes to run.

--Original Results:
--PARTY			ENEMIES				Frames/Run		NOTES						Run Failures (/1000)
--Tal/Stro/Laur	Elefrover x2		301.1			Turbo A and down, MS 1		513	241	179	67
--Tal/Stro/Laur	Elefrover x2		253.8			Turbo A and down, MS 8		523	250	160	67
--Tal/Stro/Laur	Elefrover x2		315.6			6 Hz mashing, MS 1			529	225	175	71
--Tal/Stro/Laur	Elefrover x2		317.4			6 Hz mashing, MS 8			510	227	194	69
--Hero 9/Tal 99	Flamer x3			638.7			Turbo A and down, MS 1		512	247	177	64
--Hero 9/Tal 99	Flamer x3			644.0			Turbo A and down, MS 8		493	258	193	56
--Hero 9/Tal 99	Flamer x3			631.9			6 Hz mashing, MS 1			508	257	176	59
--Hero 9/Tal 99	Flamer x3			615.8			6 Hz mashing, MS 8			514	249	188	49
--Ragnar		Giant Worm x2		290.5			Turbo A and down, MS 1		499	255	176	70
--Ragnar		Giant Worm x2		246.6			Turbo A and down, MS 8		472	271	183	74
--Ragnar		Giant Worm x2		314.9			6 Hz mashing, MS 1			505	235	199	61
--Ragnar		Giant Worm x2		290.4			6 Hz mashing, MS 8			477	282	174	67

--Second trial - track frames for run counts separately:
--PARTY			ENEMIES				Frames/Run							NOTES
--Ragnar		Giant Worm x2		  95.3	 324.2	 546.9	 778.0		Turbo A and down, MS 1
--Ragnar		Giant Worm x2		  84.0	 264.2	 440.1	 629.5		Turbo A and down, MS 8
--Ragnar		Giant Worm x2		 110.3	 350.8	 584.4	 830.8		6 Hz mashing, MS 1
--Ragnar		Giant Worm x2		 100.0	 313.2	 528.0	 749.3		6 Hz mashing, MS 8
--Hero 9/Tal 99	Flamer x3			 100.1	 692.4	1283.7	1874.6		Turbo A and down, MS 1
--Hero 9/Tal 99	Flamer x3			  87.9	 644.1	1193.5	1773.7		Turbo A and down, MS 8
--Hero 9/Tal 99	Flamer x3			 131.4	 760.5	1385.6	2038.0		6 Hz mashing, MS 1
--Hero 9/Tal 99	Flamer x3			 119.6	 743.5	1381.3	2030.4		6 Hz mashing, MS 8
--Final Party	Duke x2, Guardian	  93.5	1003.8	1867.0	2612.8		Turbo A and down, MS 1, the Guardian might've wiped the team lul
--Final Party	Duke x2, Guardian	  83.2	 937.4	1762.0	2369.9		Turbo A and down, MS 8, the Guardian might've wiped the team lul
--Final Party	Duke x2, Guardian	 121.6	1039.6	1909.1	2710.1		6 Hz mashing, MS 1, the Guardian might've wiped the team lul
--Final Party	Duke x2, Guardian	 120.0	1090.1	1982.7	2705.8		6 Hz mashing, MS 8, the Guardian might've wiped the team lul

emu.speedmode("turbo")

wins = 0
losses = 0
fails = 0
failarray = {0,0,0,0}
framearray = {0,0,0,0}
save_state_slot = 7
wins_needed = 1000

mashing_frequency = 1 --Wait this many frames after releasing A before pressing it again.  Use 1 or 9 for 30hz turbo or 6hz respectively.
chapter = 5

run_y = 0x16
menu_a = 0x52
menu_b = 0xb0
if chapter == 5 then
	run_y = 0x1A
	menu_a = 0x4f
	menu_b = 0xb1
end

framecounter = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'Frames: '..framecounter)
		gui.text(10,20,'Frames: '..framearray[1]..' '..framearray[2]..' '..framearray[3]..' '..framearray[4])
		gui.text(10,30,'Runs: '..wins)
		gui.text(10,40,'Run Failures: '..failarray[1]..' '..failarray[2]..' '..failarray[3]..' '..failarray[4])
		gui.text(10,50,'Frames/Run: '..(math.floor(framearray[1] / failarray[1] * 10)/10)..' '..
									(math.floor(framearray[2] / failarray[2] * 10)/10)..' '..
									(math.floor(framearray[3] / failarray[3] * 10)/10)..' '..
									(math.floor(framearray[4] / failarray[4] * 10)/10))
		if wins < wins_needed then
			framecounter = framecounter + 1
		end
	end
end

while wins < wins_needed do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF))
	memory.writebyte(0x0013,math.random(0xFF))
	memory.writebyte(0x050D,math.random(0xFF))
	Wait(10)
	savestate.save(state)
	savestate.persist(state)
	
	LeadMonsterHP = memory.readbyte(0x727E) + memory.readbyte(0x727F)
	
	monsterlifecount = 1
	fails = 0
	framecounter = 0
	while LeadMonsterHP == memory.readbyte(0x727E) + memory.readbyte(0x727F) do
		
		while memory.readbyte(0x0001) < run_y and LeadMonsterHP == memory.readbyte(0x727E) + memory.readbyte(0x727F) do
			joypad.write(1,{down=true})
			Wait(1)
			joypad.write(1,{down=false})
			Wait(mashing_frequency)
		end
		
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(mashing_frequency)
		
		while memory.readbyte(0x000a) ~= menu_a and memory.readbyte(0x000b) ~= menu_b and LeadMonsterHP == memory.readbyte(0x727E) + memory.readbyte(0x727F) do
			joypad.write(1,{A=true})
			Wait(1)
			joypad.write(1,{A=false})
			Wait(mashing_frequency)
		end
		
		fails = fails + 1
		
		Wait(10)
	end
	
	wins = wins + 1
	failarray[fails] = failarray[fails] + 1
	framearray[fails] = framearray[fails] + framecounter
	
	Wait(1)
end
while true do
	Wait(1)
end