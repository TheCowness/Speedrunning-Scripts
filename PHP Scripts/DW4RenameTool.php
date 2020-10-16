<?php
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
	
		header('Content-Disposition: attachment; filename="DW4_RenameHack.nes"');
		header("Content-Size: ".strlen($romdata)*512);
		echo $romdata;
		die();

		return true;
		
		
	}else{
		echo 'File was empty!<br><br>';
	}
}
?>
<html>
<head>
	<script type="text/javascript" src="../Scripts/jquery-1_11_2_min.js"></script>
</head>
<body>
<form action="DW4RenameTool.php" method="POST" enctype="multipart/form-data">
Input File:<br>
<input type="file" name="InputFile1" value="" id="input_file" size=50 /><br>
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
<input type="Submit" name="Submit" value="Hack!">
</form>

<script type="text/javascript">
$(document).ready(function(){
	$("#RenameEN").click(function(){
		$("#NameRagnar").val("Ragnar");
		$("#NameHealie").val("Healie");
		$("#NameAlena").val("Alena");
		$("#NameCristo").val("Cristo");
		$("#NameBrey").val("Brey");
		$("#NameTaloon").val("Taloon");
		$("#NameLaurent").val("Laurent");
		$("#NameStrom").val("Strom");
		$("#NameNara").val("Nara");
		$("#NameMara").val("Mara");
		$("#NameOrin").val("Orin");
		$("#NameHector").val("Hector");
		$("#NamePanon").val("Panon");
		$("#NameLucia").val("Lucia");
		$("#NameDoran").val("Doran");
	});
	$("#RenameJP").click(function(){
		$("#NameRagnar").val("Ryan");
		$("#NameHealie").val("Hoimin");
		$("#NameAlena").val("Arina");
		$("#NameCristo").val("Clift");
		$("#NameBrey").val("Burai");
		$("#NameTaloon").val("Torneko");
		$("#NameLaurent").val("Laurent");
		$("#NameStrom").val("Strom");
		$("#NameNara").val("Minea");
		$("#NameMara").val("Manya");
		$("#NameOrin").val("Orin");
		$("#NameHector").val("Hoffman");
		$("#NamePanon").val("Panon");
		$("#NameLucia").val("Lucia");
		$("#NameDoran").val("Doran");
	});
	$("#RenameDS").click(function(){
		$("#NameRagnar").val("Ragnar");
		$("#NameHealie").val("Healie");
		$("#NameAlena").val("Alena");
		$("#NameCristo").val("Kiryl");
		$("#NameBrey").val("Borya");
		$("#NameTaloon").val("Torneko");
		$("#NameLaurent").val("Laurel");
		$("#NameStrom").val("Hardie");
		$("#NameNara").val("Meena");
		$("#NameMara").val("Maya");
		$("#NameOrin").val("Oojam");
		$("#NameHector").val("Hank");
		$("#NamePanon").val("Tom");
		$("#NameLucia").val("Orifiela");
		$("#NameDoran").val("Sparkie");
	});
});
</script>
</body>
</html>