<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';

	$toReturn= new JsonResponse();
if (isset($_POST['id']) && trim($_POST['id']) != ''){
	$realId= base64_decode($_POST['id']);
	//list($id,$date,$action,$newPassword) = explode("|", $realId);
	$args = explode("|", $realId);
	$id=$args[0];
	$date=$args[1];
	$action="new";
	$newPassword="";
	if (count($args)>2){
		$action=$args[2];
		$newPassword=$args[3];
	}

	$user= new User($dbConnectionInfo);
	//echo "id=".$id." date=".$date;
	
	$currentDate= date("Y-m-d G:i:s");
	$days = Utils::getTimeDifference($currentDate, $date, 3);
	if ($days>7){
		$toReturn->set("error", true);
		$toReturn->set("msg", "Confirmation code expired!");				
	}else{
		$productTranslate=(defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $_POST['productName']);
		if ($action=="recover"){
			$email=$id;
			$userName = $user->changePassword($email, $newPassword);
			if ($userName!=""){
				$template = new Template("./templates/recover.html");
				$confirmationMsg = $template->replace(
						array("username"=>$userName,
									"password"=>$newPassword,
									"productName"=>$productTranslate));
				//
// 				$confirmationMsg = "Your generated password form username '".$userName."' is '".$newPassword."'";
// 				$confirmationMsg.="<br/>Thank you !";
				$mail = new Mail();
				$mail->Subject("[".$productTranslate."] ".$translate['RecoveredEmailSubject']);
				$mail->To($email);
				$mail->From(__EMAIL__);
				$mail->Body($confirmationMsg);
				$mail->Send();
				$toReturn->set("error", false);
				$toReturn->set("msg", Utils::translate('signUp.confirmOk'));
			}else{
				$toReturn->set("error", true);
				$toReturn->set("msg", Utils::translate("signUp.invalidPswd"));				
			}
		}else{
// 			echo print_r($_SESSION,false);
			if ($user->confirmUser($id)){
				$pName=(isset($_POST['productName']) ? $_POST['productName'] :"");
				$pVersion=(isset($_POST['productVersion']) ? $_POST['productVersion'] : "");
				$fullUser=base64_encode($pName."_".$pVersion."_user");				
				$ses=Session::getInstance();			
				$ses->$fullUser=$user;
// 				echo print_r($_SESSION,false);
// 				echo $user->msg;
				$toReturn->set("error", false);
				$toReturn->set("msg", $user->msg);
			}else{
				$toReturn->set("error", true);
				$toReturn->set("msg", $user->msg);				
			}
		}		
	}
}else{
	$toReturn->set("error", true);
	$toReturn->set("msg", "Invalid data!");	
}
echo $toReturn;

?>