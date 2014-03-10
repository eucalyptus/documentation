<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

class RecordSet
{
	/**
	 * Array containing connection information
	 *
	 * @var array
	 */
	private $dbConnectionInfo;

	var $m_Conn;
	var $m_QueryResult;
	var $m_CurrentRecord;
	var $m_RowsCount;
	var $m_AffectedRows;

	var $m_IsValid = false;

	var $m_DBErrorNumber   =0  ; //no error
	var $m_DBErrorMessage  ="" ;
	var $throwException; //

	/**
	 * RecordSet Class
	 *
	 * @param array $_dbConnectionInfo
	 * @param boolean $_compress
	 * @throws Exception
	 */
	function __construct($_dbConnectionInfo, $_compress=false,$throwException=false) {
		$this->throwException=$throwException;
		if( $_dbConnectionInfo){
			$this->dbConnectionInfo=$_dbConnectionInfo;
			$_name = $_dbConnectionInfo['dbName'];
			$_user  = $_dbConnectionInfo['dbUser'];
			$_password = $_dbConnectionInfo['dbPassword'];
			$_host = $_dbConnectionInfo['dbHost'];
		}else{
			if ($this->throwException){
				throw new Exception("r: DB Connection info ar not provided for RecordSet class!");
			}
		}
			
		$this->m_IsValid = true;
			
		$_flags = 0;
			
		if($_compress){
			$_flags = MYSQL_CLIENT_COMPRESS;
		}
			
		$this->m_Conn  = @mysql_connect ($_host,$_user,$_password, true, $_flags);
		$this->m_DBErrorNumber = mysql_errno();
		if($this->m_DBErrorNumber){
			$this->m_DBErrorMessage = mysql_error();
			$this->m_IsValid = false;
			if ($this->throwException){
				throw new Exception("r: Error:".mysql_errno()."-".$this->m_DBErrorMessage);
			}
		}
		if (strlen(trim($_name))>0){
			$this->selectDb($_name);
		}
			
	}
	function runFile($file,$ignoreErrors=false){
		if (file_exists($file)){
			$f = fopen($file,"r");
			$sqlFile = fread($f,filesize($file));
			$sqlArray = explode(';',$sqlFile);
			$count=count($sqlArray);
			$i=0;
			$err=0;
			foreach ($sqlArray as $stmt) {
				$i++;
				if (trim($stmt)!=""){
					$result = $this->Run($stmt);
					if (!$result){
						$err++;
						$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
						if($this->m_DBErrorNumber && !$ignoreErrors){
							$this->m_DBErrorMessage = mysql_error($this->m_Conn);
							$this->m_IsValid = false;
							if ($this->throwException){
								throw new Exception("r: MySQL Error:".mysql_errno()."-"
										.$this->m_DBErrorMessage."Running query='".$stmt."' ".$i." form ".$file." (Total of ".$count." )");
							}
						}
						$sqlStmt = $stmt;
					}
				}
			}
		}else{
			if ($this->throwException){
				throw new Exception("File :".$file." does not exist!");
			}
		}
	}

	function selectDb($dbName){
		if ($dbName && $this->m_IsValid){
			mysql_select_db($dbName, $this->m_Conn);

			$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
			if($this->m_DBErrorNumber){
				$this->m_DBErrorMessage = mysql_error($this->m_Conn);
				$this->m_IsValid = false;
				if ($this->throwException){
					throw new Exception("r: MySQL Error:".mysql_errno($this->m_Conn)."-".$this->m_DBErrorMessage);
				}
			}
		}
	}

