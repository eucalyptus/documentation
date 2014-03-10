<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';

$ses=Session::getInstance();

if (isset($_POST["select"]) && trim($_POST["select"]) =="true"){	
	$info= array();
	
	$pName=(isset($_POST['product']) ? $_POST['product'] :"");
	$pVersion=(isset($_POST['version']) ? $_POST['version'] : "");
	$fullUser=base64_encode($pName."_".$pVersion."_user");
	
	if (isset($ses->$fullUser) && ($ses->$fullUser instanceof User)){
		$user=$ses->$fullUser;
		if ($user->level=='admin'){
			echo $user->listUsers();
			echo "<script>";									
			echo "$('input#id_search').quicksearch('table#usersList tbody tr');</script>";
		}else{
			echo "0";
		}
	}else{
		echo "0";
	}	
}else{
	echo "0";
}
?>