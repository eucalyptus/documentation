<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class EMail
{
	const newline = "\r\n";

	private	$Server;
	private	$Port;
	private	$Localhost;
	private	$skt;

	public $Username;
	public $Password;
	public $ConnectTimeout;
	public $ResponseTimeout;
	public $Headers;
	public $ContentType;
	public $From;
	public $To;
	public $Cc;
	public $Subject;
	public $Message;
	public $Log;

	function __construct($server,$port){
		$this->Server = $server;
		$this->Port = $port;
		$this->Localhost = "localhost";
		$this->ConnectTimeout = 30;
		$this->ResponseTimeout = 8;
		$this->From = array();
		$this->To = array();
		$this->Cc = array();
		$this->Log = array();
		$this->Headers['MIME-Version'] = "1.0";
		$this->Headers['Content-type'] = "text/plain; charset=iso-8859-1";
	}

	private function GetResponse(){
		stream_set_timeout($this->skt, $this->ResponseTimeout);
		$response = '';
		while (($line = fgets($this->skt, 515)) != false){
			$response .= trim($line) . "\n";
			if (substr($line,3,1)==' ') break;
		}
		return trim($response);
	}

	private function SendCMD($CMD){
		fputs($this->skt, $CMD . self::newline);

		return $this->GetResponse();
	}

	private function FmtAddr(&$addr){
		if ($addr[1] == ""){
			return $addr[0]; 
		}else{
			return "\"{$addr[1]}\" <{$this->extractAddrs($addr[0])}>";
		}
	}
	/**
	 * Extract e-mail address from text like "Smith <Smith@oxygenxml.com>"
	 * @param String $string
	 * @return String email address like "Smith@oxygenxml.com" 
	 */
	private function extractAddrs($string){
		$toReturn=$string;
		if ((strpos($string, "<")>0) && (strpos($string, ">")>0)){
			$start=strpos($string, "<")+1;
			$end=strpos($string, ">");
			$length=$end-$start;
			$toReturn=substr($string, $start,$length);	
		}
		return $toReturn;
	}
	
	private function FmtAddrList(&$addrs){
		$list = "";
		foreach ($addrs as $addr)
		{
			if ($list) $list .= ", ".self::newline."\t";
			$list .= $this->FmtAddr($addr);
		}
		return $list;
	}

	function AddTo($addr,$name = ""){
		$this->To[] = array($addr,$name);
	}

	function AddCc($addr,$name = ""){
		$this->Cc[] = array($addr,$name);
	}

	function SetFrom($addr,$name = ""){
		$this->From = array($addr,$name);
	}

	function Send(){
		$newLine = self::newline;

		//Connect to the host on the specified port
		$this->skt = fsockopen($this->Server, $this->Port, $errno, $errstr, $this->ConnectTimeout);

		if (empty($this->skt))
			return false;

		$this->Log['connection'] = $this->GetResponse();

		//Say Hello to SMTP
		$this->Log['helo']     = $this->SendCMD("EHLO {$this->Localhost}");

		if (strlen(trim($this->Username))>0){
			//Request Auth Login
			$this->Log['auth']     = $this->SendCMD("AUTH LOGIN");
			$this->Log['username'] = $this->SendCMD(base64_encode($this->Username));
			$this->Log['password'] = $this->SendCMD(base64_encode($this->Password));
		}

		//Email From
		$this->Log['mailfrom'] = $this->SendCMD("MAIL FROM:<{$this->From[0]}>");

		//Email To
		$i = 1;
		foreach (array_merge($this->To,$this->Cc) as $addr)
			$this->Log['rcptto'.$i++] = $this->SendCMD("RCPT TO:<{$addr[0]}>");

		//The Email
		$this->Log['data1'] = $this->SendCMD("DATA");

		//Construct Headers
		if (!empty($this->ContentType))
			$this->Headers['Content-type'] = $this->ContentType;
		$this->Headers['From'] = $this->FmtAddr($this->From);
		$this->Headers['To'] = $this->FmtAddrList($this->To);
		if (!empty($this->Cc))
			$this->Headers['Cc'] = $this->FmtAddrList($this->Cc);
		$this->Headers['Subject'] = $this->Subject;
		$this->Headers['Date'] = date('r');

		$headers = '';
		foreach ($this->Headers as $key => $val){
			$headers .= $key . ': ' . $val . self::newline;
		}

		$this->Log['data2'] = $this->SendCMD("{$headers}{$newLine}{$this->Message}{$newLine}.");

		// Say Bye to SMTP
		$this->Log['quit']  = $this->SendCMD("QUIT");

		fclose($this->skt);

		return substr($this->Log['data2'],0,3) == "250";
	}
}
?>