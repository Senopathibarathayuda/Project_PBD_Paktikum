<?php
require_once __DIR__ . '/bootstrap.php';
$cfgs = [
    'pengadaan' => ['title' => 'Pengadaan', 'desc' => '', 'pk' => 'idpengadaan', 'view' => 'v_pengadaan', 'table' => 'pengadaan', 'icon' => 'clipboard', 'sp' => 'sp_konfirmasi_pengadaan'],
    'penerimaan' => ['title' => 'Penerimaan', 'desc' => '', 'pk' => 'idpenerimaan', 'view' => 'v_penerimaan', 'table' => 'penerimaan', 'icon' => 'truck', 'sp' => 'sp_konfirmasi_penerimaan'],
    'penjualan' => ['title' => 'Penjualan', 'desc' => '', 'pk' => 'idpenjualan', 'view' => 'v_penjualan', 'table' => 'penjualan', 'icon' => 'cart', 'sp' => 'sp_konfirmasi_penjualan'],
    'retur' => ['title' => 'Retur Vendor', 'desc' => '', 'pk' => 'idretur', 'view' => 'v_retur', 'table' => 'retur', 'icon' => 'return', 'sp' => 'sp_konfirmasi_retur'],
];
if (!isset($cfgs[$transaksiKey ?? ''])) exit('Halaman transaksi tidak ditemukan.');
$c = $cfgs[$transaksiKey];
wajib_izin($transaksiKey);
$canWrite = izin($transaksiKey, true);
$halaman = $transaksiKey;
$judul = $c['title'];
$subjudul = $c['desc'];
$self = $transaksiKey . '.php';
$table = $c['table'];
$pk = $c['pk'];
function transaksi_cari_induk(string $table, string $pk, int $id): array
{
    $row = db_one("SELECT * FROM {$table} WHERE {$pk} = ?", [$id]);
    if (!$row) throw new RuntimeException('Transaksi tidak ditemukan.');
    return $row;
}
function transaksi_bisa_edit(string $jenis, array $row): bool
{
    if ($jenis === 'pengadaan') {
        return $row['status'] === 'P' && empty($row['dikonfirmasi_at']);
    }
    if ($jenis === 'penerimaan') {
        return $row['status'] === 'P';
    }
    return $row['status'] === 'D';
}
function transaksi_wajib_draft(string $jenis, string $table, string $pk, int $id): array
{
    $row = transaksi_cari_induk($table, $pk, $id);
    if (!transaksi_bisa_edit($jenis, $row)) {
        throw new RuntimeException('Transaksi ini sudah dikonfirmasi dan tidak dapat diedit.');
    }
    return $row;
}
function transaksi_baris_khusus(string $kind, int $id): array
{
    return match ($kind) {
        'pengadaan' => db_all('SELECT d.iddetail_pengadaan, d.idpengadaan, d.idbarang, b.nama AS nama_barang, d.jumlah, d.harga_satuan, d.sub_total, s.nama_satuan FROM detail_pengadaan d JOIN barang b ON b.idbarang = d.idbarang JOIN satuan s ON s.idsatuan = b.idsatuan WHERE d.idpengadaan = ? ORDER BY d.iddetail_pengadaan', [$id]),
        'penerimaan' => db_all('SELECT * FROM v_detail_penerimaan WHERE idpenerimaan = ? ORDER BY iddetail_penerimaan', [$id]),
        'penjualan' => db_all('SELECT d.*, b.stok_tersedia, fn_harga_jual(b.harga, p.margin_persen) AS harga_estimasi FROM v_detail_penjualan d JOIN barang b ON b.idbarang = d.idbarang JOIN v_penjualan p ON p.idpenjualan = d.penjualan_idpenjualan WHERE d.penjualan_idpenjualan = ? ORDER BY d.iddetail_penjualan', [$id]),
        'retur' => db_all('SELECT * FROM v_detail_retur WHERE idretur = ? ORDER BY iddetail_retur', [$id]),
        default => [],
    };
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $referId = isset($_POST['id']) && ctype_digit((string)$_POST['id']) ? (int)$_POST['id'] : 0;
    try {
        wajib_izin($transaksiKey, true);
        validasi_csrf();
        $action = (string)($_POST['action'] ?? '');
        if ($action === 'create') {
            if ($transaksiKey === 'pengadaan') {
                $vendor = nilai_int($_POST['vendor'] ?? '', 1);
                if (!db_one("SELECT idvendor FROM vendor WHERE idvendor = ? AND status = '1'", [$vendor])) throw new RuntimeException('Pilih vendor aktif.');
                db_run('INSERT INTO pengadaan (user_iduser, vendor_idvendor) VALUES (?, ?)', [user_aktif()['iduser'], $vendor]);
            } elseif ($transaksiKey === 'penerimaan') {
                $po = nilai_int($_POST['idpengadaan'] ?? '', 1);
                if (!db_one("SELECT idpengadaan FROM pengadaan WHERE idpengadaan = ? AND status = 'P' AND dikonfirmasi_at IS NOT NULL", [$po])) {
                    throw new RuntimeException('Pengadaan harus sudah dikonfirmasi dan masih dalam proses.');
                }
                if (db_one("SELECT idpenerimaan FROM penerimaan WHERE idpengadaan = ? AND status = 'P'", [$po])) {
                    throw new RuntimeException('Selesaikan pemeriksaan penerimaan sebelumnya terlebih dahulu.');
                }
                db_run('INSERT INTO penerimaan (idpengadaan, iduser) VALUES (?, ?)', [$po, user_aktif()['iduser']]);
            } elseif ($transaksiKey === 'penjualan') {
                $margin = db_one('SELECT idmargin_penjualan FROM margin_penjualan WHERE status = 1');
                if (!$margin) throw new RuntimeException('Belum ada margin aktif. Aktifkan margin pada Data Master.');
                db_run('INSERT INTO penjualan (iduser, idmargin_penjualan) VALUES (?, ?)', [user_aktif()['iduser'], $margin['idmargin_penjualan']]);
            } else {
                $penerimaan = nilai_int($_POST['idpenerimaan'] ?? '', 1);
                if (!db_one("SELECT idpenerimaan FROM penerimaan WHERE idpenerimaan = ? AND status = 'S'", [$penerimaan])) throw new RuntimeException('Pilih penerimaan selesai.');
                db_run('INSERT INTO retur (idpenerimaan, iduser) VALUES (?, ?)', [$penerimaan, user_aktif()['iduser']]);
            }
            $newId = (int)$pdo->lastInsertId();
            flash('success', 'Transaksi dibuat. Tambahkan detail barang.');
            pergi($self . '?id=' . $newId);
        }
        $id = nilai_int($_POST['id'] ?? '', 1);
        $referId = $id;
        if ($action === 'confirm') {
            $stmt = $pdo->prepare('CALL ' . $c['sp'] . '(?)');
            $stmt->execute([$id]);
            $stmt->closeCursor();
            flash('success', 'Transaksi berhasil dikonfirmasi.');
            pergi($self . '?id=' . $id);
        }
        if ($action === 'delete_draft') {
            $children = ['pengadaan' => ['detail_pengadaan', 'idpengadaan'], 'penerimaan' => ['detail_penerimaan', 'idpenerimaan'], 'penjualan' => ['detail_penjualan', 'penjualan_idpenjualan'], 'retur' => ['detail_retur', 'idretur']];
            $pdo->beginTransaction();
            $header = db_one("SELECT * FROM {$table} WHERE {$pk} = ? FOR UPDATE", [$id]);
            if (!$header || !transaksi_bisa_edit($transaksiKey, $header)) throw new RuntimeException('Transaksi sudah dikonfirmasi dan tidak dapat dihapus.');
            [$child, $fk] = $children[$transaksiKey];
            db_run("DELETE FROM {$child} WHERE {$fk} = ?", [$id]);
            db_run("DELETE FROM {$table} WHERE {$pk} = ?", [$id]);
            $pdo->commit();
            flash('success', 'Draft beserta detailnya berhasil dihapus.');
            pergi($self);
        }
        $lockedDetailTransaction = in_array($action, ['save_detail', 'remove_detail'], true);
        if ($lockedDetailTransaction) {
            $pdo->beginTransaction();
            $locked = db_one("SELECT * FROM {$table} WHERE {$pk} = ? FOR UPDATE", [$id]);
            if (!$locked || !transaksi_bisa_edit($transaksiKey, $locked)) throw new RuntimeException('Transaksi sudah dikonfirmasi dan tidak dapat diedit.');
        } else {
            transaksi_wajib_draft($transaksiKey, $table, $pk, $id);
        }
        if ($action === 'save_detail') {
            if ($transaksiKey === 'pengadaan') {
                $barang = nilai_int($_POST['idbarang'] ?? '', 1);
                $jumlah = nilai_int($_POST['jumlah'] ?? '', 1);
                $harga = nilai_uang($_POST['harga_satuan'] ?? '');
                if (!db_one('SELECT idbarang FROM barang WHERE idbarang = ? AND status = 1', [$barang])) throw new RuntimeException('Pilih barang aktif.');
                db_run('INSERT INTO detail_pengadaan (idpengadaan, idbarang, jumlah, harga_satuan, sub_total) VALUES (?, ?, ?, ?, ? * ?) ON DUPLICATE KEY UPDATE jumlah = VALUES(jumlah), harga_satuan = VALUES(harga_satuan), sub_total = VALUES(sub_total)', [$id, $barang, $jumlah, $harga, $jumlah, $harga]);
            } elseif ($transaksiKey === 'penjualan') {
                $barang = nilai_int($_POST['idbarang'] ?? '', 1);
                $jumlah = nilai_int($_POST['jumlah'] ?? '', 1);
                if (!db_one('SELECT idbarang FROM barang WHERE idbarang = ? AND status = 1', [$barang])) throw new RuntimeException('Pilih barang aktif.');
                db_run('INSERT INTO detail_penjualan (penjualan_idpenjualan, idbarang, jumlah) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE jumlah = VALUES(jumlah)', [$id, $barang, $jumlah]);
            } elseif ($transaksiKey === 'retur') {
                $detail = nilai_int($_POST['iddetail_penerimaan'] ?? '', 1);
                $jumlah = nilai_int($_POST['jumlah'] ?? '', 1);
                $alasan = trim((string)($_POST['alasan'] ?? ''));
                if ($alasan === '' || panjang_teks($alasan) > 200) throw new RuntimeException('Alasan retur harus diisi, maksimal 200 karakter.');
                $retur = transaksi_cari_induk('retur', 'idretur', $id);
                if (!db_one('SELECT iddetail_penerimaan FROM detail_penerimaan WHERE iddetail_penerimaan = ? AND idpenerimaan = ? AND jumlah_terima > 0', [$detail, $retur['idpenerimaan']])) throw new RuntimeException('Detail bukan dari penerimaan yang dipilih.');
                db_run('INSERT INTO detail_retur (idretur, iddetail_penerimaan, jumlah, alasan) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE jumlah = VALUES(jumlah), alasan = VALUES(alasan)', [$id, $detail, $jumlah, $alasan]);
            } else throw new RuntimeException('Gunakan formulir pemeriksaan semua barang untuk penerimaan.');
            flash('success', 'Detail transaksi disimpan.');
        } elseif ($action === 'save_receipt' && $transaksiKey === 'penerimaan') {
            $rec = transaksi_cari_induk('penerimaan', 'idpenerimaan', $id);
            $orders = db_all('SELECT idbarang, harga_satuan FROM detail_pengadaan WHERE idpengadaan = ? ORDER BY idbarang', [$rec['idpengadaan']]);
            if (!$orders) throw new RuntimeException('Pesanan belum memiliki rincian barang.');
            $qtyMap = $_POST['jumlah_terima'] ?? [];
            $priceMap = $_POST['harga_satuan_terima'] ?? [];
            $rows = [];
            foreach ($orders as $line) {
                $productId = (int)$line['idbarang'];
                $q = nilai_int($qtyMap[$productId] ?? null, 0);
                $price = nilai_uang($priceMap[$productId] ?? null);
                $rows[] = [$id, $productId, $q, $price, $q, $price];
            }
            $pdo->beginTransaction();
            $locked = db_one('SELECT status FROM penerimaan WHERE idpenerimaan = ? FOR UPDATE', [$id]);
            if (!$locked || $locked['status'] !== 'P') throw new RuntimeException('Penerimaan sudah selesai.');
            foreach ($rows as $params) {
                db_run('INSERT INTO detail_penerimaan (idpenerimaan, barang_idbarang, jumlah_terima, harga_satuan_terima, sub_total_terima) VALUES (?, ?, ?, ?, ? * ?) ON DUPLICATE KEY UPDATE jumlah_terima = VALUES(jumlah_terima), harga_satuan_terima = VALUES(harga_satuan_terima), sub_total_terima = VALUES(sub_total_terima)', $params);
            }
            $pdo->commit();
            flash('success', 'Pemeriksaan berhasil disimpan.');
        } elseif ($action === 'remove_detail') {
            $detailId = nilai_int($_POST['detail_id'] ?? '', 1);
            $mapping = [
                'pengadaan' => ['detail_pengadaan', 'iddetail_pengadaan', 'idpengadaan'],
                'penjualan' => ['detail_penjualan', 'iddetail_penjualan', 'penjualan_idpenjualan'],
                'retur' => ['detail_retur', 'iddetail_retur', 'idretur'],
            ];
            if (!isset($mapping[$transaksiKey])) throw new RuntimeException('Baris penerimaan harus diedit melalui formulir pemeriksaan.');
            [$child, $childPk, $fk] = $mapping[$transaksiKey];
            db_run("DELETE FROM {$child} WHERE {$childPk} = ? AND {$fk} = ?", [$detailId, $id]);
            flash('success', 'Detail dihapus dari Draft.');
        } else throw new RuntimeException('Aksi tidak tersedia.');
        if ($lockedDetailTransaction) $pdo->commit();
        pergi($self . '?id=' . $id);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        flash('error', error_db($error));
        pergi($self . ($referId ? '?id=' . $referId : ''));
    }
}

