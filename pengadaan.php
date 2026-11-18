<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form transaksi dan detail berada langsung di halaman pengadaan.php.
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$induk = null;
$nilaiForm = [];
$errorForm = '';
$jenis = 'pengadaan';
$pkForm = $tab === 'detail' ? 'iddetail_pengadaan' : 'idpengadaan';
$fkDetail = 'idpengadaan';
$namaTabelForm = $tab === 'detail' ? 'detail_pengadaan' : 'pengadaan';
$fieldUtama = [
'user_iduser' => ['User', 'ref', 'user'],
'vendor_idvendor' => ['Vendor', 'ref', 'vendor']
];
$fieldDetail = [
'idbarang' => ['Barang yang Dipesan', 'ref', 'barang'],
'jumlah' => ['Jumlah Pesan', 'number', 0],
'harga_satuan' => ['Harga Satuan', 'number', 0]
];

try {
    $dbForm = koneksi();
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['tutup_id'])) {
        ks_cek_token(); $tid=ks_id($_POST['tutup_id']);
        $st=ks_jalankan($dbForm,"UPDATE pengadaan SET status='4' WHERE idpengadaan=:id AND status IN ('1','2')",[':id'=>$tid]);
        if ($st->rowCount()!==1) throw new RuntimeException('Pengadaan tidak dapat ditutup.');
        ks_ke('pengadaan.php?tab=detail&id='.$tid.'&hasil=berhasil');
    }
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['hapus_detail'])) {
        ks_cek_token(); $did=ks_id($_POST['hapus_detail']);
        $dbForm->exec('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
        $dbForm->beginTransaction();
        $baris=ks_satu($dbForm,'SELECT idpengadaan FROM detail_pengadaan WHERE iddetail_pengadaan=:id',[':id'=>$did]);
        if (!$baris) throw new RuntimeException('Detail tidak ditemukan.');
        $idInduk=(int)$baris['idpengadaan'];
        ks_kunci_draft($dbForm, $jenis, $idInduk);
        ks_jalankan($dbForm,'DELETE FROM detail_pengadaan WHERE iddetail_pengadaan=:id',[':id'=>$did]);
        ks_perbarui_total($dbForm,'pengadaan',$idInduk);
        $dbForm->commit(); ks_ke('pengadaan.php?tab=detail&id='.$idInduk.'&hasil=berhasil');
    }
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['final_id'])) {
        ks_cek_token();
        $finalId=ks_id($_POST['final_id']);
        ks_call($dbForm,'CALL sp_finalisasi_transaksi(:jenis,:id)',[':jenis'=>'pengadaan',':id'=>$finalId]);
        ks_ke('pengadaan.php?tab=detail&id='.$finalId.'&hasil=final');
    }
    if (isset($_GET['induk']) && $_GET['induk'] !== '') $induk = ks_id($_GET['induk']);
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm,
            'SELECT * FROM `' . $namaTabelForm . '` WHERE `' . $pkForm . '` = :id',
            [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
        if ($tab === 'detail') $induk = (int)$nilaiForm[$fkDetail];
        $headerEdit=ks_satu($dbForm,'SELECT status FROM pengadaan WHERE idpengadaan=:id',[':id'=>$tab==='detail'?$induk:$idEdit]);
        if (!$headerEdit || (string)$headerEdit['status']!=='0') throw new RuntimeException('Transaksi sudah selesai atau dikonfirmasi.');
    }
    if ($tab === 'detail' && $aksi === 'baru' && $induk === null) {
        throw new InvalidArgumentException('Pilih transaksi induk dari tab Daftar sebelum menambah detail.');
    }
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        ks_cek_token();
        if ($aksi === '') throw new RuntimeException('Pilih Tambah atau Edit dahulu.');
        $f = is_array($_POST['f'] ?? null) ? $_POST['f'] : [];
        $nilaiForm = $f;
        $db = $dbForm;
        $id = $idEdit;
        $db->exec('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
        $db->beginTransaction();
        try {
            if ($tab === 'detail') {
                if ($induk === null) throw new InvalidArgumentException('Transaksi induk tidak ditemukan.');
                ks_kunci_draft($db, $jenis, (int)$induk);
                if ($aksi === 'edit') {
                    $cekDetail = ks_satu($db, 'SELECT * FROM `' . $namaTabelForm . '` WHERE `' . $pkForm . '` = :id FOR UPDATE', [':id'=>$idEdit]);
                    if (!$cekDetail || (int)$cekDetail[$fkDetail] !== (int)$induk) throw new RuntimeException('Detail tidak ditemukan atau telah berubah.');
                }
            } elseif ($aksi === 'edit') {
                ks_kunci_draft($db, $jenis, (int)$idEdit);
            }
            if ($tab === 'daftar') {
                    $user = ks_id($f['user_iduser'] ?? '');
                    $vendor = ks_id($f['vendor_idvendor'] ?? '');
                    ks_aktif($db,'vendor',$vendor);
                    $status = '0';
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO pengadaan (user_iduser, vendor_idvendor, status, subtotal_nilai, ppn, total_nilai) VALUES (:user, :vendor, :status, 0, 0, 0)',
                            [':user'=>$user, ':vendor'=>$vendor, ':status'=>$status]);
                    } else {
                        ks_jalankan($db, 'UPDATE pengadaan SET user_iduser = :user, vendor_idvendor = :vendor, status = :status WHERE idpengadaan = :id',
                            [':user'=>$user, ':vendor'=>$vendor, ':status'=>$status, ':id'=>$idEdit]);
                    }
            } else {
                if ($induk === null) throw new InvalidArgumentException('Transaksi induk tidak ditemukan.');
                    $barang = ks_id($f['idbarang'] ?? '');
                    ks_aktif($db,'barang',$barang);
                    $jumlah = ks_int($f['jumlah'] ?? '', 'Jumlah pesan', 1);
                    $harga = ks_int($f['harga_satuan'] ?? '', 'Harga satuan');
                    $sub = (int)ks_jalankan($db,'SELECT fn_subtotal(:jumlah,:harga)',[':jumlah'=>$jumlah,':harga'=>$harga])->fetchColumn();
                    if ($sub > 2147483647) throw new InvalidArgumentException('Subtotal melebihi kapasitas kolom INT.');
                    // Jika barang sudah diterima, jangan mengurangi pesanannya di bawah jumlah yang sudah diterima.
                    if ($aksi === 'edit') {
                        $lamaDetail = ks_satu($db, 'SELECT idbarang FROM detail_pengadaan WHERE iddetail_pengadaan = :id', [':id'=>$idEdit]);
                        if ($lamaDetail && (int)$lamaDetail['idbarang'] !== $barang) {
                            $sudahLama = ks_satu($db, 'SELECT COALESCE(SUM(dp.jumlah_terima),0) AS jumlah FROM detail_penerimaan dp JOIN penerimaan p ON p.idpenerimaan = dp.idpenerimaan WHERE p.idpengadaan = :induk AND dp.barang_idbarang = :barang',
                                [':induk'=>$induk, ':barang'=>$lamaDetail['idbarang']]);
                            if ((int)$sudahLama['jumlah'] > 0) throw new InvalidArgumentException('Barang pada detail pengadaan tidak boleh diganti setelah barang tersebut diterima.');
                        }
                    }
                    $lain = ks_satu($db, 'SELECT COALESCE(SUM(jumlah),0) AS jumlah FROM detail_pengadaan WHERE idpengadaan = :induk AND idbarang = :barang AND iddetail_pengadaan <> :id',
                        [':induk'=>$induk, ':barang'=>$barang, ':id'=>$aksi === 'edit' ? $idEdit : 0]);
                    $diterima = ks_satu($db, 'SELECT COALESCE(SUM(dp.jumlah_terima),0) AS jumlah FROM detail_penerimaan dp JOIN penerimaan p ON p.idpenerimaan = dp.idpenerimaan WHERE p.idpengadaan = :induk AND dp.barang_idbarang = :barang',
                        [':induk'=>$induk, ':barang'=>$barang]);
                    if ($jumlah + (int)$lain['jumlah'] < (int)$diterima['jumlah']) throw new InvalidArgumentException('Jumlah pengadaan tidak boleh kurang dari barang yang telah diterima.');
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO detail_pengadaan (idpengadaan, idbarang, jumlah, harga_satuan, sub_total) VALUES (:induk, :barang, :jumlah, :harga, :sub)',
                            [':induk'=>$induk, ':barang'=>$barang, ':jumlah'=>$jumlah, ':harga'=>$harga, ':sub'=>$sub]);
                    } else {
                        ks_jalankan($db, 'UPDATE detail_pengadaan SET idbarang = :barang, jumlah = :jumlah, harga_satuan = :harga, sub_total = :sub WHERE iddetail_pengadaan = :id',
                            [':barang'=>$barang, ':jumlah'=>$jumlah, ':harga'=>$harga, ':sub'=>$sub, ':id'=>$idEdit]);
                    }
                    ks_perbarui_total($db, $jenis, $induk);
            }
            $idHasil = $aksi === 'baru' ? (int)$db->lastInsertId() : (int)$idEdit;
            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            throw $e;
        }
        if ($tab === 'daftar' && $aksi === 'baru') {
            ks_ke('pengadaan.php?tab=detail&aksi=baru&induk=' . $idHasil . '&hasil=induk');
        }
        $url = 'pengadaan.php?tab=' . $tab . ($tab === 'detail' && $induk !== null ? '&id=' . $induk : '') . '&hasil=berhasil';
        ks_ke($url);
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'Pengadaan';
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$id = isset($_GET['aksi']) ? ($tab === 'detail' && isset($induk) ? $induk : null) : filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
$data = [];
$error = '';

