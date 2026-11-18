<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form transaksi dan detail berada langsung di halaman penerimaan.php.
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$induk = null;
$nilaiForm = [];
$errorForm = '';
$jenis = 'penerimaan';
$pkForm = $tab === 'detail' ? 'iddetail_penerimaan' : 'idpenerimaan';
$fkDetail = 'idpenerimaan';
$namaTabelForm = $tab === 'detail' ? 'detail_penerimaan' : 'penerimaan';
$fieldUtama = [
'idpengadaan' => ['Dari Pengadaan', 'ref', 'pengadaan'],
'iduser' => ['User Penerima', 'ref', 'user']
];
$fieldDetail = [
'barang_idbarang' => ['Barang yang Diterima', 'ref', 'barang'],
'jumlah_terima' => ['Jumlah Diterima', 'number', 0],
'harga_satuan_terima' => ['Harga Satuan Terima', 'number', 0]
];

try {
    $dbForm = koneksi();
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['final_id'])) {
        ks_cek_token();
        $finalId=ks_id($_POST['final_id']);
        ks_call($dbForm,'CALL sp_finalisasi_transaksi(:jenis,:id)',[':jenis'=>'penerimaan',':id'=>$finalId]);
        ks_ke('penerimaan.php?tab=detail&id='.$finalId.'&hasil=final');
    }
    if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['verifikasi_id'])) {
        ks_cek_token();
        $pid=ks_id($_POST['verifikasi_id']);
        $dbForm->exec('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
        $dbForm->beginTransaction();
        $hdr=ks_satu($dbForm,'SELECT * FROM penerimaan WHERE idpenerimaan=:id FOR UPDATE',[':id'=>$pid]);
        if (!$hdr || (string)$hdr['status']!=='0') throw new RuntimeException('Penerimaan sudah dikonfirmasi.');
        $rows=ks_call($dbForm,'CALL sp_verifikasi_penerimaan(:id)',[':id'=>$hdr['idpengadaan']]);
        $input=$_POST['terima']??[]; $hargaInput=$_POST['harga']??[];
        foreach ($rows as $row) {
            $bid=(int)$row['idbarang'];
            if ((int)$row['sisa']<=0 && !array_key_exists($bid,$input)) continue;
            $q=ks_int($input[$bid]??'', 'Jumlah diterima',0,max(0,(int)$row['sisa']));
            $h=ks_int($hargaInput[$bid]??'', 'Harga terima');
            $sub=(int)ks_jalankan($dbForm,'SELECT fn_subtotal(:q,:h)',[':q'=>$q,':h'=>$h])->fetchColumn();
            if ($sub>2147483647) throw new RuntimeException('Subtotal melebihi batas INT.');
            $old=ks_satu($dbForm,'SELECT iddetail_penerimaan FROM detail_penerimaan WHERE idpenerimaan=:p AND barang_idbarang=:b',[':p'=>$pid,':b'=>$bid]);
            if ($old) ks_jalankan($dbForm,'UPDATE detail_penerimaan SET jumlah_terima=:q,harga_satuan_terima=:h,sub_total_terima=:s WHERE iddetail_penerimaan=:id',[':q'=>$q,':h'=>$h,':s'=>$sub,':id'=>$old['iddetail_penerimaan']]);
            else ks_jalankan($dbForm,'INSERT INTO detail_penerimaan (idpenerimaan,barang_idbarang,jumlah_terima,harga_satuan_terima,sub_total_terima) VALUES (:p,:b,:q,:h,:s)',[':p'=>$pid,':b'=>$bid,':q'=>$q,':h'=>$h,':s'=>$sub]);
        }
        $dbForm->commit();
        ks_ke('penerimaan.php?tab=detail&id='.$pid.'&hasil=berhasil');
    }
    if (isset($_GET['induk']) && $_GET['induk'] !== '') $induk = ks_id($_GET['induk']);
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm,
            'SELECT * FROM `' . $namaTabelForm . '` WHERE `' . $pkForm . '` = :id',
            [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
        if ($tab === 'detail') $induk = (int)$nilaiForm[$fkDetail];
        $headerEdit=ks_satu($dbForm,'SELECT status FROM penerimaan WHERE idpenerimaan=:id',[':id'=>$tab==='detail'?$induk:$idEdit]);
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
                    $pengadaan = ks_id($f['idpengadaan'] ?? '');
                    $pesananAktif=ks_satu($db,'SELECT status FROM pengadaan WHERE idpengadaan=:id',[':id'=>$pengadaan]);
                    if (!$pesananAktif || !in_array((string)$pesananAktif['status'],['1','2'],true)) throw new InvalidArgumentException('Pengadaan belum dipesan atau sudah selesai.');
                    $user = ks_id($f['iduser'] ?? '');
                    $status = '0';
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO penerimaan (idpengadaan, iduser, status) VALUES (:pengadaan, :user, :status)',
                            [':pengadaan'=>$pengadaan, ':user'=>$user, ':status'=>$status]);
                    } else {
                        // Pengadaan induk tidak boleh diganti jika sudah ada detail penerimaan.
                        $lama = ks_satu($db, 'SELECT idpengadaan FROM penerimaan WHERE idpenerimaan = :id', [':id'=>$idEdit]);
                        $ada = ks_satu($db, 'SELECT COUNT(*) AS jumlah FROM detail_penerimaan WHERE idpenerimaan = :id', [':id'=>$idEdit]);
                        if ($lama && (int)$lama['idpengadaan'] !== $pengadaan && (int)$ada['jumlah'] > 0) {
                            throw new InvalidArgumentException('Pengadaan induk tidak boleh diganti karena penerimaan sudah mempunyai detail.');
                        }
                        ks_jalankan($db, 'UPDATE penerimaan SET idpengadaan = :pengadaan, iduser = :user, status = :status WHERE idpenerimaan = :id',
                            [':pengadaan'=>$pengadaan, ':user'=>$user, ':status'=>$status, ':id'=>$idEdit]);
                    }
            } else {
                if ($induk === null) throw new InvalidArgumentException('Transaksi induk tidak ditemukan.');
                    $barang = ks_id($f['barang_idbarang'] ?? '');
                    $jumlah = ks_int($f['jumlah_terima'] ?? '', 'Jumlah diterima', 0);
                    $harga = ks_int($f['harga_satuan_terima'] ?? '', 'Harga satuan terima');
                    $sub = (int)ks_jalankan($db,'SELECT fn_subtotal(:jumlah,:harga)',[':jumlah'=>$jumlah,':harga'=>$harga])->fetchColumn();
                    if ($sub > 2147483647) throw new InvalidArgumentException('Subtotal melebihi kapasitas kolom INT.');
                    $indukInfo = ks_satu($db, 'SELECT idpengadaan FROM penerimaan WHERE idpenerimaan = :id', [':id'=>$induk]);
                    if (!$indukInfo) throw new InvalidArgumentException('Penerimaan induk tidak ditemukan.');
                    $pesanan = ks_satu($db, 'SELECT COALESCE(SUM(jumlah),0) AS jumlah FROM detail_pengadaan WHERE idpengadaan = :pengadaan AND idbarang = :barang',
                        [':pengadaan'=>$indukInfo['idpengadaan'], ':barang'=>$barang]);
                    if ((int)$pesanan['jumlah'] === 0) throw new InvalidArgumentException('Barang harus termasuk dalam detail pengadaan yang diterima.');
                    $sudah = ks_satu($db, 'SELECT COALESCE(SUM(dp.jumlah_terima),0) AS jumlah FROM detail_penerimaan dp JOIN penerimaan p ON dp.idpenerimaan = p.idpenerimaan WHERE p.idpengadaan = :pengadaan AND dp.barang_idbarang = :barang AND dp.iddetail_penerimaan <> :id AND (p.status=1 OR p.idpenerimaan=:draft)',
                        [':pengadaan'=>$indukInfo['idpengadaan'], ':barang'=>$barang, ':id'=>$aksi==='edit' ? $idEdit : 0, ':draft'=>$induk]);
                    if ((int)$sudah['jumlah'] + $jumlah > (int)$pesanan['jumlah']) throw new InvalidArgumentException('Jumlah diterima melebihi jumlah pengadaan untuk barang tersebut.');
                    if ($aksi === 'edit') {
                        $sudahDiretur = ks_satu($db, 'SELECT COALESCE(SUM(jumlah),0) AS jumlah FROM detail_retur WHERE iddetail_penerimaan = :id', [':id'=>$idEdit]);
                        $barangLama = ks_satu($db, 'SELECT barang_idbarang FROM detail_penerimaan WHERE iddetail_penerimaan = :id', [':id'=>$idEdit]);
                        if ((int)$sudahDiretur['jumlah'] > $jumlah) throw new InvalidArgumentException('Jumlah diterima tidak boleh kurang dari jumlah yang sudah diretur.');
                        if ($barangLama && (int)$barangLama['barang_idbarang'] !== $barang && (int)$sudahDiretur['jumlah'] > 0) {
                            throw new InvalidArgumentException('Barang penerimaan tidak boleh diganti setelah detailnya diretur.');
                        }
                    }
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO detail_penerimaan (idpenerimaan, barang_idbarang, jumlah_terima, harga_satuan_terima, sub_total_terima) VALUES (:induk, :barang, :jumlah, :harga, :sub)',
                            [':induk'=>$induk, ':barang'=>$barang, ':jumlah'=>$jumlah, ':harga'=>$harga, ':sub'=>$sub]);
                    } else {
                        ks_jalankan($db, 'UPDATE detail_penerimaan SET barang_idbarang = :barang, jumlah_terima = :jumlah, harga_satuan_terima = :harga, sub_total_terima = :sub WHERE iddetail_penerimaan = :id',
                            [':barang'=>$barang, ':jumlah'=>$jumlah, ':harga'=>$harga, ':sub'=>$sub, ':id'=>$idEdit]);
                    }
            }
            $idHasil = $aksi === 'baru' ? (int)$db->lastInsertId() : (int)$idEdit;
            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            throw $e;
        }
        if ($tab === 'daftar' && $aksi === 'baru') {
            ks_ke('penerimaan.php?tab=detail&id=' . $idHasil . '&hasil=induk');
        }
        $url = 'penerimaan.php?tab=' . $tab . ($tab === 'detail' && $induk !== null ? '&id=' . $induk : '') . '&hasil=berhasil';
        ks_ke($url);
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'Penerimaan';
$tab = ($_GET['tab'] ?? 'daftar') === 'detail' ? 'detail' : 'daftar';
$id = isset($_GET['aksi']) ? ($tab === 'detail' && isset($induk) ? $induk : null) : filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
$data = [];
$error = '';

