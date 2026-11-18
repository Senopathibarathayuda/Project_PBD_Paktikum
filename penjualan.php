<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form transaksi dan detail berada langsung di halaman penjualan.php.
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$induk = null;
$nilaiForm = [];
$errorForm = '';
$jenis = 'penjualan';
$pkForm = $tab === 'detail' ? 'iddetail_penjualan' : 'idpenjualan';
$fkDetail = 'penjualan_idpenjualan';
$namaTabelForm = $tab === 'detail' ? 'detail_penjualan' : 'penjualan';
$fieldUtama = [
'iduser' => ['User Penjual', 'ref', 'user'],
'idmargin_penjualan' => ['Margin', 'ref', 'margin']
];
$fieldDetail = [
'idbarang' => ['Barang yang Dijual', 'ref', 'barang'],
'jumlah' => ['Jumlah Dijual', 'number', 0]
];

try {
    $dbForm = koneksi();
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['hapus_detail'])) {
        ks_cek_token(); $did=ks_id($_POST['hapus_detail']);
        $dbForm->exec('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
        $dbForm->beginTransaction();
        $baris=ks_satu($dbForm,'SELECT penjualan_idpenjualan FROM detail_penjualan WHERE iddetail_penjualan=:id',[':id'=>$did]);
        if (!$baris) throw new RuntimeException('Detail tidak ditemukan.');
        $idInduk=(int)$baris['penjualan_idpenjualan'];
        ks_kunci_draft($dbForm, $jenis, $idInduk);
        ks_jalankan($dbForm,'DELETE FROM detail_penjualan WHERE iddetail_penjualan=:id',[':id'=>$did]);
        ks_perbarui_total($dbForm,'penjualan',$idInduk);
        $dbForm->commit(); ks_ke('penjualan.php?tab=detail&id='.$idInduk.'&hasil=berhasil');
    }
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['final_id'])) {
        ks_cek_token();
        $finalId=ks_id($_POST['final_id']);
        ks_call($dbForm,'CALL sp_finalisasi_transaksi(:jenis,:id)',[':jenis'=>'penjualan',':id'=>$finalId]);
        ks_ke('penjualan.php?tab=detail&id='.$finalId.'&hasil=final');
    }
    if (isset($_GET['induk']) && $_GET['induk'] !== '') $induk = ks_id($_GET['induk']);
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm,
            'SELECT * FROM `' . $namaTabelForm . '` WHERE `' . $pkForm . '` = :id',
            [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
        if ($tab === 'detail') $induk = (int)$nilaiForm[$fkDetail];
        $headerEdit=ks_satu($dbForm,'SELECT status FROM penjualan WHERE idpenjualan=:id',[':id'=>$tab==='detail'?$induk:$idEdit]);
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
                    $user = ks_id($f['iduser'] ?? '');
                    $margin = ks_id($f['idmargin_penjualan'] ?? '');
                    if ($aksi === 'baru') {
                        $cekMargin = ks_satu($db, 'SELECT status FROM margin_penjualan WHERE idmargin_penjualan = :id FOR UPDATE', [':id'=>$margin]);
                        if (!$cekMargin || (int)$cekMargin['status'] !== 1) throw new InvalidArgumentException('Penjualan baru hanya boleh memakai margin yang aktif.');
                        ks_jalankan($db, 'INSERT INTO penjualan (iduser, idmargin_penjualan, subtotal_nilai, ppn, total_nilai) VALUES (:user, :margin, 0, 0, 0)',
                            [':user'=>$user, ':margin'=>$margin]);
                    } else {
                        // Margin tidak diganti bila detail sudah ada supaya harga historis tidak menjadi rancu.
                        $lamaJual = ks_satu($db, 'SELECT idmargin_penjualan FROM penjualan WHERE idpenjualan = :id', [':id'=>$idEdit]);
                        $detailJual = ks_satu($db, 'SELECT COUNT(*) AS jumlah FROM detail_penjualan WHERE penjualan_idpenjualan = :id', [':id'=>$idEdit]);
                        if ($lamaJual && (int)$lamaJual['idmargin_penjualan'] !== $margin && (int)$detailJual['jumlah'] > 0) {
                            throw new InvalidArgumentException('Margin penjualan tidak dapat diganti setelah detail penjualan dibuat.');
                        }
                        if ($lamaJual && (int)$lamaJual['idmargin_penjualan'] !== $margin) {
                            $cekMargin = ks_satu($db, 'SELECT status FROM margin_penjualan WHERE idmargin_penjualan = :id FOR UPDATE', [':id'=>$margin]);
                            if (!$cekMargin || (int)$cekMargin['status'] !== 1) throw new InvalidArgumentException('Margin pengganti harus aktif.');
                        }
                        ks_jalankan($db, 'UPDATE penjualan SET iduser = :user, idmargin_penjualan = :margin WHERE idpenjualan = :id',
                            [':user'=>$user, ':margin'=>$margin, ':id'=>$idEdit]);
                    }
            } else {
                if ($induk === null) throw new InvalidArgumentException('Transaksi induk tidak ditemukan.');
                    $barang = ks_id($f['idbarang'] ?? '');
                    ks_aktif($db,'barang',$barang);
                    $jumlah = ks_int($f['jumlah'] ?? '', 'Jumlah dijual', 1);
                    $stokJual=ks_satu($db,'SELECT stok_tersedia FROM barang WHERE idbarang=:id',[':id'=>$barang]);
                    if ($jumlah>(int)$stokJual['stok_tersedia']) throw new InvalidArgumentException('Stok tidak mencukupi.');
                    $parameterHarga = ks_satu($db, 'SELECT b.harga, m.persen FROM barang b CROSS JOIN penjualan p JOIN margin_penjualan m ON m.idmargin_penjualan = p.idmargin_penjualan WHERE b.idbarang = :barang AND p.idpenjualan = :penjualan',
                        [':barang'=>$barang, ':penjualan'=>$induk]);
                    if (!$parameterHarga) throw new InvalidArgumentException('Barang atau margin penjualan tidak ditemukan.');
                    $lamaHarga=$aksi==='edit'?ks_satu($db,'SELECT idbarang,harga_satuan FROM detail_penjualan WHERE iddetail_penjualan=:id',[':id'=>$idEdit]):null;
                    $harga = $lamaHarga && (int)$lamaHarga['idbarang']===$barang ? (int)$lamaHarga['harga_satuan'] : (int) round((float) ks_jalankan($db, 'SELECT fn_harga_jual(:harga, :persen) AS harga_jual', [':harga'=>$parameterHarga['harga'], ':persen'=>$parameterHarga['persen']])->fetchColumn());
                    $sub = (int)ks_jalankan($db,'SELECT fn_subtotal(:jumlah,:harga)',[':jumlah'=>$jumlah,':harga'=>$harga])->fetchColumn();
                    if ($harga > 2147483647 || $sub > 2147483647) throw new InvalidArgumentException('Harga/subtotal melebihi kapasitas kolom INT.');
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO detail_penjualan (penjualan_idpenjualan, idbarang, harga_satuan, jumlah, subtotal) VALUES (:induk, :barang, :harga, :jumlah, :sub)',
                            [':induk'=>$induk, ':barang'=>$barang, ':harga'=>$harga, ':jumlah'=>$jumlah, ':sub'=>$sub]);
                    } else {
                        ks_jalankan($db, 'UPDATE detail_penjualan SET idbarang = :barang, harga_satuan = :harga, jumlah = :jumlah, subtotal = :sub WHERE iddetail_penjualan = :id',
                            [':barang'=>$barang, ':harga'=>$harga, ':jumlah'=>$jumlah, ':sub'=>$sub, ':id'=>$idEdit]);
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
            ks_ke('penjualan.php?tab=detail&aksi=baru&induk=' . $idHasil . '&hasil=induk');
        }
        $url = 'penjualan.php?tab=' . $tab . ($tab === 'detail' && $induk !== null ? '&id=' . $induk : '') . '&hasil=berhasil';
        ks_ke($url);
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'Penjualan';
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$id = isset($_GET['aksi']) ? ($tab === 'detail' && isset($induk) ? $induk : null) : filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
$data = [];
$error = '';

