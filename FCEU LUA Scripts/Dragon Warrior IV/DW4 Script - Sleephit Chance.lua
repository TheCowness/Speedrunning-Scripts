--This script will test how often a Giant Bantam puts you to sleep
--To set it up, get a save state in slot 10 (aka slot 0) that is about to parry against a Giant Bantam with the only Hero alive

emu.speedmode("maximum");

wins = 0
losses = 0

--Track which characters have been put to sleep
Characters = {
	Hero = 0, --Hero sleeping
	Whiff = 0, --Bantam missed
	Total = 0 --Total attacks
}

--Memory addresses for each character (Find them yourself, if you need more)
HP_Addresses = {
	Panon = 0x6110,
	Ragnar = 0x60B6,
	Hero = 0x6002,
	Alena = 0x60D4,
	Cristo = 0x6020,
	Nara = 0x603E,
	Mara = 0x605C,
	Brey = 0x607A,
	Taloon = 0x6098
}


function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'Hero Sleeps: '..Characters["Hero"].." ("..(math.floor(Characters["Hero"]/(Characters["Total"] - Characters["Whiff"])*10000)/100)..'%)')
		gui.text(10,20,'Hero Dodges: '..Characters["Whiff"].." ("..(math.floor(Characters["Whiff"]/(Characters["Total"])*10000)/100)..'%)')
		gui.text(10,30,'Total Attacks: '..Characters["Total"])
	end
end

while true do
	state = savestate.object(10)
	savestate.load(state)
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF))
	memory.writebyte(0x0013,math.random(0xFF))
	memory.writebyte(0x050D,math.random(0xFF))
	
	Hero = memory.readbyte(HP_Addresses["Hero"])
	
	joypad.write(1,{A=true});
	Wait(200);
	
	if(memory.readbyte(HP_Addresses["Hero"]) ~= Hero) then
		if(memory.readbyte(0x7215) ~= 0) then
			Characters["Hero"] = Characters["Hero"] + 1
		end
	else
		Characters["Whiff"] = Characters["Whiff"] + 1
	end
	Characters["Total"] = Characters["Total"] + 1
	
	Wait(1)
end

--Results:
--  2 party members:
--      14451  : 10685
--      57.49% : 42.51%  (23:17)

--  3 party members:
--      6532   : 4744   : 3287
--      44.85% : 32.57% : 22.57%  (18 : 13 : 9) or (9 : 4 : 3)

--  4 party members:
--      8260   : 5648   : 3281   : 1465
--      44.28% : 30.27% : 17.58% : 7.85%  (8 : 4 : 2 : 1)
