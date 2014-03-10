<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

interface IFilter{
	/**
	 * Filter or not the values to be exported
	 * @param array $AssociativeRowArray row to be exported
	 * @return boolean <code>true</code> if the specified row is to be filtered
	 */
	public function filter($AssociativeRowArray);
	/**
	 * Get SQL filter clause
	 */
	public function getSqlFilterClause();
}
?>