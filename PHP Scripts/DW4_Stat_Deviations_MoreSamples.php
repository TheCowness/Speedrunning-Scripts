<?php
$db = mysqli_connect('xxxxxx','xxxxxx','xxxxxx');
mysqli_select_db($db,'dragonquestmonsters');
$dbreturn = '';
echo 'Database initialized.<br>';

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
//execute("Select count(*) FROM dragonwarrioriv_characterstatdata3");
//var_dump(get());

$Character = "";
$Level = "";
$HP = "";
$MP = "";
$Str = "";
$Agi = "";
$Vit = "";
$Int = "";
$Luck = "";
$results = [];

if(
	array_key_exists("Character",$_REQUEST) &&
	array_key_exists("Level",$_REQUEST) &&
	array_key_exists("HP",$_REQUEST) &&
	array_key_exists("MP",$_REQUEST) &&
	array_key_exists("Str",$_REQUEST) &&
	array_key_exists("Agi",$_REQUEST) &&
	array_key_exists("Vit",$_REQUEST) &&
	array_key_exists("Int",$_REQUEST) &&
	array_key_exists("Luck",$_REQUEST)
){
	$Character = preg_replace('/[^\a-z]/i','', $_REQUEST["Character"]);
	$Level = preg_replace('/[^\d]/i','', $_REQUEST["Level"]);
	$HP = preg_replace('/[^\d]/i','', $_REQUEST["HP"]);
	$MP = preg_replace('/[^\d]/i','', $_REQUEST["MP"]);
	$Str = preg_replace('/[^\d]/i','', $_REQUEST["Str"]);
	$Agi = preg_replace('/[^\d]/i','', $_REQUEST["Agi"]);
	$Vit = preg_replace('/[^\d]/i','', $_REQUEST["Vit"]);
	$Int = preg_replace('/[^\d]/i','', $_REQUEST["Int"]);
	$Luck = preg_replace('/[^\d]/i','', $_REQUEST["Luck"]);
	
	$where_clause = " WHERE 1 = 1";
	if($Character != ''){
		$where_clause .= " AND `Character`='$Character'";
	}
	if($Level != ''){
		$where_clause .= ' AND Level='.$Level;
	}
	
	$query = "SELECT";
	
	$query .= " MAX(HP) as max_hp";
	$query .= ",MAX(MP) as max_mp";
	$query .= ",MAX(str) as max_str";
	$query .= ",MAX(agi) as max_agi";
	$query .= ",MAX(vit) as max_vit";
	$query .= ",MAX(`int`) as max_int";
	$query .= ",MAX(luck) as max_luck";
	
	$query .= ",MIN(HP) as min_hp";
	$query .= ",MIN(MP) as min_mp";
	$query .= ",MIN(str) as min_str";
	$query .= ",MIN(agi) as min_agi";
	$query .= ",MIN(vit) as min_vit";
	$query .= ",MIN(`int`) as min_int";
	$query .= ",MIN(luck) as min_luck";
	
	$query .= ",COUNT(*) as total_records";
	if($HP !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND HP >= ".$HP.") as hp_percentile";
	}else{
		$query .= ",-1 as hp_percentile";
	}
	if($MP !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND MP >= ".$MP.") as mp_percentile";
	}else{
		$query .= ",-1 as mp_percentile";
	}
	if($Str !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND Str >= ".$Str.") as str_percentile";
	}else{
		$query .= ",-1 as str_percentile";
	}
	if($Agi !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND Agi >= ".$Agi.") as agi_percentile";
	}else{
		$query .= ",-1 as agi_percentile";
	}
	if($Vit !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND Vit >= ".$Vit.") as vit_percentile";
	}else{
		$query .= ",-1 as vit_percentile";
	}
	if($Int !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND `Int` >= ".$Int.") as int_percentile";
	}else{
		$query .= ",-1 as int_percentile";
	}
	if($Luck !== ''){
		$query .= ",(SELECT count(*) FROM dragonwarrioriv_characterstatdata3".$where_clause." AND Luck >= ".$Luck.") as luck_percentile";
	}else{
		$query .= ",-1 as luck_percentile";
	}
	
	$query .= " FROM dragonwarrioriv_characterstatdata3";
	
	$query .= $where_clause;
	
	echo '<Br><br>';
	
	execute($query);
	$results = get();
	//var_dump($results);
	//echo $query.'<Br><br>';
	
	if($results['total_records'] == 0) $results['total_records'] == 1;
}

?>

This script compares against <B>10,000</b> trials of leveling up each character from level 1 to level 98 (not 99; deal with it).  Submit the form below to get the possible ranges of each character stat for the selected character and experience level.<br>
<br>
If you provide a value for any given stat, a percentile will be calculated as well, telling you how likely it is for the character to have <u>at least</u> that value at the given level.  Or you can leave level and character blank and it'll check all character and levels, if you just really like pointless data.  It's your life.<br>
<br>
I have another page set up <a href="DW4_Stat_Deviations.php">here</a> that only compares against 1,000 trials, which loads a lot faster.  I recommend using it instead.<br>
<br>

