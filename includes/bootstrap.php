<?php
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start([
        'cookie_httponly' => true,
        'cookie_samesite' => 'Lax',
        'use_strict_mode' => true,
    ]);
}
require_once __DIR__ . '/../config/koneksi.php';
require_once __DIR__ . '/fungsi.php';

// Sinkronkan role pada setiap request agar perubahan akses langsung berlaku.
if (!empty($_SESSION['auth']['iduser'])) {
    $current = db_one('SELECT u.iduser, u.username, r.nama_role FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE u.iduser = ? AND u.status = 1 AND r.status = 1', [(int)$_SESSION['auth']['iduser']]);
    if (!$current) {
        unset($_SESSION['auth']);
    } else {
        $_SESSION['auth'] = [
            'iduser' => (int)$current['iduser'],
            'username' => $current['username'],
            'nama_role' => $current['nama_role'],
        ];
    }
}
