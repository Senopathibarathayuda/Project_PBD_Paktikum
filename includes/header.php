<?php
$judul = $judul ?? 'Dashboard';
$halaman = $halaman ?? 'index';
$menus = [
    'Dashboard' => [
        ['index', 'index.php', 'Dashboard', 'grid'],
    ],
    'Data Master' => [
        ['barang', 'barang.php', 'Barang', 'package'],
        ['satuan', 'satuan.php', 'Satuan', 'layers'],
        ['vendor', 'vendor.php', 'Vendor', 'truck'],
        ['margin_penjualan', 'margin_penjualan.php', 'Margin Penjualan', 'wallet'],
        ['user', 'user.php', 'Pengguna', 'users'],
        ['role', 'role.php', 'Role', 'shield'],
    ],
    'Transaksi' => [
        ['pengadaan', 'pengadaan.php', 'Pengadaan', 'clipboard'],
        ['penerimaan', 'penerimaan.php', 'Penerimaan', 'truck'],
        ['penjualan', 'penjualan.php', 'Penjualan', 'cart'],
        ['retur', 'retur.php', 'Retur Vendor', 'return'],
    ],
    'Persediaan' => [
        ['kartu_stok', 'kartu_stok.php', 'Kartu Stok', 'layers'],
    ],
];
?><!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#0085FF">
    <title><?= e($judul) ?> | Toko Sembako</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/style.css?v=2">
    <script src="assets/app.js" defer></script>
</head>
<body>
<div class="app-shell">
    <aside class="sidebar" id="sidebar" aria-label="Navigasi utama">
        <a class="brand" href="index.php">
            <span class="brand-mark"><?= ikon('package', 23) ?></span>
            <strong>Toko Sembako</strong>
        </a>
        <nav class="side-nav">
            <?php foreach ($menus as $group => $navEntries): ?>
                <?php $visibleEntries = array_filter($navEntries, fn($entry) => izin($entry[0])); if (!$visibleEntries) continue; ?>
                <div class="nav-group">
                    <div class="nav-caption"><?= e($group) ?></div>
                    <?php foreach ($visibleEntries as $navEntry): ?>
                        <a class="nav-item <?= $halaman === $navEntry[0] ? 'active' : '' ?>"
                            href="<?= e($navEntry[1]) ?>"
                            <?= $halaman === $navEntry[0] ? 'aria-current="page"' : '' ?>>
                            <?= ikon($navEntry[3], 20) ?>
                            <span><?= e($navEntry[2]) ?></span>
                        </a>
                    <?php endforeach; ?>
                </div>
            <?php endforeach; ?>
        </nav>
        <div class="nav-bottom">
            <div class="profile-avatar"><?= e(strtoupper(substr((string)(user_aktif()['username'] ?? 'U'), 0, 1))) ?></div>
            <div class="profile-name">
                <b><?= e(user_aktif()['username'] ?? '') ?></b>
                <small><?= e(ucwords(role_sekarang())) ?></small>
            </div>
            <a class="logout" href="logout.php" aria-label="Keluar" title="Keluar"><?= ikon('logout', 20) ?></a>
        </div>
    </aside>
    <div class="main-wrap">
        <header class="topbar">
            <button class="icon-btn menu-toggle" id="menu-toggle" aria-label="Buka menu" aria-expanded="false"><?= ikon('menu', 23) ?></button>
            <b>Toko Sembako</b>
        </header>
        <main class="main-content" id="main-content">
            <div class="page-head">
                <h1><?= e($judul) ?></h1>
                <?= $headAction ?? '' ?>
            </div>
            <?= flash_tampil() ?>
