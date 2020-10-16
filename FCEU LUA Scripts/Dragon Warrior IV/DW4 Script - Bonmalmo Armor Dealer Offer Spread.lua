--To run this script, get a Save State in slot 1 that has Taloon ready to sell armor to the Bonmalmo merchant (about to say "Yes")
--The summary of how this works is that the selling price is between 85% and 125% of the shop price, but 1/32 offers will instead be between 150% and 200%.

emu.speedmode("maximum")

save_state_slot = 1

results = {}
results_total = 0
offers_total = 0
last_report = 0

outfile = io.open("DW4 Bonmalmo Armor Dealer Offer Spread.txt","a")
io.output(outfile);

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'T: '..offers_total)
		x_offset = 10
		y_offset = 20
		_min = 0
		ctr = 0
		if results_total ~= 0 then
			if offers_total % 1000 == 0 and offers_total ~= last_report then
				io.write('\nTotal Offers: '..offers_total..'\n')
			end
			while ctr <= results_total do
				_min2 = 65535
				for value,offers in pairs(results) do
					if _min2 > value and _min < value then
						_min2 = value
					end
				end
				if results[_min2] ~= null then
					gui.text(x_offset,y_offset,_min2..': '..results[_min2])
	
					if offers_total % 1000 == 0 and offers_total ~= last_report then
						io.write(_min2..': '..results[_min2]..'\n')
					end
				end
				y_offset = y_offset + 10
				if y_offset >= 230 then
					x_offset = x_offset + 60
					y_offset = 10
				end
				_min = _min2
				ctr = ctr + 1
			end
			if offers_total % 1000 == 0 and offers_total ~= last_report then
				last_report = offers_total
			end
		end
	end
end

while true do
	state = savestate.object(save_state_slot)
	savestate.load(state)
	
	--Throw random numbers into the RNG seeds
	memory.writebyte(0x0012,math.random(0xFF))
	memory.writebyte(0x0013,math.random(0xFF))
	memory.writebyte(0x050D,math.random(0xFF))
	memory.writebyte(0x050C,math.random(0xFF))
	
	--Press A until this value changes
	while memory.readbyte(0x00FD) == 0 and memory.readbyte(0x00FE) == 0 do
		joypad.write(1,{A=true})
		Wait(1)
		joypad.write(1,{A=false})
		Wait(1)
	end
	
	offer = memory.readbyte(0x00FD)+memory.readbyte(0x00FE)*256
	if results[offer] == nil then
		results[offer] = 0
		results_total = results_total + 1
	end
	results[offer] = results[offer] + 1
	offers_total = offers_total + 1
	
	Wait(1)
end