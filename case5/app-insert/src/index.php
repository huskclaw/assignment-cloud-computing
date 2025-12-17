<?php
require_once "db.php";
$conn = db();

if ($_SERVER["REQUEST_METHOD"] === "POST") {
  $name = trim($_POST["name"] ?? "");
  $note = trim($_POST["note"] ?? "");

  if ($name !== "" && $note !== "") {
    $stmt = $conn->prepare("INSERT INTO guests (name, note) VALUES (?, ?)");
    $stmt->bind_param("ss", $name, $note);
    $stmt->execute();
    $stmt->close();
  }
  header("Location: /insert/");
  exit;
}

$result = $conn->query("SELECT id, name, note, created_at FROM guests ORDER BY id DESC");
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Guest Registration</title></head>
<body>
  <h2>Guest Registration</h2>
  <p><a href="/">Home</a></p>

  <form method="POST">
    <div>
      <label>Name</label><br>
      <input name="name" required>
    </div>
    <div>
      <label>Note</label><br>
      <textarea name="note" rows="3" required></textarea>
    </div>
    <button type="submit">Add Guest</button>
  </form>

  <h3>Current Guests</h3>
  <table border="1" cellpadding="6" cellspacing="0">
    <tr><th>ID</th><th>Name</th><th>Note</th><th>Created</th></tr>
    <?php while($row = $result->fetch_assoc()): ?>
      <tr>
        <td><?= htmlspecialchars($row["id"]) ?></td>
        <td><?= htmlspecialchars($row["name"]) ?></td>
        <td><?= htmlspecialchars($row["note"]) ?></td>
        <td><?= htmlspecialchars($row["created_at"]) ?></td>
      </tr>
    <?php endwhile; ?>
  </table>
</body>
</html>
