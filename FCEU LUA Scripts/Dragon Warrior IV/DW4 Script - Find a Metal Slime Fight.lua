-- LUA Script for finding a metal slime fight in Dragon Warrior IV
-- This line of text last updated 10/17/2016 by TheCowness

-- 2019 07 17 - TheCowness - This script tries to manipulate a metal slime fight, DW3 style.  It isn't very successful.
-- This is one of my few scripts that don't start from save states.  It just wants an Endor savefile.  It soft resets and walks out of town with the same inputs every time, but oddly it gives inconsistent results.  iirc it would find four different fights, not one as expected.  I forget if the four battles repeated in a set sequence or if they seemed random.




--  S P E E D R U N B O Y S
--emu.speedmode("maximum")

--Initialize this array
--slimes_per_state = {0,0,0,0,0,0,0,0,0,0}

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		--gui.text(10,20,slimes_per_state[1].." "..slimes_per_state[2].." "..slimes_per_state[3].." "..slimes_per_state[4].." "..slimes_per_state[5].." "..slimes_per_state[6].." "..slimes_per_state[7].." "..slimes_per_state[8].." "..slimes_per_state[9].." "..slimes_per_state[10])
	end
end

while true do
	emu.softreset()
	
	--Using x,y position (42,43 on world map; 44,45 in town)
	--From power on, hold A.
	for i=1,461 do
		joypad.set(1,{A=true})
		Wait(1)
	end
	--Hold Down to select file 2 (four frame window)
	--for i=1,4 do
	--	joypad.set(1,{down=true})
	--	Wait(1)
	--end
	--Press A (Frame perfect?)
	--for i=1,211 do
	--	joypad.set(1,{A=true})
	--	Wait(1)
	--end
	--Hold Down (start walking after priest's text dismisses itself)
	while memory.readbyte(0x45) < 0x12 and memory.readbyte(0x727C) ~= 0 do
		joypad.set(1,{down=true})
		Wait(1)
	end
	--Walk to the left
	while memory.readbyte(0x44) > 0x01 and memory.readbyte(0x727C) ~= 0 do
		joypad.set(1,{left=true})
		Wait(1)
	end
	--Walk south
	while memory.readbyte(0x45) < 0x14 and memory.readbyte(0x727C) ~= 0 do
		joypad.set(1,{down=true})
		Wait(1)
	end
	--Walk left (Out of town)
	while memory.readbyte(0x42) > 0x64 and memory.readbyte(0x727C) ~= 0 do
		joypad.set(1,{left=true})
		Wait(1)
	end
	--Walk up
	while memory.readbyte(0x43) > 0x63 and memory.readbyte(0x727C) ~= 0 do
		joypad.set(1,{up=true})
		Wait(1)
	end
	--Walk left
	while memory.readbyte(0x42) > 0x60 and memory.readbyte(0x727C) ~= 0 do
		joypad.set(1,{left=true})
		Wait(1)
	end
	--Walk down and up until you find a fight
	while memory.readbyte(0x727C) ~= 0 do
		while memory.readbyte(0x43) < 0x6A and memory.readbyte(0x727C) ~= 0 do
			joypad.set(1,{down=true})
			Wait(1)
		end
		while memory.readbyte(0x43) > 0x63 and memory.readbyte(0x727C) ~= 0 do
			joypad.set(1,{up=true})
			Wait(1)
		end
	end
	
	
	
	--Using timing...
	while false do
		--From power on, hold A.
		for i=1,251 do
			joypad.set(1,{A=true})
			Wait(1)
		end
		--Hold Down to select file 2 (four frame window)
		for i=1,4 do
			joypad.set(1,{down=true})
			Wait(1)
		end
		--Press A (Frame perfect?)
		for i=1,211 do
			joypad.set(1,{A=true})
			Wait(1)
		end
		--Hold Down (start walking after priest's text dismisses itself)
		for i=1,241 do
			joypad.set(1,{down=true})
			Wait(1)
		end
		--Walk to the left
		for i=1,61 do
			joypad.set(1,{left=true})
			Wait(1)
		end
		--Walk south
		for i=1,31 do
			joypad.set(1,{down=true})
			Wait(1)
		end
		--Walk left (Out of town)
		for i=1,161 do
			joypad.set(1,{left=true})
			Wait(1)
		end
		--Walk up
		for i=1,31 do
			joypad.set(1,{up=true})
			Wait(1)
		end
		--Walk left
		for i=1,66 do
			joypad.set(1,{left=true})
			Wait(1)
		end
		--Walk down and up until you find a fight
		while memory.readbyte(0x727C) ~= 0 do
			for i=1,112 do
				joypad.set(1,{down=true})
				Wait(1)
			end
			for i=1,112 do
				joypad.set(1,{up=true})
				Wait(1)
			end
		end
	end
	
	Wait(100)
	
	--Obligatory "wait" command in case we get stuck doing nothing in this loop
	Wait(1)
end