<?php
// Konfigurasi default untuk Laragon. Gunakan environment variable jika perlu.
// Jangan masukkan password database asli ke repository publik.
define('DB_HOST', getenv('RUANG_STOK_DB_HOST') ?: '127.0.0.1');
define('DB_PORT', getenv('RUANG_STOK_DB_PORT') ?: '3306');
define('DB_NAMA', getenv('RUANG_STOK_DB_NAMA') ?: 'pbd_ruang_stok_baru');
define('DB_USER', getenv('RUANG_STOK_DB_USER') ?: 'root');
define('DB_PASSWORD', getenv('RUANG_STOK_DB_PASSWORD') ?: '');

function koneksi(): PDO
{
    static $db = null;
    if ($db === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT
            . ';dbname=' . DB_NAMA . ';charset=utf8mb4';
        $db = new PDO($dsn, DB_USER, DB_PASSWORD, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]);
    }
    return $db;
}
