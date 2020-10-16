--To use this file, put the name of the character you're tracking in the variable below
--and make a save state at the end of a fight.  Their EXP will be set to a trillion and
--A will be held until they hit 99.  Then it will reset and load the state.
--As they level their stats will be recorded in CSV format.
--CSV columns:
--Character name, Level, Str, Agi, Vit, Int, Luck, HP, MP

emu.speedmode("maximum");

current_character = "Cristo"
save_state_slot = 2

function Wait(number)
	for j=0,number-1 do
		emu.frameadvance();
		gui.text(10,10,'Trials: '..i+1);
	end
end

Characters = {
	Ragnar = 0x60ba,
	Alena = 0x60D8,
	Cristo = 0x6024,
	Brey = 0x607e,
	Taloon = 0x609c,
	Nara = 0x6042,
	Mara = 0x6060,
	Hero = 0x6006
}

outfile = io.open("DW4LevelUpDataDump.csv","a")
io.output(outfile);

i = 0
while i < 1000 do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	memory.writebyte(Characters[current_character] + 13,0xFF)
	current_level = 0
	
	while current_level ~= 99 do
		Wait(1)
		joypad.write(1,{A=true})
		memory.writebyte(0x0012,math.random(0xFF));
		memory.writebyte(0x0013,math.random(0xFF));
		memory.writebyte(0x050D,math.random(0xFF));
		if memory.readbyte(Characters[current_character]) > current_level  then
			--Level up!  Record previous level...
			if current_level ~= 0 then
				io.write(current_character..',')
				io.write(current_level..',') --Level
				io.write(memory.readbyte(Characters[current_character]+1)..',') --Str
				io.write(memory.readbyte(Characters[current_character]+2)..',') --Agi
				io.write(memory.readbyte(Characters[current_character]+3)..',') --Vit
				io.write(memory.readbyte(Characters[current_character]+4)..',') --Int
				io.write(memory.readbyte(Characters[current_character]+5)..',') --Luck
				--Not sure what the next byte is...?
				io.write(memory.readbyte(Characters[current_character]+7)+(memory.readbyte(Characters[current_character]+8)*256)..',') --HP
				io.write(memory.readbyte(Characters[current_character]+9)+(memory.readbyte(Characters[current_character]+10)*256)) --MP
				io.write('\n')
			end
			current_level = memory.readbyte(Characters[current_character])
		end
	end
	i = i + 1
end


