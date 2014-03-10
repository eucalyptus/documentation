<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class TableExporter {
	
	private $tableName;
	private $dbConnectionInfo;
	
	function __construct($tableName,$dbConnectionInfo){
		$this->dbConnectionInfo=$dbConnectionInfo;
		$this->tableName=$tableName;
	}
	
	/**
	 * export Comments for a specified page
	 * 	
	 * @param IExporter $exporter exporter to be used
	 * @param String fields to be exported separated by comma
	 * @param String orderClause to be used in selecting records
	 */
	function export($exporter,$fields=null,$orderClause=null){		
		
		$whereClause="";
		$whereFromFilter=$exporter->getFilter()->getSqlFilterClause();
		if ($whereFromFilter!=null){
			$whereClause="WHERE ".$whereFromFilter;
		}
			
		
			$db= new RecordSet($this->dbConnectionInfo);
			$select="*";
			if ($fields!=null){
				//$select=Utils::arrayToString($fields,",");
				$select=$fields;
			}
			$sql="SELECT ".$select." FROM ".$this->tableName." ".$whereClause;
			if ($orderClause!=null){
				$sql.=" ".$orderClause;
			}
			$sql.=";";
			
		
			if ($db->Open($sql)){
				$rowArray=$db->getAssoc();
				while($rowArray){
					if (is_array($rowArray)){
						$exporter->exportRow($rowArray);
					}
					$rowArray=$db->getAssoc();
				}
			}
			$db->Close();
	}	
}
?>