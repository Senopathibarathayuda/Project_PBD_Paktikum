<?php
require_once __DIR__ . '/includes/bootstrap.php';
wajib_izin('kartu_stok');
$halaman = 'kartu_stok';
$judul = 'Kartu Stok';
$subjudul = 'Riwayat stok masuk dan keluar yang dihasilkan otomatis oleh Trigger.';
$barangFilter = isset($_GET['barang']) && ctype_digit((string)$_GET['barang']) ? (int)$_GET['barang'] : 0;
$sourceFilter = in_array($_GET['sumber'] ?? '', ['PENERIMAAN', 'PENJUALAN', 'RETUR'], true) ? $_GET['sumber'] : '';
$barangOptions = array_column(db_all('SELECT idbarang, nama FROM v_barang ORDER BY nama'), 'nama', 'idbarang');
$where = [];
$parameters = [];
if ($barangFilter) { $where[] = 'idbarang = ?'; $parameters[] = $barangFilter; }
if ($sourceFilter) { $where[] = 'sumber_transaksi = ?'; $parameters[] = $sourceFilter; }
$sql = 'SELECT * FROM v_kartu_stok' . ($where ? ' WHERE ' . implode(' AND ', $where) : '') . ' ORDER BY idkartu_stok DESC LIMIT 500';
$rows = db_all($sql, $parameters);
$masuk = 0; $keluar = 0;
foreach ($rows as $r) { $masuk += (int)$r['masuk']; $keluar += (int)$r['keluar']; }
require __DIR__ . '/includes/header.php';
?>
<div class="mini-metrics"><div class="mini-metric"><span>Mutasi ditampilkan</span><strong><?= count($rows) ?></strong></div><div class="mini-metric"><span>Total stok masuk</span><strong class="positive">+<?= number_format($masuk,0,',','.') ?></strong></div><div class="mini-metric"><span>Total stok keluar</span><strong class="negative">−<?= number_format($keluar,0,',','.') ?></strong></div></div>
<section class="surface-card"><div class="card-top"><div><h2>Riwayat mutasi</h2></div></div>
<form method="get" class="filter-row">
<?= pilihan_field('barang', 'Barang', [0 => 'Semua barang'] + $barangOptions, $barangFilter, false) ?>
<?= pilihan_field('sumber', 'Sumber transaksi', ['' => 'Semua sumber', 'PENERIMAAN' => 'Penerimaan', 'PENJUALAN' => 'Penjualan', 'RETUR' => 'Retur'], $sourceFilter, false) ?>
<button class="btn btn-primary" type="submit"><?= ikon('search',17) ?> Terapkan</button><a href="kartu_stok.php" class="btn btn-outline">Reset</a>
</form><div class="table-wrap"><table class="data-table"><thead><tr><th>No.</th><th>Waktu</th><th>Barang</th><th>Sumber</th><th>Referensi detail</th><th>Masuk</th><th>Keluar</th><th>Stok setelah transaksi</th></tr></thead><tbody>
<?php foreach ($rows as $r): ?><tr><td>#<?= (int)$r['idkartu_stok'] ?></td><td><?= e(tanggal($r['created_at'])) ?></td><td><b><?= e($r['nama_barang']) ?></b></td><td><?= status_chip(ucfirst(strtolower($r['sumber_transaksi']))) ?></td><td>#<?= (int)$r['idtransaksi'] ?></td><td class="positive"><?= (int)$r['masuk'] ? '+' . (int)$r['masuk'] : '-' ?></td><td class="negative"><?= (int)$r['keluar'] ? '−' . (int)$r['keluar'] : '-' ?></td><td class="num-strong"><?= (int)$r['stock'] ?></td></tr><?php endforeach; ?>
</tbody></table></div><?php if (!$rows) echo kosong('Tidak ada mutasi yang cocok dengan filter.'); ?><div class="card-note">Angka masuk/keluar pada ringkasan dihitung dari maksimal 500 riwayat yang ditampilkan. Stok pada kartu adalah saldo setelah mutasi terkait, bukan saldo seluruh barang digabungkan.</div></section>
<?php require __DIR__ . '/includes/footer.php'; ?>