$id = isset($_GET['id']) ? max(0, (int)$_GET['id']) : 0;
$header = $id ? db_one("SELECT * FROM {$c['view']} WHERE {$pk} = ?", [$id]) : null;
if ($id && !$header) { http_response_code(404); exit('Transaksi tidak ditemukan. <a href="' . e($self) . '">Kembali</a>'); }
$isDraft = $header && transaksi_bisa_edit($transaksiKey, $header);
$editLine = null;
if ($id && $isDraft && $canWrite && isset($_GET['editdetail']) && ctype_digit((string)$_GET['editdetail'])) {
    $detailId = (int)$_GET['editdetail'];
    $detailTables = [
        'pengadaan' => ['detail_pengadaan', 'iddetail_pengadaan', 'idpengadaan'],
        'penjualan' => ['detail_penjualan', 'iddetail_penjualan', 'penjualan_idpenjualan'],
        'retur' => ['detail_retur', 'iddetail_retur', 'idretur'],
    ];
    if (isset($detailTables[$transaksiKey])) {
        [$detailTable, $detailPk, $detailFk] = $detailTables[$transaksiKey];
        $editLine = db_one("SELECT * FROM {$detailTable} WHERE {$detailPk} = ? AND {$detailFk} = ?", [$detailId, $id]);
    }
}
$items = $id ? transaksi_baris_khusus($transaksiKey, $id) : [];
$viewList = !$id ? db_all("SELECT * FROM {$c['view']} ORDER BY {$pk} DESC LIMIT 200") : [];
$products = in_array($transaksiKey, ['pengadaan', 'penjualan'], true)
    ? db_all('SELECT idbarang, nama, harga, stok_tersedia, nama_satuan FROM v_barang WHERE status = 1 ORDER BY nama') : [];
