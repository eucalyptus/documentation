<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Default cell renderer
 * 
 * @author serban
 */
class DefaultCellRenderer implements ICellRenderer{
	private $class;
	private $tag;
	private $name;
	function __construct($tag="div",$tagClass=null){
		$this->class=$tagClass;
		$this->tag=$tag;
	}
	/**
	 * Get rendered output for the specified fiel
	 *  
	 * @param String $fieldName field name 
	 * @param Strign $fieldName field value
	 */
	function render($fieldName,$fieldValue){
				
			$toReturn="<".$this->tag;
			if ($this->class!=null){
				$toReturn.=" class=\"".$this->class."\"";
			}
			$toReturn.=">".$fieldValue;
			$toReturn.="</".$this->tag.">";
		
		return $toReturn;
	}
	function setAName($name){
		$this->name=$name;
	}
	
}
?>