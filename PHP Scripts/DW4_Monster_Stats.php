<?php
/*
If I want to experiment to figure out what these all are,
make a LUA script that constantly writes a number to 0x7328 - 0x732F
Start that number at zero, increment whenever Start is pressed (double-tap protection) and also load state 1
Get into a fight with a buncha enemies (ideally 8) and see what happens.  Press Start to proceed to the next skill.
*/

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

$db_query = '
SELECT dw4.*,
	sk1.id as sk1_id, sk2.id as sk2_id, sk3.id as sk3_id, sk4.id as sk4_id, sk5.id as sk5_id, sk6.id as sk6_id, 
	sk1.name as skill_1, sk2.name as skill_2, sk3.name as skill_3, sk4.name as skill_4, sk5.name as skill_5, sk6.name as skill_6,
	(dw4.9_HP1 + (dw4.20_Unknown % 4) * 256) as HP,
	(dw4.10_Str_Lower + (dw4.21_Unknown % 4) * 256) as Atk,
	(dw4.11_Def + (dw4.22_Unknown % 4) * 256) as Def,
	(dw4.5_XP1 + (dw4.6_XP2) * 256) as EXP,
	(dw4.12_GP_Lower + (dw4.23_Unknown % 4) * 256) as Gold,
	(items.Name) as Item_Drop,
	(20_Unknown & 192)/64 as Bang,
	(20_Unknown & 48)/16 as Firebal,
	(20_Unknown & 12)/4 as Blaze,
	(21_Unknown & 192)/64 as Zap,
	(21_Unknown & 48)/16 as Infernos,
	(21_Unknown & 12)/4 as Icebolt,
	(22_Unknown & 192)/64 as Surround,
	(22_Unknown & 48)/16 as Sleep,
	(22_Unknown & 12)/4 as Beat,
	(23_Unknown & 192)/64 as Expel,
	(23_Unknown & 48)/16 as Robmagic,
	(23_Unknown & 12)/4 as Stopspell,
	(24_Unknown & 192)/64 as Chaos,
	(24_Unknown & 48)/16 as Sap,
	(25_Unknown % 8) as DropChance
FROM dragonwarrioriv dw4
LEFT JOIN dragonwarrioriv_monsterskills sk1
ON (dw4.14_Skill1 % 128) = sk1.id
LEFT JOIN dragonwarrioriv_monsterskills sk2
ON (dw4.15_Skill2 % 128) = sk2.id
LEFT JOIN dragonwarrioriv_monsterskills sk3
ON (dw4.16_Skill3 % 128) = sk3.id
LEFT JOIN dragonwarrioriv_monsterskills sk4
ON (dw4.17_Skill4 % 128) = sk4.id
LEFT JOIN dragonwarrioriv_monsterskills sk5
ON (dw4.18_Skill5 % 128) = sk5.id
LEFT JOIN dragonwarrioriv_monsterskills sk6
ON (dw4.19_Skill6 % 128) = sk6.id
LEFT JOIN dragonwarrioriv_items items
ON (dw4.13_Item_AIFlag % 128) = items.id
ORDER BY Number ASC
';
execute($db_query);

?>
<script src="/Scripts/jquery-1_11_2_min.js" type="text/javascript"></script>
<div id="table-container">
<table id="monster-data-table" cellspacing=0>
	<thead>
	<tr>
		<th>Index</th>
		<th>Monster Name</th>
		
		<th>HP</th>
		<th>MP</th>
		<th>ATK</th>
		<th>DEF</th>
		<th>AGI</th>
		<th>XP</th>
		<th>Gold</th>
		<th>Item</th>
		<th>Drop Chance</th>
		
		<th>Skill 1</th>
		<th>Skill 2</th>
		<th>Skill 3</th>
		<th>Skill 4</th>
		<th>Skill 5</th>
		<th>Skill 6</th>
		
		<th><div class="resistance-header">Bang</div></th>
		<th><div class="resistance-header">Firebal/BeDragon</div></th>
		<th><div class="resistance-header">Blaze</div></th>
		<th><div class="resistance-header">Zap/Thordain</div></th>
		<th><div class="resistance-header">Infernos</div></th>
		<th><div class="resistance-header">Icebolt/Icespears</div></th>
		<th><div class="resistance-header">Surround</div></th>
		<th><div class="resistance-header">Sleep</div></th>
		<th><div class="resistance-header">Beat/Aeolus</div></th>
		<th><div class="resistance-header">Expel/Fairy Water</div></th>
		<th><div class="resistance-header">Robmagic</div></th>
		<th><div class="resistance-header">Stopspell</div></th>
		<th><div class="resistance-header">Chaos</div></th>
		<th><div class="resistance-header">Sap</div></th>
		
	</tr>
	</thead>
	<tbody>
