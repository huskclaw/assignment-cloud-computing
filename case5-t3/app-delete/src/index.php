<?php
require_once "db.php";
$conn = db();

$result = $conn->query("SELECT id, name, note, created_at FROM guests ORDER BY id DESC");
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Guest Management</title></head>
<body>
  <h2>Guest Management</h2>
  <p><a href="/">Home</a></p>

  <h3>Guests</h3>
  <table border="1" cellpadding="6" cellspacing="0">
    <tr><th>ID</th><th>Name</th><th>Note</th><th>Created</th><th>Action</th></tr>
    <?php while($row = $result->fetch_assoc()): ?>
      <tr>
        <td><?= htmlspecialchars($row["id"]) ?></td>
        <td><?= htmlspecialchars($row["name"]) ?></td>
        <td><?= htmlspecialchars($row["note"]) ?></td>
        <td><?= htmlspecialchars($row["created_at"]) ?></td>
        <td>
          <a href="/delete/delete.php?id=<?= urlencode($row["id"]) ?>"
             onclick="return confirm('Delete this entry?');">
             Delete
          </a>
        </td>
      </tr>
    <?php endwhile; ?>
  </table>
</body>
</html>
