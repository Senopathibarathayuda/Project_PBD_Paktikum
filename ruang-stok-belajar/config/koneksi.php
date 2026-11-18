<?php
// Pengaturan koneksi database Laragon.
// Sesuaikan bagian ini jika MySQL memakai password atau port berbeda.
const DB_HOST = '127.0.0.1';
const DB_PORT = '3306';
const DB_NAMA = 'pbd_ruang_stok_baru';
const DB_USER = 'root';
const DB_PASSWORD = '';

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
