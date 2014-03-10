<?php
/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

$baseDir0 = dirname(dirname(__FILE__));
include $baseDir0.'/oxygen-webhelp/resources/php/init.php';

$ses= Session::getInstance();
session_unset();
				
$failedImg = '<img src="./img/cancel.png" width="16" height="16" alt="Failed"/>';
$okImg = '<img src="./img/ok.png" width="16" height="16" alt="OK"/>';

$cfgDir = '../oxygen-webhelp/resources/php/config';

$chmod = 0777;
$showButton=true;

$cfgFile = '../oxygen-webhelp/resources/php/config/config.php';
if (file_exists($cfgFile)){
	echo "<div class='panel'>Already configured !";
	echo "<input type=\"hidden\" name=\"existCfg\" value=\"true\">";
	// for security reasons not showing config content.
// 	$handle = fopen("$cfgFile", "rb");
// 	$contents = '';
//   echo "<pre>";
// 	while (!feof($handle)) {
// 		$contents .= fread($handle, 8192);    
//     $contents = htmlentities($contents);
// 		$contents= str_replace('\n','<br/>',$contents);
    
//     echo $contents;    
// 	}
//   echo "</pre>
// 	fclose($handle);
		echo "</div>";
}else{
	echo "<input type=\"hidden\" name=\"existCfg\" value=\"false\">";
}
?>
<div class="panel">
	<div class="title">Check for Requirements</div>
	<table class="col2">
	 <tr>
  		<td>PHP Version &gt;= 5.1.6</td>
			<td>
				<?php 
					if (version_compare(phpversion(), '5.1.6', '<')){
						echo  '<b>'.$failedImg.' ('.phpversion().'): webHelp may not work. Please upgrade!</b>';
						$showButton=false;
					}else{
						echo  $okImg.'<span> ('.phpversion().')</span>';
					}				
				?>
			</td>				
	</tr>
	<tr>			
			<td>PHP MySQL Support</td>
			<td>							
				<?php
					if (function_exists('mysql_connect')){ 
						echo  '<b>'.$okImg.'</b><span> ('.mysql_get_server_info().')</span>';
					}else{
						echo  '<span>'.$failedImg.' Not available</span>';
						$showButton=false;
					}
						?>
			</td>		
	</tr>
	<tr>
		<td>Session Save Path writable</td>
		<td>
		<?php 
	$sspath = ini_get('session.save_path');
	if (! $sspath) {
		echo "<b class='error'>$failedImg Fatal:</b> <span class='item'>session.save_path</span> <b class='error'> is not set</b>";
	} else if (is_dir($sspath) && is_writable($sspath)) {
		echo "<b class='ok'>$okImg</b> <span class='item'>($sspath)</span>";
	} else {
		echo "<b class='error'>$failedImg Fatal:</b> <span class='item'>$sspath</span><b class='error'> not existing or not writable</b>";
	}
	?>
		</td>
	</tr>
	<tr>			
			<td><?php echo $cfgFile?> writable</td>
			<td>
        <?php
        $okMessage='';
        if ((file_exists($cfgFile) && !is_writable($cfgFile)) || (!file_exists($cfgFile) && !(is_writable($cfgDir)))) {
        	@chmod($cfgFile, $chmod);
        	@chmod($cfgDir, $chmod);
        	$filemode = @fileperms($cfgFile);
        	
        	if ($filemode & 2) {
        		$okMessage='<span> World Writable</span>';
        	}
        }
        if (is_writable($cfgFile) || is_writable($cfgDir)){
        	echo '<b>'.$okImg.'</b>'.$okMessage; 
        }else{
        	echo'<b>'.$failedImg.'</b><span> Configuration process can not be continued!. </span>';
        	$showButton=false; 
        }        
         ?>
			</td>		
	</tr>
	<tr>			
			<td>Supported Web Server</td>
			<td>
				<?php echo (stristr($_SERVER['SERVER_SOFTWARE'], 'apache') != false) ? '<b>'.$okImg.'</b><span> ('.$_SERVER['SERVER_SOFTWARE'].')</span>' : '<b>'.$failedImg.'</b><span>
            It seems you are using an unsupported web server.  Only Apache Web server is fully supported by Oxygen WebHelp system, and using other web servers may result in unexpected problems.
            </span>';?>
			</td>		
	</tr>
	<tr>			
			<td>Supported Web Browser<br/>
				<span class="settingDesc">Oxygen WebHelp system supports the following browsers: IE7+, Chrome 19+, Firefox 11+, Safari 5+, Opera 11+.</span>
			</td>
			<td>
				<?php
				$browser=Utils::getBrowser();
				$supported=false;
				switch ($browser['ub']) {
					case "Chrome":
						$supported=$browser['version']>='19.0';
						break;
					case "Firefox":
						$supported=$browser['version']>='11.0';
						break;
					case "MSIE":
						$supported=$browser['version']>='7.0';
						break;
                    /* IE 11.0 report "Trident" and rv:11.0 and no longer report "MSIE" */
                    case "rv":
                        $supported=$browser['version']>='11.0';
                        break;
					case "Safari":
						$supported=$browser['version']>='5.1';
						break;
					case "Opera":
						$supported=$browser['version']>='11.0';
						break;
					case "Netscape":
						$supported=$browser['version']>='9.0';
						break;
				}
								
				
				echo ($supported ? '<b>'.$okImg.'</b><span> ('.$browser['name'].' '.$browser['version'].')</span>' : '<b>'.$failedImg.'</b><span>
            It seems you are using an unsupported web browser. </span>');?>
			</td>		
	</tr>
	</table>
</div>

<div class="panel">
	<div class="title">Recommended PHP Settings</div>
	<table class="col2">
	<tr>			
			<td>Safe Mode = OFF</td>
			<td>
				<?php echo !ini_get('safe_mode') ? '<b>'.$okImg.'</b>' : '<b>'.$failedImg.'</b><span></span>';?>
			</td>		
	</tr>
	<tr>			
			<td>Register Globals = OFF</td>
			<td>
				<?php echo !ini_get('register_globals') ? '<b>'.$okImg.'</b>' : '<b>'.$failedImg.'</b><span> There are security risks with this turned ON</span>';?>
			</td>		
	</tr>
	<tr>			
			<td>Session Use Cookies = ON</td>
			<td>
				<?php echo ini_get('session.use_cookies') ? '<b>'.$okImg.'</b>' : '<b>'.$failedImg.'</b><span> Try setting to ON if you are experiencing problems logging in</span>';?>
			</td>		
	</tr>
	</table>
</div>
<?php 
if ($showButton){
	echo "<div class=\"btActions\">
	<input align=\"right\" type=\"submit\" name=\"next\" value=\"Start Installation\" />
	</div>";
}
?>