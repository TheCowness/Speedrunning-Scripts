<?php

$db = mysqli_connect('xxxxxx','xxxxxx','xxxxxx');
mysqli_select_db($db,'dragonquestmonsters');
$dbreturn = '';
//echo 'Database initialized.<br>';


//Sends a query to the database.  Return value is stored in dbreturn.
function execute($query){
	global $dbreturn;
	global $db;
	$dbreturn = mysqli_query($db,$query);
	if(!$dbreturn){
		error_log("Error with query: ".$query."\n".mysqli_error($db));
		echo mysqli_error($db);
	}
}
//Translate dbreturn into a readable PHP array
function get(){
	global $dbreturn;
	global $db;
	$array=mysqli_fetch_array($dbreturn);
	$return = array();
	if(is_array($array)){
		foreach($array as $key=>$index){
			if(!is_numeric($key)){
				$return[$key] = $array[$key];
			}
		}
	}
	return $return;
}

/*
	http://www.angelfire.com/comics2/fatboy9175/DW3Bestiary.txt
	https://github.com/gameboy9/DW3Randomizer/blob/master/DW3Randomizer/Form1.cs

Of course Vaxherd has everything I need...
	- Enemy data can be found at address $B2D3 in bank 0 (also entry $6A in
	  the BRK #$07 array).  The data is a list of 23-byte entries, one per
	  enemy; corresponding enemy names are stored as two sequences of
	  strings in bank 2, the first line's text at $B3BC and the second
	  line's text at $B8BF.  The data structure is as follows:
	   * Byte 0, bits 7-6: bits 4-3 of evade rate
	   * Byte 0, bits 5-0: level
	   * Bytes 1-2: experience
	   * Byte 3: speed
	   * Byte 4: gold (low 8 bits)
	   * Byte 5: attack power (low 8 bits)
	   * Byte 6: defense power (low 8 bits)
	   * Byte 7: base HP (low 8 bits)
	   * Byte 8: MP
	   * Byte 9, bit 7: bit 2 of evade rate (evade rate is a multiple of 4)
	   * Byte 9, bits 6-0: item dropped ($7F = none)
	   * Bytes 10-17, bits 5-0: possible actions
	   * Bytes 10-11, bit 7: AI type selector (byte 11 has the high bit)
		  - Type 0: random target choice
		  - Type 1: smart target choice
		  - Type 2: smart target choice, and action choice is delayed until
					enemy acts
	   * Bytes 12-13, bit 7: action chance selector
		  - Type 0: equal chance for all 8 actions
		  - Type 1: $12, $16, $1A, $1E, $22, $26, $2A, $2E (/256)
		  - Type 2: $02, $04, $06, $08, $0A, $0C, $0E, $C8 (/256)
		  - Type 3: fixed action sequence
	   * Bytes 14-15, bit 7: number of actions per turn
		  - For AI type 2: 1, 1-2, 1-2, 2     COW NOTE: This doesn't seem to be true???
		  - For other AI types: 1, 1-2, 2, 1-3
	   * Bytes 16-17, bit 7: HP regeneration selector
		  - Type 0: no regeneration
		  - Type 1: 16-23 HP/turn
		  - Type 2: 44-55 HP/turn
		  - Type 3: 90-109 HP/turn
	   * Byte 18, bits 7-6: fire damage resistance
	   * Byte 18, bits 5-4: ice damage resistance
	   * Byte 18, bits 3-2: wind damage resistance
	   * Byte 18, bits 1-0: gold (high 2 bits)
	   * Byte 19, bits 7-6: lightning damage resistance
	   * Byte 19, bits 5-4: instant death resistance
	   * Byte 19, bits 3-2: Sacrifice resistance
	   * Byte 19, bits 1-0: attack power (high 2 bits)
	   * Byte 20, bits 7-6: Sleep resistance
	   * Byte 20, bits 5-4: StopSpell resistance
	   * Byte 20, bits 3-2: Sap resistance
	   * Byte 20, bits 1-0: defense power (high 2 bits)
	   * Byte 21, bits 7-6: Surround resistance
	   * Byte 21, bits 5-4: RobMagic resistance
	   * Byte 21, bits 3-2: Chaos resistance
	   * Byte 21, bits 1-0: base HP (high 2 bits)
	   * Byte 22, bits 7-6: Slow / Limbo resistance
	   * Byte 22, bits 5-4: Expel / Fairy Water / Zombie Slasher resistance
	   * Byte 22, bit 3: focus-fire flag (if set, the enemy continually
						 attacks the same character until they die)
	   * Byte 22, bits 2-0: item drop chance (100%, 1/8, 1/16, 1/32, 1/64,
							1/128, 1/256, 1/2048)
*/
$db_query = "
SELECT
	*,
	--Number,
	--Name,
	((((Field1 >> 6) % 4) << 1) + (Field10 >> 7)) << 2 as Evasion,
	Field1 % 64 as Level,
	Field8 + (Field22 % 4) * 256 as HP,
	Field9 as MP,
	Field6 + (Field20 % 4) * 256 as Atk,
	Field7 + (Field21 % 4) * 256 as Def,
	Field4 as Agi,
	Field2 + Field3 * 256 as Exp,
	Field5 + (Field19 % 4) * 256 as Gold,
	Field10 % 128 as Item_Drop,
	Field23 % 8 as Drop_Chance,
	Field11 % 64 as Skill1,
	Field12 % 64 as Skill2,
	Field13 % 64 as Skill3,
	Field14 % 64 as Skill4,
	Field15 % 64 as Skill5,
	Field16 % 64 as Skill6,
	Field17 % 64 as Skill7,
	Field18 % 64 as Skill8,
	((Field11 >> 7) % 2)+((Field12 >> 7) % 2)*2 as AI_Weighted,
	((Field23 >> 3) % 2) as AI_Concentrated,
	((Field13 >> 7) % 2)+((Field14 >> 7) % 2)*2 as ActionWeights,
	((Field15 >> 7) % 2)+((Field16 >> 7) % 2)*2 as ActionCounts,
	((Field17 >> 7) % 2)+((Field18 >> 7) % 2)*2 as Regen,
	((Field19 >> 6) % 4) as Fire,
	((Field19 >> 4) % 4) as Ice,
	((Field19 >> 2) % 4) as Infernos,
	((Field20 >> 6) % 4) as Lightning,
	((Field20 >> 4) % 4) as Defeat,
	((Field20 >> 2) % 4) as Sacrifice,
	((Field21 >> 6) % 4) as Sleep,
	((Field21 >> 4) % 4) as Stopspell,
	((Field21 >> 2) % 4) as Defense,
	((Field22 >> 6) % 4) as Surround,
	((Field22 >> 4) % 4) as Robmagic,
	((Field22 >> 2) % 4) as Chaos,
	((Field23 >> 6) % 4) as Limbo,
	((Field23 >> 4) % 4) as Expel
