<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form Tambah dan Edit Margin Penjualan langsung di halaman ini.
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$nilaiForm = [];
$errorForm = '';
$fieldForm = [
'persen' => ['Persentase Margin', 'number', 0],
'status' => ['Status', 'select', ['1' => 'Aktif', '0' => 'Tidak aktif']],
'iduser' => ['Dicatat oleh User', 'ref', 'user']
];

try {
    $dbForm = koneksi();
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm, 'SELECT * FROM `margin_penjualan` WHERE idmargin_penjualan = :id', [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        ks_cek_token();
        if ($aksi === '') throw new RuntimeException('Pilih Tambah atau Edit terlebih dahulu.');
        $f = is_array($_POST['f'] ?? null) ? $_POST['f'] : [];
        $nilaiForm = $f;
        $db = $dbForm;
        $id = $idEdit;
        $nilai = $nilaiForm;
                $persen = ks_persen($f['persen'] ?? '');
                $status = (int) ks_kode($f['status'] ?? '', ['1'=>1,'0'=>1], 'Status');
                $user = ks_id($f['iduser'] ?? '');
                // Saat mengaktifkan satu margin, nonaktifkan margin lain dalam satu transaction.
                $db->exec('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
                $db->beginTransaction();
                try {
                    if ($aksi === 'edit') {
                        $lama = ks_satu($db, 'SELECT persen FROM margin_penjualan WHERE idmargin_penjualan=:id FOR UPDATE', [':id'=>$idEdit]);
                        if (!$lama) throw new RuntimeException('Margin tidak ditemukan.');
                        if ((float)$lama['persen'] !== (float)$persen && ks_satu($db, 'SELECT idpenjualan FROM penjualan WHERE idmargin_penjualan=:id LIMIT 1 FOR UPDATE', [':id'=>$idEdit])) {
                            throw new InvalidArgumentException('Margin yang sudah dipakai tidak boleh diubah; buat margin baru.');
                        }
                    }
                    if ($aksi === 'edit' && (int) ($nilai['status'] ?? 0) === 0 && $status === 0) {
                        // Tidak membutuhkan aturan khusus.
                    }
                    if ($aksi === 'edit' && $status === 0) {
                        $cek = ks_satu($db, 'SELECT status FROM margin_penjualan WHERE idmargin_penjualan = :id', [':id'=>$idEdit]);
                        if ($cek && (int) $cek['status'] === 1) {
                            throw new InvalidArgumentException('Margin ini sedang aktif. Aktifkan margin lain dahulu agar selalu ada satu yang aktif.');
                        }
                    }
                    if ($aksi === 'baru') {
                        ks_jalankan($db, 'INSERT INTO margin_penjualan (persen, status, iduser, updated_at) VALUES (:persen, :status, :user, NOW())',
                            [':persen'=>$persen, ':status'=>0, ':user'=>$user]);
                        $idEdit=(int)$db->lastInsertId();
                    } else {
                        ks_jalankan($db, 'UPDATE margin_penjualan SET persen = :persen, iduser = :user, updated_at = NOW() WHERE idmargin_penjualan = :id',
                            [':persen'=>$persen, ':user'=>$user, ':id'=>$idEdit]);
                    }
                    if ($status===1) ks_call($db,'CALL sp_aktifkan_margin(:id,:user)',[':id'=>$idEdit,':user'=>$user]);
                    $db->commit();
                } catch (Throwable $e) {
                    if ($db->inTransaction()) $db->rollBack();
                    throw $e;
                }
        ks_ke('margin_penjualan.php?hasil=berhasil');
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'Margin Penjualan';
$data = [];
$error = '';

// Data diambil dari SQL View (materi Modul 8).
try {
    $sql = 'SELECT idmargin_penjualan, created_at, persen, status, iduser, updated_at FROM v_margin_penjualan ORDER BY idmargin_penjualan';
    $data = koneksi()->query($sql)->fetchAll();
} catch (PDOException $e) {
    $error = $e->getMessage();
}

$kolom = [
    'idmargin_penjualan' => 'ID Margin',
    'created_at' => 'Dibuat',
    'persen' => 'Persen',
    'status' => 'Status',
    'iduser' => 'ID User',
    'updated_at' => 'Diperbarui',
];
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data Margin Penjualan</h1><a class="tombol" href="index.php">Kembali</a></div>
<?php if (isset($_GET['hasil'])) ks_pesan('Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
    <a class="tombol" href="margin_penjualan.php?aksi=baru">+ Tambah Margin Penjualan</a>
    <?php if ($aksi !== ''): ?><a class="tombol" href="margin_penjualan.php">Batal</a><?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
    <h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> Margin Penjualan</h2>
    <form class="kelola-form" method="post" action="margin_penjualan.php?aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?>">
        <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
        <div class="kelola-grid">
        <?php foreach ($fieldForm as $nama => $field):
            [$label, $tipe, $opsi] = $field;
            $pilihan = $tipe === 'ref' ? ks_ref($dbForm, $opsi) : ($tipe === 'select' ? $opsi : []);
            $awal = $nilaiForm[$nama] ?? ($nama === 'status' ? '0' : '');
            if ($nama === 'password') $awal = '';
            $wajib = !($nama === 'password' && $aksi === 'edit');
            ks_form_field($nama, $label, $tipe === 'ref' ? 'select' : $tipe, $awal, $pilihan, $wajib, is_int($opsi) && $opsi > 0 ? $opsi : 100);
        endforeach; ?>
        </div>
        <button type="submit">Simpan</button>
        <a class="tombol" href="margin_penjualan.php">Batal</a>
    </form>
</section>
<?php endif; ?>

<?php
if ($error !== '') {
    pesan_error($error);
} else {
    tampil_tabel($data, $kolom, '', [['pk'=>'idmargin_penjualan', 'label'=>'Edit', 'url'=>'margin_penjualan.php?aksi=edit&id=']]);
}
require __DIR__ . '/includes/footer.php';
