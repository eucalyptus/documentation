<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

include 'init.php';


$share="";
if (isset($_REQUEST['version']) && trim($_REQUEST['version']) != ''){
		$version=trim($_REQUEST['version']);
		$product = new Product($dbConnectionInfo, $version);
		$shareFrom= $product->getSharedWith();
		foreach ($shareFrom as $productId => $productName) {
			$share.="<div class=\"shareF\"><span class=\"sharePID\">".$productId."</span><span class=\"sharePName\">".$productName."</span></div>";
			}
		}	
echo $share;

?>