$kolomDaftar = [
        'idpengadaan' => 'ID Pengadaan',
        'timestamp' => 'Tanggal',
        'user_iduser' => 'ID User',
        'status_transaksi' => 'Status',
        'nama_vendor' => 'Vendor',
        'subtotal_nilai' => 'Subtotal',
        'ppn' => 'PPN',
        'total_nilai' => 'Total',
];
$kolomDetail = [
        'iddetail_pengadaan' => 'ID Detail',
        'idpengadaan' => 'ID Pengadaan',
        'nama_barang' => 'Barang',
        'harga_satuan' => 'Harga Satuan',
        'jumlah' => 'Jumlah',
        'sub_total' => 'Subtotal',
];

try {
    $db = koneksi();
    if ($tab === 'detail') {
        // Detail ada dalam halaman transaksi, bukan dibuat menu terpisah.
        if ($id !== false && $id !== null && $id > 0) {
            $sql = 'SELECT d.*, (SELECT h.status FROM pengadaan h WHERE h.idpengadaan=d.idpengadaan) AS status_induk FROM v_detail_pengadaan d WHERE idpengadaan = :id ORDER BY iddetail_pengadaan DESC';
            $stmt = $db->prepare($sql);
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $data = $stmt->fetchAll();
        } else {
            $sql = 'SELECT d.*, (SELECT h.status FROM pengadaan h WHERE h.idpengadaan=d.idpengadaan) AS status_induk FROM v_detail_pengadaan d ORDER BY iddetail_pengadaan DESC';
            $data = $db->query($sql)->fetchAll();
        }
    } else {
        $sql = 'SELECT * FROM v_pengadaan ORDER BY idpengadaan DESC';
        $data = $db->query($sql)->fetchAll();
    }
} catch (PDOException $e) {
    $error = $e->getMessage();
}
$headerDetail=null; $verifikasi=[];
if (!$error && $tab==='detail' && $id) {
    try {
        $headerDetail=ks_satu($db,'SELECT * FROM pengadaan WHERE idpengadaan=:id',[':id'=>$id]);
        if ($headerDetail) $verifikasi=ks_call($db,'CALL sp_verifikasi_penerimaan(:id)',[':id'=>$id]);
    } catch (Throwable $e) { $error=$e->getMessage(); }
}
if ($tab==='daftar') $data=ks_status_transaksi($data,'pengadaan');
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data Pengadaan</h1><a class="tombol" href="index.php">Kembali</a></div>
<nav class="tab" aria-label="Tab Pengadaan">
    <a href="pengadaan.php?tab=daftar" class="<?= $tab === 'daftar' ? 'aktif' : '' ?>">Daftar</a>
    <a href="pengadaan.php?tab=detail" class="<?= $tab === 'detail' ? 'aktif' : '' ?>">Detail</a>