$kolomDaftar = [
        'idpenerimaan' => 'ID Penerimaan',
        'created_at' => 'Tanggal',
        'status_transaksi' => 'Status',
        'idpengadaan' => 'ID Pengadaan',
        'iduser' => 'ID User',
];
$kolomDetail = [
        'nama_barang' => 'Barang',
        'iddetail_penerimaan' => 'ID Detail',
        'idpenerimaan' => 'ID Penerimaan',
        'jumlah_terima' => 'Jumlah Terima',
        'hasil_pengiriman' => 'Pemeriksaan',
        'harga_satuan_terima' => 'Harga Satuan',
        'sub_total_terima' => 'Subtotal',
];

try {
    $db = koneksi();
    if ($tab === 'detail') {
        // Detail ada dalam halaman transaksi, bukan dibuat menu terpisah.
        if ($id !== false && $id !== null && $id > 0) {
            $sql = 'SELECT d.*, (SELECT b.nama FROM barang b WHERE b.idbarang=d.barang_idbarang) AS nama_barang, (SELECT h.status FROM penerimaan h WHERE h.idpenerimaan=d.idpenerimaan) AS status_induk FROM v_detail_penerimaan d WHERE idpenerimaan = :id ORDER BY iddetail_penerimaan DESC';
            $stmt = $db->prepare($sql);
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $data = $stmt->fetchAll();
        } else {
            $sql = 'SELECT d.*, (SELECT b.nama FROM barang b WHERE b.idbarang=d.barang_idbarang) AS nama_barang, (SELECT h.status FROM penerimaan h WHERE h.idpenerimaan=d.idpenerimaan) AS status_induk FROM v_detail_penerimaan d ORDER BY iddetail_penerimaan DESC';
            $data = $db->query($sql)->fetchAll();
        }
    } else {
        $sql = 'SELECT * FROM v_penerimaan ORDER BY idpenerimaan DESC';
        $data = $db->query($sql)->fetchAll();
    }
} catch (PDOException $e) {
    $error = $e->getMessage();
}
$headerDetail=null; $verifikasi=[];
if (!$error && $tab==='detail' && $id) {
    try {
        $headerDetail=ks_satu($db,'SELECT * FROM penerimaan WHERE idpenerimaan=:id',[':id'=>$id]);
        if ($headerDetail) $verifikasi=ks_call($db,'CALL sp_verifikasi_penerimaan(:id)',[':id'=>$headerDetail['idpengadaan']]);
    } catch (Throwable $e) { $error=$e->getMessage(); }
}
if ($tab==='daftar') $data=ks_status_transaksi($data,'penerimaan'); else foreach($data as &$row) $row['hasil_pengiriman']=(int)$row['jumlah_terima']===0?'Tidak datang':'Datang'; unset($row);
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data Penerimaan</h1><a class="tombol" href="index.php">Kembali</a></div>
<nav class="tab" aria-label="Tab Penerimaan">
    <a href="penerimaan.php?tab=daftar" class="<?= $tab === 'daftar' ? 'aktif' : '' ?>">Daftar</a>
    <a href="penerimaan.php?tab=detail" class="<?= $tab === 'detail' ? 'aktif' : '' ?>">Detail</a>
