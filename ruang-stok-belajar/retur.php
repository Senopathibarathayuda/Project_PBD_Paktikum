<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form transaksi dan detail berada langsung di halaman retur.php.
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$induk = null;
$nilaiForm = [];
$errorForm = '';
$jenis = 'retur';
$pkForm = $tab === 'detail' ? 'iddetail_retur' : 'idretur';
$fkDetail = 'idretur';
$namaTabelForm = $tab === 'detail' ? 'detail_retur' : 'retur';
$fieldUtama = [
'idpenerimaan' => ['Penerimaan yang Diretur', 'ref', 'penerimaan'],
'iduser' => ['User Pencatat', 'ref', 'user']
];
$fieldDetail = [
'iddetail_penerimaan' => ['Detail Penerimaan yang Diretur', 'ref', 'detail_penerimaan'],
'jumlah' => ['Jumlah Diretur', 'number', 0],
'alasan' => ['Alasan Retur', 'textarea', 200]
];

try {
    $dbForm = koneksi();
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['hapus_detail'])) {
        ks_cek_token(); $did=ks_id($_POST['hapus_detail']);
        $dbForm->exec('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
        $dbForm->beginTransaction();
        $baris=ks_satu($dbForm,'SELECT idretur FROM detail_retur WHERE iddetail_retur=:id',[':id'=>$did]);
        if (!$baris) throw new RuntimeException('Detail tidak ditemukan.');
        $idInduk=(int)$baris['idretur'];
        ks_kunci_draft($dbForm, $jenis, $idInduk);
        ks_jalankan($dbForm,'DELETE FROM detail_retur WHERE iddetail_retur=:id',[':id'=>$did]);
        
        $dbForm->commit(); ks_ke('retur.php?tab=detail&id='.$idInduk.'&hasil=berhasil');
    }
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['final_id'])) {
        ks_cek_token();
        $finalId=ks_id($_POST['final_id']);
        ks_call($dbForm,'CALL sp_finalisasi_transaksi(:jenis,:id)',[':jenis'=>'retur',':id'=>$finalId]);
        ks_ke('retur.php?tab=detail&id='.$finalId.'&hasil=final');
    }
    if (isset($_GET['induk']) && $_GET['induk'] !== '') $induk = ks_id($_GET['induk']);
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm,
            'SELECT * FROM `' . $namaTabelForm . '` WHERE `' . $pkForm . '` = :id',
            [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
        if ($tab === 'detail') $induk = (int)$nilaiForm[$fkDetail];
        $headerEdit=ks_satu($dbForm,'SELECT status FROM retur WHERE idretur=:id',[':id'=>$tab==='detail'?$induk:$idEdit]);
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
                    $penerimaan = ks_id($f['idpenerimaan'] ?? '');
                    $asalSelesai=ks_satu($db,'SELECT status FROM penerimaan WHERE idpenerimaan=:id',[':id'=>$penerimaan]);
                    if (!$asalSelesai || (string)$asalSelesai['status']!=='1') throw new InvalidArgumentException('Penerimaan belum selesai.');
                    $user = ks_id($f['iduser'] ?? '');
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO retur (idpenerimaan, iduser) VALUES (:penerimaan, :user)',
                            [':penerimaan'=>$penerimaan, ':user'=>$user]);
                    } else {
                        $lama = ks_satu($db, 'SELECT idpenerimaan FROM retur WHERE idretur = :id', [':id'=>$idEdit]);
                        $ada = ks_satu($db, 'SELECT COUNT(*) AS jumlah FROM detail_retur WHERE idretur = :id', [':id'=>$idEdit]);
                        if ($lama && (int)$lama['idpenerimaan'] !== $penerimaan && (int)$ada['jumlah'] > 0) {
                            throw new InvalidArgumentException('Penerimaan asal retur tidak boleh diganti karena sudah mempunyai detail.');
                        }
                        ks_jalankan($db, 'UPDATE retur SET idpenerimaan = :penerimaan, iduser = :user WHERE idretur = :id',
                            [':penerimaan'=>$penerimaan, ':user'=>$user, ':id'=>$idEdit]);
                    }
            } else {
                if ($induk === null) throw new InvalidArgumentException('Transaksi induk tidak ditemukan.');
                    $detail = ks_id($f['iddetail_penerimaan'] ?? '');
                    $jumlah = ks_int($f['jumlah'] ?? '', 'Jumlah retur', 1);
                    $alasan = ks_teks($f['alasan'] ?? '', 'Alasan retur', 200);
                    $asal = ks_satu($db, 'SELECT r.idpenerimaan FROM retur r WHERE r.idretur = :id', [':id'=>$induk]);
                    $rincian = ks_satu($db, 'SELECT d.idpenerimaan,d.jumlah_terima,b.stok_tersedia FROM detail_penerimaan d JOIN barang b ON b.idbarang=d.barang_idbarang WHERE d.iddetail_penerimaan = :detail', [':detail'=>$detail]);
                    if (!$asal || !$rincian || (int)$asal['idpenerimaan'] !== (int)$rincian['idpenerimaan']) {
                        throw new InvalidArgumentException('Detail retur harus berasal dari penerimaan yang sama.');
                    }
                    $sudah = ks_satu($db, 'SELECT COALESCE(SUM(jumlah), 0) AS jumlah FROM detail_retur d JOIN retur r ON r.idretur=d.idretur WHERE d.iddetail_penerimaan = :detail AND d.iddetail_retur <> :id AND (r.status=1 OR r.idretur=:draft)',
                        [':detail'=>$detail, ':id'=>$aksi==='edit' ? $idEdit : 0, ':draft'=>$induk]);
                    if ($jumlah > (int)$rincian['stok_tersedia']) throw new InvalidArgumentException('Stok tidak mencukupi untuk retur.');
                    if ($jumlah + (int)$sudah['jumlah'] > (int)$rincian['jumlah_terima']) throw new InvalidArgumentException('Jumlah retur melebihi jumlah yang diterima.');
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO detail_retur (idretur, iddetail_penerimaan, jumlah, alasan) VALUES (:induk, :detail, :jumlah, :alasan)',
                            [':induk'=>$induk, ':detail'=>$detail, ':jumlah'=>$jumlah, ':alasan'=>$alasan]);
                    } else {
                        ks_jalankan($db, 'UPDATE detail_retur SET iddetail_penerimaan = :detail, jumlah = :jumlah, alasan = :alasan WHERE iddetail_retur = :id',
                            [':detail'=>$detail, ':jumlah'=>$jumlah, ':alasan'=>$alasan, ':id'=>$idEdit]);
                    }
            }
            $idHasil = $aksi === 'baru' ? (int)$db->lastInsertId() : (int)$idEdit;
            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            throw $e;
        }
        if ($tab === 'daftar' && $aksi === 'baru') {
            ks_ke('retur.php?tab=detail&aksi=baru&induk=' . $idHasil . '&hasil=induk');
        }
        $url = 'retur.php?tab=' . $tab . ($tab === 'detail' && $induk !== null ? '&id=' . $induk : '') . '&hasil=berhasil';
        ks_ke($url);
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'Retur';
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$id = isset($_GET['aksi']) ? ($tab === 'detail' && isset($induk) ? $induk : null) : filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
$data = [];
$error = '';

