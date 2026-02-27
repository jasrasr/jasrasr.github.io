<?php
/*
File: log_click.php
Author: Jason Lamb (generated with ChatGPT)
Created: 2026-02-27
Modified: 2026-02-27
Revision: 1.0

Changelog:
1.0 - Receives click events and logs to daily JSONL + CSV
*/

header("Content-Type: application/json; charset=utf-8");
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
  http_response_code(400);
  echo json_encode(["ok" => false, "error" => "Invalid JSON"]);
  exit;
}

$logsDir = __DIR__ . DIRECTORY_SEPARATOR . "logs";
if (!is_dir($logsDir)) {
  @mkdir($logsDir, 0755, true);
}

$date = date("Y-m-d");
$jsonlPath = $logsDir . DIRECTORY_SEPARATOR . "clicks-$date.jsonl";
$csvPath   = $logsDir . DIRECTORY_SEPARATOR . "clicks-$date.csv";

/* Normalize / enrich */
$event = [
  "server_ts" => date("c"),
  "client_ts" => $data["ts"] ?? "",
  "id"        => $data["id"] ?? "",
  "name"      => $data["name"] ?? "",
  "url"       => $data["url"] ?? "",
  "ref"       => $data["ref"] ?? "",
  "ip"        => $_SERVER["REMOTE_ADDR"] ?? "",
  "ua"        => $data["ua"] ?? ($_SERVER["HTTP_USER_AGENT"] ?? ""),
];

/* Write JSONL */
file_put_contents($jsonlPath, json_encode($event, JSON_UNESCAPED_SLASHES) . PHP_EOL, FILE_APPEND);

/* Write CSV (add header if new file) */
$csvNew = !file_exists($csvPath);
$fp = fopen($csvPath, "a");
if ($fp) {
  if ($csvNew) {
    fputcsv($fp, array_keys($event));
  }
  fputcsv($fp, array_values($event));
  fclose($fp);
}

echo json_encode(["ok" => true]);