<?php
while($monster = get()){
	$DropChance = '1/'.(2**($monster['DropChance']+2));
	if($monster['DropChance'] == 0) $DropChance = '1/1';
	if($monster['DropChance'] == 7) $DropChance = '1/2048';
	?>
	<tr>
		<td><?php echo $monster["Number"] ?></td>
		<td><?php echo $monster["Name"] ?></td>
		
		<td><?php echo $monster["HP"] ?></td>
		<td><?php echo $monster["8_MP"] ?></td>
		<td><?php echo $monster["Atk"] ?></td>
		<td><?php echo $monster["Def"] ?></td>
		<td><?php echo $monster["7_AGI"] ?></td>
		<td><?php echo $monster["EXP"] ?></td>
		<td><?php echo $monster["Gold"] ?></td>
		<td><?php echo $monster["Item_Drop"] ?></td>
		<td><?php echo $DropChance ?></td>
		
		<td><?php echo $monster["skill_1"] ? $monster["skill_1"] : $monster["14_Skill1"] ?><?php echo $monster["skill_1"] == "Attack" && $monster["sk1_id"] != 50 ? "? (".$monster["sk1_id"].")" : '' ?></td>
		<td><?php echo $monster["skill_2"] ? $monster["skill_2"] : $monster["15_Skill2"] ?><?php echo $monster["skill_2"] == "Attack" && $monster["sk2_id"] != 50 ? "? (".$monster["sk2_id"].")" : '' ?></td>
		<td><?php echo $monster["skill_3"] ? $monster["skill_3"] : $monster["16_Skill3"] ?><?php echo $monster["skill_3"] == "Attack" && $monster["sk3_id"] != 50 ? "? (".$monster["sk3_id"].")" : '' ?></td>
		<td><?php echo $monster["skill_4"] ? $monster["skill_4"] : $monster["17_Skill4"] ?><?php echo $monster["skill_4"] == "Attack" && $monster["sk4_id"] != 50 ? "? (".$monster["sk4_id"].")" : '' ?></td>
		<td><?php echo $monster["skill_5"] ? $monster["skill_5"] : $monster["18_Skill5"] ?><?php echo $monster["skill_5"] == "Attack" && $monster["sk5_id"] != 50 ? "? (".$monster["sk5_id"].")" : '' ?></td>
		<td><?php echo $monster["skill_6"] ? $monster["skill_6"] : $monster["19_Skill6"] ?><?php echo $monster["skill_6"] == "Attack" && $monster["sk6_id"] != 50 ? "? (".$monster["sk6_id"].")" : '' ?></td>
		
		<?php foreach(array("Bang","Firebal","Blaze","Zap","Infernos","Icebolt","Surround","Sleep","Beat","Expel","Robmagic","Stopspell","Chaos","Sap") as $resistance){
			
			$rescolor = "#fff";
			if($monster[$resistance] == 1) $rescolor = "#bbb";
			if($monster[$resistance] == 2) $rescolor = "#666";
			if($monster[$resistance] == 3) $rescolor = "#000";
			/*
			$rescolor = "#0F0";
			if($monster[$resistance] == 1) $rescolor = "#CC0";
			if($monster[$resistance] == 2) $rescolor = "#F60";
			if($monster[$resistance] == 3) $rescolor = "#C00";
			*/
		?>
			<td style="background-color:<?php echo $rescolor; ?>;color:<?php echo $rescolor; ?>;"><?php echo round($monster[$resistance]); ?></td>
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
<?php 
//Not entirely sure why I re-opened this tag.
?>