$kolomDaftar = [
        'status_transaksi' => 'Status',
        'idretur' => 'ID Retur',
        'created_at' => 'Tanggal',
        'idpenerimaan' => 'ID Penerimaan',
        'iduser' => 'ID User',
];
$kolomDetail = [
        'iddetail_retur' => 'ID Detail',
        'idretur' => 'ID Retur',
        'iddetail_penerimaan' => 'ID Detail Penerimaan',
        'nama_barang' => 'Barang',
        'jumlah' => 'Jumlah',
        'alasan' => 'Alasan',
];

try {
    $db = koneksi();
    if ($tab === 'detail') {
        // Detail ada dalam halaman transaksi, bukan dibuat menu terpisah.
        if ($id !== false && $id !== null && $id > 0) {
            $sql = 'SELECT d.*, (SELECT b.nama FROM detail_penerimaan p JOIN barang b ON b.idbarang=p.barang_idbarang WHERE p.iddetail_penerimaan=d.iddetail_penerimaan) AS nama_barang, (SELECT h.status FROM retur h WHERE h.idretur=d.idretur) AS status_induk FROM v_detail_retur d WHERE idretur = :id ORDER BY iddetail_retur DESC';
            $stmt = $db->prepare($sql);
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $data = $stmt->fetchAll();
        } else {
            $sql = 'SELECT d.*, (SELECT b.nama FROM detail_penerimaan p JOIN barang b ON b.idbarang=p.barang_idbarang WHERE p.iddetail_penerimaan=d.iddetail_penerimaan) AS nama_barang, (SELECT h.status FROM retur h WHERE h.idretur=d.idretur) AS status_induk FROM v_detail_retur d ORDER BY iddetail_retur DESC';
            $data = $db->query($sql)->fetchAll();
        }
    } else {
        $sql = 'SELECT * FROM v_retur ORDER BY idretur DESC';
        $data = $db->query($sql)->fetchAll();
    }
} catch (PDOException $e) {
    $error = $e->getMessage();
}
$headerDetail=null; $verifikasi=[];
if (!$error && $tab==='detail' && $id) {
    try {
        $headerDetail=ks_satu($db,'SELECT * FROM retur WHERE idretur=:id',[':id'=>$id]);
        
    } catch (Throwable $e) { $error=$e->getMessage(); }
}
if ($tab==='daftar') $data=ks_status_transaksi($data,'retur');
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data Retur</h1><a class="tombol" href="index.php">Kembali</a></div>
<nav class="tab" aria-label="Tab Retur">
    <a href="retur.php?tab=daftar" class="<?= $tab === 'daftar' ? 'aktif' : '' ?>">Daftar</a>
    <a href="retur.php?tab=detail" class="<?= $tab === 'detail' ? 'aktif' : '' ?>">Detail</a>
