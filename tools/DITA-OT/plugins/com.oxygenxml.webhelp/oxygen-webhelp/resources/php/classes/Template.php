<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class Template {
	/**
	 * Tempplate file content
	 * @var string
	 */
	private $template;
	/**
	 * Constructor
	 * @param string $filepath template file path
	 */
	function __construct($filepath) {
		$this->template = file_get_contents($filepath);
	}

	/**
	 * Replace provided value in template
	 * 
	 * @param array $content array containing pairs of value to be replaced => value to preplace with
	 * @return content of the template after replacement 
	 */ 
	function replace($content) {
		foreach ($content as $key => $val){
			$this->template = str_replace("#$key#", $val, $this->template);
		}
		return $this->template;
	}	

}

?>