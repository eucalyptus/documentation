<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';

if (isset($_POST['id']) && trim($_POST['id']) != ''){	
	$encoded=$_POST['id'];
	$decoded=base64_decode($encoded);
	list($id,$action)=explode("&", $decoded);
	$fullUser=base64_encode($_POST['productName']."_".$_POST['productVersion']."_user");
	$commentedPage=moderateComment($id,$action,$fullUser);	
	echo __BASE_URL__.$commentedPage;
}else if (isset($_POST['uncodedId']) && trim($_POST['uncodedId']) != ''){
	$fullUser=base64_encode($_POST['product']."_".$_POST['version']."_user");
	$commentedPage=moderateComment(trim($_POST['uncodedId']),trim($_POST['action']),$fullUser);	
	echo __BASE_URL__.$commentedPage;
}else if (isset($_POST['ids']) && trim($_POST['ids']) != ''){
	$fullUser=base64_encode($_POST['product']."_".$_POST['version']."_user");
	$cmt= new Comment($dbConnectionInfo,"",$fullUser);
	$ids=trim($_POST['ids']);
	$return = $cmt->deleteComments($ids);
	echo $return;
}else if (isset($_POST['page']) && trim($_POST['page']) != ''){
	$fullUser=base64_encode($_POST['product']."_".$_POST['version']."_user");
	approveAll(substr($_POST['page'],(strlen(__BASE_URL__))),$fullUser);
	echo $_POST['page'];
}else{
	echo "Invalid data!";
}

function approveAll($page,$fullUser){
	global $dbConnectionInfo;
	
	$cmt= new Comment($dbConnectionInfo,"",$fullUser);
	
	$returnIds = $cmt->approveAll($page);

		// notify users
	$user = new User($dbConnectionInfo);
	foreach ($returnIds as $key => $updatedId){		
		$usersToNotify=$user->getUsersToNotify($page,$updatedId);		
		$cmtInfo = $cmt->getInfo($updatedId);		
		$productTranslate=(defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $cmtInfo['product']);
		foreach ($usersToNotify as $key => $value){
			$template = new Template("./templates/newComment.html");
		
			$confirmationMsg = $template->replace(array(
					"page"=>$page."#".$updatedId,
					"text"=>$cmtInfo['text'],
					"name"=>$cmtInfo['name'],
					"username"=>$cmtInfo['userName']
			));
			$mail = new Mail();
			$subject="[".$productTranslate."] ".Utils::translate('newCommentApproved');
			$subject.=" [".$page."]";
			$mail->Subject($subject);
			$mail->To($value);
			$mail->From(__EMAIL__);
			$mail->Body($confirmationMsg);
			$mail->Send();
			//$toReturn = "\nSEND to ".$value."user email='".$userEmail."'";
		}
	}
}


function moderateComment($id,$action,$fullUser){
	global $dbConnectionInfo;	
	
	$toReturn="";
	$act=false;
	if ($action=="approved"){
		$act=true;
	}
	$cmt= new Comment($dbConnectionInfo,"",$fullUser);
	$return = $cmt->moderate($id,$action);
	
	$toReturn=$return['page'];
	if ($return['page'] !="" && $act && $return['oldState'] =='new'){
		// notify users
		$user = new User($dbConnectionInfo);
		$usersToNotify=$user->getUsersToNotify($toReturn,$id);
				
		$cmtInfo = $cmt->getInfo($id);
		$productTranslate=(defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $cmtInfo['product']);
				$template = new Template("./templates/newComment.html");
				$confirmationMsg = $template->replace(array(
						"page"=>__BASE_URL__.$toReturn."#".$id,
						"text"=>$cmtInfo['text'],
						"user"=>$cmtInfo['name'],
						"productName"=>$productTranslate
				));
		foreach ($usersToNotify as $key => $value){					
				$mail = new Mail();
				$subject="[".$productTranslate."] ".Utils::translate('newCommentApproved');
				$subject.=" [".$toReturn."]";
				
				$mail->Subject($subject);
				$mail->To($value);
				$mail->From(__EMAIL__);
				$mail->Body($confirmationMsg);
				$mail->Send();
				//$toReturn = "\nSEND to ".$value."user email='".$userEmail."'";			
		}
	}
	return $toReturn;	
}
?>