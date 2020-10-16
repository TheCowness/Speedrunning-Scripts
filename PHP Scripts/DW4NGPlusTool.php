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

function getAll(){
	$returnArr = array();
	while($get = get()){
		$returnArr[] = $get;
	}
	return $returnArr;
}

$query = 'SELECT * FROM dragonwarrioriv_items ORDER BY id asc';
execute($query);
$all_items = getAll();
$item_options = '';
foreach($all_items as $item){
	$item_options .= '<option value="'.$item['id'].'">'.$item['Name'].'</option>
';
}

if(array_key_exists("Submit",$_REQUEST)){
	try
	{

		$filename1 = $_FILES['InputFile1']['tmp_name'];
		$file1 = fopen($filename1, "rb");
		$romdata = fread($file1,filesize($filename1));
		fclose($file1);
		
	}
	catch (Exception $e)
	{
		echo "<b>Empty file name or unable to open file.  Please verify the file exists.</b><br><br>";
	}
	
	if(strlen($romdata) > 0){
		$i = 0;
		
		
		// Rename all characters - this starts at 0x2fba0
		$twoCharStrings = array( "er", "on", "an", "or", "ar", "le", "ro", "al", "re", "st", "in", "ba", "ra", "ma", // 20s, starting at 22
			" s", "he", "ea", "en", "th", "el", "n ", "te", "et", "e ", "mo", "of", "ng", "at", "de", "f ", // 30s
			"rd", "ta", "ag", "me", " o", "ir", "ha", "la", "ni", "ce", "hi", "ic", "ll", "li", "sa", "nt", // 40s
			"do", "ia", "no", "to", "ur", "es", "ou", "pe", "rm", "as", "il", "ri", " h", " m", "s ", "ab", // 50s
			"be", "ee", "em", "go", "it", "l ", "ve", "dr", "ie", "ne", "r ", "wo", "ad", "ch", "ed", "nd", // 60s
			"se", "sh", "tr", " a", "bl", "fe", "ld", "nc", "ol", "os", "rn", "si", "vi", " b", " d", "am", // 70s
			"ge", "ig", "mi", "ot", "ti", "us", " c", "g ", "is", "lo", "od", "sw", "za", "ze", " r", "ac", // 80s
			"cl", "co", "d ", "gh", "ho", "io", "ke", "oo", "op", "so", "un", "y ", "ai", "bi", "cr", "da", // 90s
			"id", "im", "om", "pi", "po", "af", "ck", "ff", "gi", "gu", "ht", "iv", "rr", "sp", "ss", "t ", // a0s
			"ab", "bo", "ec", "fu", "na", "sl", " p", " w", "|s", "ak", "di", "fi", "f ", "iz", "ki", "lu", // b0s
			"mp", "nf", "rc", "av", "bb", "ca", "ef", "eo", "fa", "fl", "ga", "gr", "ly", "mb", "nu", "og", // c0s
			"ow", "pa", "pl", "pp", "ry", "sk", "tt", "tu", "wi", " k", " n", " t", "ay", "az", "a ", "br", // d0s
			"ds", "fo", "kn", "k ", "lm", "ns", "oa", "ob", "oi", "ph", "ty", "ul", "um", "ut", "wa", "au", // e0s
			"dt", "c ", "d ", "eb", "ep", "ev", "ey", "e ", "ip", "ka", "ko", "nb", "pr", "rt", "sc", "ua"); // f0s

		$stringMarker = 0;
		$names = array(
				$_REQUEST["Cristo"],
				$_REQUEST["Nara"],
				$_REQUEST["Mara"],
				$_REQUEST["Brey"],
				$_REQUEST["Taloon"],
				$_REQUEST["Ragnar"],
				$_REQUEST["Alena"],
				$_REQUEST["Healie"],
				$_REQUEST["Orin"],
				$_REQUEST["Strom"],
				$_REQUEST["Laurent"],
				$_REQUEST["Hector"],
				$_REQUEST["Panon"],
				$_REQUEST["Lucia"],
				$_REQUEST["Doran"]
		);
			
		for ($lnI = 0; $lnI < 15; $lnI++)
		{
			
			$name = $names[$lnI];

			$byteArray = array();
			for ($lnJ = 0; $lnJ < strlen($name); $lnJ++)
			{
				if ($lnJ != strlen($name) - 1)
				{
					$twoCharStringToSample = substr($name,$lnJ, 2);
					$twoCharIndex = array_search($twoCharStringToSample, $twoCharStrings);
					if ($twoCharIndex !== FALSE)
					{
						$byteArray[] = (0x22 + $twoCharIndex);
						$lnJ++;
					} else
					{
						$character = ord(strtolower(substr($name, $lnJ, 1)));
						$byteArray[] = ($character - ord('a'));
					}
				} else
				{
					$character = ord(strtolower(substr($name, $lnJ, 1)));
					$byteArray[] = ($character - ord('a'));
				}
			}
			//echo ord($romdata[0x2fba0 + $stringMarker]).' => ';
			$romdata[0x2fba0 + $stringMarker] = chr(count($byteArray));
			//echo ord($romdata[0x2fba0 + $stringMarker]).'<br>';
			$stringMarker++;
			foreach ($byteArray as $byteSingle)
			{
				//echo ord($romdata[0x2fba0 + $stringMarker]).' => ';
				$romdata[0x2fba0 + $stringMarker] = chr($byteSingle);
				//echo ord($romdata[0x2fba0 + $stringMarker]).'<br>';
				$stringMarker++;
			}
		}
		//die();

		if ($stringMarker > 86)
		{
			die("Cannot continue hack; the names are too long to translate to rom hexadecimal.");
		}

		$romdata[0x2fba0 + $stringMarker + 0] = chr(4);
		$romdata[0x2fba0 + $stringMarker + 1] = chr(0x16);
		$romdata[0x2fba0 + $stringMarker + 2] = chr(0x32);
		$romdata[0x2fba0 + $stringMarker + 3] = chr(0xa4);
		$romdata[0x2fba0 + $stringMarker + 4] = chr(0xe5);
		$romdata[0x2fba0 + $stringMarker + 5] = chr(3);
		$romdata[0x2fba0 + $stringMarker + 6] = chr(0x26);
		$romdata[0x2fba0 + $stringMarker + 7] = chr(0x3a);
		$romdata[0x2fba0 + $stringMarker + 8] = chr(0x11);
		$romdata[0x2fba0 + $stringMarker + 9] = chr(4);
		$romdata[0x2fba0 + $stringMarker + 10] = chr(0x71);
		$romdata[0x2fba0 + $stringMarker + 11] = chr(0x68);
		$romdata[0x2fba0 + $stringMarker + 12] = chr(0x76);
		$romdata[0x2fba0 + $stringMarker + 13] = chr(0x12);
		$romdata[0x2fba0 + $stringMarker + 14] = chr(4);
		$romdata[0x2fba0 + $stringMarker + 15] = chr(0x31);
		$romdata[0x2fba0 + $stringMarker + 16] = chr(0xe4);
		$romdata[0x2fba0 + $stringMarker + 17] = chr(0x38);
		$romdata[0x2fba0 + $stringMarker + 18] = chr(0x12);
		// Calculate difference from 85 and $stringMarker.
		$difference = 87 - $stringMarker;
		$romdata[0x2fba0 + $stringMarker + 19] = chr(1);
		$romdata[0x2fba0 + $stringMarker + 20] = chr(0);
		$romdata[0x2fba0 + $stringMarker + 21] = chr(1);
		$romdata[0x2fba0 + $stringMarker + 22] = chr(0);
		$romdata[0x2fba0 + $stringMarker + 23] = chr(1);
		$romdata[0x2fba0 + $stringMarker + 24] = chr(0);
		$romdata[0x2fba0 + $stringMarker + 25] = chr(1);
		$romdata[0x2fba0 + $stringMarker + 26] = chr(0);
		$romdata[0x2fba0 + $stringMarker + 27] = chr(1);
		$romdata[0x2fba0 + $stringMarker + 28] = chr(0);
		$romdata[0x2fba0 + $stringMarker + 29] = chr($difference);
		for ($lnK = 0; $lnK < $difference; $lnK++)
		{
			$romdata[0x2fba0 + $stringMarker + 30 + $lnK] = chr(0);
		}
		
		//Hack in new inventories
		$characters = [
			0 => 'Hero',
			1 => 'Cristo',
			2 => 'Nara',
			3 => 'Mara',
			4 => 'Brey',
			5 => 'Taloon',
			6 => 'Ragnar',
			7 => 'Alena'
		];
		foreach($characters as $index=>$name){
			for($i = 0; $i < 8; $i++){
				$romdata[0x0491A1 + $index*8 + $i] = chr($_REQUEST['Item'.$i.$name] + (isset($_REQUEST['Item'.$i.$name.'Equipped']) ? 128 : 0));
			}
		}
		
		//Max out stats upon character initialization
		if(isset($_REQUEST['MaxOutStats'])){
			//Max out baby stats to 255
			$romdata[0x048F6F] = chr(0xA9); //Store FF in accumulator
			$romdata[0x048F70] = chr(0xFF); //
			//Max out HP/MP to 61680 (So that it can't overflow)
			$romdata[0x048F7D] = chr(0xA9); //Store F0 in accumulator
			$romdata[0x048F7E] = chr(0xF0); //
			$romdata[0x048F7F] = chr(0xEA); //nop
			$romdata[0x048F89] = chr(0xF0); //Upper byte of HP
			$romdata[0x048FA5] = chr(0xF0); //Upper byte of MP
			//Set level to 99
			$romdata[0x048FAA] = chr(0x63);
		}
		if(isset($_REQUEST['LevelOneSpells'])){
			//Set spell lists to 0xFF (Only for spell bytes that are normally modified)
			$romdata[0x041121] = chr(0xFF);
			//Even better than above, set all spells to be learned at level 1
			for($i = 0x4A2A9; $i <= 0x4A2BC; $i++){ //Hero
				$romdata[$i] = chr(0x01);
			}
			for($i = 0x4A2C5; $i <= 0x4A2D0; $i++){ //Nara
				$romdata[$i] = chr(0x01);
			}
			for($i = 0x4A2D9; $i <= 0x4A2E5; $i++){ //Cristo
				$romdata[$i] = chr(0x01);
			}
			for($i = 0x4A2EE; $i <= 0x4A2FC; $i++){ //Mara
				$romdata[$i] = chr(0x01);
			}
			for($i = 0x4A305; $i <= 0x4A313; $i++){ //Brey
				$romdata[$i] = chr(0x01);
			}
		}
		
		
		//Modify stats using Gameboy9's randomizeHeroStatsV2 function from the randohacker (DOES NOT WORK)
		/*if(isset($_REQUEST['MaxOutStats']))
		{
			$statsArr = [
				[255,255,255,255,255,255,255],
				[255,255,255,255,255,255,255],
				[255,255,255,255,255,255,255],
				[255,255,255,255,255,255,255],
				[255,255,255,255,255,255,255],
				[255,255,255,255,255,255,0],
				[10,20,30,40,50,60,70],
				[255,255,255,255,255,255,0]
			];
			// Skip the random bit
			$romPlugin = [ 0xa9, 0x20, 0x20, 0x91, 0xff ];
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[0x49e09 + $lnI] = chr($romPlugin[$lnI]);

			$romPlugin = [ 0x4c, 0x00, 0x90 ]; // JMP 9000
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[0x81e0e + $lnI] = chr($romPlugin[$lnI]);

			$romPlugin = [ 0xa9, 0x12, 0x20, 0x91, 0xff ]; // Will need to jump back to 9DFF
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[0x81e13 + $lnI] = chr($romPlugin[$lnI]);

			for ($lnI = 0; $lnI < 8; $lnI++)
			{
				for ($lnJ = 0; $lnJ < 7; $lnJ++)
				{
					$byteToUse = 0x82010 + ($lnI * 512) + ($lnJ * 50);
					$statGains = $statsArr[$lnI][$lnJ];

					if ($lnJ < 6 || $lnI < 5)
						for ($lnK = 0; $lnK < 50 - 1; $lnK++)
							$romdata[$byteToUse + $lnK] = chr($statGains);
				}
			}

			// And now to code all of this... starting from 0x81010 (9000)
			// 000B = Stat to use (A5 0B - LDA $000B)
			// 0079 - Character to use.  01/1F/3D/5B/79/97/B5/D3
			// Decrease 0079.  Then Store into 0004, then store 00 into 0005.  Then load #$1E into the accumulator, then perform division at C851.
			$pluginByte = 0x81010;
			$romPlugin = [ 0xc6, 0x79,
									 0xa5, 0x04,
									 0xa9, 0x00,
									 0xa5, 0x05,
									 0xa9, 0x1e,
									 0x20, 0x51, 0xc8 ]; // Division algorithm
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[$pluginByte + $lnI] = chr($romPlugin[$lnI]);
			$pluginByte += count($romPlugin);

			// This gets the character number.  ASL, CLC, ADC #$A0.  Place into a variable, place 00 in the variable previous.
			$romPlugin = [ 0xa5, 0x04,
									 0x0a,
									 0x18,
									 0x69, 0xa0,
									 0x8d, 0x01, 0x61 ];
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[$pluginByte + $lnI] = chr($romPlugin[$lnI]);
			$pluginByte += count($romPlugin);

			// LDA $#32, place 000B into 0004, multiply using C827.  Add 0004 to new variable, add 0005 to new variable + 1.
			$romPlugin = [ 0xa5, 0x0b,
									 0x85, 0x04,
									 0xa9, 0x32,
									 0x20, 0x27, 0xc8,
									 0xa5, 0x04,
									 0x8d, 0x00, 0x61,
									 0xa5, 0x05,
									 0x18,
									 0x6d, 0x01, 0x61,
									 0x8d, 0x01, 0x61 ];
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[$pluginByte + $lnI] = chr($romPlugin[$lnI]);
			$pluginByte += count($romPlugin);

			// Last piece of puzzle... what level is the person at?  Well, load $#05 to Y, load indirect 0079+Y, and you'll have the level required!  Add to new variable, add 00 w/ carry to 0005.
			$romPlugin = [ 0xa0, 0x05,
									 0xb1, 0x79,
									 0x18,
									 0x6d, 0x00, 0x61,
									 0x8d, 0x00, 0x61,
									 0xad, 0x01, 0x61,
									 0x69, 0x00,
									 0x8d, 0x01, 0x61 ];
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[$pluginByte + $lnI] = chr($romPlugin[$lnI]);
			$pluginByte += count($romPlugin);

			// Now you can finally load the number stored at A000-AFFF and you're a winner!  Store to 0004 then jump back to 9DFF when you're done.
			$romPlugin = [ 0xad, 0x01, 0x61,
									 0x85, 0x05,
									 0xad, 0x00, 0x61,
									 0x85, 0x04,
									 0xa0, 0x00,
									 0xb1, 0x04,
									 0x85, 0x04,
									 0x69, 0x00,
									 0x85, 0x05,
									 0x4c, 0xff, 0x9d ];
			for ($lnI = 0; $lnI < count($romPlugin); $lnI++)
				$romdata[$pluginByte + $lnI] = chr($romPlugin[$lnI]);
			$pluginByte += count($romPlugin);
		}*/
	
		header('Content-Disposition: attachment; filename="DW4_NGPHack.nes"');
		header("Content-Size: ".strlen($romdata)*512);
		echo $romdata;
		die();

		return true;
		
		
	}else{
		echo 'File was empty!<br><br>';
	}
}
?><html>
<head>
	<script type="text/javascript" src="../Scripts/jquery-1_11_2_min.js"></script>
