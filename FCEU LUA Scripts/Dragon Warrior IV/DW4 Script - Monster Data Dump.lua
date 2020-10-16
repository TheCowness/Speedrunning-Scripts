 --LUA script for pulling data from the DW4 rom

Monster_Names = {
	'Slime',
	'Kaskos Hopper',
	'Red Slime',
	'Stag Beetle',
	'Slime (Kingslime)',
	'Prank Gopher',
	'Monjar',
	'Giant Worm',
	'Elerat',
	'Diverat',
	'Babble',
	'Troglodyte',
	'Demon Stump',
	'Blazeghost',
	'Minon',
	'Angel Head',
	'Sizarmage',
	'Demon Toadstool',
	'Chameleon Humanoid',
	'Lethal Gopher',
	'Healer',
	'Poison Arrop',
	'Lava Doll',
	'Elefrover',
	'Rabidhound',
	'Ducksbill',
	'Carnivore Plant',
	'Xemime',
	'Brahmird',
	'Ozwarg',
	'Lillypa',
	'Vampire Bat',
	'Crested Viper',
	'Giant Bantam',
	'Pixie',
	'Infernus Beetle',
	'Thevro',
	'Orc',
	'Somnabeetle',
	'Magemonja',
	'Sandmaster',
	'Giant Eyeball',
	'Poison Lizard',
	'Arrop',
	'Kordra',
	'LicLick',
	'Spectet',
	'Zappersaber',
	'King Slime',
	'Dark Doriard',
	'Viceter',
	'Flythrope',
	'Plesiosaur',
	'Bangler',
	'Grislysaber',
	'Metal Scorpion',
	'Razor Wind',
	'Man O War',
	'Guzzle Ray',
	'Runamok Albacore',
	'Mandrake',
	'Mad Clown',
	'Pterodon',
	'Sealthrope',
	'Butterfly Dragon',
	'Piranian',
	'Vampdog',
	'Rogue Wisper',
	'Infsnip (Unused)',
	'Weretiger',
	'Rogue Knight',
	'Mage Toadstool',
	'Skeleton',
	'Infurnus Knight',
	'Vileplant',
	'Rabid Roover (Unused)',
	'Baby Salamand',
	'Armor Scorpion',
	'Garcoil Rooster',
	'Conjurer',
	'Iceloth',
	'Demonite',
	'Bisonhawk',
	'Batoidei',
	'Giant Octopod',
	'Bisonbear',
	'Ouphnest',
	'Sea Worm (Unused)',
	'Mystic Doll',
	'Man-Eater Chest',
	'Dragonpup',
	'Phantom Knight',
	'Metal Slime',
	'Lethal Armor',
	'Curer',
	'Flamer',
	'Chillanodon',
	'Savnuck',
	'Mimic',
	'Tyranosaur',
	'Phantom Messenger',
	'Mantam',
	'Barrenth',
	'Rhinothrope',
	'Bengal',
	'Sea Lion (Unused)',
	'Beleth',
	'Archbison',
	'Maelstrom',
	'Skullknight',
	'Great Ohrus',
	'Dragonit',
	'Hambalba',
	'Hemasword',
	'Zapangler (Unused)',
	'Jumbat',
	'Minidemon',
	'Metal Babble',
	'Plesiodon',
	'Tyranobat',
	'Bomb Crag',
	'Raygarth',
	'Bebanbar',
	'Leaonar',
	'Balakooda',
	'Doolsnake',
	'Rhinoband',
	'Tyranobat',
	'Fury Face',
	'Karon',
	'Maskan',
	'Snowjive',
	'Necrodain',
	'Blizag',
	'Tentagor',
	'Chaos Hopper',
	'Podokesaur',
	'Eigerhorn',
	'Ogre',
	'Red Cyclone',
	'Dragon Rider',
	'Ryvern',
	'Ferocial',
	'Master Necrodain',
	'Wilymage',
	'Clay Doll',
	'Infurnus Sentinel',
	'Green Dragon',
	'Bellzabble',
	'Noctabat',
	'Beastan',
	'King Healer',
	'Leaping Maskan',
	'Impostor',
	'Pit Viper',
	'Rhinoking',
	'Bharack',
	'Flamadog',
	'Fairy Dragon',
	'Demighoul',
	'Bull Basher',
	'Red Dragon',
	'Big Sloth',
	'Guardian',
	'Swinger',
	'Master Malice',
	'Duke Malisto',
	'Great Ridon',
	'King Metal',
	'Ryvernlord',
	'Spite Spirit',
	'Mighty Healer',
	'Ogrebasher',
	'Zeroes...?',
	'Necrosaro 1',
	'Hun',
	'Roric',
	'Vivian',
	'Sampson',
	"Saro's Shadow",
	'Balzack (Chapter 4)',
	'Balzack (Chapter 5)',
	'Radimvice',
	'Infurnus Shadow',
	'Anderoug',
	'Gigademon',
	'Linguar',
	'Keeleon (Chapter 4)',
	'Esturk',
	'Zeroes...?',
	'Keeleon (Chapter 5)',
	'Lighthouse Bengal',
	'Tricksy Urchin',
	'Saroknight',
	'Bakor',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Dummy...?',
	'Necrosaro 2',
	'Necrosaro 3',
	'Necrosaro 4',
	'Necrosaro 5',
	'Necrosaro 6',
	'Necrosaro 7',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	''
}




