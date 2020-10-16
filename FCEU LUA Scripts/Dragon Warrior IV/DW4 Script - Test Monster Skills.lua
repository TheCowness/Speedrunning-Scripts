--This script can be used to gather monster skill data.
--To use it, put a save state in slot 1 where you're against multiple kaskos hoppers, with "Parry" selected on the last character.
--The script will press A, wait a few seconds, and press A again.  It will constantly overwrite the enemies' skills to integer "i" and increment "i" whenever you press Select.

--emu.speedmode("maximum");

skill_ctr = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,skill_ctr)
	end
end

timer = 0

while true do
	if joypad.get(1).select == true then
		skill_ctr = skill_ctr + 1
		skill_ctr = skill_ctr % 256
		timer = 0
		Wait(15) --"Double-click" protection
	end
	if timer == 0 then
		state = savestate.object(1)
		savestate.load(state)
	
		joypad.write(1,{A=true})
	end
	
	--Throw random values into the random RNG seed (two bytes) and the counter
	--There is no reason to do this but it was in the script I started with so we'll keep it
	memory.writebyte(0x0012,math.random(0xFF))
	memory.writebyte(0x0013,math.random(0xFF))
	memory.writebyte(0x050D,math.random(0xFF))
	
	--More importantly, overwrite the bytes for what each monster should do
	rom.writebyte(0x60075,skill_ctr)
	rom.writebyte(0x60076,skill_ctr)
	rom.writebyte(0x60077,skill_ctr)
	rom.writebyte(0x60078,skill_ctr)
	rom.writebyte(0x60079,skill_ctr)
	rom.writebyte(0x6007A,skill_ctr)
	
	timer = timer + 1
	timer = timer % 256
	
	Wait(1)
end