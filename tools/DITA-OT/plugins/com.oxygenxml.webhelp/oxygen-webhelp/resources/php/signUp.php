<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';
 
 //$ses=Session::getInstance(); 
  	$json = new JsonResponse();
if (isset($_POST['userName']) && trim($_POST['userName']) != ''){
  // send email to support
  
  $info['username']= $_POST['userName'];
  $info['name'] = $_POST['name'];
  $info['password'] = $_POST['password'];
  $info['email'] = $_POST['email']; 
  
  $user= new User($dbConnectionInfo);
  $return = $user->insertNewUser($info);  
  if ($return->error=="true"){
  	echo $return;  	  	
  }else{
  	$id=base64_encode($user->userId."|".$user->date);
    $link="<a href='".__BASE_URL__."oxygen-webhelp/resources/confirm.html?id=$id'>".__BASE_URL__."oxygen-webhelp/resources/confirm.html?id=$id</a>";
  	$template = new Template("./templates/signUp.html");
  	$productTranslate=(defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $_POST['product']);
  	$arrayProducts=$user->getSharedProducts();
  	$products="";
  	foreach ($arrayProducts as $productId => $productName) {
  		$products.="\"".$productName."\" ";
  	}
  	
  	$confirmationMsg = $template->replace(
  			array("name"=>$info['name'],
  					"username"=>$info['username'],
  					"confirmationLink"=>$link,
  					"productName"=>$productTranslate,
  					"products"=>$products));
  	$mail = new Mail();
  	$mail->Subject("[".$productTranslate."] ".Utils::translate('signUpEmailSubject'));  	 
  	$mail->To($info['email']);  	
  	$mail->From(__EMAIL__);  	
  	$mail->Body($confirmationMsg);  	
  	$mail->Send();    	
	$json->set("error", "false");
	$json->set("msg", "SignUp Success");
	echo $json;	  	
  }
}else{
	$json->set("error", "true");
	$json->set("errorCode", "6");
	$json->set("msg", "Invalid username!");
	echo $json;
}
?>