

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance(1);
		gui.text(10,10,arg)
	end
end

while true do
	Wait(1)
end