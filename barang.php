
<?php
require_once __DIR__ . '/includes/fungsi.php';
// Form Tambah dan Edit Barang langsung di halaman ini.
$aksi = in_array($_GET['aksi'] ?? '', ['baru', 'edit'], true) ? $_GET['aksi'] : '';
$idEdit = null;
$nilaiForm = [];
$errorForm = '';
$fieldForm = [
'jenis' => ['Jenis Barang', 'select', ['1' => '1 - Makanan/Minuman', '2' => '2 - Nonmakanan']],
'nama' => ['Nama Barang', 'text', 45],
'idsatuan' => ['Satuan', 'ref', 'satuan'],
'status' => ['Status', 'select', ['1' => 'Aktif', '0' => 'Tidak aktif']],
'harga' => ['Harga Dasar (rupiah)', 'number', 0]
];

try {
    $dbForm = koneksi();
    if ($aksi === 'edit') {
        $idEdit = ks_id($_GET['id'] ?? '');
        $nilaiForm = ks_satu($dbForm, 'SELECT * FROM `barang` WHERE idbarang = :id', [':id' => $idEdit]) ?? [];
        if (!$nilaiForm) throw new RuntimeException('Data tidak ditemukan.');
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        ks_cek_token();
        if ($aksi === '') throw new RuntimeException('Pilih Tambah atau Edit terlebih dahulu.');
        $f = is_array($_POST['f'] ?? null) ? $_POST['f'] : [];
        $nilaiForm = $f;
        $db = $dbForm;
        $id = $idEdit;
                $jenis = ks_kode($f['jenis'] ?? '', ['1'=>1,'2'=>1], 'Jenis barang');
                $nama = ks_teks($f['nama'] ?? '', 'Nama barang', 45);
                $satuan = ks_id($f['idsatuan'] ?? '');
                $lamaBarang=$aksi==='edit'?ks_satu($db,'SELECT idsatuan FROM barang WHERE idbarang=:id',[':id'=>$idEdit]):null;
                if (!$lamaBarang || (int)$lamaBarang['idsatuan']!==$satuan) ks_aktif($db,'satuan',$satuan);
                if ($lamaBarang && (int)$lamaBarang['idsatuan']!==$satuan && ks_satu($db,'SELECT idbarang FROM kartu_stok WHERE idbarang=:id LIMIT 1',[':id'=>$idEdit])) throw new InvalidArgumentException('Satuan barang yang memiliki riwayat stok tidak dapat diganti.');
                $status = (int) ks_kode($f['status'] ?? '', ['1'=>1,'0'=>1], 'Status');
                $harga = ks_int($f['harga'] ?? '', 'Harga');
                if ($aksi === 'baru') {
                    ks_jalankan($db, 'INSERT INTO barang (jenis, nama, idsatuan, status, harga) VALUES (:jenis, :nama, :satuan, :status, :harga)',
                        [':jenis'=>$jenis, ':nama'=>$nama, ':satuan'=>$satuan, ':status'=>$status, ':harga'=>$harga]);
                } else {
                    ks_jalankan($db, 'UPDATE barang SET jenis = :jenis, nama = :nama, idsatuan = :satuan, status = :status, harga = :harga WHERE idbarang = :id',
                        [':jenis'=>$jenis, ':nama'=>$nama, ':satuan'=>$satuan, ':status'=>$status, ':harga'=>$harga, ':id'=>$idEdit]);
                }
        ks_ke('barang.php?hasil=berhasil');
    }
} catch (Throwable $e) {
    if (isset($dbForm) && $dbForm->inTransaction()) $dbForm->rollBack();
    $errorForm = $e->getMessage();
}



$judul = 'Barang';
$data = [];
$daftarSatuan = [];
$semuaBarang = [];
$error = '';
$hasilHitung = null;
$infoHarga = '';

$idSatuan = filter_input(INPUT_GET, 'satuan', FILTER_VALIDATE_INT);
$idBarang = filter_input(INPUT_GET, 'barang', FILTER_VALIDATE_INT);
$margin = filter_input(INPUT_GET, 'margin', FILTER_VALIDATE_FLOAT);

