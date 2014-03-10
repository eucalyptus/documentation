<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';
Session::getInstance();

function getBaseUrl($product,$version){
	global $dbConnectionInfo;
	$toReturn=__BASE_URL__;
	$db= new RecordSet($dbConnectionInfo,false,true);
	$rows=$db->Open("SELECT value FROM webhelp WHERE parameter='path' AND product='".$product."' AND version='".$version."';");
	if ($rows==1){
		$db->MoveNext();
		$toReturn=$db->Field('value');
	}
	$db->Close();
	return $toReturn;	
}

if ((isset($_POST["productName"]) && trim($_POST["productName"]) !="")		
	&& (isset($_POST["productVersion"]) && trim($_POST["productVersion"]) !="")) {
	
	$info= array();
	
	$pName=(isset($_POST['productName']) ? $_POST['productName'] :"");
	$pVersion=(isset($_POST['productVersion']) ? $_POST['productVersion'] : "");
	//product to export comments for
	$fName=(isset($_POST['productN']) ? $_POST['productN'] :"");
	$fVersion=(isset($_POST['productV']) ? $_POST['productV'] : "");
	$fullUser=base64_encode($pName."_".$pVersion."_user");
	
	$info["sessionUserName"]=$fullUser;	
	$info["filter_version"]=$fVersion;
	$info["filter_product"]=$fName;
	
	$comment = new Comment($dbConnectionInfo,"",$fullUser);
	if (isset($_POST["inPage"]) && trim($_POST["inPage"]) =="true"){
		$clean=Utils::getParam($_POST, 'clean');
		$filter=new NoFilter();
		$baserUrl = getBaseUrl($fName,$fVersion);
		$cellRenderer = new LinkCellRenderer($baserUrl);
		$cellRenderer->addLinkToField("page");
		if ($clean=='true'){
			$cellRenderer = null;
			$filter=new ExistingPageFilter(__BASE_DIR__, 'page');
		}else{
			$filter=new MissingPageFilter(__BASE_DIR__, 'page');
		} 
		$exporter = new InLineExporter('commentId',array('commentId'),array(45,24,16,7));
		$exporter->setFilter($filter);
		$exporter->setCellRenderer($cellRenderer);
		$comment->exportForPage($info,$exporter,array('commentId','text','page','date','state'));
		if($exporter->getContent()!="") {
            echo $exporter->getContent();
        }
        else {
            echo Utils::translate("noDataAvailable");
        }
	}else{
		$exporter = new XmlExporter("comments");
		$comment->exportForPage($info,$exporter);
		header('Content-Description: File Transfer');
		header('Content-Type: text/xml');
		header('Content-Disposition: attachment; filename=comments_'.$fName.'_'.$fVersion.'.xml');
		header('Content-Transfer-Encoding: binary');
		header('Expires: 0');
		header('Cache-Control: must-revalidate');
		header('Pragma: public');
		ob_clean();
		flush();
		echo $exporter->getContent();
  	exit;		
	}		
}else{
	echo "No data to export as comment!";
}
?>