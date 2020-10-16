
function Wait(number)
	for i=0,number-1 do
		emu.frameadvance();
	end
end

while true do
	joypad.write(1,{down=true})
	Wait(1)
	joypad.write(1,{down=false})
	Wait(1)
end