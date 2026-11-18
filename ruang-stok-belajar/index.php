<?php
require_once __DIR__ . '/includes/fungsi.php';
$judul = 'Beranda';
require __DIR__ . '/includes/header.php';
?>
<h1>Data Master</h1>
<section class="kotak-master">
    <div class="kartu"><h2>Satuan</h2><a class="tombol" href="satuan.php">Buka</a></div>
    <div class="kartu"><h2>Vendor</h2><a class="tombol" href="vendor.php">Buka</a></div>
    <div class="kartu"><h2>Role</h2><a class="tombol" href="role.php">Buka</a></div>
    <div class="kartu"><h2>User</h2><a class="tombol" href="user.php">Buka</a></div>
    <div class="kartu"><h2>Barang</h2><a class="tombol" href="barang.php">Buka</a></div>
    <div class="kartu"><h2>Margin Penjualan</h2><a class="tombol" href="margin_penjualan.php">Buka</a></div>
</section>
<h2>Transaksi</h2>
<div class="deretan-link">
    <a href="pengadaan.php">Pengadaan</a>
    <a href="penerimaan.php">Penerimaan</a>
    <a href="penjualan.php">Penjualan</a>
    <a href="retur.php">Retur</a>
    <a href="kartu_stok.php">Kartu Stok</a>
</div>
<h2>Stok Menipis</h2>
<?php try { $batas=ks_int($_GET['batas']??'10','Batas stok'); $menipis=ks_call(koneksi(),'CALL sp_barang_stok_menipis(:batas)',[':batas'=>$batas]); ?>
<form class="formulir" method="get"><label>Batas stok <input type="number" name="batas" min="0" value="<?= $batas ?>"></label><button type="submit">Tampilkan</button></form>
<?php tampil_tabel($menipis,['nama'=>'Barang','nama_satuan'=>'Satuan','stok_tersedia'=>'Stok']); } catch(Throwable $e) { ks_pesan($e->getMessage(),true); } ?>
<?php require __DIR__ . '/includes/footer.php'; ?>
