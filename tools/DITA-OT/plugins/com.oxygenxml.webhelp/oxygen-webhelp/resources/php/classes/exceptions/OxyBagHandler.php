<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class OxyBagHandler{

	/**
	 * Exceptions bag
	 * @var String
	 */
	private $bag;
	/**
	 * email List of administrators witch will be receiving the internal errors
	 * @var String
	 */
	private $to;
	private $count;
	private $errorCount;
	private $sendIt;
    private $bagJs;

	/**
	 * Send errors when errorCount is reached
	 *
	 * @param int $errorCount default is 3
	 */
	function __construct($errorCount=0){
        $this->bagJs="";
		$this->bag="";
		$this->errorCount=$errorCount;
		$this->count=0;
		$this->sendIt = defined("__SEND_ERRORS__") && __SEND_ERRORS__;
		$this->to=array();
		if (defined('__ADMIN_EMAIL__') && strlen(trim(__ADMIN_EMAIL__))>0){
			$this->to[]=__ADMIN_EMAIL__;
		}
	}
	private function getRealIpAddr(){
		$ip="unknown";
		if (!empty($_SERVER['HTTP_CLIENT_IP'])){
			$ip=$_SERVER['HTTP_CLIENT_IP'];
		} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])){
			$ip=$_SERVER['HTTP_X_FORWARDED_FOR'];
		} else{
			$ip=$_SERVER['REMOTE_ADDR'];
		}
		return $ip;
	}
	function processException($exceptionMessage){
      $this->bagJs.="[".$this->getRealIpAddr()."] - ".$exceptionMessage."<br/>";
		if ($this->sendIt){
			$this->bag.="[".$this->getRealIpAddr()."] - ".$exceptionMessage."<br/>";
			$this->count++;
			$this->send();
		}else{
			error_log("[".$this->getRealIpAddr()."] - ".$exceptionMessage);
		}
	}
	private function getEmails(){
		global $dbConnectionInfo;
		$this->to=array();
		if (defined('__ADMIN_EMAIL__') && strlen(trim(__ADMIN_EMAIL__))>0){
			$this->to[]=__ADMIN_EMAIL__;
		}
		if (defined("__SEND_ERRORS__") && __SEND_ERRORS__){

			try{
				$ds= new RecordSet($dbConnectionInfo,false,true);
				$ds->open("SELECT email FROM users WHERE level='admin';");
				while ($ds->MoveNext()) {
					$this->to[]=$ds->Field('email');
				}
				$ds->close();
			}catch(Exception $e){
				// ignore
				$msg=date("Y-m-d H:i:s").": Error:[".$e->getCode()."] message:[".$e->getMessage()."]	file:[".$e->getFile()."] line:[".$e->getLine()."]";
				$this->bag.="[".$this->getRealIpAddr()."] - ".$msg."<br/>";
				$this->count++;
				$this->sendInternal(false);
			}
		}
	}
	private function sendInternal($fetchEmails=true){
		if ($this->sendIt){
			if ($fetchEmails){
				$this->getEmails();
			}
			foreach ($this->to as $emailTo){
				$mail = new Mail();
				$mail->Subject("[".$_SERVER["SERVER_NAME"]."] ERROR ");
				$mail->To($emailTo);
				$mail->From(__EMAIL__);
				$mail->Body($this->bag);
				@$mail->Send();
			}
		}
		error_log($this->bag);

	}
    public function poolFromJs(){
      $toReturn=$this->bagJs;
      $this->bagJs="";      
      return $toReturn; 
    }
	public function send(){
		if ((count($this->to)>0) && ($this->count>=$this->errorCount)){
			$this->sendInternal();
			$this->count=0;
			$this->bag="";
		}
		error_log($this->bag.$this->count."/".$this->errorCount);
	}
}