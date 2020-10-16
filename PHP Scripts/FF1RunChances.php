<?php

echo 'Assuming all characters have 20+ luck...<br>';

$trials = 10000;

for($y = 1; $y <= 9; $y++){
	$successful_run = 0;
	
	for($x = 0; $x < $trials; $x += 1){
		$turnorder = array(1,2,3,4,5,6,7,8,9,10,11,12,13);

		//Why 17 times?  Because go to hell.
		for($i = 1; $i <= 17; $i++){
			$a = rand(0,12);
			$b = rand(0,12);
			$_c = $turnorder[$a];
			$turnorder[$a] = $turnorder[$b];
			$turnorder[$b] = $_c;
		}
		$z = 0;
		for($i = 1; $i <= 17; $i++){
			if($turnorder[$i] <= $y){
				$z++;
			}
			if($turnorder[$i] == 10 || $turnorder[$i] == 11 || ($turnorder[$i] == 12 && $turnorder[2] < 10)){
				$successful_run += ($z / $trials);
				break;
			}
		}
	}
	
	$successful_run = floor($successful_run * 100) / 100;
	
	echo 'With '.$y.' monsters you will run away after '.$successful_run.' monsters.<br>';
}


?>