skills = {}
i = 0
while i <= 255 do
	skills[i] = '(Unknown)'
	i = i + 1
end
skills[0x00+1] = 'Blaze' --Saro's Shadow
skills[0x01+1] = 'Blazemore'
skills[0x02+1] = 'Blazemost'
skills[0x03+1] = 'Firebal' --Saro's Shadow
skills[0x04+1] = 'Firebane'
skills[0x05+1] = 'Firevolt'
skills[0x06+1] = 'Explodet?' --Infernus Shadow, Demonite
skills[0x07+1] = 'Icebolt' --Ozwarg
skills[0x17+1] = 'Defense' --Crested Viper
skills[0x1C+1] = 'Upper' --Lilypa
skills[0x1E+1] = 'Speedup' --Pixie
skills[0x32+1] = 'Basic Attack' --Slime, et al
skills[0x35+1] = 'Sleephit'--Giant Bantam
skills[0x36+1] = 'Poisonhit'--Babble, Poison Arrop, Crested Viper
skills[0x3C+1] = 'Weak Fireball' --Infernus Beetle, Thevro, Saro's Shadow
skills[0x48+1] = 'Backup' --Diverat, Troglodyte, Viceter






function DEC_HEX(IN,final_digits)
	if final_digits == nil then final_digits = 2 end
    Base = 16;
	Values = "0123456789ABCDEF";
	OUT = "";
	Digit = 0;
	I = 0;
	digits = 0;
    while IN>0 do
        I=I+1;
		Digit=math.mod(IN,Base)+1;
        IN=math.floor(IN/Base);
        OUT=string.sub(Values,Digit,Digit)..OUT;
		digits = digits + 1;
    end;
	while digits < final_digits do
		OUT = '0'..OUT;
		digits = digits + 1;
	end;
    return OUT;
end;
function DEC_BIN(IN,final_digits)
	if final_digits == nil then final_digits = 8 end
    Base = 2;
	Values = "01";
	OUT = "";
	Digit = 0;
	I = 0;
	digits = 0;
    while IN>0 do
        I=I+1;
		Digit=math.mod(IN,Base)+1;
        IN=math.floor(IN/Base);
        OUT=string.sub(Values,Digit,Digit)..OUT;
		digits = digits + 1;
    end;
	while digits < final_digits do
		OUT = '0'..OUT;
		digits = digits + 1;
	end;
    return OUT;
end;






first_monster = 0x60051
monster_data_length = 22

