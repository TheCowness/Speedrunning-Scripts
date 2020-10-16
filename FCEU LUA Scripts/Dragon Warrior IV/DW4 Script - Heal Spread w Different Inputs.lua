--To run this script, get a save state in slot 10 with someone ready to heal the Hero.  He must be missing over 40 HP.


emu.speedmode("turbo")

save_state_slot = 10

results = {}
results_total = 0
offers_total = 0
last_report = 0
trials = 0
btn = 0
range = 11 --range of the Heal spell (30-40 = 11 values)
btns = 8 -- Number of buttons on the NES controller
for i = 0,btns do
	results[i] = {}
	for j = 0,range-1 do
		results[i][j] = 0
	end
end
outputter = 0
function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		if trails == -1 then
		--if true then
			--Print a list of numbers 0-10
			for i = 0,10 do
				gui.text(5,20+10*i,(30+i)..':')
			end
			--Display a header
			gui.text(25 ,10,'Ctrl')
			gui.text(50 ,10,'A')
			gui.text(75 ,10,'B')
			gui.text(100,10,'Start')
			gui.text(125,10,'Select')
			gui.text(150,10,'Up')
			gui.text(175,10,'Down')
			gui.text(200,10,'Left')
			gui.text(225,10,'Right')
			for disp_btn = 0,8 do
			--Loop through the possible btn values
				for i = 0,10 do
					gui.text(25+25*disp_btn,20+10*i,results[disp_btn][i])
				end
			end
		end
		gui.text(5,140,'Btn: '..btn)
		gui.text(5,150,'Total: '..trials)
		--gui.text(5,160,'Outputter: '..outputter)
	end
end

while btn <= 8 do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	Wait(1)
	savestate.save(state)
	savestate.persist(state)
	
	--Press A and hold a specific button until his HP changes
	joypad.write(1,{A=true})
	Wait(1)
	joypad.write(1,{A=true})
	Wait(1)
	starting_hp = memory.readbyte(0x6002)+memory.readbyte(0x6003)*256
	while (memory.readbyte(0x6002)+memory.readbyte(0x6003)*256 == starting_hp) do
		if btn == 0 then
		elseif btn == 1 then
			joypad.write(1,{A=true})
		elseif btn == 2 then
			joypad.write(1,{B=true})
		elseif btn == 3 then
			joypad.write(1,{Start=true})
		elseif btn == 4 then
			joypad.write(1,{Select=true})
		elseif btn == 5 then
			joypad.write(1,{Up=true})
		elseif btn == 6 then
			joypad.write(1,{Down=true})
		elseif btn == 7 then
			joypad.write(1,{Left=true})
		elseif btn == 8 then
			joypad.write(1,{Right=true})
		end
		Wait(1)
	end
	
	heal_rng = memory.readbyte(0x6002)+memory.readbyte(0x6003)*256 - starting_hp - 30
	if results[btn][heal_rng] == nil then
		results[btn][heal_rng] = 0
	end
	outputter = starting_hp..' '..memory.readbyte(0x6002)+memory.readbyte(0x6003)*256
	results[btn][heal_rng] = results[btn][heal_rng] + 1
	
	trials = trials + 1
	if trials > 10000 then
		trials = 0
		btn = btn + 1
	end
end

while true do
	trials = -1
	Wait(1)
end