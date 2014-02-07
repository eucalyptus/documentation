<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Constructs the json response for ajax requests   
 * 
 * @author serban
 *
 */
class JsonResponse {
	
	private $value;
	function __construct(){
		$this->value= array();
	}
	/**
	 *  set variable 
	 * @param String $variable
	 * @param String $value
	 */
	public function set($variable, $value){
		$this->value[$variable]=$value;
	}
	
	function __get($variableName){
		$toReturn="";
		if (isset($this->value[$variableName])){
			$toReturn=$this->value[$variableName];
		}
		return $toReturn;
	}
	public function __toString(){
		return $this->getJson();
	}
	
	/**
	 * JSON  representation of the object 
	 */
	private function getJson(){
		$toReturn="{";
		
		// in order to use json_encode php >= 5.2
		//string json_encode ( mixed $value [, int $options = 0 ] )
		
		foreach ($this->value as $key=> $value){
			// replace new line with \ in order to be a valid javascript string
			$order   = array("\r\n", "\n", "\r");
			$replace = '\\';
	
			// Processes \r\n's first so they aren't converted twice.
			$newstr = str_replace($order, $replace, $value);							
			$toReturn.="\"".$key."\":\"".$newstr ."\",";
		}
		$toReturn=substr($toReturn,0, -1);
		$toReturn.="}";
		return $toReturn;
	}
}
?>