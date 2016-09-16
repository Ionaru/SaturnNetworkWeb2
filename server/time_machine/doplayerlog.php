<?php include __DIR__ . '/../register/points.php';
$db_connection = createDatabaseConnection();
$sql = 'SELECT * FROM playerlog ORDER BY playerlog_id DESC';
foreach ($db_connection->query($sql) as $row) {
    $rowid = $row['playerlog_id'];
    //$i = 24;
    $i2 = $rowid - 1;
    $changeto = 0;
    $getlastamountsql = 'SELECT * FROM playerlog WHERE playerlog_id = ' . $i2;
    foreach ($db_connection->query($getlastamountsql) as $row2) {
        $changeto = $row2['playerlog_amount'];
    }
    try {
        $sql2 = 'UPDATE playerlog SET playerlog_amount=' . $changeto . ' WHERE playerlog_id = ' . $rowid;
        $query2 = $db_connection->prepare($sql2);
        $query2->execute();
    } catch (PDOException $e) {

    }
}

require __DIR__ . '/../MulticraftAPI.php';
try {
    $config = parse_ini_file(__DIR__ . '/../config/SaturnMulticraftAPI.ini');
    $API_Host = $config['API_Host'];
    $API_User = $config['API_User'];
    $API_Key = $config['API_Key'];
} catch (Exception $e) {
    return false;
}
$api = new MulticraftAPI($API_Host, $API_User, $API_Key);
$result = $api->getServerStatus(1, true);
$onlinePlayers = 0;
$onlinePlayers = $result['data']['onlinePlayers'];
try {
    $sql2 = 'UPDATE playerlog SET playerlog_amount=' . $onlinePlayers . ' WHERE playerlog_id = 1';
    $query2 = $db_connection->prepare($sql2);
    $query2->execute();
} catch (PDOException $e) {

}