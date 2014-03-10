<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Customized cell renderer
 * 
 * @author serban
 *
 */
class LinkCellRenderer implements ICellRenderer{
	/**
	 * Fields to be rendered as link 
	 * 
	 * @var array key=>value where key is field name and value is class af the <code><a></code> tag
	 */
	private $fieldsToLink;
	
	/**
	 * Link to be prepednd
	 * 
	 * @var String
	 */
	private $baseLink;
	
	/**
	 * Anchor to apent to link
	 * 
	 * @var String
	 */
	private $aName;
	
	function __construct($baseLink){
		$this->baseLink=$baseLink;
		$this->aName="";
	}	
	/**
	 * Adds a field to be rendered as link
	 * 
	 * @param String $fieldName - name of field
	 */
	function addLinkToField($fieldName,$renderClass=""){
		$this->fieldsToLink[$fieldName]=$renderClass;
	}
	function setAName($aName){
		$this->aName=$aName;
	}
	/**
	 * Get rendered output for the specified fiel
	 *  
	 * @param String $fieldName field name 
	 * @param Strign $fieldName field value
	 */
	function render($fieldName,$fieldValue){
		$toReturn="";
		if (key_exists($fieldName, $this->fieldsToLink)){
			$toReturn="<a ";
			if ($this->fieldsToLink[$fieldName]!=""){
				$toReturn.=" class='".$this->fieldsToLink[$fieldName]."' ";
			}			
			$toReturn.=" href='".$this->baseLink.$fieldValue."#".$this->aName."'>".$fieldValue;
			$toReturn.="</a>";
		}else{
			$toReturn=$fieldValue;
		}
		return $toReturn;
	}
	
}
?>