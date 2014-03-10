<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class OxyHandler{
	static function error($errno, $errstr, $errfile, $errline){
		if (!(error_reporting() & $errno)) {
			return;
		}

		switch ($errno) {
			case E_USER_ERROR:
				$msg= date("Y-m-d H:i:s").": ERROR [$errno] $errstr on line $errline in file $errfile , PHP " . PHP_VERSION . " (" . PHP_OS . ") \n";
				OxyHandler::sendError($msg);
				exit(1);
				break;

			case E_USER_WARNING:
				$msg=date("Y-m-d H:i:s").": WARNING [$errno] $errstr on line $errline in file $errfile , PHP " . PHP_VERSION . " (" . PHP_OS . ") \n";
				OxyHandler::sendError($msg);
				break;

			case E_USER_NOTICE:
				$msg=date("Y-m-d H:i:s").": NOTICE [$errno] $errstr on line $errline in file $errfile , PHP " . PHP_VERSION . " (" . PHP_OS . ") \n";
				OxyHandler::sendError($msg);
				break;

			default:
				$msg=date("Y-m-d H:i:s").": Unknown error type: [$errno] $errstr on line $errline in file $errfile , PHP " . PHP_VERSION . " (" . PHP_OS . ") \n";
				OxyHandler::sendError($msg);
				break;
		}

		/* Don't execute PHP internal error handler */
		//return true;
	}

	/**
	 *
	 * @param Exception $exception
	 */
	static function exception($exception){
		$msg=date("Y-m-d H:i:s").": Error:[".$exception->getCode()."] message:[".$exception->getMessage()."]	file:[".$exception->getFile()."] line:[".$exception->getLine()."] \n";
		OxyHandler::sendError($msg);
	}

	static function sendError($msg){
		echo "<!-- ".$msg." -->";
		
		$ses=Session::getInstance();
		if (isset($ses->errBag) && ($ses->errBag!=null)){
			$ses->errBag->processException($msg);			
		}else{
			error_log($msg);
				}

		
	}

}