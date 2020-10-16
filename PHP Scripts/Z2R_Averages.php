<?php
//Declaring some functions...
function RandomizeArray(&$arr,$range,$order){
	//$order should be positive if the value is increasing with level, or negative if decreasing per level.
	foreach($arr as $key=>&$value){
		//$arr[$key] and $value are the same thing...
		$arr[$key] = rand($value*(1-$range),$value*(1+$range));
		if($key > 0){
			if($order > 0){
				if($arr[$key] < $arr[$key-1]) $arr[$key] = $arr[$key-1];
			}
			if($order < 0){
				if($arr[$key] > $arr[$key-1]) $arr[$key] = $arr[$key-1];
			}
		}
		//On the fence as to whether or not to factor this in...
		//if($value > 127) $value = 127;
	}
}

?>
The following statistics are based on my understanding of how the not-open-source Zelda 2 Randomizer works, and do not necessarily reflect reality in any way.<br>
<br>
<h1>Spell Costs</h1>
I think spell costs are +/- 50% of the base cost OR the previous level's cost, whichever is lower.  Note that spells cap at 128, but I don't factor that into my calculations because it's kind of irrelevant unless you find all magic containers before the cost drops.  Consequently, the numbers below are technically medians, not means.<br>
<br>
These costs are calculated when the page is loaded based on ten thousand trials, and may change when the page is refreshed.<br>
<br>
<?php
$Spell_Costs = [
	"Shield" 	=> [ 32, 24, 24, 16, 16, 16, 16, 16],
	"Jump"		=> [ 48, 40, 32, 32, 20, 16, 12,  8],
	"Life"		=> [ 70, 70, 60, 60, 50, 50, 50, 50],
	"Fairy"		=> [ 80, 80, 60, 60, 40, 40, 40, 40],
	"Fire"		=> [120, 80, 60, 30, 16, 16, 16, 16],
	"Reflect"	=> [120,120, 80, 48, 40, 32, 24, 16],
	"Spell"		=> [120,112, 96, 80, 48, 32, 24, 16],
	"Thunder"	=> [120,120,120,120,120,120,100, 64]
	];
//The RandomizeArray function will randomize this array for us, but we want to randomize thousands of them and get an average.
$Spell_Costs_Total = $Spell_Costs;
foreach($Spell_Costs_Total as $Spell=>&$Costs){
	$Costs = [0,0,0,0,0,0,0,0];
}

for($i = 0; $i < 10000; $i++){
	$Spell_Costs_Rand = $Spell_Costs;
	foreach($Spell_Costs_Rand as $Spell=>&$Costs){
		RandomizeArray($Costs,0.5,-1);
		foreach($Costs as $index=>$cost){
			$Spell_Costs_Total[$Spell][$index] += $cost;
		}
	}
}

echo '<table cellpadding=4 style="margin-left:24px">';
echo '<tr><th>Spell</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th></tr>';
foreach($Spell_Costs_Total as $Spell=>&$Costs){
	echo '<tr>';
	echo '<td>'.$Spell.'</td>';
	foreach($Costs as $index=>&$cost){
		$cost = floor($cost/10000);
		echo '<td>'.$cost.'</td>';
	}
	echo '</tr>';
}
echo '</table>';

echo '<table cellpadding=4 style="margin-left:24px">';
echo '<tr><th>Spell</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th></tr>';
foreach($Spell_Costs_Total as $Spell=>&$Costs){
	echo '<tr>';
	echo '<td>'.$Spell.'</td>';
	foreach($Costs as $index=>&$cost){
		echo '<td>'.($cost - $Spell_Costs[$Spell][$index]).'</td>';
	}
	echo '</tr>';
}
echo '</table>';

/*
echo '<pre>';
print_r($Spell_Costs_Total);
echo '</pre>';
*/
?>
<h1>Attack Effectivity</h1>
I think attack levels are +/- 50% of the base damage OR the previous level's cost, whichever is higher.  The only levels whose averages are really affected by the randomizer logic are the weaker levels (3, 6, 8), as these levels provide a 25% boost of power, and the other five levels provide a 33% boost.

