<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form Tambah dan Edit Satuan langsung di halaman ini.
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$nilaiForm = [];
$errorForm = '';
$fieldForm = [
'nama_satuan' => ['Nama Satuan', 'text', 45],
'status' => ['Status', 'select', ['1' => 'Aktif', '0' => 'Tidak aktif']]
];

try {
    $dbForm = koneksi();
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm, 'SELECT * FROM `satuan` WHERE idsatuan = :id', [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        ks_cek_token();
        if ($aksi === '') throw new RuntimeException('Pilih Tambah atau Edit terlebih dahulu.');
        $f = is_array($_POST['f'] ?? null) ? $_POST['f'] : [];
        $nilaiForm = $f;
        $db = $dbForm;
        $id = $idEdit;
                $nama = ks_teks($f['nama_satuan'] ?? '', 'Nama satuan', 45);
                $status = (int) ks_kode($f['status'] ?? '', ['1'=>1,'0'=>0], 'Status');
                if ($aksi === 'baru') {
                    ks_jalankan($db, 'INSERT INTO satuan (nama_satuan, status) VALUES (:nama, :status)', [':nama'=>$nama, ':status'=>$status]);
                } else {
                    ks_jalankan($db, 'UPDATE satuan SET nama_satuan = :nama, status = :status WHERE idsatuan = :id', [':nama'=>$nama, ':status'=>$status, ':id'=>$idEdit]);
                }
        ks_ke('satuan.php?hasil=berhasil');
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'Satuan';
$data = [];
$error = '';

// Data diambil dari SQL View
try {
    $sql = 'SELECT idsatuan, nama_satuan, status FROM v_satuan ORDER BY idsatuan';
    $data = koneksi()->query($sql)->fetchAll();
} catch (PDOException $e) {
    $error = $e->getMessage();
}

$kolom = [
    'idsatuan' => 'ID Satuan',
    'nama_satuan' => 'Nama Satuan',
    'status' => 'Status',
];
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data Satuan</h1><a class="tombol" href="index.php">Kembali</a></div>
<?php if (isset($_GET['hasil'])) ks_pesan('Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
    <a class="tombol" href="satuan.php?aksi=baru">+ Tambah Satuan</a>
    <?php if ($aksi !== ''): ?><a class="tombol" href="satuan.php">Batal</a><?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
    <h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> Satuan</h2>
    <form class="kelola-form" method="post" action="satuan.php?aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?>">
        <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
        <div class="kelola-grid">
        <?php foreach ($fieldForm as $nama => $field):
            [$label, $tipe, $opsi] = $field;
            $pilihan = $tipe === 'ref' ? ks_ref($dbForm, $opsi) : ($tipe === 'select' ? $opsi : []);
            $awal = $nilaiForm[$nama] ?? ($nama === 'status' ? '1' : '');
            if ($nama === 'password') $awal = '';
            $wajib = !($nama === 'password' && $aksi === 'edit');
            ks_form_field($nama, $label, $tipe === 'ref' ? 'select' : $tipe, $awal, $pilihan, $wajib, is_int($opsi) && $opsi > 0 ? $opsi : 100);
        endforeach; ?>
        </div>
        <button type="submit">Simpan</button>
        <a class="tombol" href="satuan.php">Batal</a>
    </form>
</section>
<?php endif; ?>

<?php
if ($error !== '') {
    pesan_error($error);
} else {
    tampil_tabel($data, $kolom, '', [['pk'=>'idsatuan', 'label'=>'Edit', 'url'=>'satuan.php?aksi=edit&id=']]);
}
require __DIR__ . '/includes/footer.php';
