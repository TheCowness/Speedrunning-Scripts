--This script will walk left and right trying to determine how much EXP/GP per minute
--you can earn grinding in an area, as well as determining how many fights you can take
--without hitting an inn.

--This script should be used with a save state that's standing on the overworld, left
--of the other tile it should be stepping on.
--Arguments: Save state slot

--Initialize some stuff...
--If arg is null, set to 1
if arg == '' then
	arg = 1
end

_statenum = arg

exp_total = 0
trips = 0
init_enemy_hp = 0
_step = 'init'
framecounter = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance(1);
		gui.text(10,10,'EXP: '..exp_total)
		if trips > 0 then
			gui.text(10,20,'EXP/Trip: '..math.floor(exp_total * 100/trips)/100)
		end
		gui.text(10,30,'Trips: '..trips)
		if exp_total > 0 then
			gui.text(10,40,'Frames/EXP: '..math.floor(framecounter * 100/exp_total)/100)
		end
		
		gui.text(10,60,'HP: '..memory.readbyte(0xC5)..'/'..memory.readbyte(0xCA))
		gui.text(10,70,'Enemy HP: '..memory.readbyte(0xE2)..'/'..init_enemy_hp)
		
		gui.text(10,90,'Step: '.._step)
		framecounter = framecounter + 1
		gui.text(10,100,'Frames: '..framecounter)
	end
end


emu.speedmode("maximum")

while true do
	state = savestate.object(_statenum)
	savestate.load(state)
	
	--First, grab the coordinates we're starting in.
	init_x = memory.readbyte(0x3A)
	init_y = memory.readbyte(0x3B)
	
	Wait(20)
	savestate.save(state)
	savestate.persist(state)
	
	--Loop until hero dies
	while memory.readbyte(0xC5) > 0 do
		_step = 'find battle'
		--Set enemy HP byte to zero
		memory.writebyte(0xE2,0)
		--Remember current EXP
		init_xp = memory.readbyte(0xBA)

		--While enemy HP byte is 0, walk left and right
		while memory.readbyte(0xE2) == 0 do
			--_step = 'step right: init x '..init_x..', current x '..memory.readbyte(0x3A)
			while memory.readbyte(0x3A) <= init_x and memory.readbyte(0xE2) == 0 do
				joypad.set(1,{right=true});
				Wait(1)
				joypad.set(1,{right=true});
				Wait(1)
			end
			--_step = 'step left: init x '..init_x..', current x '..memory.readbyte(0x3A)
			while memory.readbyte(0x3A) > init_x and memory.readbyte(0xE2) == 0 do
				joypad.set(1,{left=true});
				Wait(1)
				joypad.set(1,{left=true});
				Wait(1)
			end
			Wait(1)
		end
		
		_step = 'battle'
		--Battle has started.  Mash A until it's over.
		init_enemy_hp = memory.readbyte(0xE2)
		while memory.readbyte(0xE2) > 0 and memory.readbyte(0xE2) <= init_enemy_hp and memory.readbyte(0xC5) > 0 do
			joypad.set(1,{A=true});
			Wait(1)
			joypad.set(1,{A=false});
			Wait(1)
		end
		
		_step = 'post battle'
		--Wait for the rest end of battle text to scroll
		Wait(200)
		--Dismiss battle window and wait for it to disappear
		joypad.set(1,{B=true});
		Wait(1)
		joypad.set(1,{B=false});
		Wait(20)
		
		--After battle, if level >= 3, missing >= 17 HP, and MP >= 4, cast Heal
		while memory.readbyte(0xC7) >= 3 and memory.readbyte(0xC5) > 0 and memory.readbyte(0xC6) >= 4 and memory.readbyte(0xC5) + 17 <= memory.readbyte(0xCA) do
			_step = 'heal'
			joypad.set(1,{A=true});
			Wait(1)
			joypad.set(1,{A=true});
			Wait(40)
			joypad.set(1,{right=true});
			Wait(1)
			joypad.set(1,{right=true});
			Wait(1)
			joypad.set(1,{A=true});
			Wait(1)
			joypad.set(1,{A=true});
			Wait(20)
			joypad.set(1,{A=true});
			Wait(1)
			joypad.set(1,{A=true});
			Wait(150)
			joypad.set(1,{A=true});
			Wait(1)
		end
		
		_step = 'reset'
		if memory.readbyte(0xC5) == 0 then
			trips = trips + 1
		end
		exp_total = exp_total - init_xp + memory.readbyte(0xBA)
		memory.writebyte(0xBA,init_xp)
	end
	
	Wait(1)
end