<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';

//$ses=Session::getInstance();
	$toReturn = new JsonResponse();
if (isset($_POST['email']) && trim($_POST['email']) != ''){
	// send email to support
	$info['product']= $_POST['product'];
	$info['version'] = $_POST['version'];
	$info['username']= $_POST['userName'];
	$info['email'] = $_POST['email'];

	$user= new User($dbConnectionInfo);
	$generateInfo=$user->generatePasswd($info);
	 
	$productTranslate=(defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $info['product']);

	if ($generateInfo['generated']==""){
		// nu are email valid
		$toReturn->set("success", "false");
		$toReturn->set("message", Utils::translate('noEmailFound'));
		//echo "No ";		
	}else if ($generateInfo['match']){
		// generated password
		$template = new Template("./templates/recover.html");
		$confirmationMsg = $template->replace(array(
				"username"=>$info['username'],
				"password"=>$generateInfo['generated'],
				"productName"=>$productTranslate
				));
		//   	$confirmationMsg = "Your new generated password for user name = ".$info['username']." is ".$generateInfo['generated'];
		$mail = new Mail();
		$mail->Subject("[".$productTranslate."] ".Utils::translate('RecoveredEmailSubject'));
		$mail->To($info['email']);
		$mail->From(__EMAIL__);
		$mail->Body($confirmationMsg);
		$mail->Send();
		$user->changePassword($info['email'],$generateInfo['generated']);
		$toReturn->set("success", "true");
		$toReturn->set("message", Utils::translate('passwordChanged'));		
	}else{
		// confirmation link
		$data= date('Y-m-d H:i:s');
		$template = new Template("./templates/confirmRecover.html");
		$id=base64_encode($info['email']."|".$data."|recover|".$generateInfo['generated']);
		$link="<a href='".__BASE_URL__."oxygen-webhelp/resources/confirm.html?id=$id'>".__BASE_URL__."oxygen-webhelp/resources/confirm.html?id=$id</a>";
		$confirmationMsg = $template->replace(array(
				"product"=>$info['product'],
				"link"=>$link,
				"productName"=>$productTranslate
				));


		$mail = new Mail();
		$mail->Subject("[".$productTranslate."] ".Utils::translate('RecoverConfirmationEmailSubject'));
		$mail->To($info['email']);
		$mail->From(__EMAIL__);
		$mail->Body($confirmationMsg);
		$mail->Send();
		$toReturn->set("success", "true");		
		$toReturn->set("message", Utils::translate('confirmationRequired'));		
	}
	//echo "Success";	
}else{
	$toReturn->set("success", "false");
	$toReturn->set("message", Utils::translate('noEmailSpecified'));
	//echo "Invalid recovery data!";
}
echo $toReturn;
?>