$vendorOptions = $transaksiKey === 'pengadaan'
    ? array_column(db_all("SELECT idvendor, nama_vendor FROM v_vendor WHERE status = '1' ORDER BY nama_vendor"), 'nama_vendor', 'idvendor') : [];
$poOptions = $transaksiKey === 'penerimaan'
    ? array_column(db_all("SELECT idpengadaan, nama_vendor FROM v_pengadaan WHERE status = 'P' AND dikonfirmasi_at IS NOT NULL ORDER BY idpengadaan DESC"), 'nama_vendor', 'idpengadaan') : [];
$receiptOptions = $transaksiKey === 'retur'
    ? db_all("SELECT p.idpenerimaan, p.idpengadaan, p.created_at, v.nama_vendor FROM v_penerimaan p JOIN v_pengadaan v ON v.idpengadaan = p.idpengadaan WHERE p.status = 'S' ORDER BY p.idpenerimaan DESC") : [];
$verifyRows = [];
if ($transaksiKey === 'penerimaan' && $id && isset($_GET['verify'])) {
    try {
        $st = $pdo->prepare('CALL sp_verifikasi_penerimaan(?)');
        $st->execute([$id]);
        $verifyRows = $st->fetchAll();
        $st->closeCursor();
    } catch (Throwable $e) { flash('error', error_db($e)); pergi($self . '?id=' . $id); }
}
$receiptOrderLines = [];
$returChoices = [];
if ($transaksiKey === 'penerimaan' && $id) {
    $receiptOrderLines = db_all("SELECT o.idbarang, b.nama, o.jumlah AS dipesan, o.harga_satuan,
        COALESCE((SELECT SUM(d2.jumlah_terima) FROM detail_penerimaan d2 JOIN penerimaan r2 ON r2.idpenerimaan = d2.idpenerimaan WHERE r2.idpengadaan = p.idpengadaan AND r2.status = 'S' AND r2.idpenerimaan <> p.idpenerimaan AND d2.barang_idbarang = o.idbarang), 0) AS sudah_diterima,
        dp.jumlah_terima, dp.harga_satuan_terima, dp.iddetail_penerimaan
        FROM penerimaan p JOIN detail_pengadaan o ON o.idpengadaan = p.idpengadaan JOIN barang b ON b.idbarang = o.idbarang
        LEFT JOIN detail_penerimaan dp ON dp.idpenerimaan = p.idpenerimaan AND dp.barang_idbarang = o.idbarang
        WHERE p.idpenerimaan = ? ORDER BY o.iddetail_pengadaan", [$id]);
}
if ($transaksiKey === 'retur' && $id) {
    $returChoices = db_all("SELECT dp.iddetail_penerimaan, b.nama, b.stok_tersedia, dp.jumlah_terima,
        COALESCE((SELECT SUM(dr.jumlah) FROM detail_retur dr JOIN retur r ON r.idretur = dr.idretur WHERE r.status = 'S' AND dr.iddetail_penerimaan = dp.iddetail_penerimaan), 0) AS sudah_retur
        FROM retur parent JOIN detail_penerimaan dp ON dp.idpenerimaan = parent.idpenerimaan
        JOIN barang b ON b.idbarang = dp.barang_idbarang
        WHERE parent.idretur = ? AND dp.jumlah_terima > 0 ORDER BY dp.iddetail_penerimaan", [$id]);
}
$headAction = $id ? '<a href="' . $self . '" class="btn btn-outline">' . ikon('back',16) . ' Semua transaksi</a>' : ($canWrite ? '<a href="' . $self . '?new=1" class="btn btn-primary">' . ikon('plus',18) . ' Tambah ' . e($c['title']) . '</a>' : '');
require __DIR__ . '/header.php';
?>
<?php if (!$id): ?>
<?php if ($canWrite && isset($_GET['new'])): ?>
<section class="surface-card create-card"><div class="card-top"><div><h2>Buat <?= e($c['title']) ?> baru</h2></div><a href="<?= e($self) ?>" class="icon-btn">×</a></div>
<form method="post" class="form-grid"><?= csrf_field() ?><input type="hidden" name="action" value="create">
<?php if ($transaksiKey === 'pengadaan'): ?><?= pilihan_field('vendor', 'Vendor aktif', $vendorOptions) ?>
<?php elseif ($transaksiKey === 'penerimaan'): ?><?php $options = []; foreach ($poOptions as $v => $n) $options[$v] = 'PO #' . $v . ' · ' . $n; ?><?= pilihan_field('idpengadaan','Pengadaan diproses', $options) ?>
<?php elseif ($transaksiKey === 'penjualan'): ?><div class="inline-hint">Margin aktif digunakan saat penjualan dikonfirmasi. PPN 11%.</div>
<?php else: ?><?php $options = []; foreach ($receiptOptions as $r) $options[$r['idpenerimaan']] = 'Terima #' . $r['idpenerimaan'] . ' · PO #' . $r['idpengadaan'] . ' · ' . $r['nama_vendor']; ?><?= pilihan_field('idpenerimaan','Penerimaan selesai', $options) ?><?php endif; ?>
<div class="form-actions span-full"><a class="btn btn-outline" href="<?= e($self) ?>">Batal</a><button class="btn btn-primary" type="submit">Lanjutkan <?= ikon('arrow',17) ?></button></div></form></section>
<?php endif; ?>
<section class="surface-card"><div class="card-top"><div><h2>Daftar <?= e($c['title']) ?></h2></div><label class="table-search"><?= ikon('search',17) ?><input type="search" placeholder="Cari transaksi..." data-table-filter="transaction-table"></label></div>
<div class="table-wrap"><table class="data-table" id="transaction-table"><thead><tr><th>No.</th><th>Tanggal</th><th>Referensi</th><th>Petugas</th><?php if (in_array($transaksiKey, ['pengadaan','penjualan'], true)): ?><th>Total</th><?php endif; ?><th>Status</th><th>Aksi</th></tr></thead><tbody><?php foreach ($viewList as $r): ?><tr><td class="num-strong">#<?= (int)$r[$pk] ?></td><td><?= e(tanggal($r[$transaksiKey === 'pengadaan' ? 'timestamp' : 'created_at'])) ?></td><td><?php
if ($transaksiKey === 'pengadaan') echo e($r['nama_vendor']);
elseif ($transaksiKey === 'penerimaan') echo 'PO #' . (int)$r['idpengadaan'];
elseif ($transaksiKey === 'penjualan') echo 'Margin ' . e($r['margin_persen']) . '%';
else echo 'Terima #' . (int)$r['idpenerimaan'];
?></td><td><?= e($r['username']) ?></td><?php if (in_array($transaksiKey, ['pengadaan','penjualan'], true)): ?><td class="num-strong"><?= e(rupiah_tahan($r['total_nilai'])) ?></td><?php endif; ?><td><?= status_chip($r['status_label']) ?></td><td><a class="btn btn-tonal btn-sm" href="<?= e($self) ?>?id=<?= (int)$r[$pk] ?>">Detail <?= ikon('arrow',15) ?></a></td></tr><?php endforeach; ?></tbody></table></div><?php if (!$viewList) echo kosong('Belum ada transaksi.'); ?></section>
<?php else: ?>
<div class="detail-head surface-card"><div class="detail-head-primary"><div class="detail-icon"><?= ikon($c['icon'],28) ?></div><div><p class="eyebrow">RINCIAN TRANSAKSI</p><h2><?= e($c['title']) ?> #<?= (int)$header[$pk] ?></h2><div class="detail-meta"><?= e(tanggal($header[$transaksiKey === 'pengadaan' ? 'timestamp' : 'created_at'])) ?> <span>·</span> <?= e($header['username']) ?></div></div></div><div class="detail-head-status"><?= status_chip($header['status_label']) ?></div></div>
<div class="detail-info-grid"><div><span>Referensi</span><b><?php
if ($transaksiKey === 'pengadaan') echo e($header['nama_vendor']);
elseif ($transaksiKey === 'penerimaan') echo 'Pengadaan #' . (int)$header['idpengadaan'];
elseif ($transaksiKey === 'penjualan') echo 'Margin ' . e($header['margin_persen']) . '%';
else echo 'Penerimaan #' . (int)$header['idpenerimaan'];
?></b></div><div><span>Status</span><b><?= e($header['status_label']) ?></b></div>
<?php if (in_array($transaksiKey,['pengadaan','penjualan'],true)): ?><div><span>Subtotal</span><b><?= e(rupiah_tahan($header['subtotal_nilai'])) ?></b></div><div><span>PPN (<?= e($header['tarif_ppn']) ?>%)</span><b><?= e(rupiah_tahan($header['ppn'])) ?></b></div><div><span>Total</span><b><?= e(rupiah_tahan($header['total_nilai'])) ?></b></div><?php endif; ?>
</div>
<?php if ($transaksiKey === 'pengadaan'): ?>
<?php if ($isDraft && $canWrite): ?><section class="surface-card detail-form-card"><div class="card-top"><div><h2>Tambah / perbarui barang pesanan</h2></div></div><form method="post" class="form-grid"><?= csrf_field() ?><input type="hidden" name="action" value="save_detail"><input type="hidden" name="id" value="<?= $id ?>"><?php $opts = []; foreach ($products as $p) $opts[$p['idbarang']] = $p['nama'] . ' · ' . $p['nama_satuan']; ?><?= pilihan_field('idbarang','Barang aktif',$opts,$editLine['idbarang'] ?? null) ?><?= field('jumlah','Jumlah pesan',$editLine['jumlah'] ?? '1','number','min="1" step="1" required') ?><?= field('harga_satuan','Harga beli per unit (Rp)',$editLine['harga_satuan'] ?? '0','number','min="0" step="1" required') ?><div class="form-actions span-full"><button type="submit" class="btn btn-primary"><?= ikon('plus',17) ?> Simpan barang</button></div></form></section><?php endif; ?>
<section class="surface-card"><div class="card-top"><div><h2>Detail pengadaan</h2></div></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Jumlah</th><th>Harga satuan</th><th>Subtotal</th><?php if ($isDraft && $canWrite): ?><th>Aksi</th><?php endif; ?></tr></thead><tbody><?php $previewTotal=0; foreach ($items as $r): $previewTotal+=(int)$r['jumlah']*(int)$r['harga_satuan']; ?><tr><td><?= e($r['nama_barang']) ?></td><td><?= (int)$r['jumlah'] ?></td><td><?= e(rupiah($r['harga_satuan'])) ?></td><td><?= e(rupiah($r['sub_total'])) ?></td><?php if ($isDraft && $canWrite): ?><td><a class="btn btn-text btn-sm" href="pengadaan.php?id=<?= $id ?>&editdetail=<?= (int)$r['iddetail_pengadaan'] ?>">Edit</a> <?php detail_delete_form($id, $r['iddetail_pengadaan']); ?></td><?php endif; ?></tr><?php endforeach; ?></tbody></table></div><?php if (!$items) echo kosong('Tambahkan barang pesanan terlebih dahulu.'); ?><?php if ($isDraft && $items): $calculated = db_one('SELECT fn_total_dengan_ppn(?, 12) AS total', [$previewTotal]); ?><div class="total-strip">Subtotal <b><?= e(rupiah($previewTotal)) ?></b> <span>PPN 12%</span> <b><?= e(rupiah($calculated['total'] - $previewTotal)) ?></b> <span>Estimasi total</span> <b><?= e(rupiah($calculated['total'])) ?></b></div><?php endif; ?></section>
<?php elseif ($transaksiKey === 'penerimaan'): ?>
<section class="surface-card"><div class="card-top"><div><h2>Detail pemeriksaan barang</h2></div></div>
<?php if ($isDraft && $canWrite): ?><form method="post"><?= csrf_field() ?><input type="hidden" name="action" value="save_receipt"><input type="hidden" name="id" value="<?= $id ?>"><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Dipesan</th><th>Sudah diterima</th><th>Sisa pesanan</th><th>Terima sekarang</th><th>Harga per unit (Rp)</th></tr></thead><tbody><?php foreach ($receiptOrderLines as $r): $remain=max(0,(int)$r['dipesan']-(int)$r['sudah_diterima']); ?><tr><td><b><?= e($r['nama']) ?></b></td><td><?= (int)$r['dipesan'] ?></td><td><?= (int)$r['sudah_diterima'] ?></td><td><?= $remain ?></td><td><input class="table-input" type="number" name="jumlah_terima[<?= (int)$r['idbarang'] ?>]" min="0" max="<?= $remain ?>" step="1" required value="<?= $r['jumlah_terima'] === null ? '0' : (int)$r['jumlah_terima'] ?>"></td><td><input class="table-input money-input" type="number" name="harga_satuan_terima[<?= (int)$r['idbarang'] ?>]" min="0" step="1" required value="<?= (int)($r['harga_satuan_terima'] ?? $r['harga_satuan']) ?>"></td></tr><?php endforeach; ?></tbody></table></div><div class="form-actions inset-actions"><button type="submit" class="btn btn-primary"><?= ikon('check',17) ?> Simpan pemeriksaan</button></div></form>
<?php else: ?><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Dipesan</th><th>Sudah diterima sebelumnya</th><th>Diterima kali ini</th><th>Harga terima</th><th>Kondisi</th></tr></thead><tbody><?php foreach ($receiptOrderLines as $r): ?><tr><td><?= e($r['nama']) ?></td><td><?= (int)$r['dipesan'] ?></td><td><?= (int)$r['sudah_diterima'] ?></td><td><?= $r['jumlah_terima'] === null ? '-' : (int)$r['jumlah_terima'] ?></td><td><?= $r['harga_satuan_terima'] === null ? '-' : e(rupiah($r['harga_satuan_terima'])) ?></td><td><?= $r['jumlah_terima'] === null ? status_chip('Belum diperiksa') : status_chip((int)$r['jumlah_terima'] === 0 ? 'Tidak datang' : 'Datang') ?></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?>
<?php if ($verifyRows): ?><div class="verification"><h3>Hasil verifikasi</h3><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Dipesan</th><th>Sudah diterima</th><th>Terima kali ini</th><th>Hasil</th></tr></thead><tbody><?php foreach ($verifyRows as $r): ?><tr><td><?= e($r['nama_barang']) ?></td><td><?= (int)$r['jumlah_dipesan'] ?></td><td><?= (int)$r['sudah_diterima_sebelumnya'] ?></td><td><?= $r['diterima_pada_pemeriksaan_ini'] === null ? '-' : (int)$r['diterima_pada_pemeriksaan_ini'] ?></td><td><?= status_chip($r['hasil_verifikasi']) ?></td></tr><?php endforeach; ?></tbody></table></div></div><?php endif; ?>
<div class="inset-actions"><a class="btn btn-outline" href="penerimaan.php?id=<?= $id ?>&verify=1"><?= ikon('search',16) ?> Periksa penerimaan</a></div>
</section>
<?php elseif ($transaksiKey === 'penjualan'): ?>
<?php if ($isDraft && $canWrite): ?><section class="surface-card detail-form-card"><div class="card-top"><div><h2>Tambah / perbarui barang terjual</h2></div></div><form method="post" class="form-grid"><?= csrf_field() ?><input type="hidden" name="action" value="save_detail"><input type="hidden" name="id" value="<?= $id ?>"><?php $opts=[]; foreach ($products as $p) $opts[$p['idbarang']] = $p['nama'] . ' · stok ' . $p['stok_tersedia'] . ' · ' . rupiah($p['harga']); ?><?= pilihan_field('idbarang', 'Barang aktif', $opts, $editLine['idbarang'] ?? null) ?><?= field('jumlah','Jumlah terjual',$editLine['jumlah'] ?? '1','number','min="1" step="1" required') ?><div class="form-actions span-full"><button class="btn btn-primary" type="submit"><?= ikon('plus',17) ?> Simpan barang</button></div></form></section><?php endif; ?>
<section class="surface-card"><div class="card-top"><div><h2>Detail penjualan</h2></div></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Jumlah</th><th>Harga satuan</th><th>Subtotal</th><th>Stok saat ini</th><?php if ($isDraft && $canWrite): ?><th>Aksi</th><?php endif; ?></tr></thead><tbody><?php $salePreview = 0; foreach ($items as $r): $unitPrice = $isDraft ? $r['harga_estimasi'] : $r['harga_satuan']; $sub = $isDraft ? $unitPrice*$r['jumlah'] : $r['subtotal']; $salePreview += $sub; ?><tr><td><?= e($r['nama_barang']) ?></td><td><?= (int)$r['jumlah'] ?></td><td><?= e(rupiah($unitPrice)) ?></td><td><?= e(rupiah($sub)) ?></td><td><?= (int)$r['stok_tersedia'] ?></td><?php if ($isDraft && $canWrite): ?><td><a class="btn btn-text btn-sm" href="penjualan.php?id=<?= $id ?>&editdetail=<?= (int)$r['iddetail_penjualan'] ?>">Edit</a> <?php detail_delete_form($id, $r['iddetail_penjualan']); ?></td><?php endif; ?></tr><?php endforeach; ?></tbody></table></div><?php if (!$items) echo kosong('Tambahkan barang ke penjualan.'); ?><?php if ($isDraft && $items): $calculated = db_one('SELECT fn_total_dengan_ppn(?, 11) AS total', [$salePreview]); ?><div class="total-strip">Subtotal <b><?= e(rupiah($salePreview)) ?></b> <span>PPN 11%</span> <b><?= e(rupiah($calculated['total']-$salePreview)) ?></b> <span>Estimasi total</span> <b><?= e(rupiah($calculated['total'])) ?></b></div><?php endif; ?></section>
<?php else: ?>
<?php if ($isDraft && $canWrite): ?><section class="surface-card detail-form-card"><div class="card-top"><div><h2>Tambah / perbarui barang retur</h2></div></div><form method="post" class="form-grid"><?= csrf_field() ?><input type="hidden" name="action" value="save_detail"><input type="hidden" name="id" value="<?= $id ?>"><?php $opts=[]; foreach ($returChoices as $r) { $remaining=max(0,(int)$r['jumlah_terima']-(int)$r['sudah_retur']); if ($remaining > 0) $opts[$r['iddetail_penerimaan']] = $r['nama'] . ' · bisa retur ' . $remaining . ' · stok ' . $r['stok_tersedia']; } ?><?= pilihan_field('iddetail_penerimaan','Barang dari penerimaan',$opts,$editLine['iddetail_penerimaan'] ?? null) ?><?= field('jumlah','Jumlah retur',$editLine['jumlah'] ?? '1','number','min="1" step="1" required') ?><?= field('alasan','Alasan retur',$editLine['alasan'] ?? '','text','required maxlength="200"') ?><div class="form-actions span-full"><button type="submit" class="btn btn-primary"><?= ikon('plus',17) ?> Simpan retur</button></div></form></section><?php endif; ?>
<section class="surface-card"><div class="card-top"><div><h2>Detail barang retur</h2></div></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Barang</th><th>Jumlah</th><th>Alasan</th><?php if ($isDraft && $canWrite): ?><th>Aksi</th><?php endif; ?></tr></thead><tbody><?php foreach ($items as $r): ?><tr><td><?= e($r['nama_barang']) ?></td><td><?= (int)$r['jumlah'] ?></td><td><?= e($r['alasan']) ?></td><?php if ($isDraft && $canWrite): ?><td><a class="btn btn-text btn-sm" href="retur.php?id=<?= $id ?>&editdetail=<?= (int)$r['iddetail_retur'] ?>">Edit</a> <?php detail_delete_form($id, $r['iddetail_retur']); ?></td><?php endif; ?></tr><?php endforeach; ?></tbody></table></div><?php if (!$items) echo kosong('Belum ada barang yang akan diretur.'); ?></section>
<?php endif; ?>
<div class="detail-actions"><div class="detail-hint"><?= ikon('info',17) ?> <?php if ($isDraft): ?>Konfirmasi akan mengunci detail transaksi.<?php else: ?>Transaksi dikonfirmasi dan tidak dapat diubah.<?php endif; ?></div>
<?php if ($canWrite && $isDraft): ?><div class="action-buttons"><form method="post" data-confirm="Hapus transaksi yang belum dikonfirmasi beserta detailnya?" class="inline-form"><?= csrf_field() ?><input type="hidden" name="action" value="delete_draft"><input type="hidden" name="id" value="<?= $id ?>"><button class="btn btn-outline danger-text" type="submit"><?= ikon('trash',16) ?> Hapus</button></form><form method="post" data-confirm="Konfirmasi transaksi? Proses ini dapat mengubah stok dan tidak bisa dibatalkan lewat edit." class="inline-form"><?= csrf_field() ?><input type="hidden" name="action" value="confirm"><input type="hidden" name="id" value="<?= $id ?>"><button class="btn btn-primary" type="submit"><?= ikon('check',17) ?> Konfirmasi <?= e($c['title']) ?></button></form></div><?php endif; ?></div>
<?php endif; ?>
<?php require __DIR__ . '/footer.php'; ?>
<?php
function detail_delete_form(int $parentId, $detailId): void
{
    echo '<form method="post" class="inline-form" data-confirm="Hapus baris detail ini?">' . csrf_field()
        . '<input type="hidden" name="action" value="remove_detail"><input type="hidden" name="id" value="' . $parentId . '">'
        . '<input type="hidden" name="detail_id" value="' . (int)$detailId . '"><button class="btn btn-text btn-sm danger-text" type="submit">Hapus</button></form>';
}
