<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

require_once 'init.php';
$ses=Session::getInstance();

if ((isset($_POST["productName"]) && trim($_POST["productName"]) !="")		
	&& (isset($_POST["productVersion"]) && trim($_POST["productVersion"]) !="")){
	
	$product=(isset($_POST['productName']) ? $_POST['productName'] :"");
	$version=(isset($_POST['productVersion']) ? $_POST['productVersion'] : "");
	
	if (Utils::isAdministrator($product, $version)){
		if (isset($_POST["inPage"]) && trim($_POST["inPage"]) =="true"){
			$clean=Utils::getParam($_POST, 'clean');
			$filter=new NoFilter();			
			$cellRenderer = new DefaultCellRenderer("span");
			if ($clean=='true'){
				$filter=new UnconfirmedUserFilter(-7, "date");
			}else{
				$filter=new ConfirmedUserFilter(-7, "date");
			}
			$exporter = new InLineExporter('userId',array('userId'),array(17,25,30,20));
			$exporter->setFilter($filter);
			$exporter->setCellRenderer($cellRenderer);
			$tableExporter = new TableExporter("users", $dbConnectionInfo);
			$tableExporter->export($exporter,"userId,userName,name,email,date","ORDER BY date DESC");
			if($exporter->getContent()!="") {
                echo $exporter->getContent();
            }
            else {
                echo Utils::translate("noDataAvailable");
            }
		}else{
// 		$exporter = new XmlExporter("comments");
// 		$comment->exportForPage($info,$exporter);
// 		header('Content-Description: File Transfer');
// 		header('Content-Type: text/xml');
// 		header('Content-Disposition: attachment; filename=comments_'.$fName.'_'.$fVersion.'.xml');
// 		header('Content-Transfer-Encoding: binary');
// 		header('Expires: 0');
// 		header('Cache-Control: must-revalidate');
// 		header('Pragma: public');
// 		ob_clean();
// 		flush();
// 		echo $exporter->getContent();
//   	exit;		
		}
	}
}else{
	echo "No data to export as comment!";
}
?>