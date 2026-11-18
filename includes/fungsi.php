<?php
require_once __DIR__ . '/../config/koneksi.php';

// Mencegah isi tabel menjadi kode HTML yang dijalankan browser.
function aman($isi): string
{
    return htmlspecialchars((string) ($isi ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// Format harga; kolom ppn tidak dianggap nominal karena aturannya belum ditentukan.
function tampil_nilai($namaKolom, $nilai): string
{
    if ($nilai === null) {
        return '-';
    }

    $kolomUang = [
        'harga', 'harga_satuan', 'harga_satuan_terima',
        'sub_total', 'sub_total_terima', 'subtotal',
        'subtotal_nilai', 'total_nilai', 'harga_jual'
    ];

    if (in_array($namaKolom, $kolomUang, true) && is_numeric($nilai)) {
        return 'Rp ' . number_format((float) $nilai, 0, ',', '.');
    }

    if ($namaKolom === 'status') {
        return (string)$nilai === '1' ? 'Aktif' : 'Tidak Aktif';
    }
    if ($namaKolom === 'status_transaksi') return aman($nilai);
    if ($namaKolom === 'jenis_transaksi') return $nilai === 'M' ? 'Masuk' : 'Keluar';
    if ($namaKolom === 'persen' && is_numeric($nilai)) {
        return aman($nilai) . '%';
    }

    return aman($nilai);
}

// Tabel sederhana untuk semua halaman. Kolom tetap ditentukan oleh setiap file PHP.
function tampil_tabel(array $data, array $kolom, string $kolomDetail = '', array $aksiLain = []): void
{
    if (count($data) === 0) {
        echo '<p class="kosong">Belum ada data untuk ditampilkan.</p>';
        return;
    }

    echo '<div class="area-tabel"><table><thead><tr>';
    foreach ($kolom as $judul) {
        echo '<th>' . aman($judul) . '</th>';
    }
    if ($kolomDetail !== '' || count($aksiLain) > 0) {
        echo '<th>Aksi</th>';
    }
    echo '</tr></thead><tbody>';

    foreach ($data as $baris) {
        echo '<tr>';
        foreach ($kolom as $namaKolom => $judul) {
            echo '<td>' . tampil_nilai($namaKolom, $baris[$namaKolom] ?? null) . '</td>';
        }
        if ($kolomDetail !== '' || count($aksiLain) > 0) {
            echo '<td class="aksi-tabel">';
            if ($kolomDetail !== '') {
                $id = (int) ($baris[$kolomDetail] ?? 0);
                echo '<a class="tombol-kecil" href="?tab=detail&amp;id=' . $id . '">Detail</a> ';
            }
            foreach ($aksiLain as $item) {
                if (!empty($item['draft']) && (string)($baris['status'] ?? $baris['status_induk'] ?? '') !== '0') continue;
                $idAksi = (int) ($baris[$item['pk']] ?? 0);
                if ($idAksi > 0) {
                    if (isset($item['post'])) {
                        echo '<form method="post" action="'.aman($item['url']).'" style="display:inline" onsubmit="return confirm(\'Hapus detail draft ini?\')"><input type="hidden" name="token" value="'.aman(ks_token()).'"><input type="hidden" name="'.aman($item['post']).'" value="'.$idAksi.'"><button class="tombol-kecil" type="submit">'.aman($item['label']).'</button></form> ';
                    } else {
                        $url = $item['url'] . $idAksi;
                        echo '<a class="tombol-kecil" href="' . aman($url) . '">' . aman($item['label']) . '</a> ';
                    }
                }
            }
            echo '</td>';
        }
        echo '</tr>';
    }
    echo '</tbody></table></div>';
}

function pesan_error(string $teks): void
{
    echo '<div class="pesan-error">Data belum bisa dibaca. Periksa MySQL Laragon, '
        . 'nama database, dan View yang dipakai.';
    echo '<details><summary>Lihat pesan error (untuk belajar di komputer lokal)</summary>'
        . '<pre>' . aman($teks) . '</pre></details></div>';
}

// Fungsi pendukung form input dan edit.
// Fungsi tambahan khusus halaman Tambah/Edit. Halaman lama tidak diubah.

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

function ks_token(): string
{
    if (!isset($_SESSION['ks_token'])) {
        $_SESSION['ks_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['ks_token'];
}

function ks_cek_token(): void
{
    $dikirim = $_POST['token'] ?? '';
    if (!is_string($dikirim) || !hash_equals(ks_token(), $dikirim)) {
        throw new RuntimeException('Form tidak valid. Muat ulang halaman, kemudian coba lagi.');
    }
}

function ks_ke(string $url): void
{
    header('Location: ' . $url, true, 303);
    exit;
}

function ks_id($nilai): int
{
    $nilai = (string) ($nilai ?? '');
    if (!preg_match('/^[1-9][0-9]*$/', $nilai) || strlen($nilai) > 18) {
        throw new InvalidArgumentException('ID tidak valid.');
    }
    $id = (int) $nilai;
    if ($id < 1) {
        throw new InvalidArgumentException('ID harus lebih dari 0.');
    }
    return $id;
}

function ks_int($nilai, string $nama, int $minimal = 0, int $maksimal = 2147483647): int
{
    $nilai = trim((string) ($nilai ?? ''));
    if (!preg_match('/^(0|[1-9][0-9]*)$/', $nilai) || strlen($nilai) > 10) {
        throw new InvalidArgumentException($nama . ' harus berupa bilangan bulat positif atau nol.');
    }
    $hasil = (int) $nilai;
    if ($hasil < $minimal || $hasil > $maksimal) {
        throw new InvalidArgumentException($nama . ' harus di antara ' . $minimal . ' dan ' . $maksimal . '.');
    }
    return $hasil;
}

function ks_teks($nilai, string $nama, int $maksimum, bool $wajib = true): string
{
    $hasil = trim((string) ($nilai ?? ''));
    $panjang = function_exists('mb_strlen') ? mb_strlen($hasil, 'UTF-8') : strlen($hasil);
    if (($wajib && $hasil === '') || $panjang > $maksimum) {
        throw new InvalidArgumentException($nama . ' wajib diisi dan maksimal ' . $maksimum . ' karakter.');
    }
    return $hasil;
}

function ks_persen($nilai): float
{
    $nilai = trim((string) ($nilai ?? ''));
    if (!preg_match('/^[0-9]+(?:\.[0-9]{1,2})?$/', $nilai)) {
        throw new InvalidArgumentException('Margin harus berupa angka, contoh: 10 atau 12.5.');
    }
    $angka = (float) $nilai;
    if ($angka < 0 || $angka > 100) {
        throw new InvalidArgumentException('Margin harus berada antara 0 sampai 100 persen.');
    }
    return $angka;
}

function ks_kode($nilai, array $pilihan, string $nama): string
{
    $nilai = (string) ($nilai ?? '');
    if (!array_key_exists($nilai, $pilihan)) {
        throw new InvalidArgumentException($nama . ' tidak dikenal.');
    }
    return $nilai;
}

function ks_jalankan(PDO $db, string $sql, array $parameter = []): PDOStatement
{
    // SQL ditulis langsung, tidak memakai Laravel atau Query Builder.
    $stmt = $db->prepare($sql);
    $stmt->execute($parameter);
    return $stmt;
}

function ks_satu(PDO $db, string $sql, array $parameter = []): ?array
{
    $baris = ks_jalankan($db, $sql, $parameter)->fetch();
    return $baris === false ? null : $baris;
}

function ks_pilihan(PDO $db, string $sql, string $kolomId, string $kolomLabel): array
{
    $hasil = [];
    foreach ($db->query($sql)->fetchAll() as $baris) {
        $hasil[(string) $baris[$kolomId]] = (string) $baris[$kolomLabel];
    }
    return $hasil;
}

function ks_ref(PDO $db, string $jenis): array
{
    // Semua query pilihan bersifat tetap, bukan berasal dari input pengguna.
    switch ($jenis) {
        case 'satuan': return ks_pilihan($db, 'SELECT idsatuan, nama_satuan FROM v_satuan WHERE status=1 ORDER BY idsatuan', 'idsatuan', 'nama_satuan');
        case 'role': return ks_pilihan($db, 'SELECT idrole, nama_role FROM v_role ORDER BY idrole', 'idrole', 'nama_role');
        case 'user': return ks_pilihan($db, 'SELECT iduser, username FROM v_user ORDER BY iduser', 'iduser', 'username');
        case 'vendor': return ks_pilihan($db, 'SELECT idvendor, nama_vendor FROM v_vendor WHERE status=1 ORDER BY idvendor', 'idvendor', 'nama_vendor');
        case 'barang': return ks_pilihan($db, 'SELECT idbarang, nama FROM v_barang WHERE status=1 ORDER BY nama', 'idbarang', 'nama');
        case 'margin': return ks_pilihan($db, "SELECT idmargin_penjualan, CONCAT(persen,'%') AS persen FROM v_margin_penjualan WHERE status=1 ORDER BY idmargin_penjualan", 'idmargin_penjualan', 'persen');
        case 'pengadaan': return ks_pilihan($db, "SELECT idpengadaan, CONCAT('#',idpengadaan,' - ',nama_vendor) AS nama_vendor FROM v_pengadaan WHERE status IN ('1','2') ORDER BY idpengadaan DESC", 'idpengadaan', 'nama_vendor');
        case 'penerimaan': return ks_pilihan($db, "SELECT idpenerimaan, CONCAT('#',idpenerimaan,' / Pengadaan #',idpengadaan) AS idpengadaan FROM v_penerimaan WHERE status='1' ORDER BY idpenerimaan DESC", 'idpenerimaan', 'idpengadaan');
        case 'penjualan': return ks_pilihan($db, 'SELECT idpenjualan, iduser FROM v_penjualan ORDER BY idpenjualan DESC', 'idpenjualan', 'iduser');
        case 'retur': return ks_pilihan($db, 'SELECT idretur, idpenerimaan FROM v_retur ORDER BY idretur DESC', 'idretur', 'idpenerimaan');
        case 'detail_penerimaan': return ks_pilihan($db, 'SELECT iddetail_penerimaan, barang_idbarang FROM v_detail_penerimaan ORDER BY iddetail_penerimaan DESC', 'iddetail_penerimaan', 'barang_idbarang');
        default: throw new InvalidArgumentException('Pilihan referensi tidak dikenal.');
    }
}

function ks_form_field(string $nama, string $label, string $tipe, $nilai, array $opsi = [], bool $required = true, int $max = 100): void
{
    $idHtml = 'field_' . $nama;
    echo '<div class="kelola-field"><label for="' . aman($idHtml) . '">' . aman($label) . '</label>';
    if ($tipe === 'select') {
        echo '<select id="' . aman($idHtml) . '" name="f[' . aman($nama) . ']" ' . ($required ? 'required' : '') . '>';
        echo '<option value="">-- Pilih --</option>';
        foreach ($opsi as $id => $teks) {
            $selected = (string) $nilai === (string) $id ? ' selected' : '';
            echo '<option value="' . aman($id) . '"' . $selected . '>' . aman($teks) . '</option>';
        }
        echo '</select>';
    } elseif ($tipe === 'textarea') {
        echo '<textarea id="' . aman($idHtml) . '" name="f[' . aman($nama) . ']" maxlength="' . $max . '" rows="3" ' . ($required ? 'required' : '') . '>' . aman($nilai) . '</textarea>';
    } else {
        $inputType = in_array($tipe, ['number', 'password'], true) ? $tipe : 'text';
        $attr = $tipe === 'number' ? ' min="0" step="1"' : ' maxlength="' . $max . '"';
        if ($nama === 'persen') $attr = ' min="0" max="100" step="0.01"';
        echo '<input id="' . aman($idHtml) . '" type="' . $inputType . '" name="f[' . aman($nama) . ']" value="' . ($tipe === 'password' ? '' : aman($nilai)) . '"' . $attr . ($required ? ' required' : '') . '>';
    }
    echo '</div>';
}

function ks_pesan(string $pesan, bool $error = false): void
{
    echo '<p class="' . ($error ? 'pesan-error' : 'hasil') . '">' . aman($pesan) . '</p>';
}

// Memperbarui total pada pengadaan dan penjualan setelah detail tersimpan.
function ks_perbarui_total(PDO $db, string $jenis, int $induk): void
{
    if ($jenis === 'pengadaan') {
        $cek = ks_satu($db, 'SELECT COALESCE(SUM(sub_total), 0) AS total FROM detail_pengadaan WHERE idpengadaan = :id', [':id'=>$induk]);
        if ((float)$cek['total'] > 2147483647) throw new InvalidArgumentException('Total pengadaan melebihi batas INT.');
        ks_jalankan($db,
            'UPDATE pengadaan SET
                subtotal_nilai = (SELECT COALESCE(SUM(sub_total), 0) FROM detail_pengadaan WHERE idpengadaan = :a),
                total_nilai = (SELECT COALESCE(SUM(sub_total), 0) FROM detail_pengadaan WHERE idpengadaan = :b) + ppn
             WHERE idpengadaan = :c', [':a'=>$induk, ':b'=>$induk, ':c'=>$induk]);
    } elseif ($jenis === 'penjualan') {
        $cek = ks_satu($db, 'SELECT COALESCE(SUM(subtotal), 0) AS total FROM detail_penjualan WHERE penjualan_idpenjualan = :id', [':id'=>$induk]);
        if ((float)$cek['total'] > 2147483647) throw new InvalidArgumentException('Total penjualan melebihi batas INT.');
        ks_jalankan($db,
            'UPDATE penjualan SET
                subtotal_nilai = (SELECT COALESCE(SUM(subtotal), 0) FROM detail_penjualan WHERE penjualan_idpenjualan = :a),
                total_nilai = (SELECT COALESCE(SUM(subtotal), 0) FROM detail_penjualan WHERE penjualan_idpenjualan = :b) + ppn
             WHERE idpenjualan = :c', [':a'=>$induk, ':b'=>$induk, ':c'=>$induk]);
    }
}



// Baca SP dan tutup seluruh result set agar koneksi bisa digunakan kembali.
function ks_call(PDO $db, string $sql, array $params=[]): array {
    $st=ks_jalankan($db,$sql,$params);
    $rows=$st->columnCount() ? $st->fetchAll() : [];
    $st->closeCursor();
    return $rows;
}
function ks_status_transaksi(array $data, string $jenis): array {
    $map=$jenis==='pengadaan' ? ['0'=>'Draft','1'=>'Dipesan','2'=>'Diterima Sebagian','3'=>'Selesai','4'=>'Ditutup'] : ['0'=>'Draft','1'=>'Selesai'];
    foreach ($data as &$b) $b['status_transaksi']=$map[(string)$b['status']] ?? 'Tidak diketahui';
    return $data;
}
function ks_aktif(PDO $db,string $tabel,int $id): void {
    $kolom=['barang'=>'idbarang','satuan'=>'idsatuan','vendor'=>'idvendor'];
    if (!isset($kolom[$tabel])) throw new InvalidArgumentException('Referensi tidak valid.');
    $b=ks_satu($db,"SELECT status FROM `$tabel` WHERE `{$kolom[$tabel]}`=:id",[':id'=>$id]);
    if (!$b || (string)$b['status']!=='1') throw new InvalidArgumentException(ucfirst($tabel).' tidak aktif.');
}
function ks_final_form(string $jenis,int $id,string $label): void {
    echo '<form method="post" onsubmit="return confirm(\'Konfirmasi transaksi? Data selesai tidak dapat diedit.\')" action="'.aman($jenis).'.php?tab=detail&amp;id='.$id.'" style="display:inline-block;margin:8px 0"><input type="hidden" name="token" value="'.aman(ks_token()).'"><input type="hidden" name="final_id" value="'.$id.'"><button type="submit">'.aman($label).'</button></form>';
}

// Semua perubahan detail harus mengunci induk draft dalam transaksi database.
function ks_kunci_draft(PDO $db, string $jenis, int $id): void {
    if (!$db->inTransaction()) throw new RuntimeException('Transaksi database belum dimulai.');
    if (!in_array($jenis,['pengadaan','penerimaan','penjualan','retur'],true)) throw new InvalidArgumentException('Jenis transaksi tidak valid.');
    $h=ks_satu($db,"SELECT status FROM `$jenis` WHERE `id$jenis`=:id FOR UPDATE",[':id'=>$id]);
    if (!$h || (string)$h['status']!=='0') throw new RuntimeException('Transaksi sudah dikonfirmasi atau tidak ditemukan.');
}