function txtDump()
	outfile = io.open("Dragon Warrior IV Monster Data Dump.txt","w+")
	io.output(outfile)
	i = 0
	while i < 211 do
		io.write("Monster Name: "..Monster_Names[i+1]..' (#'..(i+1)..')\n')
		
		j = 0
		while j <= 24 do
			value = rom.readbyte(first_monster + monster_data_length * i + 0)
			io.write(DEC_HEX(j,2)..' - ')
			if(j == 1) then io.write('????') end
			if(j == 1) then io.write('????') end
			if(j == 1) then io.write('????') end
			io.write(DEC_HEX(value,2)..' ('..value..')')
		end
		
		io.write('00  - ????: 0x'..DEC_HEX(rom.readbyte(first_monster + monster_data_length * i + 0))..'\n')
		io.write('01  - ????: 0x'..DEC_HEX(rom.readbyte(first_monster + monster_data_length * i + 1))..'\n')
		io.write('02  - ????: 0x'..DEC_HEX(rom.readbyte(first_monster + monster_data_length * i + 2))..'\n')
		io.write('03  - ????: 0x'..DEC_HEX(rom.readbyte(first_monster + monster_data_length * i + 3))..'\n')
		io.write('04  - ????: 0x'..DEC_HEX(rom.readbyte(first_monster + monster_data_length * i + 4))..'\n')
		io.write('05  -  XP1: '..rom.readbyte(first_monster + monster_data_length * i + 5)..'\n')
		io.write('06  -  XP2: '..rom.readbyte(first_monster + monster_data_length * i + 6)..' (Total: '..(rom.readbyte(first_monster + monster_data_length * i + 5)+rom.readbyte(first_monster + monster_data_length * i + 6)*0x100)..')'..'\n')
		io.write('07  -  AGI: '..rom.readbyte(first_monster + monster_data_length * i + 7)..'\n')
		io.write('08  -  MP : '..rom.readbyte(first_monster + monster_data_length * i + 8)..'\n')
		io.write('09  -  HP1: '..rom.readbyte(first_monster + monster_data_length * i + 9)..'\n')
		io.write('0A  -  STR: '..rom.readbyte(first_monster + monster_data_length * i + 10)..'\n')
		io.write('0B  -  DEF: '..rom.readbyte(first_monster + monster_data_length * i + 11)..'\n')
		io.write('0C  -  GP1: '..rom.readbyte(first_monster + monster_data_length * i + 12)..'\n')
		-- Leftmost bit on 0D may be for "focus" -- see Lethal Gopher and Kaskos Hopper
		io.write('0D.0 - FOCUS: '..(math.round(AND(rom.readbyte(first_monster + monster_data_length * i + 13),0x80)/128))..'\n')
		io.write('0D.1-7 - DROP: 0x'..DEC_HEX(AND(rom.readbyte(first_monster + monster_data_length * i + 13),0x7F))..'\n')
		--Skills can be as high as 0x66 (Randohacker code) so only leftmost bit means something else...
		--0E Leftmost bit set for: Ozwarg, Vampire Bat
		io.write('0E  - SKL1: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 14)))..'\n')
		--0F Leftmost bit set for: Lilypa
		io.write('0F  - SKL2: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 15)))..'\n')
		io.write('10  - SKL3: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 16)))..'\n')
		io.write('11  - SKL4: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 17)))..'\n')
		io.write('12  - SKL5: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 18)))..'\n')
		io.write('13  - SKL6: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 19)))..'\n')
		--Wind?, Fire?, Ice?, NOT A RESISTANCE (MS has a zero here)
		io.write('14  - ????: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 20)))..'\n')
		--???, ???, ???, Extra attack bits (only used by Necrosaro 6-7)
		io.write('15  - ????: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 21)))..'\n')
		--???, ???, ???, Extra defense bits (only used by metals)
		io.write('16  - ????: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 22)))..'\n')
		--???, ???, ???, Extra gold bit
		io.write('17  - ????: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 23)))..'\n')
		io.write('18  - ????: 0x'..DEC_HEX((rom.readbyte(first_monster + monster_data_length * i + 24)))..'\n')
		
		io.write('\n')
		i = i + 1
	end
	io.close(outfile)
end


--Create CSV dump of all stats
function dump()
	outfile = io.open("Dragon Warrior IV Monster Data Dump.csv","w+")
	io.output(outfile)
	i = 0
	while i < 211 do
		io.write((i+1)..",'"..Monster_Names[i+1].."',")
		
		j = 0
		while j < 25 do
			io.write(rom.readbyte(first_monster + monster_data_length * i + j))
			if j ~= 24 then io.write(',') end
			j = j + 1
		end
		
		io.write('\n')
		i = i + 1
	end
	io.close(outfile)
end





--This code will check for DIFFERENCES between the selected monster and EVERY MONSTER in the given range.
--Basically, anything I have that you don't.
function Diff(check,first,last)
	outfile = io.open("Dragon Warrior IV Monster Data Dump DIFF.txt","w+")
	io.output(outfile)
	io.write('\n')
	io.write('\n')
	io.write('\n')
	io.write('Differences: \n')
	i = 0
	j = 0
	k = last --Last monster to check, 0-210
	l = first --First monster to check, 0-210 (Shut up)
	monster_to_check = check --Corresponds to the number spat out above
	data = 0
	while j < 28 do
		data = (rom.readbyte(first_monster + monster_data_length * (monster_to_check-1) + j))
		i = l
		while i <= k and i <= 210 do
			if j == 10 then --uncomment to spit out progress for one stat
			--	io.write(DEC_HEX(j,2)..'  - ????: 0x'..DEC_HEX(data)..' & 0x'..DEC_HEX(0xFF - rom.readbyte(first_monster + monster_data_length * i + j),2))
			end
			data = AND(data,0xFF - rom.readbyte(first_monster + monster_data_length * i + j))
			if j == 10 then
			--	io.write(' = 0x'..DEC_HEX(data)..'\n')
			end
			i = i + 1
		end
		io.write(DEC_HEX(j,2)..'  - ????: 0x'..DEC_HEX(data)..'\n')
		j = j + 1
	end
	io.close(outfile)
end

dump()