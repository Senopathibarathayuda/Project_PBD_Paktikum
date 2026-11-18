<?php
require_once __DIR__ . '/includes/fungsi.php';
$judul = 'Cek Koneksi';
$hasil = [];
$error = '';

try {
    $db = koneksi();
    $hasil = $db->query('SELECT DATABASE() AS nama_database')->fetch();
    $jumlah = $db->query('SELECT COUNT(*) FROM v_barang')->fetchColumn();
} catch (PDOException $e) {
    $error = $e->getMessage();
}
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Cek Koneksi Database</h1><a class="tombol" href="index.php">Kembali</a></div>
<?php if ($error !== ''): ?>
    <?php pesan_error($error); ?>
    <p>Periksa <code>config/koneksi.php</code> dan pastikan file SQL database baru sudah diimpor.</p>
<?php else: ?>
    <p class="hasil">Koneksi berhasil.<br>Nama database: <strong><?= aman($hasil['nama_database']) ?></strong><br>
       Jumlah barang dalam <code>v_barang</code>: <strong><?= (int) $jumlah ?></strong></p>
<?php endif; ?>
<?php require __DIR__ . '/includes/footer.php'; ?>
