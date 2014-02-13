<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
* @deprecated
*/
header('Content-Type: text/css');

$baseDir = dirname(dirname(__FILE__));
require_once $baseDir.'/php/init.php';

$baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') ? 'https://' : 'http://';
$baseUrl .= isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : getenv('HTTP_HOST');
$baseUrl .= isset($_SERVER['SCRIPT_NAME']) ? dirname(dirname(dirname(dirname($_SERVER['SCRIPT_NAME'])))) : dirname(dirname(getenv('SCRIPT_NAME')));

$baseUrl =rtrim($baseUrl, '/\\');

$browser=Utils::getBrowser();
if (defined('__THEME__')){
	$sufix=__THEME__."";
}else{
	$sufix="";
}


switch ($browser['ub']) {
	case "Chrome":
		$sufix= "c_";
		break;
	case "Firefox":
		$sufix= "f_";
		break;
	case "MSIE":
		$sufix= "i_";
		break;
	case "Safari":
		$sufix= "s_";
		break;
	case "Opera":
		$sufix= "o_";
		break;
	case "Netscape":
		$sufix= "n_";
		break;
}

readCss($baseDir."/css/",$sufix,"comments.css");
readCss($baseDir."/css/",$sufix,"admin.css");

/**
 * read and puts css content
 * 
 * @param String $file
 */
function readCss($path,$sufix,$fileName){	
	$file=$path.$sufix.$fileName;	
	if (file_exists($file)){
		$includeFile=$file;
	}else{
		$file=$path.$fileName;
		if (file_exists($file)){
			$includeFile=$file;		
		}else{
			echo "/* invalid file : ".$path.$sufix.$fileName." or ".$path.$fileName." */";
			exit;
		}
	}		
					
		$handle = fopen($includeFile, "r");
		$contents = '';
		while (!feof($handle)) {
			$contents .= fread($handle, 8192);
		}
		fclose($handle);
		echo $contents;	
	
} 
?>