$kolomDaftar = [
        'status_transaksi' => 'Status',
        'idpenjualan' => 'ID Penjualan',
        'created_at' => 'Tanggal',
        'subtotal_nilai' => 'Subtotal',
        'ppn' => 'PPN',
        'total_nilai' => 'Total',
        'iduser' => 'ID User',
        'idmargin_penjualan' => 'ID Margin',
];
$kolomDetail = [
        'iddetail_penjualan' => 'ID Detail',
        'penjualan_idpenjualan' => 'ID Penjualan',
        'nama_barang' => 'Barang',
        'harga_satuan' => 'Harga Satuan',
        'jumlah' => 'Jumlah',
        'subtotal' => 'Subtotal',
];

try {
    $db = koneksi();
    if ($tab === 'detail') {
        // Detail ada dalam halaman transaksi, bukan dibuat menu terpisah.
        if ($id !== false && $id !== null && $id > 0) {
            $sql = 'SELECT d.*, (SELECT b.nama FROM barang b WHERE b.idbarang=d.idbarang) AS nama_barang, (SELECT h.status FROM penjualan h WHERE h.idpenjualan=d.penjualan_idpenjualan) AS status_induk FROM v_detail_penjualan d WHERE penjualan_idpenjualan = :id ORDER BY iddetail_penjualan DESC';
            $stmt = $db->prepare($sql);
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $data = $stmt->fetchAll();
        } else {
            $sql = 'SELECT d.*, (SELECT b.nama FROM barang b WHERE b.idbarang=d.idbarang) AS nama_barang, (SELECT h.status FROM penjualan h WHERE h.idpenjualan=d.penjualan_idpenjualan) AS status_induk FROM v_detail_penjualan d ORDER BY iddetail_penjualan DESC';
            $data = $db->query($sql)->fetchAll();
        }
    } else {
        $sql = 'SELECT * FROM v_penjualan ORDER BY idpenjualan DESC';
        $data = $db->query($sql)->fetchAll();
    }
} catch (PDOException $e) {
    $error = $e->getMessage();
}
$headerDetail=null; $verifikasi=[];
if (!$error && $tab==='detail' && $id) {
    try {
        $headerDetail=ks_satu($db,'SELECT * FROM penjualan WHERE idpenjualan=:id',[':id'=>$id]);
        
    } catch (Throwable $e) { $error=$e->getMessage(); }
}
if ($tab==='daftar') $data=ks_status_transaksi($data,'penjualan');
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data Penjualan</h1><a class="tombol" href="index.php">Kembali</a></div>
<nav class="tab" aria-label="Tab Penjualan">
    <a href="penjualan.php?tab=daftar" class="<?= $tab === 'daftar' ? 'aktif' : '' ?>">Daftar</a>
    <a href="penjualan.php?tab=detail" class="<?= $tab === 'detail' ? 'aktif' : '' ?>">Detail</a>
