<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Filter all users that are not validated
 */
class ConfirmedUserFilter extends AbstractUserFilter{

	/**
	 * 
	 * @see IFilter::filter()
	 */
	public function filter($AssociativeRowArray){
		return $AssociativeRowArray['status']=="created" && $AssociativeRowArray['userName']!='anonymous';		
	}
	public function getSqlFilterClause(){		
		return "userName<>'anonymous' AND (status='validated' OR status='suspended')";
	}
}
?>