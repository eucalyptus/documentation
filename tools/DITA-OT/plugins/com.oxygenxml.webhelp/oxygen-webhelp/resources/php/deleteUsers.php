<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';
$ses=Session::getInstance();
global $dbConnectionInfo;

if ((isset($_POST["productName"]) && trim($_POST["productName"]) !="")		
	&& (isset($_POST["productVersion"]) && trim($_POST["productVersion"]) !="")){
	
	$product=(isset($_POST['productName']) ? $_POST['productName'] :"");
	$version=(isset($_POST['productVersion']) ? $_POST['productVersion'] : "");
	
	if (Utils::isAdministrator($product, $version)){		
		if (isset($_POST['ids']) && trim($_POST['ids']) != ''){
			$return=false;
			$usr= new User($dbConnectionInfo);
			$ids=trim($_POST['ids']);
			$return = $usr->delete($ids);
			echo $return;
			
		}	
	}	
			
}else{
	echo "No data to process!";
}
?>