$kolom = [
    'idbarang' => 'ID Barang',
    'jenis' => 'Jenis',
    'nama' => 'Nama Barang',
    'nama_satuan' => 'Satuan',
    'status' => 'Status',
    'stok_tersedia' => 'Stok',
    'harga' => 'Harga'
];

try {
    // Menghubungkan PHP dengan database MySQL.
    $db = koneksi();

    // Mengambil daftar satuan dari View.
    $daftarSatuan = $db->query(
        'SELECT idsatuan, nama_satuan
         FROM v_satuan
         ORDER BY idsatuan'
    )->fetchAll();

    // Mengambil daftar barang untuk simulasi harga jual.
    $semuaBarang = $db->query(
        'SELECT idbarang, nama, harga
         FROM v_barang
         ORDER BY nama'
    )->fetchAll();

    // Menampilkan barang berdasarkan satuan yang dipilih.
    if ($idSatuan !== false && $idSatuan !== null && $idSatuan > 0) {

        // Filter menggunakan View, bukan Stored Procedure.
        $sql = 'SELECT idbarang, jenis, nama,
                       nama_satuan, status, harga, stok_tersedia
                FROM v_barang
                WHERE idsatuan = :id
                ORDER BY idbarang';

        $stmt = $db->prepare($sql);
        $stmt->bindValue(':id', $idSatuan, PDO::PARAM_INT);
        $stmt->execute();

        $data = $stmt->fetchAll();

    } else {

        // Menampilkan seluruh barang melalui View.
        $sql = 'SELECT idbarang, jenis, nama,
                       nama_satuan, status, harga, stok_tersedia
                FROM v_barang
                ORDER BY idbarang';

        $data = $db->query($sql)->fetchAll();
    }

    // Menghitung simulasi harga jual menggunakan Function.
    if (isset($_GET['hitung'])) {

        if (
            !$idBarang ||
            $idBarang < 1 ||
            $margin === false ||
            $margin === null ||
            $margin < 0 ||
            $margin > 100
        ) {

            $infoHarga = 'Pilih barang dan isi margin antara 0 sampai 100.';

        } else {

            // Mengambil harga barang yang dipilih.
            $stmtBarang = $db->prepare(
                'SELECT nama, harga
                 FROM v_barang
                 WHERE idbarang = :id'
            );

            $stmtBarang->bindValue(':id', $idBarang, PDO::PARAM_INT);
            $stmtBarang->execute();

            $barangPilihan = $stmtBarang->fetch();

            if (!$barangPilihan) {

                $infoHarga = 'Barang tidak ditemukan.';

            } else {

                // Function MySQL menghitung harga jual.
                $stmtHarga = $db->prepare(
                    'SELECT fn_harga_jual(:harga, :persen)
                     AS harga_jual'
                );

                $stmtHarga->execute([
                    ':harga' => $barangPilihan['harga'],
                    ':persen' => $margin
                ]);

                $hasilHitung = $stmtHarga->fetchColumn();
                $infoHarga = $barangPilihan['nama'];
            }
        }
    }

} catch (PDOException $e) {
    $error = $e->getMessage();
}

require __DIR__ . '/includes/header.php';
?>

<div class="atas-halaman">
    <h1>Data Barang</h1>
    <a class="tombol" href="index.php">Kembali</a>
</div>
<?php if (isset($_GET['hasil'])) ks_pesan('Data berhasil disimpan.'); ?>
<?php if ($errorForm !== '') ks_pesan($errorForm, true); ?>
<div class="baris-tindakan">
    <a class="tombol" href="barang.php?aksi=baru">+ Tambah Barang</a>
    <?php if ($aksi !== ''): ?><a class="tombol" href="barang.php">Batal</a><?php endif; ?>
