<?php

class DumpDB{

	public $conn;
	public $db;
	public function __construct($host, $username, $password, $db){
		$this->conn =  mysql_connect($host, $username, $password);
		if(!$this->conn){
			exit("mysql Connect Error!");
		}
		$this->db = $db;
		mysql_select_db($db);
		$this->Dump();
		$this->addFileToZip($this->db);
	}

	public function Dump(){
		$result = mysql_query("show tables");
		$table = array();
		while (!!$rs=mysql_fetch_array($result)) {
			$sql = "select * from " . $rs[0];
			$content = mysql_query($sql);
			while (!!$ns=mysql_fetch_assoc($content)) {
				$this->dataformat($rs[0], $ns);
			}	
		}
	}

	public function dataformat($table, $ns){
		$split = ", ";
		$dir = $this->db;
		$str = implode($split, $ns);
		if(!is_dir($dir)){
			mkdir($dir);
		}
		$filename = $dir . '/' . $table . '.txt';
		if (!file_exists($filename)){
			$columns = "";
			foreach ($ns as $key => $value) {
				$columns .= $key . $split;
			}
			$columns = substr($columns, 0, strrpos($columns, $split)) . "\r\n";
			file_put_contents($filename, $columns, FILE_APPEND);
			return 1;
		}
		file_put_contents($filename, $str. "\r\n", FILE_APPEND);
	}

	public function addFileToZip($dbname){
		$zip = new ZipArchive;
		$zipfile = $dbname . '.zip';
		$res = $zip->open($zipfile, ZipArchive::CREATE);
		if($res===TRUE){
			$handler = opendir($dbname);
			while (($filename = readdir($handler)) !== false) {
				if($filename != '.' && $filename != '..'){
					if(is_dir($dbname.'/'.$filename)){
						addFileToZip($dbname.'/'.$filename, $zip);
					}else{
						$zip->addFile($dbname. '/' . $filename);
					}
				}
			}
			@closedir($handler);
			$zip->close();
		}
	}

	public function __destruct(){
		mysql_close($this->conn);
		echo "<br/><h2>Dump Database successful</h2>";
	}

}
if (isset($_POST['submit']) && $_POST['submit'] == 'dump'){
	new DumpDB($_POST['host'], $_POST['username'], $_POST['password'], $_POST['database']);
}


?>

<!DOCTYPE html>
<html>
<head>
	<title>mysql dump database</title>
</head>
<body>
<h2>blog: http://www.evalshell.com</h2>
<form action="" method="POST">
	<table>
		<tr>
			<th>
				HOST
			</th>
			<th>
				User
			</th>
			<th>
				Password
			</th>
			<th>
				Database
			</th>
		</tr>
		<tr>
			<td><input type="text" value="" name="host"/></td>
			<td><input type="text" value="" name="username"/></td>
			<td><input type="text" value="" name="password"/></td>
			<td><input type="text" value="" name="database"/></td>
		</tr>
	</table>
	<input type="submit" value="dump" name="submit"/>
</form>
</body>
</html>
