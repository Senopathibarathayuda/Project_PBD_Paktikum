<?php
require_once __DIR__ . '/includes/fungsi.php';
$judul = 'Kartu Stok';

$data = [];
$stok = [];
$barang = [];
$error = '';

$idBarang = filter_input(INPUT_GET, 'barang', FILTER_VALIDATE_INT);

try {

    // Menghubungkan PHP dengan database MySQL.
    $db = koneksi();

    // Mengambil daftar barang dari View.
    $barang = $db->query(
        'SELECT idbarang, nama
         FROM v_barang
         ORDER BY nama'
    )->fetchAll();

    // Mengambil sisa stok terakhir setiap barang.
    // Nilai stock dihitung oleh Trigger ketika INSERT kartu_stok.
    // PHP hanya membaca hasil perhitungan tersebut.
    $sqlStok = 'SELECT b.idbarang, b.nama,
                      COALESCE(
                          (
                              SELECT k.stock
                              FROM v_kartu_stok k
                              WHERE k.idbarang = b.idbarang
                              ORDER BY k.idkartu_stok DESC
                              LIMIT 1
                          ), 0
                      ) AS sisa_stok
               FROM v_barang b
               ORDER BY b.nama';

    $stok = $db->query('SELECT idbarang,nama,stok_tersedia AS sisa_stok FROM v_barang ORDER BY nama')->fetchAll();
    $audit=ks_call($db,'CALL sp_audit_kartu_stok()');

    // Menampilkan riwayat berdasarkan barang yang dipilih.
    if (
        $idBarang !== false &&
        $idBarang !== null &&
        $idBarang > 0
    ) {

        // Stored Procedure dari Modul 9.
        $stmt = $db->prepare(
            'CALL sp_riwayat_stok_per_barang(:id)'
        );

        $stmt->bindValue(':id', $idBarang, PDO::PARAM_INT);
        $stmt->execute();

        $data = $stmt->fetchAll();
        $stmt->closeCursor();

    } else {

        // Menampilkan seluruh riwayat melalui View.
        $sql = 'SELECT idkartu_stok, idbarang,
                       jenis_transaksi, masuk, keluar,
                       stock, created_at, sumber_transaksi, idtransaksi
                FROM v_kartu_stok
                ORDER BY idkartu_stok DESC';

        $data = $db->query($sql)->fetchAll();
    }

} catch (PDOException $e) {

    $error = $e->getMessage();
}

require __DIR__ . '/includes/header.php';
?>

<div class="atas-halaman">
    <h1>Kartu Stok</h1>

    <a class="tombol" href="index.php">
        Kembali
    </a>
</div>




<?php if ($error !== ''): ?>

    <?php pesan_error($error); ?>

<?php else: ?>

    <h2>1. Sisa Stok Per Barang</h2>

    

    <?php
    tampil_tabel($stok, [
        'idbarang' => 'ID Barang',
        'nama' => 'Nama Barang',
        'sisa_stok' => 'Sisa Stok'
    ]);
    ?>

    


    <h2>2. Riwayat Kartu Stok</h2>

    

    <form
        class="formulir"
        method="get"
        action="kartu_stok.php"
    >

        <div>
            <label for="barang">
                Pilih Barang
            </label>

            <select name="barang" id="barang">

                <option value="">Semua Barang</option>

                <?php foreach ($barang as $b): ?>

                    <option
                        value="<?= (int) $b['idbarang'] ?>"
                        <?= (int) $idBarang === (int) $b['idbarang'] ? 'selected' : '' ?>
                    >
                        <?= aman($b['nama']) ?>
                    </option>

                <?php endforeach; ?>

            </select>
        </div>

        <button type="submit">
            Tampilkan
        </button>

        <a class="tombol" href="kartu_stok.php">
            Reset
        </a>

    </form>

    <?php
    tampil_tabel($data, [
        'idkartu_stok' => 'ID Kartu',
        'idbarang' => 'ID Barang',
        'jenis_transaksi' => 'Jenis',
        'sumber_transaksi' => 'Sumber',
        'idtransaksi' => 'ID Detail',
        'masuk' => 'Masuk',
        'keluar' => 'Keluar',
        'stock' => 'Sisa Stok',
        'created_at' => 'Tanggal'
    ]);
    ?>

<?php endif; ?>

<?php if (!$error): ?><details><summary>Audit Stok</summary><?php tampil_tabel($audit,['nama'=>'Barang','stok_tersedia'=>'Stok','stok_hitung'=>'Masuk - Keluar','stok_terakhir'=>'Catatan terakhir','hasil_audit'=>'Hasil']); ?></details><?php endif; ?>
<?php require __DIR__ . '/includes/footer.php'; ?>
