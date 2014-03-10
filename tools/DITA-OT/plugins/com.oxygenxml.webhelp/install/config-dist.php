<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

// Email address to be used as from in sent emails
define('__EMAIL__',"no-reply@oxygenxml.com");

// Email address to be notified when error occur
define('__ADMIN_EMAIL__',"no-reply@oxygenxml.com");

// Send errors to system administartor?
define('__SEND_ERRORS__',true);

// If the system is moderated each post must be confirmed by moderator
define('__MODERATE__', true);

// User session life time in seconds, by default is 7 days
define('__SESSION_LIFETIME__',604800);

// User friendly Product name
define('__PRODUCT_NAME__',"@PRODUCT_ID@");

// Is unauthenticated user allowed to post comments
define('__GUEST_POST__', true);

$dbConnectionInfo['dbName']="comments";
$dbConnectionInfo['dbUser']="oxygen";
$dbConnectionInfo['dbPassword']="oxygen";
$dbConnectionInfo['dbHost']="localhost";

?>