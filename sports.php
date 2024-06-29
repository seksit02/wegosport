<?php
include 'config.php';

// Function to generate new sport_id
function generateSportID($conn) {
    $sql = "SELECT sport_id FROM sports ORDER BY sport_id DESC LIMIT 1";
    $result = $conn->query($sql);
    $newID = 's001';
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $lastID = $row['sport_id'];
        $num = intval(substr($lastID, 1)) + 1;
        $newID = 's' . str_pad($num, 3, '0', STR_PAD_LEFT);
    }
    return $newID;
}

// Handle insert
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['insert'])) {
    $sport_id = generateSportID($conn);
    $sport_name = $_POST['sport_name'];
    $sport_detail = $_POST['sport_detail'];
    $sql = "INSERT INTO sports (sport_id, sport_name, sport_detail) VALUES ('$sport_id', '$sport_name', '$sport_detail')";
    if ($conn->query($sql) === TRUE) {
        echo "New record created successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Handle delete
if (isset($_GET['delete'])) {
    $sport_id = $_GET['delete'];
    $sql = "DELETE FROM sports WHERE sport_id='$sport_id'";
    $conn->query($sql);
}

// Handle update
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update'])) {
    $sport_id = $_POST['sport_id'];
    $sport_name = $_POST['sport_name'];
    $sport_detail = $_POST['sport_detail'];
    $sql = "UPDATE sports SET sport_name='$sport_name', sport_detail='$sport_detail' WHERE sport_id='$sport_id'";
    if ($conn->query($sql) === TRUE) {
        echo "Record updated successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Fetch data
$sql = "SELECT * FROM sports";
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sports Management</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container">
            <h1>Sports Management</h1>
        </div>
    </header>
    <div class="sidebar" id="sidebar">
        <button class="toggle-btn" onclick="toggleSidebar()">☰</button>
        <ul>
            <li><a href="index.php">Home</a></li>
            <li><a href="sports.php">Manage Sports</a></li>
        </ul>
    </div>
    <div class="container" id="main-content">
        <form method="POST" action="">
            <input type="hidden" name="sport_id" id="sport_id">
            <input type="text" name="sport_name" id="sport_name" placeholder="Sport Name" required>
            <textarea name="sport_detail" id="sport_detail" placeholder="Sport Detail" required></textarea>
            <button type="submit" name="insert">Insert</button>
        </form>
        <hr>
        <table>
            <tr>
                <th>Sport ID</th>
                <th>Sport Name</th>
                <th>Sport Detail</th>
                <th>Action</th>
            </tr>
            <?php while ($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?php echo $row['sport_id']; ?></td>
                <td><?php echo $row['sport_name']; ?></td>
                <td><?php echo $row['sport_detail']; ?></td>
                <td class="action-buttons">
                    <a href="sports.php?delete=<?php echo $row['sport_id']; ?>">Delete</a>
                    <button type="button" onclick="editItem('<?php echo $row['sport_id']; ?>', '<?php echo $row['sport_name']; ?>', '<?php echo $row['sport_detail']; ?>')">Edit</button>
                </td>
            </tr>
            <?php endwhile; ?>
        </table>
    </div>
    <script>
        function editItem(sport_id, sport_name, sport_detail) {
            document.getElementById('sport_id').value = sport_id;
            document.getElementById('sport_name').value = sport_name;
            document.getElementById('sport_detail').value = sport_detail;
            document.querySelector('button[name="insert"]').textContent = 'Update';
            document.querySelector('button[name="insert"]').name = 'update';
        }

        function toggleSidebar() {
    var sidebar = document.getElementById("sidebar");
    var mainContent = document.getElementById("main-content");
    var container = document.querySelector('.container');
    
    if (sidebar.style.width === "0px") {
        sidebar.style.width = "250px";
        mainContent.style.marginLeft = "250px";
        container.style.marginLeft = "0px";  // Reset margin for centered header
    } else {
        sidebar.style.width = "0px";
        mainContent.style.marginLeft = "0px";
        container.style.marginLeft = "auto";  // Center the header
    }
}
    </script>
</body>
</html>
