<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class DbUpdater{
	private $dbConnectionInfo;
	function __construct($dbConnectionInfo){
		$this->dbConnectionInfo=$dbConnectionInfo;
	}

	function updateDb(){
		$params=array();
		$toReturn=array();
		$toReturn['updated']=true;
		$toReturn['message']="";
		$db= new RecordSet($this->dbConnectionInfo,false,true);
		$rows=$db->Open("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA =  '".$this->dbConnectionInfo['dbName']."' AND TABLE_NAME =  'webhelp'");
		if ($rows>0){
			$db->Open("SELECT * FROM webhelp;");
			while ($db->MoveNext()) {
				$assoc=$db->getAssoc();
				$params[$db->Field("parameter")]=$db->Field("value");
			}
			$db->Close();
			if ($params['databaseVersion']!='1'){
				$toReturn['updated']=false;
				$toReturn['message']="Incompatible database version found!";
			}
		}else{
			$toReturn['updated']=false;
			$toReturn['message']="Database structure does not exist! In order to create a compatible database structure you must check option <strong>\"Create new database structure\"</strong> from previous instalation page.";
		}
		return $toReturn;
	}

}