<form action="" method="GET">
<table>
	<tr>
		<td>Character:</td>
		<td>
			<select name="Character">
				<option value=""></option>
				<option value="Ragnar" <?php echo $Character == "Ragnar" ? 'selected' : ''?>>Ragnar</option>
				<option value="Alena" <?php echo $Character == "Alena" ? 'selected' : ''?>>Alena</option>
				<option value="Cristo" <?php echo $Character == "Cristo" ? 'selected' : ''?>>Cristo</option>
				<option value="Brey" <?php echo $Character == "Brey" ? 'selected' : ''?>>Brey</option>
				<option value="Taloon" <?php echo $Character == "Taloon" ? 'selected' : ''?>>Taloon</option>
				<option value="Nara" <?php echo $Character == "Nara" ? 'selected' : ''?>>Nara</option>
				<option value="Mara" <?php echo $Character == "Mara" ? 'selected' : ''?>>Mara</option>
				<option value="Hero" <?php echo $Character == "Hero" ? 'selected' : ''?>>Hero</option>
			</select>
		</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>Level:</td>
		<td><input name="Level" value="<?php echo $Level ?>" /></td>
		</td>
		<td></td>
	</tr>
	<tr>
		<td>HP:</td>
		<td><input name="HP" value="<?php echo $HP ?>" /></td>
		</td>
		<td><?php echo array_key_exists('max_hp',$results) ? $results['min_hp'].' - '.$results['max_hp'].($results['hp_percentile'] !== '-1' ? ' ('.$HP.' =  '.(round($results['hp_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>MP:</td>
		<td><input name="MP" value="<?php echo $MP ?>" /></td>
		<td><?php echo array_key_exists('max_mp',$results) ? $results['min_mp'].' - '.$results['max_mp'].($results['mp_percentile'] !== '-1' ? ' ('.$MP.' =  '.(round($results['mp_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>Str:</td>
		<td><input name="Str" value="<?php echo $Str ?>" /></td>
		<td><?php echo array_key_exists('max_str',$results) ? $results['min_str'].' - '.$results['max_str'].($results['str_percentile'] !== '-1' ? ' ('.$Str.' =  '.(round($results['str_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>Agi:</td>
		<td><input name="Agi" value="<?php echo $Agi ?>" /></td>
		<td><?php echo array_key_exists('max_agi',$results) ? $results['min_agi'].' - '.$results['max_agi'].($results['agi_percentile'] !== '-1' ? ' ('.$Agi.' =  '.(round($results['agi_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>Vit:</td>
		<td><input name="Vit" value="<?php echo $Vit ?>" /></td>
		<td><?php echo array_key_exists('max_vit',$results) ? $results['min_vit'].' - '.$results['max_vit'].($results['vit_percentile'] !== '-1' ? ' ('.$HP.' =  '.(round($results['vit_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>Int:</td>
		<td><input name="Int" value="<?php echo $Int ?>" /></td>
		<td><?php echo array_key_exists('max_int',$results) ? $results['min_int'].' - '.$results['max_int'].($results['int_percentile'] !== '-1' ? ' ('.$Int.' =  '.(round($results['int_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>Luck:</td>
		<td><input name="Luck" value="<?php echo $Luck ?>" /></td>
		<td><?php echo array_key_exists('max_luck',$results) ? $results['min_luck'].' - '.$results['max_luck'].($results['luck_percentile'] !== '-1' ? ' ('.$Luck.' =  '.(round($results['luck_percentile']/$results['total_records'],4)*100)." percentile)" : '') : '' ?></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="Submit" value="Submit">
	</tr>
</table>
<?php
$odds = 1;
if(array_key_exists('hp_percentile',$results)){
	if($results['hp_percentile'] !== '-1') $odds *= $results['hp_percentile']/$results['total_records'];
	if($results['mp_percentile'] !== '-1') $odds *= $results['mp_percentile']/$results['total_records'];
	if($results['str_percentile'] !== '-1') $odds *= $results['str_percentile']/$results['total_records'];
	if($results['agi_percentile'] !== '-1') $odds *= $results['agi_percentile']/$results['total_records'];
	if($results['vit_percentile'] !== '-1') $odds *= $results['vit_percentile']/$results['total_records'];
	if($results['int_percentile'] !== '-1') $odds *= $results['int_percentile']/$results['total_records'];
	if($results['luck_percentile'] !== '-1') $odds *= $results['luck_percentile']/$results['total_records'];
}

if($odds !== 1){
	echo '<br><br>Odds of producing a character with all given stats: '.(round($odds,4)*100).'%';
}

if($Character != '' && $Level != ''){
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g.HP) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   HP AS HP
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY HP) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avghp = $results['_avg'];
	
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g.MP) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   MP AS MP
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY MP) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avgmp = $results['_avg'];
	
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g.str) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   str AS str
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY str) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avgstr = $results['_avg'];
	
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g.agi) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   agi AS agi
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY agi) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avgagi = $results['_avg'];
	
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g.vit) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   vit AS vit
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY vit) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avgvit = $results['_avg'];
	
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g._int) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   `int` AS _int
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY `int`) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avgint = $results['_avg'];
	
	execute('SET @rowindex := -1;');
	$query = '
	SELECT
	   AVG(g.Luck) as _avg
	FROM
	   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
			   Luck AS Luck
		FROM dragonwarrioriv_characterstatdata
		where `character`=\''.$Character.'\' and level = '.$Level.'
		ORDER BY Luck) AS g
	WHERE
	g.rowindex IN (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));';
	execute($query);
	$results = get();
	$_avgluck = $results['_avg'];
	
	echo 'Median stats for '.$Character.' at '.$Level.':<br>';
	echo 'HP: '.floor($_avghp).'<br>';
	echo 'MP: '.floor($_avgmp).'<br>';
	echo 'Str: '.floor($_avgstr).'<br>';
	echo 'Agi: '.floor($_avgagi).'<br>';
	echo 'Vit: '.floor($_avgvit).'<br>';
	echo 'Int: '.floor($_avgint).'<br>';
	echo 'Luck: '.floor($_avgluck).'<br>';
	echo '<br>(Medians above may actually be one point lower than the true median due to the way I\'m rounding)';
}
?>