<?php
$judul = $judul ?? 'Beranda';
$halamanAktif = basename($_SERVER['SCRIPT_NAME'] ?? 'index.php');
$menu = [
    'index.php' => 'Beranda',
    'pengadaan.php' => 'Pengadaan',
    'penerimaan.php' => 'Penerimaan',
    'penjualan.php' => 'Penjualan',
    'retur.php' => 'Retur',
    'kartu_stok.php' => 'Kartu Stok'
];
?>
<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= aman($judul) ?> | Ruang Stok</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
    <header class="kepala">
        <div class="wadah">
            <div class="nama-aplikasi">RUANG STOK</div>
            
            <nav class="navigasi" aria-label="Menu utama">
                <?php foreach ($menu as $file => $nama): ?>
                    <a class="<?= $halamanAktif === $file ? 'aktif' : '' ?>"
                       href="<?= aman($file) ?>"><?= aman($nama) ?></a>
                <?php endforeach; ?>
            </nav>
        </div>
    </header>
    <main class="wadah isi">
