-- LUA Script for finding a metal slime fight in Dragon Warrior III
-- This line of text last updated 03/09/2016 by TheCowness

-- Notes: THIS SCRIPT WILL DELETE ALL OF YOUR SAVE STATES!
-- To use:
--  1) Get a save file to Dhama and move it to the slot you want your manipulation file to be on (I recommend slot two)
--  2) Delete all saved games in the above slots, so that when you mash A the game begins in Dhama
--  3) Back up your save states, if you care about them!  The "output" from this file comes in the form of overwriting your save states.
--  4) Execute this script within the emulator (script was written and tested on FCEUX version 2.2.2 only)

-- How it works:
--   The ten "best" fights are kept in save states at all times.
--   The numbers at the top of the screen correspond to the number of slimes in the fight stored on the respected save state.
--   If a "good" fight is found, it will throw out one of the "worst" ones to save the new one.
--   If you ever stop the script (for instance, to check on what it found), remember to back up the save states before restarting it or the script will run them over without checking to see if they were important.

-- I claim no responsibility if this script starts a new file, completes the whole game, and beats your PB.




--  S P E E D R U N B O Y S
emu.speedmode("maximum");

--Initialize this array (Eight savefiles, eight monster slots, Max/Min)
Monster_HP = {
	{
		{45,60},{45,60},{45,60},{45,60},{0,0},{0,0},{0,0},{0,0}
	},
	{
		{3,4},{3,4},{3,4},{3,4},{3,4},{3,4},{3,4},{3,4},{45,60}
	},
	{
		{30,40},{30,40},{30,40},{0,0},{0,0},{0,0},{0,0},{0,0}
	},
	{
		{30,40},{30,40},{31,42},{0,0},{0,0},{0,0},{0,0},{0,0}
	},
	{
		{26,35},{26,35},{26,35},{26,35},{0,0},{0,0},{0,0},{0,0}
	},
	{
		{45,60},{45,60},{45,60},{45,60},{0,0},{0,0},{0,0},{0,0}
	},
	{
		{30,40},{30,40},{30,40},{0,0},{0,0},{0,0},{0,0},{0,0}
	},
	{
		{30,40},{30,40},{3,4},{3,4},{0,0},{0,0},{0,0},{0,0}
	}
};
--0 if what we found matches the above, 1 if not
Match_Array = {0,0,0,0,0,0,0,0};
--By starting this at one, we'll move the message speed to 1 before starting
Restart = 1;
--Make this global so I can use it in Wait
MessageSpeed = 0;
--Output file
OutputFileName = "E:\LUAScriptOutput.txt";

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
		gui.text(10,10,"Current Message Speed: "..MessageSpeed);
		gui.text(10,20,Match_Array[1].." "..Match_Array[2].." "..Match_Array[3].." "..Match_Array[4].." "..Match_Array[5].." "..Match_Array[6].." "..Match_Array[7].." "..Match_Array[8]);
	end;
end;

