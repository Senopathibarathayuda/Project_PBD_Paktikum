<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form Tambah dan Edit User langsung di halaman ini.
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$nilaiForm = [];
$errorForm = '';
$fieldForm = [
'username' => ['Username', 'text', 45],
'password' => ['Password (kosongkan saat edit jika tidak diganti)', 'password', 72],
'idrole' => ['Role', 'ref', 'role']
];

try {
    $dbForm = koneksi();
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm, 'SELECT * FROM `user` WHERE iduser = :id', [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        ks_cek_token();
        if ($aksi === '') throw new RuntimeException('Pilih Tambah atau Edit terlebih dahulu.');
        $f = is_array($_POST['f'] ?? null) ? $_POST['f'] : [];
        $nilaiForm = $f;
        $db = $dbForm;
        $id = $idEdit;
                $nama = ks_teks($f['username'] ?? '', 'Username', 45);
                $role = ks_id($f['idrole'] ?? '');
                $pass = (string) ($f['password'] ?? '');
                if ($aksi === 'baru' && strlen($pass) < 8) throw new InvalidArgumentException('Password baru minimal 8 karakter.');
                if ($pass !== '' && (strlen($pass) < 8 || strlen($pass) > 72)) throw new InvalidArgumentException('Password harus 8 sampai 72 karakter.');
                if ($aksi === 'baru') {
                    ks_jalankan($db, 'INSERT INTO `user` (username, password, idrole) VALUES (:nama, :pass, :role)',
                        [':nama'=>$nama, ':pass'=>password_hash($pass, PASSWORD_BCRYPT), ':role'=>$role]);
                } elseif ($pass !== '') {
                    ks_jalankan($db, 'UPDATE `user` SET username = :nama, password = :pass, idrole = :role WHERE iduser = :id',
                        [':nama'=>$nama, ':pass'=>password_hash($pass, PASSWORD_BCRYPT), ':role'=>$role, ':id'=>$idEdit]);
                } else {
                    ks_jalankan($db, 'UPDATE `user` SET username = :nama, idrole = :role WHERE iduser = :id',
                        [':nama'=>$nama, ':role'=>$role, ':id'=>$idEdit]);
                }
        ks_ke('user.php?hasil=berhasil');
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}


$judul = 'User';
$data = [];
$error = '';

// Data diambil dari SQL View (materi Modul 8).
try {
    $sql = 'SELECT iduser, username, idrole, nama_role FROM v_user ORDER BY iduser';
    $data = koneksi()->query($sql)->fetchAll();
} catch (PDOException $e) {
    $error = $e->getMessage();
}

$kolom = [
    'iduser' => 'ID User',
    'username' => 'Username',
    'idrole' => 'ID Role',
    'nama_role' => 'Nama Role',
];
require __DIR__ . '/includes/header.php';
?>
<div class="atas-halaman"><h1>Data User</h1><a class="tombol" href="index.php">Kembali</a></div>
<?php if (isset($_GET['hasil'])) ks_pesan('Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
    <a class="tombol" href="user.php?aksi=baru">+ Tambah User</a>
    <?php if ($aksi !== ''): ?><a class="tombol" href="user.php">Batal</a><?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
    <h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> User</h2>
    <form class="kelola-form" method="post" action="user.php?aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?>">
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
        <a class="tombol" href="user.php">Batal</a>
    </form>
</section>
<?php endif; ?>

<?php
if ($error !== '') {
    pesan_error($error);
} else {
    tampil_tabel($data, $kolom, '', [['pk'=>'iduser', 'label'=>'Edit', 'url'=>'user.php?aksi=edit&id=']]);
}
require __DIR__ . '/includes/footer.php';
