<?php
function db() {
  $host = getenv("DB_HOST");
  $name = getenv("DB_NAME");
  $user = getenv("DB_USER");
  $pass = getenv("DB_PASS");

  $conn = new mysqli($host, $user, $pass, $name);
  if ($conn->connect_error) {
    die("DB connection failed: " . $conn->connect_error);
  }
  $conn->set_charset("utf8mb4");
  return $conn;
}
