<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

abstract class AbstractUserFilter implements IFilter{
	protected $lastDate;
	protected $dateField;
	/**
	 * Constructor
	 */
	function __construct($lastDays,$dateField){		
		$this->lastDate=date("Y-m-d H:i:s", strtotime($lastDays." day"));
		$this->dateField=$dateField;		
	}	
}
?>