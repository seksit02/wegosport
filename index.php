<?php
include 'config.php';

// Handle insert
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['insert'])) {
    $name = $_POST['name'];
    $description = $_POST['description'];
    $sql = "INSERT INTO items (name, description) VALUES ('$name', '$description')";
    $conn->query($sql);
}

// Handle delete
if (isset($_GET['delete'])) {
    $id = $_GET['delete'];
    $sql = "DELETE FROM items WHERE id=$id";
    $conn->query($sql);
}

// Handle update
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update'])) {
    $id = $_POST['id'];
    $name = $_POST['name'];
    $description = $_POST['description'];
    $sql = "UPDATE items SET name='$name', description='$description' WHERE id=$id";
    $conn->query($sql);
}

// Fetch data
$sql = "SELECT * FROM items";
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Page</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container">
            <h1>Admin Page</h1>
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
            <input type="hidden" name="id" id="id">
            <input type="text" name="name" id="name" placeholder="Name" required>
            <textarea name="description" id="description" placeholder="Description" required></textarea>
            <button type="submit" name="insert">Insert</button>
        </form>
        <hr>
        <table>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
                <th>Action</th>
            </tr>
            <?php while ($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?php echo $row['id']; ?></td>
                <td><?php echo $row['name']; ?></td>
                <td><?php echo $row['description']; ?></td>
                <td class="action-buttons">
                    <a href="index.php?delete=<?php echo $row['id']; ?>">Delete</a>
                    <button type="button" onclick="editItem(<?php echo $row['id']; ?>, '<?php echo $row['name']; ?>', '<?php echo $row['description']; ?>')">Edit</button>
                </td>
            </tr>
            <?php endwhile; ?>
        </table>
    </div>
    <script>
        function editItem(id, name, description) {
            document.getElementById('id').value = id;
            document.getElementById('name').value = name;
            document.getElementById('description').value = description;
            document.querySelector('button[name="insert"]').textContent = 'Update';
            document.querySelector('button[name="insert"]').name = 'update';
        }

        function toggleSidebar() {
            var sidebar = document.getElementById("sidebar");
            var mainContent = document.getElementById("main-content");
            var container = document.querySelector('.container');
            
            if (sidebar.style.width === "0px" || sidebar.style.width === "") {
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
