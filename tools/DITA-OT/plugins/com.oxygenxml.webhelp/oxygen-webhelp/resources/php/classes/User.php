<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class User{
	/**
	 * DB Connection info  set in the configuration file
	 *
	 * @var array storring 'dbName', 'dbUser', 'dbPassword', 'dbHost'
	 */
	private $dbConnectionInfo;
	/**
	 * Validated User info form database
	 *
	 * @var array ['userName','userId','name','company','email','accessLevel','msg'];
	 */
	private $info;
	/**
	 * Constructor
	 *
	 * @param array $dbConnectionInfo db connection info
	 */
	function __construct($dbConnectionInfo){
		$this->dbConnectionInfo=$dbConnectionInfo;
		$this->info = array();
		$this->info['isAnonymous']='false';
	}
	/**
	 * When system is in guest mode post there must be one generic user to post
	 *
	 * @return true if is validated the anonymous user in db
	 */
	function initAnonymous(){
		$this->info['isAnonymous']='true';
		return $this->validate('anonymous', '97968c7aedaba6d6d08a3626b23bd9a1');
	}

	/**
	 * Insert new user into database
	 *
	 * @param array $info containing 'username','name','password','email'
	 * @return JsonResponse {"msg","msgType","errorCode"}
	 */
	function insertNewUser($info){
		$this->info['msg']="user::false";		
		$response = new JsonResponse();
		$response->set("msgType","error");
		$response->set("error","true");

		$db= new RecordSet($this->dbConnectionInfo);
		$username=$db->sanitize($info['username']);
		$name=$db->sanitize($info['name']);
		$email=$db->sanitize($info['email']);
	if ($this->isUqFieldViolated('userName',$username)){
			$response->set("msg","User name is already taken!");
			$response->set("errorCode","4");
		}else if ($this->isUqFieldViolated('email',$email)){
			$response->set("msg","Email is already in the database!");
			$response->set("errorCode","5");		
		}else if (!$this->checkEmail($email)){
			$response->set("msg","Invalid e-mail address!");
			$response->set("errorCode","3");
		}else if (strlen(trim($info['password']))<5){
			$response->set("msg","Password is too short!");
			$response->set("errorCode","1");
		}else if ($db->sanitize($info['password']) != $info['password']){
			$response->set("msg","Invalid password!");
			$response->set("errorCode","2");
		}else{
			$password=MD5($db->sanitize($info['password']));			
			$date = date("Y-m-d H:i:s");
			$sql = "INSERT INTO  users (userId ,userName ,email ,name ,company ,password ,date ,level ,status,notifyAll,notifyReply,notifyPage) VALUES (NULL,'".$username."','".$email."','".$name."','noCompany','".$password."','".$date."','user','created','no','yes','yes');";
			$rows = $db->Run($sql);
			$this->info['msg']="user::rows::".$rows;
			// 			$toReturn=$sql;
			if ($rows<=0){				
					$response->set("msg",$db->m_DBErrorNumber.$db->m_DBErrorMessage.$sql);
					$response->set("errorCode","10");				
			}else{
				$response->set("error", "false");
				$response->set("errorCode","0");
				$this->validate($username,$info['password'],'created');
			}

			$db->Close();
		}
		return $response;
	}
	
	private function isValidPassword($oldPassword){
		$toReturn=false;
		$db= new RecordSet($this->dbConnectionInfo);
		$sql="SELECT userId FROM users WHERE userId='".$this->info['userId']."' AND password='".md5($oldPassword)."';";
		$ids=$db->open($sql);
		if ($ids==1){
			$toReturn=true;
		}
		$db->Close();
		return $toReturn;
	} 
	/**
	 * Update current user profile data
	 *
	 * @param array $profileInfo contains "password" or "name","e-mail","notifyPage","notifyAll","notifyReply"
	 * @return string message after update
	 */
	function updateProfile($profileInfo){
		$toReturn="";
		$db= new RecordSet($this->dbConnectionInfo,false,true);
		if (!$profileInfo['editByAdmin']){
			if (isset($profileInfo['oldPassword']) && !$this->isValidPassword($profileInfo['oldPassword'])){
			$toReturn=Utils::translate('msg.secureOldPass');
		}else{
			$toReturn = $this->updateProf($db, $profileInfo);
		}
		}else{			
			$toReturn = $this->updateProf($db, $profileInfo);
		}
		$db->Close();
		return $toReturn;
	}
	/**
	 * Clean db for unconfirmed users
	 * @return number of deleted users
	 * @throws dbException or invalid parameter
	 */
	function cleanUsers($days){
		$toReturn=-1;		
		if ($days<0){
			$db= new RecordSet($this->dbConnectionInfo,false,true);
			$query="DELETE FROM users WHERE date<'".date('Y-m-d H:i:s',strtotime($days.' day'))."' AND status='created';";
			$toReturn = $db->Run($query);
			$db->Close();
		}else{
			throw new Exception("Invalid days to clean users!");
		}
		return $toReturn;
	}
	/**
	 * Update password
	 *
	 * @param RecordSet $db db connection
	 * @param array $info info to be updated with keys
	 * 		 "name","email","notifyPage","notifyAll","notifyReply" as fields in database
	 * @return string "" when success otherwise error message
	 */
	private function updateProf($db,$info){
		$toReturn="";
		global $translate;
		$newArray=$db->sanitizeArray($info);
		$invalidInput="";
		$dataToUpdate="";
		$adminUserId=-1;
		foreach ($newArray as $key => $val){
			if ($info[$key]!=$val){
				$translateKey='user.'.$key.".label";
				$invalidInput.=Utils::translate($translateKey).", ";
			}else{
				if ($key=="email"){
					if (!$this->checkEmail($info["email"])){
						if (strlen($invalidInput)>0){
							$invalidInput.=", ";
						}
						$invalidInput.=Utils::translate("user.email.label");
					}
				}
			}
			if ($key!="userId"){
				if (isset($info['password']) && $key=="password"){
					$password=$info['password'];
					$newPass=$db->sanitize($password);
					if ($newPass != $password){
						$invalidInput.=Utils::translate('pwd.invalid');
					}else if(strlen(trim($password))<5){
						$invalidInput.=Utils::translate('pwd.tooShort');
					}else{							
						$dataToUpdate.=$key." = '".md5($password)."' ,";						
					}
				}else if ($key!='oldPassword' && $key!='editByAdmin'){
				$dataToUpdate.=$key." = '".$val."' ,";
				}
			}else{
				$adminUserId=$info["userId"];
			}
		}

		$dataToUpdate=substr($dataToUpdate,0, -2);

		if ($invalidInput==""){
			if ($this->isUqFieldViolated('email',$info['email'],($adminUserId>0 ? $adminUserId : $this->info["userId"]))){
				$toReturn=Utils::translate('email.duplicate');
			}else{
				$query="UPDATE users SET ".$dataToUpdate." where userId=";
				if ($adminUserId>0){
					$query.=$adminUserId.";";
				}else{
					$query.=$this->info["userId"].";";
				}
				// 			$toReturn=$query;
				$toReturn="";
				try{
					$rows = $db->Run($query);
				}catch(Exception $e){
					//$e->getCode();
					$toReturn=$e->getMessage();
					if ($this->isUqViolated($toReturn, "email")){
						$toReturn=Utils::translate('email.duplicate');
					}else if ($this->isUqViolated($toReturn, "userName")){
						$toReturn=Utils::translate('username.duplicate');
					}else{
						throw $e;
					}
				}
			}
			
			
			if ($toReturn==""){
				$myrs = new RecordSet($this->dbConnectionInfo);

				$query="SELECT * FROM users WHERE userId=".$this->info["userId"].";";
				if ($myrs->Open($query) > 0 && $myrs->m_IsValid){
					$myrs->MoveNext();
					$this->info['userName'] = $myrs->Field('userName');
					$this->info['userId'] = $myrs->Field('userId');
					$this->info['name'] = $myrs->Field('name');
					$this->info['level'] = $myrs->Field('level');
					$this->info['company'] = $myrs->Field('company');
					$this->info['email'] = $myrs->Field('email');
					$this->info['date'] = $myrs->Field('date');
					$this->info['notifyAll'] = $myrs->Field('notifyAll');
					$this->info['notifyReply'] = $myrs->Field('notifyReply');
					$this->info['notifyPage'] = $myrs->Field('notifyPage');
				}
				$myrs->close();
			}
		}else{
			if (substr($invalidInput,-2)==", "){
				$invalidInput=substr($invalidInput, 0,-2);
			}
			$toReturn=Utils::translate('input.invalid').$invalidInput;
		}
		return $toReturn;
	}

	/**
	 * Check if the 'email' is a valid email address
	 *
	 * @return true if it is a valid email
	 */
	function checkEmail($email){
		if(preg_match("/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/",
				$email)){
			return true;
		}
		return false;
	}
	/**
	 * Get all modetators email to be notified on a new comment is added
	 *
	 * @return array emails
	 */
	public function getModeratorsEmails(){
		$toReturn=array();
		$db= new RecordSet($this->dbConnectionInfo);
		$query="select  concat(name,' <',email,'> ') adrs FROM users WHERE level='moderator' OR level='admin'";
		$db->Open($query);
		while ($db->MoveNext()){
			$toReturn[]=$db->Field("adrs");
		}
		// 		$toReturn=substr($toReturn, 0,-2);
		$db->Close();
		return $toReturn;
	}

	/**
	 * Check if a error message contains info about duplicate key for username
	 *
	 * @param Strign  $message
	 */
	private function isUqViolated($message,$field){
		$toReturn= false;
		if (strpos($message, "Duplicate entry")===FALSE){
			$toReturn= false;
		}else if (strpos($message, "Duplicate entry")>=0){
			if (strpos($message, $field)===FALSE){
				$toReturn= false;
			}else if (strpos($message, $field)>=0){
				$toReturn= true;
			}
		}
		return $toReturn;
	}

	/**
	 * Confirm user from email
	 *
	 * @param int $id
	 * @return boolean true if the user is validated
	 */
	function confirmUser($id){
		$toReturn=false;
		$this->info['msg']="User not updated!";

		$db= new RecordSet($this->dbConnectionInfo);
		$query="UPDATE users SET status='validated' WHERE userId=$id AND status='created'";
		$rows=$db->Run($query);
		if ($rows>0){
			$toReturn=true;
			$this->info['msg']="";
			$db1 = new RecordSet($this->dbConnectionInfo);
			$rows1=$db1->Open("SELECT * FROM users WHERE userId=".$id.";");
			if ($rows1==1){
				$db1->MoveNext();
				$this->loadData($db1);
				$this->info['msg']=Utils::translate("signUp.confirmUsr");
			}
			$db1->close();
		}else{				
			$query="SELECT userId FROM users WHERE status='validated' AND userId=".$id.";";
			if ($db->Open($query)>0){
				$this->info['msg']=Utils::translate("signUp.userConfirmed");
			}else{
				$this->info['msg']=Utils::translate("signUp.invalidUsr");
		}
			$db->Close();
		}
		$db->Close();
		return $toReturn;
	}
	
	/**
	 * Check if field is violating unique constraint
	 * @param String $field
	 * @param String $value
	 * @param int $id id to be excluded
	 */
	private function isUqFieldViolated($field,$value,$id=null){
		$toReturn=false;
		$db= new RecordSet($this->dbConnectionInfo);
		$query="SELECT userId FROM users WHERE ".$field."='".$value."'";
		if ($id!=null){
			$query.=" AND userId<>".$id.";";
		}		
		$rows=$db->Run($query);
		if ($rows>0){
			$toReturn=true;			
		}
		$db->close();
		return $toReturn;
	} 
	/**
	 * Validate a username and a password
	 *
	 * @param String $userName
	 * @param String $password
	 * @param String $status 'created','validated','suspended'
	 * @return boolean validation status
	 */
	public function validate($userName,$password,$status='validated'){
		$toReturn= FALSE;
		try{
			$myrs = new RecordSet($this->dbConnectionInfo);
			// To protect MySQL injection
			$userName = $myrs->sanitize($userName);
			$password = $myrs->sanitize($password);

			$query="SELECT * FROM users WHERE username ='$userName' AND password = '".md5($password)."' AND status='$status'";
				$this->info['msg']="";
			if ($myrs->Open($query) == 1 && $myrs->m_IsValid){
				$toReturn=TRUE;
				$myrs->MoveNext();
				$this->loadData($myrs);
			}else{
				if ($myrs->m_DBErrorNumber){
					$this->info['msg']="DBError=".$myrs->m_DBErrorNumber." DBMessage=".$myrs->m_DBErrorMessage;
				}
			}
			$myrs->close();

		}catch (Exception $e){
			// ignored
		}
		return $toReturn;
	}
	/**
	 * load internal data
	 * 
	 * @param RecordSet $mysqlDS
	 */
	private function loadData($mysqlDS){
		$this->info['userName'] = $mysqlDS->Field('userName');
		$this->info['userId'] = $mysqlDS->Field('userId');
		$this->info['name'] = $mysqlDS->Field('name');
		$this->info['level'] = $mysqlDS->Field('level');
		$this->info['company'] = $mysqlDS->Field('company');
		$this->info['email'] = $mysqlDS->Field('email');
		$this->info['date'] = $mysqlDS->Field('date');
		$this->info['notifyAll'] = $mysqlDS->Field('notifyAll');
		$this->info['notifyReply'] = $mysqlDS->Field('notifyReply');
		$this->info['notifyPage'] = $mysqlDS->Field('notifyPage');
	}
	/**
	 * List all users for moderators
	 *
	 */
	function listUsers(){
		$toReturn="";
		$db = new RecordSet($this->dbConnectionInfo);
		// To protect MySQL injection

		$query="SELECT * FROM users";
		$db->Open($query);
		$toReturn.="<table id=\"usersList\" cellpadding='0' cellspacing='0'>";
		$toReturn.="<thead>";
		$toReturn.="<tr>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.userName.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.name.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.level.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.company.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.email.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.date.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.notifyAll.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.notifyReply.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.notifyPage.label');
		$toReturn.="</td>";
		$toReturn.="<td>";
		$toReturn.=Utils::translate('admin.status.label');
		$toReturn.="</td>";
// 		$toReturn.="<td>";
// 		$toReturn.=Utils::translate('admin.action.label');
// 		$toReturn.="</td>";
		$toReturn.="</tr>";
		$toReturn.="</thead>";
		while ($db->MoveNext()){
			$id=$db->Field('userId');
			if($db->Field('userName') != "anonymous" && $db->Field('userId') != 1){
				$toReturn.="<tr id=\"u_$id\" onclick='editUser($id)'>";
				$toReturn.="<td class=\"username\">";
				$toReturn.=$db->Field('userName');
				$toReturn.="</td>";
				$toReturn.="<td class=\"name\">";
				$toReturn.=$db->Field('name');
				$toReturn.="</td>";
				$toReturn.="<td class=\"level\">";
				$toReturn.=$db->Field('level');
				$toReturn.="</td>";
				$toReturn.="<td class=\"company\">";
				$toReturn.=$db->Field('company');
				$toReturn.="</td>";
				$toReturn.="<td class=\"email\">";
				$toReturn.=$db->Field('email');
				$toReturn.="</td>";
				$toReturn.="<td class=\"date\">";
				$toReturn.=$db->Field('date');
				$toReturn.="</td>";
				$toReturn.="<td class=\"notifyAll\">";
				$toReturn.=$db->Field('notifyAll');
				$toReturn.="</td>";
				$toReturn.="<td class=\"notifyReply\">";
				$toReturn.=$db->Field('notifyReply');
				$toReturn.="</td>";
				$toReturn.="<td class=\"notifyPage\">";
				$toReturn.=$db->Field('notifyPage');
				$toReturn.="</td>";
				$toReturn.="<td class=\"status\">";
				$toReturn.=$db->Field('status');
				$toReturn.="</td>";
// 				$toReturn.="<td class=\"action\">";
// 				$toReturn.="<span class='bt_edit_user' title='Edit' onclick='editUser($id)'>".Utils::translate('edit')."</span>";
// 				$toReturn.="</td>";
				$toReturn.="</tr>";
			}
		}
		$toReturn.="</table>";
		return $toReturn;
	}
	/**
	 * Recover lost password
	 *
	 * @param array $info containing user email, product , version
	 * @return array Information about new generated password as: the email match username or not and generated password
	 */
	function generatePasswd($info){
		$toReturn= array();
		$this->info['msg']="Password not generated!";
		$db= new RecordSet($this->dbConnectionInfo);
		$info['username']=$db->sanitize($info['username']);
		$info['email']=$db->sanitize($info['email']);
		$query="SELECT userName FROM users where email='".$info['email']."' AND status='validated'";
		$rows=$db->Open($query);
		$toReturn['match']=false;
		if ($rows==1){
			$db->MoveNext();
			if ($db->Field("userName")==$info['username']){
				$toReturn['match']=true;
			}
			$toReturn['generated']=Utils::generatePassword(6,true,true,false);
		}else{
			$toReturn['generated']="";
			$this->info['msg']=Utils::translate('email.user.not.match');
		}
		$db->Close();
		return $toReturn;
	}
	/**
	 * Change password for an specified email with the specified one
	 *
	 * @param String $email user emai
	 * @param String $password unencripted password
	 * @return String user name
	 */
	function changePassword($email,$password){
		$toReturn="";
		$db= new RecordSet($this->dbConnectionInfo);
		if ($password == $db->sanitize($password)){
			$query="UPDATE users SET password = '".MD5($password)."' WHERE email='".$email."'";
			$rows=$db->Run($query);
			if ($rows>0){
				$query="SELECT userName FROM users WHERE email='".$email."'";
				$db->Open($query);
				$db->MoveNext();
				$toReturn= $db->Field("userName");
			}
		}
		$db->Close();
		return $toReturn;
	}
	/**
	 * Get ser info from internal data
	 *
	 * @param String $variableName variable name to be return
	 */
	public function __get($variableName){
		$toReturn="";
		if (isset($this->info[$variableName])){
			$toReturn=$this->info[$variableName];
		}
		return $toReturn;
	}
	/**
	 * Recutrsive user email harvesting
	 * @param int $commentId new inserted comment ID
	 * @param array $emailArray array to collect on the emails
	 * @param RecordSet $db dbconnection to be used
	 */
	private function addUserToNotify($commentId,$emailArray,$db){
		$sql="SELECT concat(name,' <',email,'> ') adrs from users where notifyPage='no' AND notifyAll='no'
		AND notifyReply='yes' AND status ='validated' AND userId in (SELECT userId from comments where commentId='$commentId');";
		$db->Open($sql);
		while($db->MoveNext()){
			$newEmail=$db->Field('adrs');
			if (!in_array($newEmail, $emailArray)){
				$emailArray[]=$newEmail;
			}
		}

		$db->Open("SELECT referedComment FROM comments WHERE commentId='$commentId'");
		while($db->MoveNext()){
			if ($db->Field('referedComment')>0){
				$emailArray=$this->addUserToNotify($db->Field('referedComment'),$emailArray,$db);
			}
		}
		return $emailArray;
	}

	/**
	 * Obtaint all users to be notified when a new comment is inserted
	 *
	 * @param String $page page that is comment on
	 * @param int $commentId new comment id
	 *
	 * @return array list of emails to be notified
	 */
	function getUsersToNotify($page,$commentId){
		$toReturn=array();
		$s_notifyAll="SELECT concat(name,' <',email,'> ') adrs from users where notifyAll='yes' AND status ='validated';";
		$db= new RecordSet($this->dbConnectionInfo);
		$db->Open($s_notifyAll);
		while($db->MoveNext()){
			$newEmail=$db->Field('adrs');
			if (!in_array($newEmail, $toReturn)){
				$toReturn[]=$newEmail;
			}
		}
		$s_notifyPage="SELECT concat(name,' <',email,'> ') adrs from users where notifyPage='yes' AND notifyAll='no'
		AND status ='validated' AND userId in (SELECT userId from comments where page='$page');";
		$db->Open($s_notifyPage);
		while($db->MoveNext()){
			$newEmail=$db->Field('adrs');
			if (!in_array($newEmail, $toReturn)){
				$toReturn[]=$newEmail;
			}
		}


		$r_comment="SELECT referedComment FROM comments WHERE commentId='$commentId'";
		$db->Open($r_comment);
		while($db->MoveNext()){
			if ($db->Field('referedComment')>0){
				$toReturn=$this->addUserToNotify($db->Field('referedComment'),$toReturn,$db);
			}
		}
		$db->close();
		return $toReturn;
	}
	/**
	 * Delete specified users
	 * 
	 * @param array ids to be deleted
	 */
	function delete($ids){
		if (count($ids)>0){
			$db= new RecordSet($this->dbConnectionInfo,false,true);							
			$query="DELETE FROM users WHERE userId in (".$ids.");";
			$toReturn=$db->Run($query);			
			$db->close();
		}
	}
	/**
	 * Get allproduct for witch this user is valid 
	 * 
	 * @return multitype:Strign productId=>Name
	 */
	function getSharedProducts(){
		$toReturn= array();
		$db= new RecordSet($this->dbConnectionInfo,false,true);
		$prds=$db->Open("Select product,value from webhelp where parameter='name' ;");
		if ($prds>0){
			while ($db->MoveNext()){
				$product=$db->Field('product');
				$value=$db->Field('value');
				$toReturn[$product]=$value;					
			}
		}
		$db->close();
		return $toReturn;
	}

}
?>