FROM dragonwarrioriiiht_monsters
ORDER BY Number ASC
";
execute($db_query);

/*
   - Bytes 12-13, bit 7: action chance selector
	  - Type 0: equal chance for all 8 actions
	  - Type 1: $12, $16, $1A, $1E, $22, $26, $2A, $2E (/256)
	  - Type 2: $02, $04, $06, $08, $0A, $0C, $0E, $C8 (/256)
	  - Type 3: fixed action sequence
*/

$Skills = Array(
	0x00 => "Assessing",
	0x01 => "Parry",
	0x02 => "Attack",
	0x03 => "Critical Hit",
	0x04 => "Sleep Hit",
	0x05 => "Poison Hit",
	0x06 => "Numb Hit",
	0x07 => "Flee",
	0x08 => "Call Help",
	0x09 => "Curious dance",
	0x0A => "Fire Breath, Weak",
	0x0B => "Fire Breath, Medium",
	0x0C => "Fire Breath, Strong",
	0x0D => "Ice Breath, Weak",
	0x0E => "Ice Breath, Medium",
	0x0F => "Ice Breath, Strong",
	0x10 => "Sleep Breath",
	0x11 => "Poison Breath",
	0x12 => "Numb Breath",
	0x13 => "Blaze",
	0x14 => "Blazemore",
	0x15 => "Blazemost",
	0x16 => "Icebolt",
	0x17 => "Firebal",
	0x18 => "Firebane",
	0x19 => "Explodet",
	0x1A => "Snowblast",
	0x1B => "Snowstorm",
	0x1C => "Infernos",
	0x1D => "Infermore",
	0x1E => "Infermost",
	0x1F => "Beat",
	0x20 => "Defeat",
	0x21 => "Sacrifice",
	0x22 => "Sleep",
	0x23 => "Stopspell",
	0x24 => "Sap",
	0x25 => "Defence",
	0x26 => "Surround",
	0x27 => "Robmagic",
	0x28 => "Chaos",
	0x29 => "Slow",
	0x2A => "Limbo",
	0x2B => "Freezing Waves",
	0x2C => "Bounce",
	0x2D => "Increase (2D)",
	0x2E => "Increase (2E)",
	0x2F => "Vivify",
	0x30 => "Revive",
	0x31 => "Heal (31)",
	0x32 => "Healmore (32)",
	0x33 => "Healall (33)",
	0x34 => "Healus (34)",
	0x35 => "Healusall (35)",
	0x36 => "Heal (36)",
	0x37 => "Healmore (37)",
	0x38 => "Healall (38)",
	0x39 => "Healus (39)",
	0x3A => "Healusall (3A)",
	0x3B => "Call Healer",
	0x3C => "Call Granite Titan",
	0x3D => "Call Hork",
	0x3E => "Call Elysium Bird",
	0x3F => "Call Voodoo Shaman"
);

