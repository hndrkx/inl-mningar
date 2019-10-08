<html>
<head>
	<link href="style.css" rel="stylesheet" type="text/css">	
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.1/css/all.css">
        <title>DEVOPS18</title> 
</head>
<body>
<div class="search">
<h2>DEVOPS18
<?php
date_default_timezone_set('Europe/Stockholm');
echo date("d-m-Y (D) H:i:s", time())
?></h2>
<h1> Search a name... </h1>
<form action="index.php" method="GET">
    <input type="text" name="search_string" id="search_1" placeholder="Search a name..."/>
    <button type="submit"><i class="fas fa-search"></i></button>
</form>
<h2>
</h2>
<h2>
<?php
    $key=$_GET['search_string'];
    $array = array();
    $con=mysqli_connect("localhost","mathias","mahe","testdb");
    $query=mysqli_query($con, "select * from persons where name LIKE '%{$key}%'");
    while($row=mysqli_fetch_assoc($query))
    {
      $array[] = $row['name'];
    }
    if ($array[0] == ""){
	    echo "Nothing found in database...";
    }
    elseif (!empty($key)){
            echo "Persons found in database: \n<br />\n<br />";
            foreach ($array as $item)
                echo "$item\n<br />";
    }
    mysqli_close($con);
?>
</h2>
</div>
</body>
</html>

