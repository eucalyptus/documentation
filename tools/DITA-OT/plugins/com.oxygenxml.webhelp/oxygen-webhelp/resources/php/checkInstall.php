<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once "init.php";
$cfgFile = './config/config.php';
$cfgInstall = '../../../install/';
$toReturn = new JsonResponse();
if (file_exists($cfgInstall)){
	$toReturn->set("installPresent", "true");
}else{
	$toReturn->set("installPresent", "false");
}
if (file_exists($cfgFile)){
	$toReturn->set("configPresent", "true");
}else{
	$toReturn->set("configPresent", "false");	
}
echo $toReturn;

?>