</head>
<body>
<form action="DW4NGPlusTool.php" method="POST" enctype="multipart/form-data">
Input File:<br>
<input type="file" name="InputFile1" value="" id="input_file" size=50 /><br>
<hr>
Default Names: 
<input type="button" value="EN" id="RenameEN">
<input type="button" value="JP" id="RenameJP">
<input type="button" value="DS" id="RenameDS">
<table>
	<tr>
		<td>Ragnar:</td>
		<td><input id="NameRagnar" name="Ragnar" value="Ragnar"></td>
		<td>Healie:</td>
		<td><input id="NameHealie" name="Healie" value="Healie"></td>
	</tr>
	<tr>
		<td>Alena:</td>
		<td><input id="NameAlena" name="Alena" value="Alena"></td>
		<td>Cristo:</td>
		<td><input id="NameCristo" name="Cristo" value="Cristo"></td>
		<td>Brey:</td>
		<td><input id="NameBrey" name="Brey" value="Brey"></td>
	</tr>
	<tr>
		<td>Taloon:</td>
		<td><input id="NameTaloon" name="Taloon" value="Taloon"></td>
		<td>Laurent:</td>
		<td><input id="NameLaurent" name="Laurent" value="Laurent"></td>
		<td>Strom:</td>
		<td><input id="NameStrom" name="Strom" value="Strom"></td>
	</tr>
	<tr>
		<td>Nara:</td>
		<td><input id="NameNara" name="Nara" value="Nara"></td>
		<td>Mara:</td>
		<td><input id="NameMara" name="Mara" value="Mara"></td>
		<td>Orin:</td>
		<td><input id="NameOrin" name="Orin" value="Orin"></td>
	</tr>
	<tr>
		<td>Hector:</td>
		<td><input id="NameHector" name="Hector" value="Hector"></td>
		<td>Panon:</td>
		<td><input id="NamePanon" name="Panon" value="Panon"></td>
		<td>Lucia:</td>
		<td><input id="NameLucia" name="Lucia" value="Lucia"></td>
		<td>Doran:</td>
		<td><input id="NameDoran" name="Doran" value="Doran"></td>
	</tr>