<?php
$Attack_Damage = [2,3,4,6,9,12,18,24];
//The RandomizeArray function will randomize this array for us, but we want to randomize thousands of them and get an average.
$Attack_Damages_Total = [0,0,0,0,0,0,0,0];

for($i = 0; $i < 10000; $i++){
	$Attack_Damages_Rand = $Attack_Damage;
	RandomizeArray($Attack_Damages_Rand,0.5,1);
	foreach($Attack_Damages_Rand as $index=>$Damage){
		$Attack_Damages_Total[$index] += $Damage;
	}
}

foreach($Attack_Damages_Total as $index=>&$Damage){
	$Damage = floor($Damage/1000)/10;
}
//print_r($Attack_Damages_Total);
echo '<table>';
echo '<tr><td>Level</td><td>Damage</td><td>Increase</td><td>% Increase</td></tr>';
for($i = 0; $i < count($Attack_Damages_Total); $i++){
	echo '<tr>';
	echo '<td>'.($i+1).'</td>';
	echo '<td>'.($Attack_Damages_Total[$i]).'</td>';
	if($i != 0){
		echo '<td>'.($Attack_Damages_Total[$i] - $Attack_Damages_Total[$i-1]).'</td>';
		echo '<td>'.(floor(100 * $Attack_Damages_Total[$i] / $Attack_Damages_Total[$i-1]) - 100).'%</td>';
	};
	echo '</tr>';
};
echo '</table>';
?>

<h1>EXP Requirements</h1>
"This shuffles how much experience is needed for each level. The values range from -25% to +25% of their normal values. It is guaranteed that each level will cost more than the previous level."<br>
<br>
I don't know what "more than the previous level" means, so I'm using the same logic as the above:  If the previous level costs more, raise the cost of this one to match it.  Maybe the randomizer re-rolls?  Anyway, since the 75%-125% range is so small, it looks like the only average affected by the randomizer is Attack 9.  Shout-outs to Atk9Guy.<br>
<br>


<?php
$Experience_Costs = [
	"Attack" 	=> [ 200, 500,1000,2000,3000,5000,8000,9000],
	"Magic"		=> [ 100, 300, 700,1200,2200,3500,6000,9000],
	"Life"		=> [  50, 150, 400, 800,1500,2500,4000,9000]
	];
//The RandomizeArray function will randomize this array for us, but we want to randomize thousands of them and get an average.
$Experience_Costs_Total = $Experience_Costs;
foreach($Experience_Costs_Total as $Experience=>&$Costs){
	$Costs = [0,0,0,0,0,0,0,0];
}

for($i = 0; $i < 10000; $i++){
	$Experience_Costs_Rand = $Experience_Costs;
	foreach($Experience_Costs_Rand as $Experience=>&$Costs){
		RandomizeArray($Costs,0.25,1);
		foreach($Costs as $index=>$cost){
			$Experience_Costs_Total[$Experience][$index] += $cost;
		}
	}
}

echo '<table cellpadding=4 style="margin-left:24px">';
echo '<tr><th>Experience</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th></tr>';
foreach($Experience_Costs_Total as $Experience=>&$Costs){
	echo '<tr>';
	echo '<td>'.$Experience.'</td>';
	foreach($Costs as $index=>&$cost){
		$cost = floor($cost/100000)*10;
		echo '<td>'.$cost.'</td>';
	}
	echo '</tr>';
}
echo '</table>';

echo '<table cellpadding=4 style="margin-left:24px">';
echo '<tr><th>Experience</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th></tr>';
foreach($Experience_Costs_Total as $Experience=>&$Costs){
	echo '<tr>';
	echo '<td>'.$Experience.'</td>';
	foreach($Costs as $index=>&$cost){
		echo '<td>'.($cost - $Experience_Costs[$Experience][$index]).'</td>';
	}
	echo '</tr>';
}
echo '</table>';
?>