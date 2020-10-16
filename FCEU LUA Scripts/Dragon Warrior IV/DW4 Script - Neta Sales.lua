--To run this script, get a Save State in slot 9 that's one frame away from Neta updating the inventory (after staying the night)

emu.speedmode("maximum")

save_state_slot = 9

results = {}
results_items_sold = {}
results_total = 0
results_items_sold_total = 0
offers_total = 0
last_report = 0

function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		gui.text(10,10,'T: '..offers_total)
		x_offset = 10
		y_offset = 20
		_min = 0
		ctr = 0
		if results_total ~= 0 then
			while ctr <= results_total do
				_min2 = 65535
				for value,offers in pairs(results) do
					if _min2 > value and _min < value then
						_min2 = value
					end
				end
				if results[_min2] ~= null then
					gui.text(x_offset,y_offset,_min2..': '..results[_min2])
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
	
	joypad.write(1,{A=true})
	Wait(1)
	
	--Count up how much money money Neta has for you
	offer = memory.readbyte(0x6254)+memory.readbyte(0x6255)*256+memory.readbyte(0x6256)*65536
	if results[offer] == nil then
		results[offer] = 0
		results_total = results_total + 1
	end
	
	--Count items sold by starting at the start of Neta's inventory and continuing until we see 0xFF
	items_sold = 0
	addy = 0x61DB
	while memory.readbyte(addy) ~= 0xFF do
		addy = addy + 1
	end
	items_sold = 32 - (addy - 0x61DB)
	if results_items_sold[items_sold] == nil then
		results_items_sold[items_sold] = 0
		results_items_sold_total = results_items_sold_total + 1
	end
	
	results[offer] = results[offer] + 1
	results_items_sold[items_sold] = results_items_sold[items_sold] + 1
	offers_total = offers_total + 1
	
	Wait(1)
end