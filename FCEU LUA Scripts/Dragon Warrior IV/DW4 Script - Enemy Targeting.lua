--This script will test how often an enemy attacks each character in the party.
--To set it up, get a save state in slot 10 (aka slot 0) that has up to four of the following in the party: Hero, Taloon, Nara, Mara


--Results:
--  2 party members:
--      14451  : 10685
--      57.49% : 42.51%  (23:17 or 9:7)

--  3 party members:
--      6532   : 4744   : 3287
--      44.85% : 32.57% : 22.57%  (18 : 13 : 9) or (9 : 4 : 3)

--  4 party members:
--      8260   : 5648   : 3281   : 1465
--      44.28% : 30.27% : 17.58% : 7.85%  (8 : 4 : 2 : 1)



emu.speedmode("maximum");

wins = 0
losses = 0

--Track which characters have used which abilities
Characters = {
	Hero = 0,
	Mara = 0,
	Nara = 0,
	Taloon = 0,
	Total = 0
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
		gui.text(10,10,'Hero Hits: '..Characters["Hero"].." ("..(math.floor(Characters["Hero"]/Characters["Total"]*10000)/100)..'%)')
		gui.text(10,20,'Taloon Hits: '..Characters["Taloon"].." ("..(math.floor(Characters["Taloon"]/Characters["Total"]*10000)/100)..'%)')
		gui.text(10,30,'Nara Hits: '..Characters["Nara"].." ("..(math.floor(Characters["Nara"]/Characters["Total"]*10000)/100)..'%)')
		gui.text(10,40,'Mara Hits: '..Characters["Mara"].." ("..(math.floor(Characters["Mara"]/Characters["Total"]*10000)/100)..'%)')
	end
end

while true do
	state = savestate.object(10);
	savestate.load(state);
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF));
	memory.writebyte(0x0013,math.random(0xFF));
	memory.writebyte(0x050D,math.random(0xFF));
	
	Hero = memory.readbyte(HP_Addresses["Hero"])
	Taloon = memory.readbyte(HP_Addresses["Taloon"])
	Nara = memory.readbyte(HP_Addresses["Nara"])
	Mara = memory.readbyte(HP_Addresses["Mara"])
	
	joypad.write(1,{A=true});
	Wait(50);
	
	if(memory.readbyte(HP_Addresses["Hero"]) ~= Hero) then
		Characters["Hero"] = Characters["Hero"] + 1
		Characters["Total"] = Characters["Total"] + 1
	end
	if(memory.readbyte(HP_Addresses["Taloon"]) ~= Taloon) then
		Characters["Taloon"] = Characters["Taloon"] + 1
		Characters["Total"] = Characters["Total"] + 1
	end
	if(memory.readbyte(HP_Addresses["Nara"]) ~= Nara) then
		Characters["Nara"] = Characters["Nara"] + 1
		Characters["Total"] = Characters["Total"] + 1
	end
	if(memory.readbyte(HP_Addresses["Mara"]) ~= Mara) then
		Characters["Mara"] = Characters["Mara"] + 1
		Characters["Total"] = Characters["Total"] + 1
	end
	
	Wait(1)
end
