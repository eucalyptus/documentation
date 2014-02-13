<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class NoFilter implements IFilter{
	/**
	 * 
	 * @see IFilter::filter()
	 */
	public function filter($AssociativeRowArray){
		return false;
	}
	public function getSqlFilterClause(){
		return null;
}
}
?>