</table>
<hr>
<?php
/*

Ragnar's stats:
0107040D0102001B00000000000082A6FFFFFFFFFFFF0000000000000000
01 07 04 0D 01 02 00 1B 00 00 00 00 00 00 82 A6 FF FF FF FF FF FF 00 00 00 00 00 00 00 00


Inventory order:
0x0491A1	Hero		82A4C674FFFFFFFF
0x0491A9	Cristo		A581FFFFFFFFFFFF
0x0491B1	Nara		82ABFFFFFFFFFFFF
0x0491B9	Mara		ACFFFFFFFFFFFFFF
0x0491C1	Brey		80A4FFFFFFFFFFFF
0x0491C9	Taloon		A474FFFFFFFFFFFF
0x0491D1	Ragnar		82A6FFFFFFFFFFFF
0x0491D9	Alena		ABFFFFFFFFFFFFFF

*/
?>
Inventories:
<input type="button" value="Default" id="ItemsDefault">
<input type="button" value="Empty" id="ItemsEmpty">
<input type="button" value="NG+" id="ItemsNGP">
<table>
	<tr>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Ragnar</th>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Alena</th>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Cristo</th>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Brey</th>
	</tr>
	<?php
	for($i = 0; $i < 8; $i++){
		?>
		<tr>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>RagnarEquipped" id="Item<?php echo $i; ?>RagnarEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Ragnar" id="Item<?php echo $i; ?>Ragnar">
				<?php echo $item_options; ?>
				</select>
			</td>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>AlenaEquipped" id="Item<?php echo $i; ?>AlenaEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Alena" id="Item<?php echo $i; ?>Alena">
				<?php echo $item_options; ?>
				</select>
			</td>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>CristoEquipped" id="Item<?php echo $i; ?>CristoEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Cristo" id="Item<?php echo $i; ?>Cristo">
				<?php echo $item_options; ?>
				</select>
			</td>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>BreyEquipped" id="Item<?php echo $i; ?>BreyEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Brey" id="Item<?php echo $i; ?>Brey">
				<?php echo $item_options; ?>
				</select>
			</td>
		</tr>
	<?php
	}
	?>