</nav>
<?php if (isset($_GET['hasil'])) ks_pesan($_GET['hasil'] === 'final' ? 'Transaksi berhasil dikonfirmasi.' : 'Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
<?php if ($tab === 'daftar'): ?>
    <a class="tombol" href="pengadaan.php?tab=daftar&amp;aksi=baru">+ Tambah Pengadaan</a>
<?php elseif ($headerDetail && (string)$headerDetail['status']==='0'): ?>
    <a class="tombol" href="pengadaan.php?tab=detail&amp;aksi=baru&amp;induk=<?= (int)$id ?>">+ Tambah Detail</a>
<?php endif; ?>
<?php if ($aksi !== ''): ?>
    <a class="tombol" href="pengadaan.php?tab=<?= aman($tab) ?><?= $tab === 'detail' && $induk !== null ? '&amp;id=' . (int)$induk : '' ?>">Batal</a>
<?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
<h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> <?= $tab === 'detail' ? 'Detail ' : '' ?>Pengadaan</h2>
<form class="kelola-form" method="post" action="pengadaan.php?tab=<?= aman($tab) ?>&amp;aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?><?= $induk !== null ? '&amp;induk=' . (int)$induk : '' ?>">
    <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
    <div class="kelola-grid">
    <?php foreach (($tab === 'detail' ? $fieldDetail : $fieldUtama) as $nama => $field):
        [$label, $tipe, $opsi] = $field;
        $pilihan = $tipe === 'select' ? $opsi : [];
        if ($tipe === 'ref') {
            if ('pengadaan' === 'penerimaan' && $tab === 'detail' && $nama === 'barang_idbarang' && $induk !== null) {
                $asal = ks_satu($dbForm, 'SELECT idpengadaan FROM penerimaan WHERE idpenerimaan = :id', [':id'=>$induk]);
                $pilihan = [];
                if ($asal) foreach (ks_jalankan($dbForm, 'SELECT DISTINCT b.idbarang, b.nama FROM v_barang b JOIN detail_pengadaan d ON d.idbarang = b.idbarang WHERE d.idpengadaan = :id ORDER BY b.nama', [':id'=>$asal['idpengadaan']])->fetchAll() as $baris) $pilihan[$baris['idbarang']] = $baris['nama'];
            } elseif ('pengadaan' === 'retur' && $tab === 'detail' && $nama === 'iddetail_penerimaan' && $induk !== null) {
                $pilihan = [];
                foreach (ks_jalankan($dbForm, 'SELECT d.iddetail_penerimaan, b.nama FROM detail_penerimaan d JOIN retur r ON r.idpenerimaan = d.idpenerimaan JOIN v_barang b ON b.idbarang = d.barang_idbarang WHERE r.idretur = :id ORDER BY d.iddetail_penerimaan', [':id'=>$induk])->fetchAll() as $baris) $pilihan[$baris['iddetail_penerimaan']] = '#' . $baris['iddetail_penerimaan'] . ' - ' . $baris['nama'];
            } elseif ('pengadaan' === 'penjualan' && $tab === 'daftar' && $nama === 'idmargin_penjualan' && $aksi === 'baru') {
                $pilihan = [];
                foreach ($dbForm->query('SELECT idmargin_penjualan, persen FROM v_margin_penjualan WHERE status = 1 ORDER BY idmargin_penjualan')->fetchAll() as $m) $pilihan[(string)$m['idmargin_penjualan']] = $m['persen'] . '%';
            } else {
                $pilihan = ks_ref($dbForm, $opsi);
            }
        }
        $awal = $nilaiForm[$nama] ?? ($nama === 'status' ? '0' : '');
        if ($tipe==='ref' && $awal!=='' && !isset($pilihan[$awal])) $pilihan[$awal]='#'.$awal.' (pilihan lama)';
        ks_form_field($nama, $label, $tipe === 'ref' ? 'select' : $tipe, $awal, $pilihan, true, is_int($opsi) ? $opsi : 100);
    endforeach; ?>
    </div>
    <button type="submit">Simpan</button>
    <a class="tombol" href="pengadaan.php?tab=<?= aman($tab) ?>">Batal</a>
</form>
</section>
<?php endif; ?>
<?php if ($tab==='detail' && $headerDetail): ?>
<p><strong>Status:</strong> <?= aman(ks_status_transaksi([$headerDetail],'pengadaan')[0]['status_transaksi']) ?></p>
<?php if ((string)$headerDetail['status']==='0' && $aksi===''): ks_final_form('pengadaan',(int)$id,'Konfirmasi Pesanan'); endif; ?>
<?php endif; ?>
<?php if ($headerDetail && in_array((string)$headerDetail['status'],['1','2'],true)): ?><form method="post" action="pengadaan.php?tab=detail&amp;id=<?= (int)$id ?>" onsubmit="return confirm('Tutup sisa pesanan?')"><input type="hidden" name="token" value="<?= aman(ks_token()) ?>"><input type="hidden" name="tutup_id" value="<?= (int)$id ?>"><button type="submit">Tutup Sisa Pesanan</button></form><?php endif; ?>
<?php if ($headerDetail && $verifikasi): ?><h2>Pemenuhan Pesanan</h2><?php tampil_tabel($verifikasi,['nama_barang'=>'Barang','dipesan'=>'Dipesan','diterima'=>'Diterima','sisa'=>'Sisa','hasil_verifikasi'=>'Status']); endif; ?>
<?php if ($tab === 'detail'): ?>
    <h2>Detail Pengadaan<?= $id !== false && $id !== null && $id > 0 ? ' #' . (int) $id : '' ?></h2>
    <?php if ($id !== false && $id !== null && $id > 0): ?>
        <p><a href="pengadaan.php?tab=detail">Tampilkan semua detail</a></p>
    <?php endif; ?>
<?php else: ?>
    <h2>Daftar Pengadaan</h2>
<?php endif; ?>
<?php
if ($error !== '') {
    pesan_error($error);
} elseif ($tab === 'detail') {
    tampil_tabel($data, $kolomDetail, '', [['pk'=>'iddetail_pengadaan', 'label'=>'Edit', 'draft'=>true, 'url'=>'pengadaan.php?tab=detail&aksi=edit&id='], ['pk'=>'iddetail_pengadaan','label'=>'Hapus','draft'=>true,'post'=>'hapus_detail','url'=>'pengadaan.php?tab=detail']]);
} else {
    tampil_tabel($data, $kolomDaftar, 'idpengadaan', [['pk'=>'idpengadaan', 'label'=>'Edit', 'draft'=>true, 'url'=>'pengadaan.php?tab=daftar&aksi=edit&id='], ['pk'=>'idpengadaan', 'label'=>'+ Detail', 'draft'=>true, 'url'=>'pengadaan.php?tab=detail&aksi=baru&induk=']]);
}
require __DIR__ . '/includes/footer.php';
