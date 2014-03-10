<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class Product {
	private $dbConnectionInfo;
	private $version;
	function __construct($dbConnectionInfo,$version){
		$this->dbConnectionInfo=$dbConnectionInfo;
		$this->version=$version;
	}
	/**
	 * @return array all products that share comments with this one
	 */
	function getSharedWith(){
		$toReturn= array();
		$db= new RecordSet($this->dbConnectionInfo,false,true);
		$prds=$db->Open("Select product,value from webhelp where parameter='name' and version='".$this->version."' "
				.(defined('__SHARE_WITH__') ? "AND product in (".__SHARE_WITH__ .")": '').";");
		if ($prds>0){
			while ($db->MoveNext()){
				$product=$db->Field('product');
				$value=$db->Field('value');
				$toReturn[$product]=$value;
			
			}
		}
		$db->close();
		return $toReturn;
	}
}
?>