$Items = Array(
0x00 => "Cypress stick",
0x01 => "Club",
0x02 => "Copper sword",
0x03 => "Magic Knife",
0x04 => "Iron Spear",
0x05 => "Battle Axe",
0x06 => "Broad Sword",
0x07 => "Wizard's Wand",
0x08 => "Poison Needle",
0x09 => "Iron Claw",
0x0A => "Halberd",
0x0B => "Giant Shears",
0x0C => "Chain Sickle",
0x0D => "Sacred Claw",
0x0E => "Blizzard Blade",
0x0F => "Demon Axe",
0x10 => "Staff of Rain",
0x11 => "Sword of Gaia",
0x12 => "Magma Staff",
0x13 => "Sword of Destruction",
0x14 => "Multi-Edge Sword",
0x15 => "Staff of Force",
0x16 => "Fangs of Fenrir",
0x17 => "Zombie Slasher",
0x18 => "Falcon Sword",
0x19 => "Sledge Hammer",
0x1A => "Thunder Sword",
0x1B => "Staff of Thunder",
0x1C => "Sword of Kings",
0x1D => "Orochi Sword",
0x1E => "Dragon Killer",
0x1F => "Staff of Judgement",
0x20 => "Clothes",
0x21 => "Training Suit",
0x22 => "Leather Armor",
0x23 => "Flashy Clothes",
0x24 => "Half Plate Armor",
0x25 => "Full Plate Armor",
0x26 => "Magic Armor",
0x27 => "Cloak of Evasion",
0x28 => "Armor of Radiance",
0x29 => "Dark Robe",
0x2A => "Animal Suit",
0x2B => "Fighting Suit",
0x2C => "Sacred Robe",
0x2D => "Armor of Hades",
0x2E => "Flowing Robe",
0x2F => "Chain Mail",
0x30 => "Wayfarers Clothes",
0x31 => "Sizzling Swimsuit",
0x32 => "Soldier's Uniform",
0x33 => "Wool Robe",
0x34 => "Armor of Terrafirma",
0x35 => "Dragon Mail",
0x36 => "Swordedge Armor",
0x37 => "Angel's Robe",
0x38 => "Leather Shield",
0x39 => "Iron Shield",
0x3A => "Shield of Strength",
0x3B => "Shield of Heroes",
0x3C => "Shield of Sorrow",
0x3D => "Bronze Shield",
0x3E => "Silver Shield",
0x3F => "Golden Crown",
0x40 => "Iron Helmet",
0x41 => "Mysterious Hat",
0x42 => "Blessed Helmet",
0x43 => "Gambler's Turban",
0x44 => "Noh Mask",
0x45 => "Leather Helmet",
0x46 => "Iron Mask",
0x47 => "Sacred Amulet",
0x48 => "Ring of Life",
0x49 => "Shoes of Happiness",
0x4A => "Golden Claw",
0x4B => "Meteorite Armband",
0x4C => "Book of Satori",
0x4D => "",
0x4E => "Wizard's Ring",
0x4F => "Black Pepper",
0x50 => "Sage's Stone",
0x51 => "Mirror of Ra",
0x52 => "Vase of Draught",
0x53 => "Lamp of Darkness",
0x54 => "Staff of Change",
0x55 => "Stone of Life",
0x56 => "Invisibility Herb",
0x57 => "Magic Ball",
0x58 => "Thief's Key",
0x59 => "Magic Key",
0x5A => "Final Key",
0x5B => "Dream Ruby",
0x5C => "Wake-up Powder",
0x5D => "Royal Scroll",
0x5E => "Oricon",
0x5F => "Strength Seed",
0x60 => "Agility Seed",
0x61 => "Vitality Seed",
0x62 => "Luck Seed",
0x63 => "Intelligence Seed",
0x64 => "Acorns of Life",
0x65 => "Medical Herb",
0x66 => "Antidote Herb",
0x67 => "Fairy Water",
0x68 => "Wing of Wyvern",
0x69 => "Leaf of the World Tree",
0x6A => "",
0x6B => "Locket of Love",
0x6C => "Full Moon Herb",
0x6D => "Water Blaster",
0x6E => "Sailors Thigh Bone",
0x6F => "Echoing Flute",
0x70 => "Fairy Flute",
0x71 => "Silver Harp",
0x72 => "Sphere of Light",
0x73 => "Poison Moth Powder",
0x74 => "Spiders Web",
0x75 => "Stone of Sunlight",
0x76 => "Rainbow Drop",
0x77 => "Silver Orb",
0x78 => "Red Orb",
0x79 => "Yellow Orb",
0x7A => "Purple Orb",
0x7B => "Blue Orb",
0x7C => "Green Orb",
0x7D => "",
0x7E => "",
0x7F => "" //Vaxherd's notes say 7F equates to no item drop (think chests are the same) instead of the dummy 7F item
);