</nav>
<?php if (isset($_GET['hasil'])) ks_pesan($_GET['hasil'] === 'final' ? 'Transaksi berhasil dikonfirmasi.' : 'Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
<?php if ($tab === 'daftar'): ?>
    <a class="tombol" href="penjualan.php?tab=daftar&amp;aksi=baru">+ Tambah Penjualan</a>
<?php elseif ($headerDetail && (string)$headerDetail['status']==='0'): ?>
    <a class="tombol" href="penjualan.php?tab=detail&amp;aksi=baru&amp;induk=<?= (int)$id ?>">+ Tambah Detail</a>
<?php endif; ?>
<?php if ($aksi !== ''): ?>
    <a class="tombol" href="penjualan.php?tab=<?= aman($tab) ?><?= $tab === 'detail' && $induk !== null ? '&amp;id=' . (int)$induk : '' ?>">Batal</a>
<?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
<h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> <?= $tab === 'detail' ? 'Detail ' : '' ?>Penjualan</h2>
<form class="kelola-form" method="post" action="penjualan.php?tab=<?= aman($tab) ?>&amp;aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?><?= $induk !== null ? '&amp;induk=' . (int)$induk : '' ?>">
    <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
    <div class="kelola-grid">
    <?php foreach (($tab === 'detail' ? $fieldDetail : $fieldUtama) as $nama => $field):
        [$label, $tipe, $opsi] = $field;
        $pilihan = $tipe === 'select' ? $opsi : [];
        if ($tipe === 'ref') {
            if ('penjualan' === 'penerimaan' && $tab === 'detail' && $nama === 'barang_idbarang' && $induk !== null) {
                $asal = ks_satu($dbForm, 'SELECT idpengadaan FROM penerimaan WHERE idpenerimaan = :id', [':id'=>$induk]);
                $pilihan = [];
                if ($asal) foreach (ks_jalankan($dbForm, 'SELECT DISTINCT b.idbarang, b.nama FROM v_barang b JOIN detail_pengadaan d ON d.idbarang = b.idbarang WHERE d.idpengadaan = :id ORDER BY b.nama', [':id'=>$asal['idpengadaan']])->fetchAll() as $baris) $pilihan[$baris['idbarang']] = $baris['nama'];
            } elseif ('penjualan' === 'retur' && $tab === 'detail' && $nama === 'iddetail_penerimaan' && $induk !== null) {
                $pilihan = [];
                foreach (ks_jalankan($dbForm, 'SELECT d.iddetail_penerimaan, b.nama FROM detail_penerimaan d JOIN retur r ON r.idpenerimaan = d.idpenerimaan JOIN v_barang b ON b.idbarang = d.barang_idbarang WHERE r.idretur = :id ORDER BY d.iddetail_penerimaan', [':id'=>$induk])->fetchAll() as $baris) $pilihan[$baris['iddetail_penerimaan']] = '#' . $baris['iddetail_penerimaan'] . ' - ' . $baris['nama'];
            } elseif ('penjualan' === 'penjualan' && $tab === 'daftar' && $nama === 'idmargin_penjualan' && $aksi === 'baru') {
                $pilihan = [];
                foreach ($dbForm->query('SELECT idmargin_penjualan, persen FROM v_margin_penjualan WHERE status = 1 ORDER BY idmargin_penjualan')->fetchAll() as $m) $pilihan[(string)$m['idmargin_penjualan']] = $m['persen'] . '%';
            } else {
                if ($nama==='idbarang') $pilihan=ks_pilihan($dbForm, "SELECT idbarang, CONCAT(nama,' / Stok: ',stok_tersedia) AS nama FROM v_barang WHERE status=1 AND stok_tersedia>0 ORDER BY nama",'idbarang','nama'); else $pilihan = ks_ref($dbForm, $opsi);
            }
        }
        $awal = $nilaiForm[$nama] ?? ($nama === 'status' ? '0' : '');
        if ($tipe==='ref' && $awal!=='' && !isset($pilihan[$awal])) $pilihan[$awal]='#'.$awal.' (pilihan lama)';
        ks_form_field($nama, $label, $tipe === 'ref' ? 'select' : $tipe, $awal, $pilihan, true, is_int($opsi) ? $opsi : 100);
    endforeach; ?>
    </div>
    <button type="submit">Simpan</button>
    <a class="tombol" href="penjualan.php?tab=<?= aman($tab) ?>">Batal</a>
</form>
</section>
<?php endif; ?>
<?php if ($tab==='detail' && $headerDetail): ?>
<p><strong>Status:</strong> <?= aman(ks_status_transaksi([$headerDetail],'penjualan')[0]['status_transaksi']) ?></p>
<?php if ((string)$headerDetail['status']==='0' && $aksi===''): ks_final_form('penjualan',(int)$id,'Selesaikan Penjualan'); endif; ?>
<?php endif; ?>
<?php if ($tab === 'detail'): ?>
    <h2>Detail Penjualan<?= $id !== false && $id !== null && $id > 0 ? ' #' . (int) $id : '' ?></h2>
    <?php if ($id !== false && $id !== null && $id > 0): ?>
        <p><a href="penjualan.php?tab=detail">Tampilkan semua detail</a></p>
    <?php endif; ?>
<?php else: ?>
    <h2>Daftar Penjualan</h2>
<?php endif; ?>
<?php
if ($error !== '') {
    pesan_error($error);
} elseif ($tab === 'detail') {
    tampil_tabel($data, $kolomDetail, '', [['pk'=>'iddetail_penjualan', 'label'=>'Edit', 'draft'=>true, 'url'=>'penjualan.php?tab=detail&aksi=edit&id='], ['pk'=>'iddetail_penjualan','label'=>'Hapus','draft'=>true,'post'=>'hapus_detail','url'=>'penjualan.php?tab=detail']]);
} else {
    tampil_tabel($data, $kolomDaftar, 'idpenjualan', [['pk'=>'idpenjualan', 'label'=>'Edit', 'draft'=>true, 'url'=>'penjualan.php?tab=daftar&aksi=edit&id='], ['pk'=>'idpenjualan', 'label'=>'+ Detail', 'draft'=>true, 'url'=>'penjualan.php?tab=detail&aksi=baru&induk=']]);
}
require __DIR__ . '/includes/footer.php';