while Match_Array ~= {1,1,1,1,1,1,1,1} do
	emu.softreset();
	Wait(10);

	--Mash Start until we're on the Continue a Quest menu
	while memory.readbyte(0x047d) ~= 0x91 do --Tempo of music on main menu
		joypad.set(1,{start=true});
		Wait(10);
	end;
	Wait(10);
	
	
	--Select the next message speed on the top file (Assume you're looking at the five-option menu)
	joypad.set(1,{down=true});
	Wait(10);
	joypad.set(1,{down=true});
	Wait(10);
	joypad.set(1,{down=true});
	Wait(10);
	joypad.set(1,{down=true});
	Wait(10);
	joypad.set(1,{down=true});
	Wait(10);
	joypad.set(1,{A=true});
	Wait(10);
	joypad.set(1,{A=true});
	Wait(10);
	if memory.readbyte(0x0004) == 0x17 or Restart == 1 then
		--If message speed is 8 already, reset the message speed to 1, then load and save the game.
		--We'll never test message speed one this way, but eh.
		while memory.readbyte(0x0004) ~= 0x09 do --0x09 = MS 1
			Match_Array = {0,0,0,0,0,0,0,0};
			joypad.set(1,{left=true});
			Wait(2);
		end;
	else
		joypad.set(1,{right=true});
		Wait(5);
	end;
	MessageSpeed = (memory.readbyte(0x0004) - 7) / 2;
	--Mash A to start the game
	while memory.readbyte(0x047d) == 0x91 do --Tempo of music on main menu
		joypad.set(1,{A=true});
		Wait(10);
	end;
	--Mash B to get through his text...
	while memory.readbyte(0x01FC) ~= 124 do
		joypad.set(1,{B=true});
		Wait(10);
	end;
	--Hold Down until you're outside... (5D = tempo of Dhama music)
	while memory.readbyte(0x047d) == 0x5D do
		joypad.set(1,{down=true});
		Wait(1);
	end;
	
	--Walk back and forth until you're in battle
	while memory.readbyte(0x0101) ~= 0x7F do
		joypad.set(1,{up=true});
		Wait(1);
	end;
	while memory.readbyte(0x047d) == 0x78 do
		while memory.readbyte(0x047d) == 0x78 and memory.readbyte(0x0100) < 0x7B do
			joypad.set(1,{right=true});
			Wait(1);
		end;
		while memory.readbyte(0x047d) == 0x78 and memory.readbyte(0x0100) > 0x7A do
			joypad.set(1,{left=true});
			Wait(1);
		end;
	end;
	--We're in a battle.  Hooray.
	while memory.readbyte(0x0500) == 0 do
		Wait(1);
	end;
	Wait(20);
	--Check which enemies you ran into
	Restart = 0;
	for i=0,7 do
		--Technically doesn't check the upper HP byte, but we aren't fighting bombcrags here.
		if memory.readbyte(0x0500+(2*i)) >= Monster_HP[MessageSpeed][i+1][1] and memory.readbyte(0x0500+(2*i)) <= Monster_HP[MessageSpeed][i+1][2] then
			Wait(1);
		else
			Restart = 1;
		end;
	end;
	
	if Restart == 0 then
		Match_Array[MessageSpeed] = 1;
	end;
	
	if Match_Array[1] == 1 then
		outfile = io.open(OutputFileName,"a");
		io.output(outfile);
		if MessageSpeed == 1 then
			io.write(os.date());
			io.write("\r\n");
		end;
		for i=0,7 do
			io.write( memory.readbyte(0x0500+(2*i)) );
			io.write(" ");
		end;
		io.write("\r\n");
		if Restart == 1 then
			io.write("--------\r\n");
		end;
		io.close(outfile);
	end;
	
	--If we're on message speed one, we need to escape this fight and get back to Dhama.
	if Restart == 1 then
		oops_i_died = false;
		--Mash A until the battle ends...
		while memory.readbyte(0x047d) == 0x91 or memory.readbyte(0x047d) == 0x41 do --Tempo of battle music
			joypad.set(1,{A=true});
			Wait(10);
			if memory.readbyte(0x047d) == 0x41 then
				oops_i_died = true;
			end;
		end;
		--Hold Down until you're inside... (5D = tempo of Dhama music)
		while memory.readbyte(0x047d) ~= 0x5D and oops_i_died ~= true do
			joypad.set(1,{down=true,B=true});
			Wait(1);
		end;
		--Now, we're either in front of the guy or at the entrance.
		while memory.readbyte(0x0100) > 0x0D and oops_i_died ~= true do
			joypad.set(1,{left=true,B=true});
			Wait(1);
		end;
		while memory.readbyte(0x0101) > 0x24 and oops_i_died ~= true do
			joypad.set(1,{up=true});
			Wait(1);
		end;
		while memory.readbyte(0x0100) < 0x0E and oops_i_died ~= true do
			joypad.set(1,{right=true});
			Wait(1);
		end;
		--Mash A...
		while (memory.readbyte(0x006C) ~= 0xFB or memory.readbyte(0x0004) ~= 0x17 or memory.readbyte(0x0005) ~= 0x08) do
			joypad.set(1,{A=true});
			Wait(2);
		end;
		--Press A to save the game, and reset!
		joypad.set(1,{A=true});
		Wait(20);
	end;
	
	
	
	--Obligatory "wait" command in case we get stuck doing nothing in this loop
	Wait(1);
end;