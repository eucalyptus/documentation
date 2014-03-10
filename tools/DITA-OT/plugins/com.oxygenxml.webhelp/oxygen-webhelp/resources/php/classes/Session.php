<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class Session{
	const SESSION_STARTED = TRUE;
	const SESSION_NOT_STARTED = FALSE;
	
	// The state of the session
	private $sessionState = self::SESSION_NOT_STARTED;
	
	// THE only instance of the class
	private static $instance;
	
	
	private function __construct() {
	}
	
	
	/**
	 *    Returns THE instance of 'Session'.
	 *    The session is automatically initialized if it wasn't.
	 *
	 *    @return    object
	 **/
	
	public static function getInstance()
	{
		if ( !isset(self::$instance))
		{
			self::$instance = new self;
		}
	
		self::$instance->startSession();
	
		return self::$instance;
	}
	
	
	/**
	 *    (Re)starts the session.
	 *
	 *    @return    bool    TRUE if the session has been initialized, else FALSE.
	 **/
	
	public function startSession()
	{
		if (defined('__SESSION_LIFETIME__')){
			ini_set('session.gc_maxlifetime', __SESSION_LIFETIME__);
			ini_set('session.cookie_lifetime', __SESSION_LIFETIME__);
		}
		if ( $this->sessionState == self::SESSION_NOT_STARTED )
		{
			$this->sessionState = session_start();
		}
	
		return $this->sessionState;
	}
	
	
	/**
	 *    Stores datas in the session.
	 *    Example: $instance->foo = 'bar';
	 *
	 *    @param    name    Name of the datas.
	 *    @param    value    Your datas.
	 *    @return    void
	 **/
	
	public function __set( $name , $value )
	{
		$_SESSION[$name] = $value;
	}
		
	
	
	/**
	 *    Gets datas from the session.
	 *    Example: echo $instance->foo;
	 *
	 *    @param    name    Name of the datas to get.
	 *    @return    mixed    Datas stored in session.
	 **/	
	public function __get( $name )
	{
		if ( isset($_SESSION[$name]))
		{
			return $_SESSION[$name];
		}
	}
	
	
	public function __isset( $name )
	{
		return isset($_SESSION[$name]);
	}
	
	
	public function __unset( $name )
	{
		unset( $_SESSION[$name] );
	}
	
	
	/**
	 *    Destroys the current session.
	 *
	 *    @return    bool    TRUE is session has been deleted, else FALSE.
	 **/
	
	public function destroy()
	{
	
		if (isset($_SESSION['errBag'])){
			$_SESSION['errBag']->send();
			unset($_SESSION['errBag']);
		}
	
		if ( $this->sessionState == self::SESSION_STARTED )
		{
			$this->sessionState = !session_destroy();
			unset( $_SESSION );
	
			return !$this->sessionState;
		}	
		
	
		return FALSE;
	}
}
?>