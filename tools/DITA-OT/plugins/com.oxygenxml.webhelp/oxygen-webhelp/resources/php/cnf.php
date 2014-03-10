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
Header("content-type: application/x-javascript");

$baseDir = dirname(dirname(__FILE__));
require_once $baseDir.'/php/init.php';

$baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') ? 'https://' : 'http://';
$baseUrl .= isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : getenv('HTTP_HOST');
$baseUrl .= isset($_SERVER['SCRIPT_NAME']) ? dirname(dirname(dirname(dirname($_SERVER['SCRIPT_NAME'])))) : dirname(dirname(getenv('SCRIPT_NAME')));

$baseUrl =rtrim($baseUrl, '/\\');

$val=array();
if (defined('__BASE_URL__')){
	$parts=explode("/", __BASE_URL__,4);
	if (count($parts)<4){
		$relPath="/";
	}else{    
		$relPath="/".($parts[3]=="" ? "": $parts[3]);
	}
  	echo 'var conf = {"htpath":"'.$relPath.'","baseUrl":"'.__BASE_URL__.'"};';
}else{
	$parts=explode("/", $baseUrl,4);
	if (count($parts)<4){
		$relPath="/";
	}else{
    $relPath="/".($parts[3]=="" ? "" : $parts[3]."/");
		//$relPath="/".$parts[3]."/";
	}
  echo 'var conf = {"htpath":"'.$relPath.'","baseUrl":"'.$baseUrl.'/"};';
}
echo "
function objToString (obj) {
    var str = '';
    for (var p in obj) {
        if (obj.hasOwnProperty(p)) {
            str += p + '::' + obj[p] + '\\n';
        }
    }
    return str;
}
$.ajaxSetup({
  cache	  	: false,
  timeout 	: 60000,
  error 	: function(jqXHR, errorType, exception) {
				//console.log(\"error :\"+jqXHR.status +\":\"+jqXHR.responseText +\":\"+errorType+\":\"+exception);
			},
  complete 	: function(jqXHR, textStatus){
  			if (textStatus != \"success\"){
					//console.log(\"?complete :\"+jqXHR+\":\"+textStatus);
  			}
			}
});"

?>