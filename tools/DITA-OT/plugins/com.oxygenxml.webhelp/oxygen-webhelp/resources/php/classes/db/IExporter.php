<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Exporter Interface
 * 
 * @author serban
 *
 */
interface IExporter{
	/**
	 * Export one row 
	 * @param Array $AssociativeRowArray - array containing fieldName=>fieldValue
	 */
	function exportRow($AssociativeRowArray);
	/**
	 * Return the exported contents
	 * @return String content exported
	 */
	function getContent();
	/**
	 * Enable rowFilter by setting this filter
	 * @param IFilter $filter
	 */
	function setFilter($filter);
	/**
	 * Get current filter 
	 * @return IFilter
	 */
	function getFilter(); 
}
?>