$ActionWeights = Array(
	0 => Array(
		0 => "12.5%",
		1 => "12.5%",
		2 => "12.5%",
		3 => "12.5%",
		4 => "12.5%",
		5 => "12.5%",
		6 => "12.5%",
		7 => "12.5%"
	),
	1 => Array(
		0 => round(100 * 0x12 / 256,1)."%",
		1 => round(100 * 0x16 / 256,1)."%",
		2 => round(100 * 0x1A / 256,1)."%",
		3 => round(100 * 0x1E / 256,1)."%",
		4 => round(100 * 0x22 / 256,1)."%",
		5 => round(100 * 0x26 / 256,1)."%",
		6 => round(100 * 0x2A / 256,1)."%",
		7 => round(100 * 0x2E / 256,1)."%",
	),
	2 => Array(
		0 => round(100 * 0x02 / 256,1)."%",
		1 => round(100 * 0x04 / 256,1)."%",
		2 => round(100 * 0x06 / 256,1)."%",
		3 => round(100 * 0x08 / 256,1)."%",
		4 => round(100 * 0x0A / 256,1)."%",
		5 => round(100 * 0x0C / 256,1)."%",
		6 => round(100 * 0x0E / 256,1)."%",
		7 => round(100 * 0xC8 / 256,1)."%",
	),
	3 => Array(
		0 => "->",
		1 => "->",
		2 => "->",
		3 => "->",
		4 => "->",
		5 => "->",
		6 => "->",
		7 => "->"
	)
);
?>
<script src="/Scripts/jquery-1_11_2_min.js" type="text/javascript"></script>
<div id="table-container">
<table id="monster-data-table" cellspacing=0>
	<thead>
	<tr>
		<th>Index</th>
		<th>Monster Name</th>
		<th>Level</th>
		<th>Actions</th>
		<th>AI</th>
		
		<th>HP</th>
		<th>MP</th>
		<th>ATK</th>
		<th>DEF</th>
		<th>AGI</th>
		<th>Evasion</th>
		<th>XP</th>
		<th>Gold</th>
		<th>Item</th>
		<th>Drop Chance</th>
		
		<th>Skill 1/5</th>
		<th>Skill 2/6</th>
		<th>Skill 3/7</th>
		<th>Skill 4/8</th>
		
		<th><div class="resistance-header">Fire</div></th>
		<th><div class="resistance-header">Ice</div></th>
		<th><div class="resistance-header">Infernos</div></th>
		<th><div class="resistance-header">Lightning</div></th>
		<th><div class="resistance-header">Defeat</div></th>
		<th><div class="resistance-header">Sacrifice</div></th>
		<th><div class="resistance-header">Sleep</div></th>
		<th><div class="resistance-header">Stopspell</div></th>
		<th><div class="resistance-header">Defense</div></th>
		<th><div class="resistance-header">Surround</div></th>
		<th><div class="resistance-header">Robmagic</div></th>
		<th><div class="resistance-header">Chaos</div></th>
		<th><div class="resistance-header">Limbo/Slow</div></th>
		<th><div class="resistance-header">Expel</div></th>
		
	</tr>
	</thead>
	<tbody>
