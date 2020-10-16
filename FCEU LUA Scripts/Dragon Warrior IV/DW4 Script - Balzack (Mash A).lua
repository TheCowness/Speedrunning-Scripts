--This script will fight Balzack by mashing A until he (or you) dies.
--This line of text last updated by TheCowness on 05/05/2016

--To use this, set up a save state that is in the Balzack fight already, with whatever team comp you want.
--Make sure you use the save state slot associated with the team comp of choice (see below).  You can easily tweak the script to use other comps.
--You should just have to change the Party[] array below, or possibly the HP array.  You won't need to change code.

--2019 07 17 - TheCowness - I don't remember what the results of this script were except that Balzack has a very even 1/3 chance to use each of his three skills.  No clue what the percent chances were of winning with different comps.

emu.speedmode("maximum");

wins = 0
losses = 0
save_state_slot = -1

--Track which characters have used which abilities
Characters = {
	Panon = {RobDance = 0,Sleep = 0,Attack = 0,Other = 0},
	Ragnar = {Attack = 0,Sword = 0,Parry = 0,Other = 0},
	Hero = {Attack = 0,Other = 0},
	Alena = {Attack = 0,Staff = 0,Parry = 0,Other = 0},
	Cristo = {Attack = 0,Parry = 0,Heal = 0,Healmore = 0,Other = 0},
	Nara = {Attack = 0,Other = 0},
	Mara = {Attack = 0,Other = 0},
	Brey = {Attack = 0,Other = 0},
	Taloon = {Attack = 0,Other = 0},
	--Balzack = {Attack = 0,Snow = 0,Wind = 0,Other = 0}
	Balzack = {LowCrit = 0,Palsyhit = 0,PalsyAir = 0,Upper = 0,Assession = 0,Parry = 0,Other = 0} --Ouphnest
}
--Assign the parties to each save state.  Leave Balzack in here; it's important.
Party = {}
Party[1] = {"Panon","Hero","Ragnar","Alena","Balzack","Balzack"}
Party[2] = {"Panon","Hero","Ragnar","Cristo","Balzack","Balzack"}
--Party[3] = {"Panon","Hero","Alena","Cristo","Balzack","Balzack"}
Party[3] = {"Nara","Taloon","Mara","Brey","Balzack","Balzack"}
Party[4] = {"Hero","Ragnar","Alena","Cristo","Balzack","Balzack"}
--Party[5] = {"Panon","Hero","Alena","Cristo","Balzack","Balzack"}
Party[5] = {"Nara","Taloon","Mara","Brey","Balzack","Balzack"}
Party[6] = {"Panon","Hero","Alena","Cristo","Balzack","Balzack"}
Party[7] = {"Panon","Hero","Alena","Cristo","Balzack","Balzack"}
Party[8] = {"Panon","Hero","Alena","Cristo","Balzack","Balzack"}
Party[9] = {"Panon","Hero","Alena","Cristo","Balzack","Balzack"}
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
--Some memory address constants
command_addresses = {0x7324,0x7325,0x7326,0x7327,0x7328,0x7334}
command_values = {0xF7,0xF7,0xF7,0xF7,0xF7,0xF7}
--Some common battle commands (Note that I'm not sure these are the same for monsters and PCs?)
Commands = {}
Commands[0x43] = "Attack"
Commands[0x4A] = "RobDance"
Commands[0x46] = "Attack"
Commands[0x50] = "Wind"--Freezing Wind
Commands[0x0A] = "Snow"--storm
Commands[0x41] = "Parry"
Commands[0x85] = "Sword"--OfLethargy
Commands[0x84] = "Staff"--OfPunishment
Commands[0x17] = "Sleep"
Commands[0x2A] = "Healmore"
Commands[0x29] = "Heal"
--Ouphnest
Commands[0x44] = "LowCrit"
Commands[0x48] = "Palsyhit"
Commands[0x55] = "PalsyAir"
Commands[0x21] = "Upper"
Commands[0xF7] = "Assessing"

framecounter = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(120,75,memory.readbyte(0x727E) + memory.readbyte(0x727F) * 256) --Big Boy's HP
		gui.text(10,90,'Wins: '..wins)
		gui.text(10,100,'Losses: '..losses)
		if(wins + losses ~= 0) then
			gui.text(10,110,'Win Rate: '..(math.floor(1000 * wins / (wins + losses))/10).."%")
		end
		--Display the ability counts...
		if save_state_slot ~= -1 then
			--display_member = math.floor((framecounter / 1200)) % 10 + 2
			display_member = 10;
			gui.text(190,80,Party[save_state_slot][math.floor(display_member/2)])
			total = 0
			for attack,uses in pairs(Characters[Party[save_state_slot][math.floor(display_member/2)]]) do
				total = total + uses
			end
			y_offset = 10
			for attack,uses in pairs(Characters[Party[save_state_slot][math.floor(display_member/2)]]) do
				if(display_member % 2 == 0) then
					gui.text(190,80+y_offset,attack..': '..uses)
				else
					gui.text(190,80+y_offset,attack..': '..(math.floor(uses * 1000 / total)/10).."%")
				end
				y_offset = y_offset + 10
			end
		end
		
		--Display currently-chosen commands
		for i = 1,4 do
			if Commands[command_values[i]] ~= nil and command_values[i] ~= 0x7F then
				gui.text(40*i-10,63,Commands[command_values[i]]);
			end
		end
		framecounter = framecounter + 1
	end
end

while save_state_slot == -1 do
	Wait(1)
	if joypad.get(1).A == true then
		save_state_slot = 1
	elseif joypad.get(1).B == true then
		save_state_slot = 2
	elseif joypad.get(1).start == true then
		save_state_slot = 3
	elseif joypad.get(1).select == true then
		save_state_slot = 4
	elseif joypad.get(1).up == true then
		save_state_slot = 5
	elseif joypad.get(1).down == true then
		save_state_slot = 6
	elseif joypad.get(1).left == true then
		save_state_slot = 7
	elseif joypad.get(1).right == true then
		save_state_slot = 8
	elseif framecounter > 1000 then
		save_state_slot = 9
	end
end

while true do
	state = savestate.object(save_state_slot);
	savestate.load(state);
	--Throw random values into the random RNG seed (two bytes) and the counter
	memory.writebyte(0x0012,math.random(0xFF));
	memory.writebyte(0x0013,math.random(0xFF));
	memory.writebyte(0x050D,math.random(0xFF));
	
	lifecount = 5
	while (memory.readbyte(0x727E) + memory.readbyte(0x727F) ~= 0) and lifecount > 0 do --Balzack's HP
		
		for i=1,5 do
			joypad.write(1,{A=true});
			Wait(1);
			joypad.write(1,{A=false});
			Wait(math.random(5)+1);
		end
		
		--To use other party members, you'll need to find the memory address of their HP.  If you have over 255 HP (why), you'll need to use both bytes.
		lifecount = 0
		for i = 1,4 do
			if(Party[save_state_slot][i] ~= "Panon" and memory.readbyte(HP_Addresses[Party[save_state_slot][i]]) ~= 0) then
				lifecount = lifecount + 1
			end
		end
		
		--For each command, if it was NOT 0xF7 and now it IS, save it.
		for i=1,6 do
			if(command_values[i] ~= 0xF7 and memory.readbyte(command_addresses[i]) == 0xF7) then
				if(Commands[command_values[i]] ~= nil and Characters[Party[save_state_slot][i]][Commands[command_values[i]]] ~= nil) then
					Characters[Party[save_state_slot][i]][Commands[command_values[i]]] = Characters[Party[save_state_slot][i]][Commands[command_values[i]]] + 1
				else
					Characters[Party[save_state_slot][i]]["Other"] = Characters[Party[save_state_slot][i]]["Other"] + 1
				end
			end
			command_values[i] = memory.readbyte(command_addresses[i])
		end
		
		Wait(1)
	end
	
	if lifecount == 0 then
		losses = losses + 1
	else
		wins = wins + 1
	end
	
	Wait(1)
end