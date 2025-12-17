<?php
require_once "db.php";
$conn = db();

$id = intval($_GET["id"] ?? 0);
if ($id > 0) {
  $stmt = $conn->prepare("DELETE FROM guests WHERE id = ?");
  $stmt->bind_param("i", $id);
  $stmt->execute();
  $stmt->close();
}

header("Location: /delete/");
exit;