</nav>
<?php if (isset($_GET['hasil'])) ks_pesan($_GET['hasil'] === 'final' ? 'Transaksi berhasil dikonfirmasi.' : 'Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
<?php if ($tab === 'daftar'): ?>
    <a class="tombol" href="retur.php?tab=daftar&amp;aksi=baru">+ Tambah Retur</a>
<?php elseif ($headerDetail && (string)$headerDetail['status']==='0'): ?>
    <a class="tombol" href="retur.php?tab=detail&amp;aksi=baru&amp;induk=<?= (int)$id ?>">+ Tambah Detail</a>
<?php endif; ?>
<?php if ($aksi !== ''): ?>
    <a class="tombol" href="retur.php?tab=<?= aman($tab) ?><?= $tab === 'detail' && $induk !== null ? '&amp;id=' . (int)$induk : '' ?>">Batal</a>
<?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
<h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> <?= $tab === 'detail' ? 'Detail ' : '' ?>Retur</h2>
<form class="kelola-form" method="post" action="retur.php?tab=<?= aman($tab) ?>&amp;aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?><?= $induk !== null ? '&amp;induk=' . (int)$induk : '' ?>">
    <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
    <div class="kelola-grid">
    <?php foreach (($tab === 'detail' ? $fieldDetail : $fieldUtama) as $nama => $field):
        [$label, $tipe, $opsi] = $field;
        $pilihan = $tipe === 'select' ? $opsi : [];
        if ($tipe === 'ref') {
            if ('retur' === 'penerimaan' && $tab === 'detail' && $nama === 'barang_idbarang' && $induk !== null) {
                $asal = ks_satu($dbForm, 'SELECT idpengadaan FROM penerimaan WHERE idpenerimaan = :id', [':id'=>$induk]);
                $pilihan = [];
                if ($asal) foreach (ks_jalankan($dbForm, 'SELECT DISTINCT b.idbarang, b.nama FROM v_barang b JOIN detail_pengadaan d ON d.idbarang = b.idbarang WHERE d.idpengadaan = :id ORDER BY b.nama', [':id'=>$asal['idpengadaan']])->fetchAll() as $baris) $pilihan[$baris['idbarang']] = $baris['nama'];
            } elseif ('retur' === 'retur' && $tab === 'detail' && $nama === 'iddetail_penerimaan' && $induk !== null) {
                $pilihan = [];
                foreach (ks_jalankan($dbForm, 'SELECT d.iddetail_penerimaan, CONCAT(b.nama, \' / Sisa retur: \',fn_sisa_retur(d.iddetail_penerimaan),\' / Stok: \',b.stok_tersedia) AS nama FROM detail_penerimaan d JOIN retur r ON r.idpenerimaan = d.idpenerimaan JOIN v_barang b ON b.idbarang = d.barang_idbarang WHERE r.idretur = :id AND d.jumlah_terima>0 ORDER BY d.iddetail_penerimaan', [':id'=>$induk])->fetchAll() as $baris) $pilihan[$baris['iddetail_penerimaan']] = '#' . $baris['iddetail_penerimaan'] . ' - ' . $baris['nama'];
            } elseif ('retur' === 'penjualan' && $tab === 'daftar' && $nama === 'idmargin_penjualan' && $aksi === 'baru') {
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
    <a class="tombol" href="retur.php?tab=<?= aman($tab) ?>">Batal</a>
</form>
</section>
<?php endif; ?>
<?php if ($tab==='detail' && $headerDetail): ?>
<p><strong>Status:</strong> <?= aman(ks_status_transaksi([$headerDetail],'retur')[0]['status_transaksi']) ?></p>
<?php if ((string)$headerDetail['status']==='0' && $aksi===''): ks_final_form('retur',(int)$id,'Selesaikan Retur'); endif; ?>
<?php endif; ?>
<?php if ($tab === 'detail'): ?>
    <h2>Detail Retur<?= $id !== false && $id !== null && $id > 0 ? ' #' . (int) $id : '' ?></h2>
    <?php if ($id !== false && $id !== null && $id > 0): ?>
        <p><a href="retur.php?tab=detail">Tampilkan semua detail</a></p>
    <?php endif; ?>
<?php else: ?>
    <h2>Daftar Retur</h2>
<?php endif; ?>
<?php
if ($error !== '') {
    pesan_error($error);
} elseif ($tab === 'detail') {
    tampil_tabel($data, $kolomDetail, '', [['pk'=>'iddetail_retur', 'label'=>'Edit', 'draft'=>true, 'url'=>'retur.php?tab=detail&aksi=edit&id='], ['pk'=>'iddetail_retur','label'=>'Hapus','draft'=>true,'post'=>'hapus_detail','url'=>'retur.php?tab=detail']]);
} else {
    tampil_tabel($data, $kolomDaftar, 'idretur', [['pk'=>'idretur', 'label'=>'Edit', 'draft'=>true, 'url'=>'retur.php?tab=daftar&aksi=edit&id='], ['pk'=>'idretur', 'label'=>'+ Detail', 'draft'=>true, 'url'=>'retur.php?tab=detail&aksi=baru&induk=']]);
}
require __DIR__ . '/includes/footer.php';