</table>
<table>
	<tr>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Taloon</th>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Nara</th>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Mara</th>
		<th style="color:#aaa;font-size:10px;vertical-align:bottom;padding-left:16px;">E</th>
		<th>Hero</th>
	</tr>
	<?php
	for($i = 0; $i < 8; $i++){
		?>
		<tr>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>TaloonEquipped" id="Item<?php echo $i; ?>TaloonEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Taloon" id="Item<?php echo $i; ?>Taloon">
				<?php echo $item_options; ?>
				</select>
			</td>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>NaraEquipped" id="Item<?php echo $i; ?>NaraEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Nara" id="Item<?php echo $i; ?>Nara">
				<?php echo $item_options; ?>
				</select>
			</td>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>MaraEquipped" id="Item<?php echo $i; ?>MaraEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Mara" id="Item<?php echo $i; ?>Mara">
				<?php echo $item_options; ?>
				</select>
			</td>
			<td style="padding-left:16px;">
				<input type="Checkbox" name="Item<?php echo $i; ?>HeroEquipped" id="Item<?php echo $i; ?>HeroEquipped">
			</td>
			<td>
				<select name="Item<?php echo $i; ?>Hero" id="Item<?php echo $i; ?>Hero">
				<?php echo $item_options; ?>
				</select>
			</td>
		</tr>
	<?php
	}
	?>
