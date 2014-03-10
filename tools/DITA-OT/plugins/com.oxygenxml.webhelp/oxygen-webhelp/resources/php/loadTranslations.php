<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

  include_once "config.php";
  include_once "../localization/strings.php";
  global $localization;
  $toReturn=new JsonResponse();
  foreach ($localization as $key => $translation){
  	$toReturn->set($key, $translation);  	
  }  
  echo $toReturn;
?>