</nav>
<?php if (isset($_GET['hasil'])) ks_pesan($_GET['hasil'] === 'final' ? 'Transaksi berhasil dikonfirmasi.' : 'Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
<?php if ($tab === 'daftar'): ?>
    <a class="tombol" href="penerimaan.php?tab=daftar&amp;aksi=baru">+ Tambah Penerimaan</a>
<?php elseif (false): ?>
    <a class="tombol" href="penerimaan.php?tab=detail&amp;aksi=baru&amp;induk=<?= (int)$id ?>">+ Tambah Detail</a>
<?php endif; ?>
<?php if ($aksi !== ''): ?>
    <a class="tombol" href="penerimaan.php?tab=<?= aman($tab) ?><?= $tab === 'detail' && $induk !== null ? '&amp;id=' . (int)$induk : '' ?>">Batal</a>
<?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
<h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> <?= $tab === 'detail' ? 'Detail ' : '' ?>Penerimaan</h2>
<form class="kelola-form" method="post" action="penerimaan.php?tab=<?= aman($tab) ?>&amp;aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?><?= $induk !== null ? '&amp;induk=' . (int)$induk : '' ?>">
    <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
    <div class="kelola-grid">
    <?php foreach (($tab === 'detail' ? $fieldDetail : $fieldUtama) as $nama => $field):
        [$label, $tipe, $opsi] = $field;
        $pilihan = $tipe === 'select' ? $opsi : [];
        if ($tipe === 'ref') {
            if ('penerimaan' === 'penerimaan' && $tab === 'detail' && $nama === 'barang_idbarang' && $induk !== null) {
                $asal = ks_satu($dbForm, 'SELECT idpengadaan FROM penerimaan WHERE idpenerimaan = :id', [':id'=>$induk]);
                $pilihan = [];
                if ($asal) foreach (ks_jalankan($dbForm, 'SELECT DISTINCT b.idbarang, b.nama FROM v_barang b JOIN detail_pengadaan d ON d.idbarang = b.idbarang WHERE d.idpengadaan = :id ORDER BY b.nama', [':id'=>$asal['idpengadaan']])->fetchAll() as $baris) $pilihan[$baris['idbarang']] = $baris['nama'];
            } elseif ('penerimaan' === 'retur' && $tab === 'detail' && $nama === 'iddetail_penerimaan' && $induk !== null) {
                $pilihan = [];
                foreach (ks_jalankan($dbForm, 'SELECT d.iddetail_penerimaan, b.nama FROM detail_penerimaan d JOIN retur r ON r.idpenerimaan = d.idpenerimaan JOIN v_barang b ON b.idbarang = d.barang_idbarang WHERE r.idretur = :id ORDER BY d.iddetail_penerimaan', [':id'=>$induk])->fetchAll() as $baris) $pilihan[$baris['iddetail_penerimaan']] = '#' . $baris['iddetail_penerimaan'] . ' - ' . $baris['nama'];
            } elseif ('penerimaan' === 'penjualan' && $tab === 'daftar' && $nama === 'idmargin_penjualan' && $aksi === 'baru') {
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
    <a class="tombol" href="penerimaan.php?tab=<?= aman($tab) ?>">Batal</a>
</form>
</section>
<?php endif; ?>
<?php if ($tab==='detail' && $headerDetail): ?>
<p><strong>Status:</strong> <?= aman(ks_status_transaksi([$headerDetail],'penerimaan')[0]['status_transaksi']) ?></p>

<?php endif; ?>
<?php if ($headerDetail && (string)$headerDetail['status']==='0' && $aksi===''): ?>
<section class="form-di-halaman"><h2>Verifikasi Barang</h2>
<form method="post" action="penerimaan.php?tab=detail&amp;id=<?= (int)$id ?>">
<input type="hidden" name="token" value="<?= aman(ks_token()) ?>"><input type="hidden" name="verifikasi_id" value="<?= (int)$id ?>">
<div class="area-tabel"><table><thead><tr><th>Barang</th><th>Dipesan</th><th>Diterima sebelumnya</th><th>Sisa</th><th>Datang sekarang (0 jika tidak datang)</th><th>Harga terima</th><th>Pemeriksaan</th></tr></thead><tbody>
<?php $saved=[]; foreach($data as $d) $saved[$d['barang_idbarang']]=$d; foreach($verifikasi as $v): $b=(int)$v['idbarang']; $d=$saved[$b]??null; ?>
<tr><td><?= aman($v['nama_barang']) ?></td><td><?= aman($v['dipesan']) ?></td><td><?= aman($v['diterima']) ?></td><td><?= aman($v['sisa']) ?></td>
<?php if ((int)$v['sisa']>0 || $d): ?>
<td><input type="number" name="terima[<?= $b ?>]" min="0" max="<?= max(0,(int)$v['sisa']) ?>" value="<?= aman($d['jumlah_terima']??'') ?>" required></td>
<td><input type="number" name="harga[<?= $b ?>]" min="0" max="2147483647" value="<?= aman($d['harga_satuan_terima']??$v['harga_satuan']) ?>" required></td>
<td><?= !$d?'Belum diperiksa':((int)$d['jumlah_terima']===0?'Tidak datang':((int)$d['jumlah_terima']===(int)$v['sisa']?'Lengkap':'Sebagian')) ?></td>
<?php else: ?><td>—</td><td>—</td><td>Sudah lengkap</td><?php endif; ?></tr><?php endforeach; ?></tbody></table></div><button type="submit">Simpan Pemeriksaan</button></form>
<?php $lengkapPeriksa=true; foreach($verifikasi as $v) if ((int)$v['sisa']>0 && !isset($saved[$v['idbarang']])) $lengkapPeriksa=false; ?>
<?php if ($lengkapPeriksa && count($saved)>0): ks_final_form('penerimaan',(int)$id,'Konfirmasi Pemeriksaan Tersimpan'); endif; ?>
</section>
<?php endif; ?>
<?php if ($tab === 'detail'): ?>
    <h2>Detail Penerimaan<?= $id !== false && $id !== null && $id > 0 ? ' #' . (int) $id : '' ?></h2>
    <?php if ($id !== false && $id !== null && $id > 0): ?>
        <p><a href="penerimaan.php?tab=detail">Tampilkan semua detail</a></p>
    <?php endif; ?>
<?php else: ?>
    <h2>Daftar Penerimaan</h2>
<?php endif; ?>
<?php
if ($error !== '') {
    pesan_error($error);
} elseif ($tab === 'detail') {
    tampil_tabel($data, $kolomDetail);
} else {
    tampil_tabel($data, $kolomDaftar, 'idpenerimaan', [['pk'=>'idpenerimaan', 'label'=>'Edit', 'draft'=>true, 'url'=>'penerimaan.php?tab=daftar&aksi=edit&id=']]);
}
require __DIR__ . '/includes/footer.php';
