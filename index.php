<?php
require_once __DIR__ . '/includes/bootstrap.php';
wajib_izin('index');
$halaman = 'index';
$judul = 'Dashboard';
$subjudul = 'Ringkasan aktivitas dan persediaan Toko Sembako.';
$barang = db_one('SELECT COUNT(*) jumlah, COALESCE(SUM(stok_tersedia), 0) unit, SUM(CASE WHEN status = 1 AND stok_tersedia <= 5 THEN 1 ELSE 0 END) menipis FROM v_barang');
$pengadaan = db_one("SELECT COUNT(*) jumlah, SUM(status = 'P') proses FROM v_pengadaan");
$penjualan = db_one("SELECT COUNT(*) jumlah, COALESCE(SUM(CASE WHEN status = 'S' THEN total_nilai ELSE 0 END), 0) omzet FROM v_penjualan");
$penerimaan = db_one("SELECT COUNT(*) jumlah, SUM(status = 'P') proses FROM v_penerimaan");
$retur = db_one("SELECT COUNT(*) jumlah FROM v_retur");
$lowStock = db_all('SELECT nama, stok_tersedia, nama_satuan FROM v_barang WHERE status = 1 ORDER BY stok_tersedia ASC, nama ASC LIMIT 6');
$recent = db_all('SELECT idpenjualan, created_at, total_nilai, status_label FROM v_penjualan ORDER BY idpenjualan DESC LIMIT 6');
require __DIR__ . '/includes/header.php';
?>
<div class="metric-grid">
<div class="metric-card"><span class="metric-icon blue"><?= ikon('package',22) ?></span><span class="metric-label">Jumlah barang</span><strong><?= number_format((int)$barang['jumlah'], 0, ',', '.') ?></strong></div>
<div class="metric-card"><span class="metric-icon purple"><?= ikon('clipboard',22) ?></span><span class="metric-label">Pengadaan diproses</span><strong><?= (int)$pengadaan['proses'] ?></strong></div>
<div class="metric-card"><span class="metric-icon green"><?= ikon('cart',22) ?></span><span class="metric-label">Omzet penjualan selesai</span><strong class="currency-value"><?= e(rupiah($penjualan['omzet'])) ?></strong></div>
<div class="metric-card"><span class="metric-icon orange"><?= ikon('layers',22) ?></span><span class="metric-label">Stok rendah (≤5)</span><strong><?= (int)$barang['menipis'] ?></strong></div>
</div>
<div class="dashboard-grid"><section class="surface-card"><div class="card-top"><div><h2>Stok yang perlu diperhatikan</h2></div><?php if (izin('barang')): ?><a class="btn btn-text" href="barang.php">Lihat barang <?= ikon('arrow',16) ?></a><?php endif; ?></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Stok</th><th>Keterangan</th></tr></thead><tbody><?php foreach ($lowStock as $r): ?><tr><td><b><?= e($r['nama']) ?></b></td><td><?= (int)$r['stok_tersedia'] ?> <?= e($r['nama_satuan']) ?></td><td><?= (int)$r['stok_tersedia'] <= 5 ? status_chip('Perlu restok') : status_chip('Cukup') ?></td></tr><?php endforeach; ?></tbody></table></div><?php if (!$lowStock) echo kosong(); ?></section>
<section class="surface-card"><div class="card-top"><div><h2>Penjualan terbaru</h2></div><?php if (izin('penjualan')): ?><a class="btn btn-text" href="penjualan.php">Lihat semua <?= ikon('arrow',16) ?></a><?php endif; ?></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Transaksi</th><th>Tanggal</th><th>Nilai</th><th>Status</th></tr></thead><tbody><?php foreach ($recent as $r): ?><tr><td><?php if (izin('penjualan')): ?><a class="table-link" href="penjualan.php?id=<?= (int)$r['idpenjualan'] ?>">#<?= (int)$r['idpenjualan'] ?></a><?php else: ?>#<?= (int)$r['idpenjualan'] ?><?php endif; ?></td><td><?= e(tanggal($r['created_at'])) ?></td><td><?= e(rupiah_tahan($r['total_nilai'])) ?></td><td><?= status_chip($r['status_label']) ?></td></tr><?php endforeach; ?></tbody></table></div><?php if (!$recent) echo kosong('Belum ada penjualan.'); ?></section></div>
<?php require __DIR__ . '/includes/footer.php'; ?>
