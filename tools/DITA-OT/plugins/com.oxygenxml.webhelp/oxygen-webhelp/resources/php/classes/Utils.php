<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class Utils{
	/**
	 *  return the difference between two dates formatted as "YYYY-MM-DD HH:MM:SS"
	 * @param String $startDate
	 * @param String $endDate
	 * @param int $format
	 * <ul>
	 * 	<li>1 - Difference in Minutes</li>
	 *  <li>2 - Difference in Hours</li>
	 *  <li>3 - Difference in Days</li>
	 *  <li>4 - Difference in Weeks</li>
	 *  <li>5 - Difference in Months</li>
	 *  <li>4 - Difference in Years</li>
	 * </ul>
	 * @return int
	 */
	static function getTimeDifference($startDate,$endDate,$format = 3)
	{
		list($date,$time) = explode(' ',$endDate);
		$startdate = explode("-",$date);
		$starttime = explode(":",$time);

		list($date,$time) = explode(' ',$startDate);
		$enddate = explode("-",$date);
		$endtime = explode(":",$time);

		$secondsDifference = mktime($endtime[0],$endtime[1],$endtime[2],
				$enddate[1],$enddate[2],$enddate[0]) - mktime($starttime[0],
						$starttime[1],$starttime[2],$startdate[1],$startdate[2],$startdate[0]);

		switch($format){
			// Difference in Minutes
			case 1:
				return floor($secondsDifference/60);
				// Difference in Hours
			case 2:
				return floor($secondsDifference/60/60);
				// Difference in Days
			case 3:
				return floor($secondsDifference/60/60/24);
				// Difference in Weeks
			case 4:
				return floor($secondsDifference/60/60/24/7);
				// Difference in Months
			case 5:
				return floor($secondsDifference/60/60/24/7/4);
				// Difference in Years
			default:
				return floor($secondsDifference/365/60/60/24);
		}
	}
	static function translate($key){
		global $translate;
		$toReturn=$key;
		if (array_key_exists($key, $translate)){
			$toReturn = $translate[$key];
		}
		return $toReturn;
	}
	/**
	 *
	 * Generate Password
	 *
	 * @param int $pw_length
	 * @param bool pe $use_caps
	 * @param bool $use_numeric
	 * @param bool $use_specials
	 */
	static function generatePassword($pw_length = 8, $use_caps = true, $use_numeric = true, $use_specials = true) {
		$caps = array();
		$numbers = array();
		$num_specials = 0;
		$reg_length = $pw_length;
		$pws = array();
		$chars = range(97, 122); // create a-z
		if ($use_caps) $caps = range(65, 90); // create A-Z
		if ($use_numeric) $numbers = range(48, 57); // create 0-9
		$all = array_merge($chars, $caps, $numbers);
		if ($use_specials) {
			$reg_length =  ceil($pw_length*0.75);
			$num_specials = $pw_length - $reg_length;
			if ($num_specials > 5) $num_specials = 5;
			$signs = range(33, 47);
			$rs_keys = array_rand($signs, $num_specials);
			foreach ($rs_keys as $rs) {
				$pws[] = chr($signs[$rs]);
			}
		}
		$rand_keys = array_rand($all, $reg_length);
		foreach ($rand_keys as $rand) {
			$pw[] = chr($all[$rand]);
		}
		$compl = array_merge($pw, $pws);
		shuffle($compl);
		return implode('', $compl);
	}
	/**
	 * Convert an array into string values been separated by separator
	 * 
	 * @param array $array to be converted
	 * @param string $separator values separator
	 */
	static public function arrayToString($array,$separator=","){
		$toReturn="";
		if (count($array)>0){
			foreach ($array as $value){
				$toReturn.=$value.$separator;
			}
			$toReturn=substr($toReturn, 0,strlen($toReturn)-strlen($separator));
		}
		return $toReturn;
	}
	/**
	 * Convert a string into an array using the the beginChar and EndChar to be added to any array element 
	 * 
	 * @param String $string
	 * @param String $delimiter
	 * @param String $beginChar
	 * @param String $endChar
	 */
	static public function stringToArray($string,$delimiter=",",$beginChar="",$endChar=""){
		$toReturn=explode($delimiter, $string);			
		for ($i=0; $i<count($toReturn);$i++){
			$toReturn[$i]=$beginChar.$toReturn[$i].$endChar;
		}		
		return $toReturn;
	}

	/**
	 * Strip html tags and allow only
	 *
	 * @param String $text
	 * @param array $allowTags allowed tags as '<p>','<a>'
	 * @return String stripped tags
	 *
	 */
	static public function strip_html_tags( $text,$allowTags=array('<p>','<b>','<div>','<i>','<u>','<strike>','<sub>','<sup>','<font>','<ol>','<span>','<li>','<ul>','<h1>','<h2>','<h3>','<h4>','<h5>','<h6>','<h7>','<h8>','<h9>','<br>','<blockquote>','<hr>','<img>','<a>')){		
		$tagsStr=Utils::arrayToString($allowTags,'');
		$text = preg_replace(
				array(
						// Remove invisible content
						'@<head[^>]*?>.*?</head>@siu',
						'@<style[^>]*?>.*?</style>@siu',
						'@<script[^>]*?.*?</script>@siu',
						'@<object[^>]*?.*?</object>@siu',
						'@<embed[^>]*?.*?</embed>@siu',
						'@<applet[^>]*?.*?</applet>@siu',
						'@<noframes[^>]*?.*?</noframes>@siu',
						'@<noscript[^>]*?.*?</noscript>@siu',
						'@<noembed[^>]*?.*?</noembed>@siu',
						// Add line breaks before and after blocks
						'@</?((address)|(blockquote)|(center)|(del))@iu',
						'@</?((div)|(h[1-9])|(ins)|(isindex)|(p)|(pre))@iu',
						'@</?((dir)|(dl)|(dt)|(dd)|(li)|(menu)|(ol)|(ul))@iu',
						'@</?((table)|(th)|(td)|(caption))@iu',
						'@</?((form)|(button)|(fieldset)|(legend)|(input))@iu',
						'@</?((label)|(select)|(optgroup)|(option)|(textarea))@iu',
						'@</?((frameset)|(frame)|(iframe))@iu',
				),
				array(
						' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',"$0", "$0", "$0", "$0", "$0", "$0","$0", "$0",), $text );

		$strip_tags = strip_tags( $text , $tagsStr );
		
        if (__MODERATE__===true){
          // if the posts ar to be moderated, then we do not strip links from content
        }else{
          // replace "a href" with wiki sintax style
          $strip_tags = preg_replace('/<a href=\"(.*?)\">(.*?)<\/a>/', "[\\1 \\2]",$strip_tags);
        }
		
		/*
		$dom = new DOMDocument();
		$dom->loadHTML($strip_tags);
		
		$strip_attributes = array('onclick', 'onload', 'onleave');
		foreach($dom->getElementsByTagName('*') as $node){
			for($i = $node->attributes->length -1; $i >= 0; $i--){
				$attribute = $node->attributes->item($i);
				if(in_array($attribute->name,$strip_attributes)) {
					$node->removeAttributeNode($attribute);
				}
			}
		}
		$toReturn = $dom->saveHTML();

		if($toReturn === FALSE){
			$toReturn = $strip_tags;			
		}
		*/
		$toReturn=Utils::strip_tags_attributes($strip_tags,$allowTags);
		
	$result=preg_match('/\<body\>(?P<text>.+)\<\/body\>/', $toReturn, $matches);
    if ($result===FALSE){
      return $toReturn;
    }else{
      if ($result>0){
           return $matches['text'];
      }else{
        return $toReturn;
      }    
    }		
		//preg_match('/\<body\>(?<text>.+)\<\/body\>/', $strip_tags, $matches);
		//return $matches['text'];
	}
	
	static public function strip_tags_attributes($sSource, $aAllowedTags = array(), $aDisabledAttributes = null ){
		if ($aDisabledAttributes==null){
			$aDisabledAttributes=array('onabort', 'onactivate', 'onafterprint', 'onafterupdate',
					'onbeforeactivate', 'onbeforecopy', 'onbeforecut', 'onbeforedeactivate', 
					'onbeforeeditfocus', 'onbeforepaste', 'onbeforeprint', 'onbeforeunload', 
					'onbeforeupdate', 'onblur', 'onbounce', 'oncellchange', 'onchange', 'onclick',
					'oncontextmenu', 'oncontrolselect', 'oncopy', 'oncut', 'ondataavaible', 
					'ondatasetchanged', 'ondatasetcomplete', 'ondblclick', 'ondeactivate', 'ondrag',
					'ondragdrop', 'ondragend', 'ondragenter', 'ondragleave', 'ondragover', 'ondragstart',
					'ondrop', 'onerror', 'onerrorupdate', 'onfilterupdate', 'onfinish', 'onfocus', 'onfocusin',
					'onfocusout', 'onhelp', 'onkeydown', 'onkeypress', 'onkeyup', 'onlayoutcomplete', 'onload', 
					'onlosecapture', 'onmousedown', 'onmouseenter', 'onmouseleave', 'onmousemove', 'onmoveout', 
					'onmouseover', 'onmouseup', 'onmousewheel', 'onmove', 'onmoveend', 'onmovestart', 'onpaste', 
					'onpropertychange', 'onreadystatechange', 'onreset', 'onresize', 'onresizeend', 'onresizestart',
					'onrowexit', 'onrowsdelete', 'onrowsinserted', 'onscroll', 'onselect', 'onselectionchange', 
					'onselectstart', 'onstart', 'onstop', 'onsubmit', 'onunload');
		}
		if (is_array($aDisabledAttributes) && empty($aDisabledAttributes)){
			 return strip_tags($sSource, implode('', $aAllowedTags));
		}
		return preg_replace('/<(.*?)>/ie', "'<' . preg_replace(array('/javascript:[^\"\']*/i', '/(" . implode('|', $aDisabledAttributes) . ")[ \\t\\n]*=[ \\t\\n]*[\"\'][^\"\']*[\"\']/i', '/\s+/'), array('', '', ' '), stripslashes('\\1')) . '>'", strip_tags($sSource, implode('', $aAllowedTags)));
	}
	
	/**
	 * Utility function to return a value from a named array or a specified default
	 */
	static function getParam(&$arr, $name, $def=null) {
		return isset($arr[$name]) ? $arr[$name] : $def;
	}
	
	/**
	 * copy files from source to dest
	 * 
	 * @param String $path
	 * @param String $dest
	 */
	static function copy_r( $path, $dest ){
		if( is_dir($path) ){
			@mkdir( $dest );
			$objects = scandir($path);
			if( sizeof($objects) > 0 ){
				foreach( $objects as $file ){
					if( $file == "." || $file == ".." )
						continue;
					// go on
					if( is_dir( $path.DIRECTORY_SEPARATOR.$file ) ){
						copy_r( $path.DIRECTORY_SEPARATOR.$file, $dest.DIRECTORY_SEPARATOR.$file );
					}else{					
						copy( $path.DIRECTORY_SEPARATOR.$file, $dest.DIRECTORY_SEPARATOR.$file );
					}
				}
			}
			return true;
		}elseif( is_file($path) ){
			return copy($path, $dest);
		}else{
			return false;
		}
	}
	
	/**
	 * Extract email address
	 */
	static function extractEmail($text){
		$toReturn="";
		if ((strpos($text, "<") !== false) && (strpos($text, "<")>0)){
			if ((strpos($text, ">") !== false) && (strpos($text, ">")>0)){				
				$toReturn=substr($text, strpos($text, "<")+1,strpos($text, ">"));
			}
		}	
		return $toReturn;
	}
	/**
	 * Extrcat browser information
	 * 
	 * @return array {
   *     'userAgent' => $u_agent,
   *     'name'      => $bname,
   *     'version'   => $version,
   *     'platform'  => $platform,
   *     'pattern'
   *     }
	 */
	static function getBrowser(){ 
    $u_agent = $_SERVER['HTTP_USER_AGENT']; 
    $bname = 'Unknown';
    $platform = 'Unknown';
    $version= "";   
    $ub="";   

    //First get the platform?
    if (preg_match('/linux/i', $u_agent)) {
        $platform = 'linux';
}
    elseif (preg_match('/macintosh|mac os x/i', $u_agent)) {
        $platform = 'mac';
    }
    elseif (preg_match('/windows|win32/i', $u_agent)) {
        $platform = 'windows';
    }
    
    // Next get the name of the useragent yes seperately and for good reason
    if(preg_match('/MSIE/i',$u_agent) && !preg_match('/Opera/i',$u_agent)) 
    { 
        $bname = 'Internet Explorer'; 
        $ub = "MSIE"; 
    }
    elseif(preg_match('/Trident/i',$u_agent) && !preg_match('/Opera/i',$u_agent))
    {
        $bname = 'Internet Explorer';
        $ub = "rv";
    }
    elseif(preg_match('/Firefox/i',$u_agent)) 
    { 
        $bname = 'Mozilla Firefox'; 
        $ub = "Firefox"; 
    } 
    elseif(preg_match('/Chrome/i',$u_agent)) 
    { 
        $bname = 'Google Chrome'; 
        $ub = "Chrome"; 
    } 
    elseif(preg_match('/Safari/i',$u_agent)) 
    { 
        $bname = 'Apple Safari'; 
        $ub = "Safari"; 
    } 
    elseif(preg_match('/Opera/i',$u_agent)) 
    { 
        $bname = 'Opera'; 
        $ub = "Opera"; 
    } 
    elseif(preg_match('/Netscape/i',$u_agent)) 
    { 
        $bname = 'Netscape'; 
        $ub = "Netscape"; 
    } 
    
    // finally get the correct version number
    $known = array('Version', $ub, 'other');
    $pattern = '#(?P<browser>' . join('|', $known) .')[/ |:]+(?P<version>[0-9.|a-zA-Z.]*)#';
    if (!preg_match_all($pattern, $u_agent, $matches)) {
        // we have no matching number just continue
    }
    
    // see how many we have
    if (isset($matches['browser'])){
    $i = count($matches['browser']);
    if ($i != 1) {
        //we will have two since we are not using 'other' argument yet
        //see if version is before or after the name
        if (strripos($u_agent,"Version") < strripos($u_agent,$ub)){
            $version= $matches['version'][0];
        }
        else {
            $version= $matches['version'][1];
        }
    }
    else {
        $version= $matches['version'][0];
    }
    }else{
    	$version="?";
    }
    
    // check if we have a number
    if ($version==null || $version=="") {$version="?";}
    
    return array(
        'userAgent' => $u_agent,
        'name'      => $bname,
        'version'   => $version,
        'platform'  => $platform,
        'pattern'    => $pattern,
    		'ub'		=>	$ub
    );
} 
	/**
	 * Check if is a logged user with moderation rights in order to update comments
	 *  @param string $product product specified in comment
	 *  @param string $product version specified in comment
	 *  @param int $cmtUser userId from comment - if is the same user as the logged one then it will be administrator for that comment
	 *  @return true if there is a logged user found in session
	 */
	static function isLoggedModerator($product,$version,$cmtUser=-2){
		$ses=Session::getInstance();		
		$fullUser=base64_encode($product."_".$version."_user");
		$toReturn=false;		
		if (isset($ses->$fullUser) && $ses->$fullUser instanceof User){
			if (($ses->$fullUser->isAnonymous!='true') && (($ses->$fullUser->level!='user' || $ses->$fullUser->userId==$cmtUser))){
				$toReturn=true;
}
		}
		return $toReturn;
	}
	/**
	 * Check if current logged user has administrator role
	 * @param unknown_type $product
	 * @param unknown_type $version
	 */
	static function isAdministrator($product,$version){
		$ses=Session::getInstance();
		$fullUser=base64_encode($product."_".$version."_user");
		$toReturn=false;
		if (isset($ses->$fullUser) && $ses->$fullUser instanceof User){
			$toReturn=$ses->$fullUser->level=='admin';
		}
		return $toReturn;
	}
}
?>