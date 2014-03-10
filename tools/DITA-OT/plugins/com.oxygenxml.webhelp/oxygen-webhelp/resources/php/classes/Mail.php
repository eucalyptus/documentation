<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class Mail{

	private $subject;
	private $from;
	private $replyTo;
	private $sendTo = array();
	private $ccTo = array();
	private $bccTo = array();
	private $body;
	private $headers;

	function __construct(){
		
	}


	function Subject( $subject ){
		$this->subject=strtr( $subject, "\r\n" , "  " );
	}

	function From( $from ){
		if( ! is_string($from) ) {
			throw new Exception("Class Mail: error, From is not a string");
		}
		$this->from=$from;
	}

	function ReplyTo( $address ){

		if( ! is_string($address) ){
			throw new Exception("Class Mail: error, Reply-To is not a string");
		}
		$this->replyTo-$address;
	}


	function To( $to ){
		if( is_array($to) ){
			$this->sendTo= $to;
		}else{
			$this->sendTo[] = $to;
		}

	}

	function Cc( $cc ){
		if(is_array($cc)){
			$this->ccTo= $cc;
		}else{
			$this->ccTo[]= $cc;
		}


	}
	function Bcc( $bcc ){
		if( is_array($bcc) ) {
			$this->bccTo = $bcc;
		} else {
			$this->bccTo[]= $bcc;
		}

	}

	function Body( $body){
		$this->body = $body;
	}

	function Organization( $org ){
		if(trim($org != "")){
			$this->organization=$org;
		}
	}


	private function build(){
		$this->headers = "";
		
		if(count($this->ccTo) > 0 ){
			$this->headers.="CC: ".implode( ", ", $this->ccTo )."\r\n";
    }
    
    if (trim($this->replyTo)!=""){
      $this->headers.="Reply-To: ".$this->replyTo."\r\n";
    }
    $this->headers.="From: ".$this->from."\r\n";
    

		if( count($this->bccTo) > 0 ){
			$this->headers.="BCC: ".implode( ", ", $this->bccTo)."\r\n";
		}
		// $this->xheaders['BCC'] = implode( ", ", $this->abcc );
		$this->headers.="X-Mailer: oXygen Webhelp system\r\n";
		$this->headers.= "MIME-Version: 1.0\r\n";
		$this->headers.= "Content-Type: text/html; charset=ISO-8859-1\r\n";
	}

	function Send(){
		$this->build();

		$this->sendTo = implode( ", ", $this->sendTo);

		$result = @mail( $this->sendTo, $this->subject, $this->body, $this->headers);
		return $result;
	}




} // class Mail

?>