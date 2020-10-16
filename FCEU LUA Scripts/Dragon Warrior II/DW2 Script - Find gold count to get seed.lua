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

--Initialize this array

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
		gui.text(10,20,"Gold: "..Gold);
	end
end

Gold = 0

while true do
	state = savestate.object(10)
	savestate.load(state)
	
	memory.writebyte(0x0624,Gold%256)
	memory.writebyte(0x0625,math.floor(Gold/256))
	
	for i=0,20 do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(1)
	end
	
	RNG = memory.readbyte(0x32) + memory.readbyte(0x33)*256
	if RNG == 0x5FEA or RNG == 0xAFF5 then
		outfile = io.open("DW2 RNG Seed Seeker Results.txt","a")
		io.output(outfile);
		io.write("Gold: "..Gold)
		io.write("\n")
		io.write("RNG Seed: "..RNG)
		io.write("\n")
		io.write("\n")
		io.close(outfile)
	end
	
	Gold = Gold + 1
	
	--Obligatory "wait" command in case we get stuck doing nothing in this loop
	Wait(1)
end