<?php
$monsterctr = 0;
while($monster = get()){
	$monsterctr++;
	?>
	<tr class="monster<?php echo ($monsterctr % 2); ?>">
		<td><?php echo $monster["Number"] ?></td>
		<td><?php echo $monster["Name"] ?></td>
		<td><?php echo $monster["Level"] ?></td>
		<td><?php
			//echo $monster["ActionCounts"].','.$monster["AI_Weighted"].',';
			switch($monster["ActionCounts"]){
				case 0:
					echo '1';
					break;
				case 1:
					echo '1-2';
					break;
				/*
					Vaxherd's notes say to do this, but I don't think this is correct?
				case 2:
					if($monster["AI_Weighted"] == 2)
						echo '1-2';
					else
						echo '2';
					break;
				case 3:
					if($monster["AI_Weighted"] == 2)
						echo '2';
					else
						echo '1-3';
					break;
				*/
				case 2:
					echo '1-3';
					break;
				case 3:
					echo '2';
					break;
			}
		?></td>
		<td><?php
		switch($monster["AI_Weighted"]){
			case 2:
				echo 'S';
				break;
			case 1:
				echo 'N';
				break;
			default:
				echo 'U';
				break;
		}
		echo ($monster["AI_Concentrated"] ? 'C' : '');
		?></td>
		
		<td>
			<?php
				switch($monster["Name"]){
					case 'King Hydra':
						echo '<b>2300</b>';
						break;
					case 'Baramos Bomus':
						echo '<b>3000</b>';
						break;
					case 'Baramos Gonus':
						echo '<b>1200</b>';
						break;
					case 'Zoma (Strong)':
						echo '<b>10000</b>';
						break;
					case 'Zoma (Weak)':
						echo '<b>3000</b>';
						break;
					default:
						echo $monster["HP"];
				}
			?>
		</td>
		<td><?php echo $monster["MP"] ?></td>
		<td><?php echo $monster["Atk"] ?></td>
		<td><?php echo $monster["Def"] ?></td>
		<td><?php echo $monster["Agi"] ?></td>
		<td><?php echo (round($monster["Evasion"] / 0.256)/10).'%' ?></td>
		<td><?php echo $monster["Exp"] ?></td>
		<td><?php echo $monster["Gold"] ?></td>
		<td><?php echo $Items[$monster["Item_Drop"]] ?></td>
		<td>
		<?php
			//Vanilla: (100%, 1/8, 1/16, 1/32, 1/64, 1/128, 1/256, 1/2048)
			switch($monster["Drop_Chance"]){
				case 0:
					echo '1/1';
					break;
				case 1:
					echo '1/8';
					break;
				case 2:
					echo '1/16';
					break;
				case 3:
					echo '1/32';
					break;
				case 4:
					echo '1/64';
					break;
				case 5:
					echo '1/128';
					break;
				case 6:
					echo '1/256';
					break;
				case 7:
					echo '1/2048';
					break;
			}
		?>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill1"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][0]; ?>
			</span>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill2"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][1]; ?>
			</span>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill3"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][2]; ?>
			</span>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill4"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][3]; ?>
			</span>
		</td>
		
		<?php foreach(array("Fire","Ice","Infernos","Lightning","Defeat","Sacrifice","Sleep","Stopspell","Defense","Surround","Robmagic","Chaos","Limbo","Expel") as $resistance){
			
			$rescolor = "#fff";
			if($monster[$resistance] == 1) $rescolor = "#bbb";
			if($monster[$resistance] == 2) $rescolor = "#666";
			if($monster[$resistance] == 3) $rescolor = "#000";
		?>
			<td style="background-color:<?php echo $rescolor; ?>;color:<?php echo $rescolor; ?>;" rowspan=2><?php echo round($monster[$resistance]); ?></td>
		<?php
		}
		?>
	</tr>
	<tr class="monster<?php echo ($monsterctr % 2); ?>">
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		
		<?php
			$regen = '';
			switch($monster["Regen"]){
				case 1:
					$regen = "(+20)";
					break;
				case 2:
					$regen = "(+50)";
					break;
				case 3:
					$regen = "(+100)";
					break;
				default:
					$regen = '';
					break;
			}
		?>
		
		<td><?php echo $regen; ?></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		
		<td>
			<?php echo $Skills[$monster["Skill5"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][4]; ?>
			</span>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill6"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][5]; ?>
			</span>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill7"]]; ?>
			<span class="skill_weight">
			<?php echo $ActionWeights[$monster["ActionWeights"]][6]; ?>
			</span>
		</td>
		<td>
			<?php echo $Skills[$monster["Skill8"]]; ?>
			<span class="skill_weight" <?php echo $monster["ActionWeights"] == 2 ? 'style="font-weight:bold"' : ''; ?>>
			<?php echo $ActionWeights[$monster["ActionWeights"]][7]; ?>
			</span>
		</td>
		
		<?php foreach(array("Fire","Ice","Infernos","Lightning","Defeat","Sacrifice","Sleep","Stopspell","Defense","Surround","Robmagic","Chaos","Limbo","Expel") as $resistance){
		?>
			
		<?php
		}
		?>
	</tr>
	</tbody>
	<?php
}
?>
</table>
<div id="bottom_anchor"></div>
</div>
<style type="text/css">
.resistance-header {
	width:12px;
	margin-left:12px;
	
	-webkit-transform: rotate(-90deg);
	-moz-transform: rotate(-90deg);
	-ms-transform: rotate(-90deg);
	-o-transform: rotate(-90deg);
	transform: rotate(-90deg);

	/* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
	-webkit-transform-origin: 50% 50%;
	-moz-transform-origin: 50% 50%;
	-ms-transform-origin: 50% 50%;
	-o-transform-origin: 50% 50%;
	transform-origin: 0% 50%;

	/* Should be unset in IE9+ I think. */
	filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
}
table th{
	padding-top:150px;
	border-bottom:1px solid #ccc;
}

body { height: 1000px;}
#clone thead{
    background-color:white;
}

