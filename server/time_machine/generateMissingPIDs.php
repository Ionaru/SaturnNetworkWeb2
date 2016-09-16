<?php include __DIR__ . '/../register/points.php';
$db_connection = createDatabaseConnection();
$sql = 'SELECT user_id, user_name FROM users WHERE user_pid = \'\';';
foreach ($db_connection->query($sql) as $row) {
    $user_pid = generateUniquePID('users');
    $sql = 'UPDATE users SET user_pid=\'' . $user_pid . '\' WHERE user_name = \'' . $row['user_name'] . '\';';
    $query2 = $db_connection->exec($sql);
    echo $row['user_name'] . ' ('. $user_pid .')<br>';
}
echo 'End of file';
