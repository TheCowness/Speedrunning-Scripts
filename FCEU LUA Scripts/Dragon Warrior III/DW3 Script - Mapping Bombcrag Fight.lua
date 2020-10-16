

emu.speedmode("maximum");
OutputFileName = "BombcragFightMap.txt";
discard_ctr = 0;
fastest_win = 50;
fastest_outcome = 0;
outcomes_tried = 0;
turn = 1;
first_crag_death_turn = 0;
load_state = 1;

outfile = io.open(OutputFileName,"a");
io.output(outfile);
io.write(os.date());
io.write("\n\n");
io.close(outfile);

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
		gui.text(10,10,discard_ctr);
		gui.text(10,20,fastest_win);
		gui.text(10,30,outcomes_tried);
		gui.text(10,40,turn);
	end;
end;

while discard_ctr < 16 do
	if load_state == 1 then
		--Load state and set the discard counter
		state = savestate.object(1);
		savestate.load(state);
		memory.writebyte(0x6A68,discard_ctr);
		load_state = 0;
	end;
	
	--Wait until the command menu opens
	while memory.readbyte(0x006C) ~= 0x79 do
		Wait(1);
	end;
	
	--If we want to parry, go down to the item menu (no Parry option if Wizard is solo)
	if first_crag_death_turn ~= 0 and outcomes_tried ~= 0 and AND(outcomes_tried,2^(turn-first_crag_death_turn-1)) ~= 0 then
		Wait(10);
		while memory.readbyte(0x0005) ~= 0x1A do
			joypad.write(1,{down=true});
			Wait(1);
		end;
	end;
	
	--Mash A until combat starts
	while memory.readbyte(0x006C) ~= 0xDD do
		joypad.write(1,{A=true});
		Wait(2);
	end;
	
	--Wait until the round is done processing, or the last crag dies - Check the bombcrags' status (poison needle doesn't set HP to zero)
	while (memory.readbyte(0x006C) ~= 0x79) and ((memory.readbyte(0x0531) + memory.readbyte(0x0533) + memory.readbyte(0x0535) + memory.readbyte(0x0537)) ~= 0) do
		Wait(5);
	end;
	
	
	crags = 0;
	for i=0,3 do
		--Check the bombcrags' status (poison needle doesn't set HP to zero)
		if memory.readbyte(0x0531+(i*2)) > 0 then
			crags = crags + 1;
		end;
	end;
	if crags == 3 and first_crag_death_turn == 0 then
		first_crag_death_turn = turn;
	end;
	if crags == 0 then
		--We killed them all!  This should be the fastest way to do it.  So far.
		fastest_win = turn;
		fastest_outcome = outcomes_tried;
		load_state = 1;
	else
		--Didn't kill it.  Should we continue?
		if turn == fastest_win - crags then
			--We should not continue.  New outcome.
			load_state = 1;
		end;
	end;
	
	if load_state == 1 then
		--Reinitialize variables for the next attempt
		turn = 1;
		
		--One last check: Should we increment the discard counter before moving on? (If the next attempt will try to parry without enough turns left to kill all the crags)
		if outcomes_tried >= 2^(fastest_win - 2)-1 then
			--Record the results of this discard counter value, and reset everything else.
			outfile = io.open(OutputFileName,"a");
			io.output(outfile);
			io.write("Discard Counter "..discard_counter..": ");
			for i=1,first_crag_death_turn do
				io.write("A");
			end;
			i = fastest_outcome;
			while i ~= 0 do
				if i % 2 == 1 then
					io.write("P");
				else
					io.write("A");
				end;
				i = i/2;
			end;
			io.write(" ("..fastest_outcome.."; "..fastest_win.." turns)");
			io.write("\n");
			io.close(outfile);
			
			discard_ctr = discard_ctr + 1;
			fastest_win = 50;
			fastest_outcome = 0;
			outcomes_tried = 0;
		else
			outcomes_tried = outcomes_tried + 1;
		end;
	else
		--Default case: We hit a bombcrag, there's still one there, but we haven't taken so long that we need to give up.
		turn = turn + 1;
	end;
	
	Wait(1);
end;