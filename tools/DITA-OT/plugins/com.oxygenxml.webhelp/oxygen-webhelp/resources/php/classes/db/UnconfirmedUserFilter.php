<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Filter all users that are validated or waiting for validation
 */

class UnconfirmedUserFilter extends AbstractUserFilter{

	/**
	 * 
	 * @see IFilter::filter()
	 */
	public function filter($AssociativeRowArray){
		return $AssociativeRowArray[$this->dateField]>=$this->lastDate && $AssociativeRowArray['userName']!='anonymous';		
	}
	public function getSqlFilterClause(){
		return $this->dateField."<'".$this->lastDate."' AND status='created' AND userName<>'anonymous'";
	}
}
?>