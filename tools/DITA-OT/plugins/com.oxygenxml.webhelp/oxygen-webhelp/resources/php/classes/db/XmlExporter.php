<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Export data in xml format
 * 
 * @author serban
 *
 */
class XmlExporter implements IExporter{	
	/**
	 * exported content
	 * 
	 * @var String
	 */
	private $toReturn;
	/**
	 * Constructor
	 * @param String $table table name
	 */
	function __construct($table=""){		
		$this->toReturn="<table name=\"".$table."\">\n";
	}
	/**
	 * Export one row 
	 * @param Array $AssociativeRowArray - array containing fieldName=>fieldValue
	 */
	function exportRow($AssociativeRowArray){
		$this->toReturn.="<row>\n";
		foreach ($AssociativeRowArray as $field => $value){
			$this->toReturn.="<column name=\"";
			$this->toReturn.=$field."\">".htmlspecialchars($value)."</column>\n";
		}
		$this->toReturn.="</row>\n";
	}
	function setFilter($filter){}
	function getContent(){
		$this->toReturn.="</table>\n";
		return  $this->toReturn;
	}
	function getFilter(){
		return $this->filter;
}
}
?>