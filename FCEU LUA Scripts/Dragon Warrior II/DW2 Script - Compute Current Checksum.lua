
--Not working.  Dunno why.
--SRAM range is wrong?
--Bytes aren't being read in the right order?
--Bits aren't being read in the right order?
--Function is wrong altogether?
--Hum...

first_sram_byte = 0x7000
last_sram_byte = 0x7072


function Wait(number)
	for i=0,number-1 do
		emu.frameadvance()
		
		gui.text(10,10,seed)
		gui.text(10,20,memory.readbyte(0x32) + memory.readbyte(0x33) * 0x100)
		--gui.text(10,30,a)
		--gui.text(10,40,b)
		--gui.text(10,50,c)
	end
end

--LFSR(seed, input) = (seed << 1) ^ ((seed>>15 ^ input) ? $1021 : 0)
--LFSR(seed, input) = (a) ^ ((b ^ input) ? $1021 : 0)
--LFSR(seed, input) = (a) ^ (c)
seed = 0x3A3A
a = 0
b = 0
c = 0
function LFSR(input)
	a = (seed * 2) % 65536 --seed << 1
	b = math.floor(seed / 0x8000) --seed >> 15
	c = 0
	if XOR(b,1) == 1 then
		c = 0x1021
	end
	--Wait(100)
    return XOR(a,c) % 65536
end

function Checksum()
	seed = 0x3A3A
	for i=0,(last_sram_byte - first_sram_byte) do
		for j=0,8 do
			n = 8 - j
			--bit = memory.readbyte(first_sram_byte + i)
			bit = memory.readbyte(last_sram_byte - i)
			if n > 1 then
				for k=0,n do
					bit = math.floor(bit / 2)
				end
			end
			bit = AND(bit,1)
			seed = LFSR(bit)
		end
	end
end

Checksum()
while true do
	Wait(1)
end