</div>
<?php if ($aksi !== '' && $errorForm === ''): ?>
<section class="form-di-halaman" id="form-data">
    <h2><?= $aksi === 'baru' ? 'Tambah' : 'Edit' ?> Barang</h2>
    <form class="kelola-form" method="post" action="barang.php?aksi=<?= aman($aksi) ?><?= $idEdit !== null ? '&amp;id=' . (int)$idEdit : '' ?>">
        <input type="hidden" name="token" value="<?= aman(ks_token()) ?>">
        <div class="kelola-grid">
        <?php foreach ($fieldForm as $nama => $field):
            [$label, $tipe, $opsi] = $field;
            $pilihan = $tipe === 'ref' ? ks_ref($dbForm, $opsi) : ($tipe === 'select' ? $opsi : []);
            $awal = $nilaiForm[$nama] ?? ($nama === 'status' ? '1' : '');
            if ($nama==='idsatuan' && $awal!=='' && !isset($pilihan[$awal])) $pilihan[$awal]='Satuan #'.$awal.' (nonaktif)';
            if ($nama === 'password') $awal = '';
            $wajib = !($nama === 'password' && $aksi === 'edit');
            ks_form_field($nama, $label, $tipe === 'ref' ? 'select' : $tipe, $awal, $pilihan, $wajib, is_int($opsi) && $opsi > 0 ? $opsi : 100);
        endforeach; ?>
        </div>
        <button type="submit">Simpan</button>
        <a class="tombol" href="barang.php">Batal</a>
    </form>
</section>
<?php endif; ?>



<?php if ($error !== ''): ?>

    <?php pesan_error($error); ?>

<?php else: ?>

    <h2>1. Daftar Barang</h2>

    <form class="formulir" method="get" action="barang.php">

        <div>
            <label for="satuan">Filter Satuan Barang</label>

            <select name="satuan" id="satuan">

                <option value="">Semua Satuan</option>

                <?php foreach ($daftarSatuan as $satuan): ?>

                    <option
                        value="<?= (int) $satuan['idsatuan'] ?>"
                        <?= (int) $idSatuan === (int) $satuan['idsatuan'] ? 'selected' : '' ?>
                    >
                        <?= aman($satuan['nama_satuan']) ?>
                    </option>

                <?php endforeach; ?>

            </select>
        </div>

        <button type="submit">Tampilkan</button>

        <a class="tombol" href="barang.php">Reset</a>

    </form>

    <?php tampil_tabel($data, $kolom, '', [['pk'=>'idbarang', 'label'=>'Edit', 'url'=>'barang.php?aksi=edit&id=']]); ?>


    <h2>2. Hitung Harga Jual</h2>

    <p class="keterangan">
        Masukkan margin untuk menghitung harga jual.
    </p>

    <form class="formulir" method="get" action="barang.php">

        <div>
            <label for="barang">Pilih Barang</label>

            <select name="barang" id="barang" required>

                <option value="">Pilih Barang</option>

                <?php foreach ($semuaBarang as $b): ?>

                    <option
                        value="<?= (int) $b['idbarang'] ?>"
                        <?= (int) $idBarang === (int) $b['idbarang'] ? 'selected' : '' ?>
                    >
                        <?= aman($b['nama']) ?>
                    </option>

                <?php endforeach; ?>

            </select>
        </div>

        <div>
            <label for="margin">Margin (%)</label>

            <input
                type="number"
                name="margin"
                id="margin"
                min="0"
                max="100"
                step="0.1"
                value="<?= aman(isset($_GET['hitung']) && $margin !== false && $margin !== null ? $margin : 10) ?>"
                required
            >
        </div>

        <button type="submit" name="hitung" value="1">
            Hitung Harga Jual
        </button>

    </form>

    <?php if ($hasilHitung !== null): ?>

        <p class="hasil">
            Harga jual <?= aman($infoHarga) ?>:

            <strong>
                <?= tampil_nilai('harga_jual', $hasilHitung) ?>
            </strong>
        </p>

    <?php elseif (isset($_GET['hitung'])): ?>

        <p class="kosong">
            <?= aman($infoHarga) ?>
        </p>

    <?php endif; ?>

<?php endif; ?>

<?php require __DIR__ . '/includes/footer.php'; ?>