</table>
<hr>
Extra options:<br>
<input type="checkbox" name="MaxOutStats" id="MaxOutStats"> <label for="MaxOutStats">Max Out Stats and Level</label><br>
<input type="checkbox" name="LevelOneSpells" id="LevelOneSpells"> <label for="LevelOneSpells">Learn All Spells at Level 1 (does not change Int requirement)</label><br>
<hr>
<input type="Submit" name="Submit" value="Hack!" style="padding:8px 32px;">
</form>
<hr>
Note: This script will modify any file you upload to it per the parameters above.  Copyrighted materials (ROM data) including uploaded files are never stored on this server.

<script type="text/javascript">
$(document).ready(function(){
	$('#RenameEN').click(function(){
		$('#NameRagnar').val('Ragnar');
		$('#NameHealie').val('Healie');
		$('#NameAlena').val('Alena');
		$('#NameCristo').val('Cristo');
		$('#NameBrey').val('Brey');
		$('#NameTaloon').val('Taloon');
		$('#NameLaurent').val('Laurent');
		$('#NameStrom').val('Strom');
		$('#NameNara').val('Nara');
		$('#NameMara').val('Mara');
		$('#NameOrin').val('Orin');
		$('#NameHector').val('Hector');
		$('#NamePanon').val('Panon');
		$('#NameLucia').val('Lucia');
		$('#NameDoran').val('Doran');
	});
	$('#RenameJP').click(function(){
		$('#NameRagnar').val('Ryan');
		$('#NameHealie').val('Hoimin');
		$('#NameAlena').val('Arina');
		$('#NameCristo').val('Clift');
		$('#NameBrey').val('Burai');
		$('#NameTaloon').val('Torneko');
		$('#NameLaurent').val('Laurent');
		$('#NameStrom').val('Strom');
		$('#NameNara').val('Minea');
		$('#NameMara').val('Manya');
		$('#NameOrin').val('Orin');
		$('#NameHector').val('Hoffman');
		$('#NamePanon').val('Panon');
		$('#NameLucia').val('Lucia');
		$('#NameDoran').val('Doran');
	});
	$('#RenameDS').click(function(){
		$('#NameRagnar').val('Ragnar');
		$('#NameHealie').val('Healie');
		$('#NameAlena').val('Alena');
		$('#NameCristo').val('Kiryl');
		$('#NameBrey').val('Borya');
		$('#NameTaloon').val('Torneko');
		$('#NameLaurent').val('Laurel');
		$('#NameStrom').val('Hardie');
		$('#NameNara').val('Meena');
		$('#NameMara').val('Maya');
		$('#NameOrin').val('Oojam');
		$('#NameHector').val('Hank');
		$('#NamePanon').val('Tom');
		$('#NameLucia').val('Orifiela');
		$('#NameDoran').val('Sparkie');
	});
	$('#ItemsDefault').click(function(){
		$('#Item0Ragnar option:contains("Copper Sword")').prop('selected',true);
		$('#Item0RagnarEquipped').prop('checked',true);
		$('#Item1Ragnar option:contains("Leather Armor")').prop('selected',true);
		$('#Item1RagnarEquipped').prop('checked',true);
		$('#Item2Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item2RagnarEquipped').prop('checked',false);
		$('#Item3Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item3RagnarEquipped').prop('checked',false);
		$('#Item4Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item4RagnarEquipped').prop('checked',false);
		$('#Item5Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item5RagnarEquipped').prop('checked',false);
		$('#Item6Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item6RagnarEquipped').prop('checked',false);
		$('#Item7Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item7RagnarEquipped').prop('checked',false);
		
		$('#Item0Alena option:contains("Silk Robe")').prop('selected',true);
		$('#Item0AlenaEquipped').prop('checked',true);
		$('#Item1Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item1AlenaEquipped').prop('checked',false);
		$('#Item2Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item2AlenaEquipped').prop('checked',false);
		$('#Item3Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item3AlenaEquipped').prop('checked',false);
		$('#Item4Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item4AlenaEquipped').prop('checked',false);
		$('#Item5Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item5AlenaEquipped').prop('checked',false);
		$('#Item6Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item6AlenaEquipped').prop('checked',false);
		$('#Item7Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item7AlenaEquipped').prop('checked',false);
		
		$('#Item0Cristo option:contains("Copper Sword")').prop('selected',true);
		$('#Item0CristoEquipped').prop('checked',true);
		$('#Item1Cristo option:contains("Wayfarer")').prop('selected',true);
		$('#Item1CristoEquipped').prop('checked',true);
		$('#Item2Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item2CristoEquipped').prop('checked',false);
		$('#Item3Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item3CristoEquipped').prop('checked',false);
		$('#Item4Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item4CristoEquipped').prop('checked',false);
		$('#Item5Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item5CristoEquipped').prop('checked',false);
		$('#Item6Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item6CristoEquipped').prop('checked',false);
		$('#Item7Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item7CristoEquipped').prop('checked',false);
		
		$('#Item0Brey option:contains("Cypress Stick")').prop('selected',true);
		$('#Item0BreyEquipped').prop('checked',true);
		$('#Item1Brey option:contains("Basic Clothes")').prop('selected',true);
		$('#Item1BreyEquipped').prop('checked',true);
		$('#Item2Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item2BreyEquipped').prop('checked',false);
		$('#Item3Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item3BreyEquipped').prop('checked',false);
		$('#Item4Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item4BreyEquipped').prop('checked',false);
		$('#Item5Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item5BreyEquipped').prop('checked',false);
		$('#Item6Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item6BreyEquipped').prop('checked',false);
		$('#Item7Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item7BreyEquipped').prop('checked',false);
		
		$('#Item0Taloon option:contains("Basic Clothes")').prop('selected',true);
		$('#Item0TaloonEquipped').prop('checked',true);
		$('#Item1Taloon option:contains("Lunch")').prop('selected',true);
		$('#Item1TaloonEquipped').prop('checked',false);
		$('#Item2Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item2TaloonEquipped').prop('checked',false);
		$('#Item3Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item3TaloonEquipped').prop('checked',false);
		$('#Item4Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item4TaloonEquipped').prop('checked',false);
		$('#Item5Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item5TaloonEquipped').prop('checked',false);
		$('#Item6Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item6TaloonEquipped').prop('checked',false);
		$('#Item7Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item7TaloonEquipped').prop('checked',false);
		
		$('#Item0Nara option:contains("Copper Sword")').prop('selected',true);
		$('#Item0NaraEquipped').prop('checked',true);
		$('#Item1Nara option:contains("Silk Robe")').prop('selected',true);
		$('#Item1NaraEquipped').prop('checked',true);
		$('#Item2Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item2NaraEquipped').prop('checked',false);
		$('#Item3Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item3NaraEquipped').prop('checked',false);
		$('#Item4Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item4NaraEquipped').prop('checked',false);
		$('#Item5Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item5NaraEquipped').prop('checked',false);
		$('#Item6Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item6NaraEquipped').prop('checked',false);
		$('#Item7Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item7NaraEquipped').prop('checked',false);
		
		$('#Item0Mara option:contains("Dancer")').prop('selected',true);
		$('#Item0MaraEquipped').prop('checked',true);
		$('#Item1Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item1MaraEquipped').prop('checked',false);
		$('#Item2Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item2MaraEquipped').prop('checked',false);
		$('#Item3Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item3MaraEquipped').prop('checked',false);
		$('#Item4Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item4MaraEquipped').prop('checked',false);
		$('#Item5Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item5MaraEquipped').prop('checked',false);
		$('#Item6Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item6MaraEquipped').prop('checked',false);
		$('#Item7Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item7MaraEquipped').prop('checked',false);
		
		$('#Item0Hero option:contains("Copper Sword")').prop('selected',true);
		$('#Item0HeroEquipped').prop('checked',true);
		$('#Item1Hero option:contains("Basic Clothes")').prop('selected',true);
		$('#Item1HeroEquipped').prop('checked',true);
		$('#Item2Hero option:contains("Leather Hat")').prop('selected',true);
		$('#Item2HeroEquipped').prop('checked',true);
		$('#Item3Hero option:contains("Lunch")').prop('selected',true);
		$('#Item3HeroEquipped').prop('checked',false);
		$('#Item4Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item4HeroEquipped').prop('checked',false);
		$('#Item5Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item5HeroEquipped').prop('checked',false);
		$('#Item6Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item6HeroEquipped').prop('checked',false);
		$('#Item7Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item7HeroEquipped').prop('checked',false);
	});
		
	$('#ItemsEmpty').click(function(){
		$('#Item0Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item0RagnarEquipped').prop('checked',false);
		$('#Item1Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item1RagnarEquipped').prop('checked',false);
		$('#Item2Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item2RagnarEquipped').prop('checked',false);
		$('#Item3Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item3RagnarEquipped').prop('checked',false);
		$('#Item4Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item4RagnarEquipped').prop('checked',false);
		$('#Item5Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item5RagnarEquipped').prop('checked',false);
		$('#Item6Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item6RagnarEquipped').prop('checked',false);
		$('#Item7Ragnar option:contains("(Empty)")').prop('selected',true);
		$('#Item7RagnarEquipped').prop('checked',false);
		
		$('#Item0Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item0AlenaEquipped').prop('checked',false);
		$('#Item1Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item1AlenaEquipped').prop('checked',false);
		$('#Item2Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item2AlenaEquipped').prop('checked',false);
		$('#Item3Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item3AlenaEquipped').prop('checked',false);
		$('#Item4Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item4AlenaEquipped').prop('checked',false);
		$('#Item5Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item5AlenaEquipped').prop('checked',false);
		$('#Item6Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item6AlenaEquipped').prop('checked',false);
		$('#Item7Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item7AlenaEquipped').prop('checked',false);
		
		$('#Item0Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item0CristoEquipped').prop('checked',false);
		$('#Item1Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item1CristoEquipped').prop('checked',false);
		$('#Item2Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item2CristoEquipped').prop('checked',false);
		$('#Item3Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item3CristoEquipped').prop('checked',false);
		$('#Item4Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item4CristoEquipped').prop('checked',false);
		$('#Item5Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item5CristoEquipped').prop('checked',false);
		$('#Item6Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item6CristoEquipped').prop('checked',false);
		$('#Item7Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item7CristoEquipped').prop('checked',false);
		
		$('#Item0Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item0BreyEquipped').prop('checked',false);
		$('#Item1Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item1BreyEquipped').prop('checked',false);
		$('#Item2Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item2BreyEquipped').prop('checked',false);
		$('#Item3Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item3BreyEquipped').prop('checked',false);
		$('#Item4Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item4BreyEquipped').prop('checked',false);
		$('#Item5Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item5BreyEquipped').prop('checked',false);
		$('#Item6Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item6BreyEquipped').prop('checked',false);
		$('#Item7Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item7BreyEquipped').prop('checked',false);
		
		$('#Item0Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item0TaloonEquipped').prop('checked',false);
		$('#Item1Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item1TaloonEquipped').prop('checked',false);
		$('#Item2Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item2TaloonEquipped').prop('checked',false);
		$('#Item3Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item3TaloonEquipped').prop('checked',false);
		$('#Item4Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item4TaloonEquipped').prop('checked',false);
		$('#Item5Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item5TaloonEquipped').prop('checked',false);
		$('#Item6Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item6TaloonEquipped').prop('checked',false);
		$('#Item7Taloon option:contains("(Empty)")').prop('selected',true);
		$('#Item7TaloonEquipped').prop('checked',false);
		
		$('#Item0Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item0NaraEquipped').prop('checked',false);
		$('#Item1Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item1NaraEquipped').prop('checked',false);
		$('#Item2Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item2NaraEquipped').prop('checked',false);
		$('#Item3Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item3NaraEquipped').prop('checked',false);
		$('#Item4Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item4NaraEquipped').prop('checked',false);
		$('#Item5Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item5NaraEquipped').prop('checked',false);
		$('#Item6Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item6NaraEquipped').prop('checked',false);
		$('#Item7Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item7NaraEquipped').prop('checked',false);
		
		$('#Item0Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item0MaraEquipped').prop('checked',false);
		$('#Item1Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item1MaraEquipped').prop('checked',false);
		$('#Item2Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item2MaraEquipped').prop('checked',false);
		$('#Item3Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item3MaraEquipped').prop('checked',false);
		$('#Item4Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item4MaraEquipped').prop('checked',false);
		$('#Item5Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item5MaraEquipped').prop('checked',false);
		$('#Item6Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item6MaraEquipped').prop('checked',false);
		$('#Item7Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item7MaraEquipped').prop('checked',false);
		
		$('#Item0Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item0HeroEquipped').prop('checked',false);
		$('#Item1Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item1HeroEquipped').prop('checked',false);
		$('#Item2Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item2HeroEquipped').prop('checked',false);
		$('#Item3Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item3HeroEquipped').prop('checked',false);
		$('#Item4Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item4HeroEquipped').prop('checked',false);
		$('#Item5Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item5HeroEquipped').prop('checked',false);
		$('#Item6Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item6HeroEquipped').prop('checked',false);
		$('#Item7Hero option:contains("(Empty)")').prop('selected',true);
		$('#Item7HeroEquipped').prop('checked',false);
	});
	$('#ItemsNGP').click(function(){
		$('#Item0Ragnar option:contains("Fairy Water")').prop('selected',true);
		$('#Item0RagnarEquipped').prop('checked',false);
		$('#Item1Ragnar option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item1RagnarEquipped').prop('checked',false);
		$('#Item2Ragnar option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item2RagnarEquipped').prop('checked',false);
		$('#Item3Ragnar option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item3RagnarEquipped').prop('checked',false);
		$('#Item4Ragnar option:contains("Demon Hammer")').prop('selected',true);
		$('#Item4RagnarEquipped').prop('checked',true);
		$('#Item5Ragnar option:contains("Dragon Mail")').prop('selected',true);
		$('#Item5RagnarEquipped').prop('checked',true);
		$('#Item6Ragnar option:contains("Shield of Strength")').prop('selected',true);
		$('#Item6RagnarEquipped').prop('checked',true);
		$('#Item7Ragnar option:contains("Metal Babble Helm")').prop('selected',true);
		$('#Item7RagnarEquipped').prop('checked',true);
		
		$('#Item0Alena option:contains("Fire Claw")').prop('selected',true);
		$('#Item0AlenaEquipped').prop('checked',true);
		$('#Item1Alena option:contains("Stilleto Earrings")').prop('selected',true);
		$('#Item1AlenaEquipped').prop('checked',false);
		$('#Item2Alena option:contains("Cloak of Evasion")').prop('selected',true);
		$('#Item2AlenaEquipped').prop('checked',true);
		$('#Item3Alena option:contains("Final Key")').prop('selected',true);
		$('#Item3AlenaEquipped').prop('checked',false);
		$('#Item4Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item4AlenaEquipped').prop('checked',false);
		$('#Item5Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item5AlenaEquipped').prop('checked',false);
		$('#Item6Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item6AlenaEquipped').prop('checked',false);
		$('#Item7Alena option:contains("(Empty)")').prop('selected',true);
		$('#Item7AlenaEquipped').prop('checked',false);
		
		$('#Item0Cristo option:contains("Sword of Miracles")').prop('selected',true);
		$('#Item0CristoEquipped').prop('checked',true);
		$('#Item1Cristo option:contains("Sacred Robe")').prop('selected',true);
		$('#Item1CristoEquipped').prop('checked',true);
		$('#Item2Cristo option:contains("Metal Babble Shield")').prop('selected',true);
		$('#Item2CristoEquipped').prop('checked',true);
		$('#Item3Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item3CristoEquipped').prop('checked',false);
		$('#Item4Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item4CristoEquipped').prop('checked',false);
		$('#Item5Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item5CristoEquipped').prop('checked',false);
		$('#Item6Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item6CristoEquipped').prop('checked',false);
		$('#Item7Cristo option:contains("(Empty)")').prop('selected',true);
		$('#Item7CristoEquipped').prop('checked',false);
		
		$('#Item0Brey option:contains("Fairy Water")').prop('selected',true);
		$('#Item0BreyEquipped').prop('checked',false);
		$('#Item1Brey option:contains("Fairy Water")').prop('selected',true);
		$('#Item1BreyEquipped').prop('checked',false);
		$('#Item2Brey option:contains("Fairy Water")').prop('selected',true);
		$('#Item2BreyEquipped').prop('checked',false);
		$('#Item3Brey option:contains("Fairy Water")').prop('selected',true);
		$('#Item3BreyEquipped').prop('checked',false);
		$('#Item4Brey option:contains("Metal Babble Shield")').prop('selected',true);
		$('#Item4BreyEquipped').prop('checked',true);
		$('#Item5Brey option:contains("Water Flying Clothes")').prop('selected',true);
		$('#Item5BreyEquipped').prop('checked',true);
		$('#Item6Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item6BreyEquipped').prop('checked',false);
		$('#Item7Brey option:contains("(Empty)")').prop('selected',true);
		$('#Item7BreyEquipped').prop('checked',false);
		
		$('#Item0Taloon option:contains("Metal Babble Sword")').prop('selected',true);
		$('#Item0TaloonEquipped').prop('checked',true);
		$('#Item1Taloon option:contains("Metal Babble Armor")').prop('selected',true);
		$('#Item1TaloonEquipped').prop('checked',true);
		$('#Item2Taloon option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item2TaloonEquipped').prop('checked',false);
		$('#Item3Taloon option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item3TaloonEquipped').prop('checked',false);
		$('#Item4Taloon option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item4TaloonEquipped').prop('checked',false);
		$('#Item5Taloon option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item5TaloonEquipped').prop('checked',false);
		$('#Item6Taloon option:contains("Wing of Wyvern")').prop('selected',true);
		$('#Item6TaloonEquipped').prop('checked',false);
		$('#Item7Taloon option:contains("Fairy Water")').prop('selected',true);
		$('#Item7TaloonEquipped').prop('checked',false);
		
		$('#Item0Nara option:contains("Fairy Water")').prop('selected',true);
		$('#Item0NaraEquipped').prop('checked',false);
		$('#Item1Nara option:contains("Water Flying Clothes")').prop('selected',true);
		$('#Item1NaraEquipped').prop('checked',true);
		$('#Item2Nara option:contains("Boarding Pass")').prop('selected',true);
		$('#Item2NaraEquipped').prop('checked',false);
		$('#Item3Nara option:contains("Sword of Miracles")').prop('selected',true);
		$('#Item3NaraEquipped').prop('checked',true);
		$('#Item4Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item4NaraEquipped').prop('checked',false);
		$('#Item5Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item5NaraEquipped').prop('checked',false);
		$('#Item6Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item6NaraEquipped').prop('checked',false);
		$('#Item7Nara option:contains("(Empty)")').prop('selected',true);
		$('#Item7NaraEquipped').prop('checked',false);
		
		$('#Item0Mara option:contains("Water Flying Clothes")').prop('selected',true);
		$('#Item0MaraEquipped').prop('checked',true);
		$('#Item1Mara option:contains("Magic Key")').prop('selected',true);
		$('#Item1MaraEquipped').prop('checked',false);
		$('#Item2Mara option:contains("Metal Babble Armor")').prop('selected',true);
		$('#Item2MaraEquipped').prop('checked',false);
		$('#Item3Mara option:contains("Metal Babble Armor")').prop('selected',true);
		$('#Item3MaraEquipped').prop('checked',false);
		$('#Item4Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item4MaraEquipped').prop('checked',false);
		$('#Item5Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item5MaraEquipped').prop('checked',false);
		$('#Item6Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item6MaraEquipped').prop('checked',false);
		$('#Item7Mara option:contains("(Empty)")').prop('selected',true);
		$('#Item7MaraEquipped').prop('checked',false);
		
		$('#Item0Hero option:contains("Zenithian Sword (Powered Up)")').prop('selected',true);
		$('#Item0HeroEquipped').prop('checked',true);
		$('#Item1Hero option:contains("Zenithian Armor")').prop('selected',true);
		$('#Item1HeroEquipped').prop('checked',true);
		$('#Item2Hero option:contains("Zenithian Helm")').prop('selected',true);
		$('#Item2HeroEquipped').prop('checked',true);
		$('#Item3Hero option:contains("Zenithian Shield")').prop('selected',true);
		$('#Item3HeroEquipped').prop('checked',true);
		$('#Item4Hero option:contains("Symbol of Faith")').prop('selected',true);
		$('#Item4HeroEquipped').prop('checked',false);
		$('#Item5Hero option:contains("Gas Canister")').prop('selected',true);
		$('#Item5HeroEquipped').prop('checked',false);
		$('#Item6Hero option:contains("Sword of Lethargy")').prop('selected',true);
		$('#Item6HeroEquipped').prop('checked',false);
		$('#Item7Hero option:contains("Demon Hammer")').prop('selected',true);
		$('#Item7HeroEquipped').prop('checked',false);
	});
});
</script>
</body>
</html>