.monster1{
	background-color: #f0f0f8;
}
.monster0{
	background-color: white;
}

.skill_weight{
	font-size:9px;
}

</style>
<script type="text/javascript">
function moveScroll(){
    var scroll = $(window).scrollTop();
    var anchor_top = $("#monster-data-table").offset().top;
    var anchor_bottom = $("#bottom_anchor").offset().top;
    if (scroll>anchor_top && scroll<anchor_bottom) {
		clone_table = $("#clone");
		if(clone_table.length == 0){
			clone_table = $("#monster-data-table").clone();
			clone_table.attr('id', 'clone');
			clone_table.width($("#monster-data-table").width());
			$("#table-container").append(clone_table);
			$("#clone").css({visibility:'hidden'});
			$("#clone thead").css({'visibility':'visible','pointer-events':'auto'});
			clone_table.css({position:'fixed',
					 'pointer-events': 'none',
					 top: 0 });
		}
    } else {
    $("#clone").remove();
    }
}
$(window).scroll(moveScroll); 
moveScroll();
</script>
<script type="text/javascript">
function moveScroll(){
    var scroll = $(window).scrollTop();
    var anchor_top = $("#monster-data-table").offset().top;
    var anchor_bottom = $("#bottom_anchor").offset().top;
    if (scroll>anchor_top && scroll<anchor_bottom) {
		clone_table = $("#clone");
		if(clone_table.length == 0){
			clone_table = $("#monster-data-table").clone();
			clone_table.attr('id', 'clone');
			clone_table.width($("#monster-data-table").width());
			$("#table-container").append(clone_table);
			$("#clone").css({visibility:'hidden'});
			$("#clone thead").css({'visibility':'visible','pointer-events':'auto'});
			clone_table.css({position:'fixed',
					 'pointer-events': 'none',
					 top: 0 });
		}
    } else {
    $("#clone").remove();
    }
}
$(window).scroll(moveScroll); 
moveScroll();
</script>
<br>
<br>
<u>Additional Notes:</u><br><br>
This data is all for the "Dragon Warrior III Hardtype" hack by Zombero.  If you want data for the vanilla game, remove the "HT" from your address bar.<br>
<br>
The bolded HP values for the end-game bosses do not come from the monster data table.  It appears their HP is raised after the battle starts, because the data table only supports enemy HP values up to 1023.<br>
<br>
Note that Marauder and Orochi each have one skill where the second bit is set to 1, and I don't know what that means.  Vanilla DW3 doesn't have any monsters with skills like this, so it may just be a mistake in the hack.
<br><br>
<?php 
//Not entirely sure why I re-opened this tag.
?>