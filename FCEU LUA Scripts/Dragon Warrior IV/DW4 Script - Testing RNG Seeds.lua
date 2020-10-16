emu.speedmode("turbo")

Seeds = {}
Seeds_total = 0
RNGs_total = 0
last_report = 0


function Wait(number)
	--Actually a "wait counter" but all waits are for one frame except for the one where I want to delay to show the frame counter
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,220,'T: '..RNGs_total)
		gui.text(70,220,'RNG: '..(memory.readbyte(0x0012)+memory.readbyte(0x0013)*256)..'    ')
		gui.text(130,220,'('..memory.readbyte(0x0012)..',   ')
		gui.text(160,220,memory.readbyte(0x0013)..')')
		x_offset = 10
		y_offset = 10
		_min = 0
		ctr = 0
		if Seeds_total ~= 0 then
			if RNGs_total % 100 == 0 and RNGs_total ~= last_report then
				io.write('\nTotal RNGs: '..RNGs_total..'\n')
			end
			while ctr <= Seeds_total do
				_min2 = 65535
				for value,RNGs in pairs(Seeds) do
					if _min2 > value and _min < value then
						_min2 = value
					end
				end
				if Seeds[_min2] ~= null then
					gui.text(x_offset,y_offset,_min2..': '..Seeds[_min2])
	
					if RNGs_total % 1000 == 0 and RNGs_total ~= last_report then
						io.write(_min2..': '..Seeds[_min2]..'\n')
					end
				end
				y_offset = y_offset + 10
				if y_offset >= 220 then
					x_offset = x_offset + 60
					y_offset = 10
				end
				_min = _min2
				ctr = ctr + 1
			end
			if RNGs_total % 1000 == 0 and RNGs_total ~= last_report then
				last_report = RNGs_total
			end
		end
	end
end

for t=1,100000 do
	emu.softreset()
	
	for i = 1,2500 do
		joypad.write(1,{down=true,A=true});
		Wait(1)
	end
	while memory.readbyte(0x45) ~= 0x20 do
		joypad.write(1,{down=true,A=true});
		Wait(1)
	end
	
	RNG = memory.readbyte(0x0012)+memory.readbyte(0x0013)*256
	if Seeds[RNG] == nil then
		Seeds[RNG] = 0
		Seeds_total = Seeds_total + 1
	end
	Seeds[RNG] = Seeds[RNG] + 1
	RNGs_total = RNGs_total + 1
	
	Wait(1)
end
while true do
	Wait(1)
end