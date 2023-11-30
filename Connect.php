<?php
$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "btth01_cse485"; 

// Tạo kết nối
$conn = new mysqli($servername, $username, $password, $dbname);

// Kiểm tra kết nối
if ($conn->connect_error) {
    die("Kết nối không thành công: " . $conn->connect_error);
}
echo "Kết nối thành công";

?>