	/**
	 * Open the record set for the specified query
	 *
	 * @param String $query
	 * @return Number of rows returned by running the secified query
	 */
	function Open($query){
		if ($this->m_IsValid){
			$this->m_QueryResult   = mysql_query ($query,$this->m_Conn);
		}
		if ($this->m_Conn===FALSE){
			$this->m_RowsCount=-1;
		}else{
			$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
			$this->m_RowsCount=false;

			if($this->m_DBErrorNumber){
				$this->m_DBErrorMessage = mysql_error($this->m_Conn);
				if ($this->throwException){
					throw new Exception("r: Error:".mysql_errno($this->m_Conn)."-".$this->m_DBErrorMessage);
				}
			}else{
				$this->m_RowsCount  = mysql_num_rows ($this->m_QueryResult);
				$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
				if($this->m_DBErrorNumber) {
					$this->m_DBErrorMessage = mysql_error($this->m_Conn);
					if ($this->throwException){
						throw new Exception("r: Error:".mysql_errno($this->m_Conn)."-".$this->m_DBErrorMessage);
					}
				}
			}
		}
		return $this->m_RowsCount;
	}



	function Run($ActionQuery){
		$this->m_QueryResult  = mysql_query ($ActionQuery,$this->m_Conn);
		if ($this->m_QueryResult===FALSE){
			$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
			$this->m_DBErrorMessage = mysql_error($this->m_Conn);
			if ($this->throwException){
				throw new Exception("Error:".mysql_errno($this->m_Conn)."-".$this->m_DBErrorMessage);
			}
			$this->m_RowsCount=-1;
		}else{
			$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
			if($this->m_DBErrorNumber){
				$this->m_DBErrorMessage = mysql_error($this->m_Conn);
				if ($this->throwException){
					throw new Exception("Error:".mysql_errno($this->m_Conn)."-".$this->m_DBErrorMessage);
				}
			}
			$this->m_RowsCount  = mysql_affected_rows ($this->m_Conn);

			$this->m_DBErrorNumber = mysql_errno($this->m_Conn);
			if($this->m_DBErrorNumber){
				$this->m_DBErrorMessage = mysql_error($this->m_Conn);
				if ($this->throwException){
					throw new Exception("Error:".mysql_errno($this->m_Conn)."-".$this->m_DBErrorMessage);
				}
			}
		}
		return $this->m_RowsCount;
	}

	/**
	 * Return the value for the specified field on the current row
	 *
	 * @param String $fieldName
	 * @return Strign Field value
	 */
	function Field($fieldName){
		return $this->m_CurrentRow[$fieldName];
	}

	function IsValid(){
		return $this->m_IsValid;
	}
	/**
	 * Snitize mysql strings
	 *
	 * @param String $text
	 */
	function sanitize($text){
		$toReturn=$text;
		if( $this->dbConnectionInfo){
			$_name = $this->dbConnectionInfo['dbName'];
			$_user  = $this->dbConnectionInfo['dbUser'];
			$_password = $this->dbConnectionInfo['dbPassword'];
			$_host = $this->dbConnectionInfo['dbHost'];
			$newConn  = @mysql_connect ($_host,$_user,$_password, false, $_flags);
			$toReturn = mysql_real_escape_string($toReturn,$newConn);
		}else{
			if ($this->throwException){
				throw new Exception("r: DB Connection info ar not provided for RecordSet class!");
			}
		}
		return $toReturn;
	}
	/**
	 * Sanitize value af an array
	 *
	 * @param array $array
	 * @throws Exception
	 * @return array sanitized
	 */
	function sanitizeArray($array){
		$toReturn=array();
		if ($this->m_Conn){
			foreach ($array as $key => $val){
				$toReturn[$key]=mysql_real_escape_string($val,$this->m_Conn);
			}
		}else{
			if ($this->throwException){
				throw new Exception("r: No connection available in order to use sanitize");
			}
		}
		return $toReturn;
	}

	function MoveNext(){
		$this->m_CurrentRow = mysql_fetch_array($this->m_QueryResult);
		if($this->m_CurrentRow)
			return 1;
		return 0;
	}

	function getAssoc(){
		$row = mysql_fetch_assoc($this->m_QueryResult);
		if($row)
			return $row;
		return 0;
	}

	function Close(){
		if ($this->m_Conn){
			mysql_close($this->m_Conn);
			$this->m_Conn=null;
		}
	}
	function __destruct(){
		if ($this->m_Conn){
			mysql_close($this->m_Conn);
			$this->m_Conn=null;
		}
	}

}

?>
