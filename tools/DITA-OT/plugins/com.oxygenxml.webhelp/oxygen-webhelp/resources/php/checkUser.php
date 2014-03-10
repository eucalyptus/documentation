<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once "init.php";
$ses=Session::getInstance();

$pName=(isset($_POST['productName']) ? $_POST['productName'] :"");
$pVersion=(isset($_POST['productVersion']) ? $_POST['productVersion'] : "");
$fullUser=base64_encode($pName."_".$pVersion."_user");

if (isset($_POST['userName']) && trim($_POST['userName']) != ''){
	$username= $_POST['userName'];
	$password= $_POST['password'];
	$toReturn=new JsonResponse();
	$toReturn->set("authenticated", "false");	
	
	$user= new User($dbConnectionInfo);
	if ($user->validate($username, $password)){
		$toReturn->set("authenticated", "true");		
		$ses->$fullUser=$user;		
		$toReturn->set("name",$ses->$fullUser->name);
		$toReturn->set("userName",$ses->$fullUser->userName);
		$toReturn->set("level",$ses->$fullUser->level);
	}else{
		if (strlen(trim($user->msg)) > 0){		
			$toReturn->set("error", $user->msg);
		}	
	}
	echo $toReturn;
}elseif (isset($_POST['logOff']) && trim($_POST['logOff']) != ''){
	$ses->errBag=null;
	unset($ses->errBag);
	unset($ses->$fullUser);
	// 		echo print_r($_POST,true);
}elseif (isset($_POST['check']) && trim($_POST['check']) != ''){
		$toReturn=new JsonResponse();
		$toReturn->set("isAnonymous", "false");
		$toReturn->set("loggedIn","false");
	if ((defined('__GUEST_POST__') && !__GUEST_POST__) 
			&& (isset($ses->$fullUser) 
			&& $ses->$fullUser->isAnonymous=='true')){		
		unset($ses->$fullUser);	
	}
	
	
	if ((defined('__GUEST_POST__') && __GUEST_POST__) 
			&& (!isset($ses->$fullUser))){
		$user= new User($dbConnectionInfo);
		// user not logged in and guest is allowed to post
		if (!$user->initAnonymous()){
			$toReturn->set("isAnonymous", "false");
			$toReturn->set("loggedIn","false");
			$toReturn->set("msg","1");
			$toReturn->set("msgType","error");
		}else{
			// anonymous must be logged in
			$ses->$fullUser=$user;
			$toReturn->set("isAnonymous", "true");
			$toReturn->set("loggedIn","true");
			//TODO: to prompt with last log or else?
			//$toReturn->set("msg","2");
			//$toReturn->set("msgType","info");
			$toReturn->set("name",$ses->$fullUser->name);
			$toReturn->set("userName",$ses->$fullUser->userName);
			$toReturn->set("level",$ses->$fullUser->level);			
		}
	}else{
		if (isset($ses->$fullUser) &&  $ses->$fullUser instanceof User){			
			$toReturn->set("isAnonymous", $ses->$fullUser->isAnonymous);
			$toReturn->set("loggedIn","true");
			//TODO: to prompt with last log or else?
			//$toReturn->set("msg","3");
			//$toReturn->set("msgType","info");
			$toReturn->set("name",$ses->$fullUser->name);
			$toReturn->set("userName",$ses->$fullUser->userName);
			$toReturn->set("level",$ses->$fullUser->level);
		}else{			
			$toReturn->set("isAnonymous", "false");
			$toReturn->set("loggedIn","false");
			//TODO: to prompt with last log or else?
			//$toReturn->set("msg","4");
			//$toReturn->set("msgType","error");			
		}
	}
	$comts = New Comment($dbConnectionInfo);
	$minVer=$comts->getMinimVersion($pName);
	$toReturn->set("minVisibleVersion",$minVer);
	echo $toReturn;
}else{
	// 	echo "none".print_r($_POST,true);
}
?>