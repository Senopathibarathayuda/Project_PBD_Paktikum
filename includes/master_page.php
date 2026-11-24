<?php
require_once __DIR__ . '/bootstrap.php';
$masters = [
    'barang' => [
        'title' => 'Barang', 'desc' => 'Daftar produk dan saldo stok saat ini.',
        'table' => 'barang', 'view' => 'v_barang', 'pk' => 'idbarang',
        'fields' => ['nama' => 'Nama barang', 'jenis' => 'Kategori', 'idsatuan' => 'Satuan', 'harga' => 'Harga modal', 'status' => 'Status'],
        'columns' => ['idbarang' => 'ID', 'nama' => 'Nama barang', 'jenis' => 'Kategori', 'nama_satuan' => 'Satuan', 'harga' => 'Harga modal', 'stok_tersedia' => 'Stok', 'status_label' => 'Status'],
        'status' => true,
    ],
    'satuan' => [
        'title' => 'Satuan', 'desc' => 'Satuan ukuran untuk setiap barang.',
        'table' => 'satuan', 'view' => 'v_satuan', 'pk' => 'idsatuan',
        'fields' => ['nama_satuan' => 'Nama satuan', 'status' => 'Status'],
        'columns' => ['idsatuan' => 'ID', 'nama_satuan' => 'Nama satuan', 'status_label' => 'Status'],
        'status' => true,
    ],
    'vendor' => [
        'title' => 'Vendor', 'desc' => 'Pemasok yang bisa dipilih pada pengadaan.',
        'table' => 'vendor', 'view' => 'v_vendor', 'pk' => 'idvendor',
        'fields' => ['nama_vendor' => 'Nama vendor', 'badan_hukum' => 'Badan hukum', 'status' => 'Status'],
        'columns' => ['idvendor' => 'ID', 'nama_vendor' => 'Nama vendor', 'badan_hukum' => 'Badan hukum', 'status_label' => 'Status'],
        'status' => true,
    ],
    'role' => [
        'title' => 'Role', 'desc' => 'Jenis peran pengguna sistem.',
        'table' => '`role`', 'view' => 'v_role', 'pk' => 'idrole',
        'fields' => ['nama_role' => 'Nama role', 'status' => 'Status'],
        'columns' => ['idrole' => 'ID', 'nama_role' => 'Nama role', 'status_label' => 'Status'],
        'status' => true,
    ],
    'user' => [
        'title' => 'Pengguna', 'desc' => 'Akun login dengan role yang ditetapkan.',
        'table' => '`user`', 'view' => 'v_user', 'pk' => 'iduser',
        'fields' => ['username' => 'Username', 'idrole' => 'Role', 'password' => 'Kata sandi', 'status' => 'Status'],
        'columns' => ['iduser' => 'ID', 'username' => 'Username', 'nama_role' => 'Role', 'status_label' => 'Status'],
        'status' => true,
    ],
];
if (!isset($masters[$masterKey ?? ''])) exit('Halaman tidak dikenal.');
$c = $masters[$masterKey];
wajib_izin($masterKey);
$canWrite = izin($masterKey, true);
$halaman = $masterKey;
$judul = $c['title'];
$subjudul = $c['desc'];
$self = $masterKey . '.php';
$pk = $c['pk'];
$table = $c['table'];

function master_validasi(string $name, $value, bool $isEdit): ?string
{
    if ($name === 'password') {
        if ($value === '' && $isEdit) return null;
        if (strlen((string)$value) < 8) throw new RuntimeException('Kata sandi minimal 8 karakter.');
        return password_hash((string)$value, PASSWORD_DEFAULT);
    }
    if (in_array($name, ['idsatuan', 'idrole'], true)) return (string)nilai_int($value, 1);
    if ($name === 'harga') return (string)nilai_uang($value);
    if ($name === 'jenis') return pilih((string)$value, ['1', '2']);
    if ($name === 'badan_hukum') return pilih((string)$value, ['Y', 'N']);
    if ($name === 'status') return pilih((string)$value, ['0', '1']);
    $text = trim((string)$value);
    if ($text === '' || panjang_teks($text) > 100) throw new RuntimeException('Kolom ' . $name . ' harus diisi dengan benar.');
    if ($name === 'nama' && panjang_teks($text) > 45) throw new RuntimeException('Nama barang maksimal 45 karakter.');
    if ($name === 'nama_satuan' && panjang_teks($text) > 45) throw new RuntimeException('Nama satuan maksimal 45 karakter.');
    if ($name === 'username' && panjang_teks($text) > 45) throw new RuntimeException('Username maksimal 45 karakter.');
    if ($name === 'nama_role' && !in_array(strtolower($text), ['super admin', 'manager', 'petugas gudang', 'kasir'], true)) {
        throw new RuntimeException('Role aplikasi hanya mendukung Super Admin, Manager, Petugas Gudang, dan Kasir.');
    }
    return $text;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        wajib_izin($masterKey, true);
        validasi_csrf();
        $action = (string)($_POST['action'] ?? '');
        $id = isset($_POST['id']) ? nilai_int($_POST['id'], 0) : 0;
        if ($action === 'save') {
            $isEdit = $id > 0;
            if ($isEdit && !db_one("SELECT {$pk} FROM {$table} WHERE {$pk} = ?", [$id])) throw new RuntimeException('Data tidak ditemukan.');
            $data = [];
            foreach ($c['fields'] as $name => $label) {
                $val = master_validasi($name, $_POST[$name] ?? '', $isEdit);
                if ($val !== null) $data[$name] = $val;
            }
            if ($masterKey === 'role' && $isEdit) {
                $old = db_one('SELECT nama_role FROM `role` WHERE idrole = ?', [$id]);
                if ($old && strtolower((string)$old['nama_role']) !== strtolower((string)$data['nama_role'])) {
                    throw new RuntimeException('Nama role tidak dapat diubah karena digunakan untuk aturan akses aplikasi.');
                }
            }
            if ($isEdit && $masterKey === 'user' && isset($data['idrole'])) {
                $existing = db_one('SELECT r.nama_role FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE u.iduser = ?', [$id]);
                $target = db_one('SELECT nama_role, status FROM `role` WHERE idrole = ?', [$data['idrole']]);
                if (!$target || (int)$target['status'] !== 1) throw new RuntimeException('Pilih role yang aktif.');
                if ($existing && $target && strtolower($existing['nama_role']) === 'super admin' && strtolower($target['nama_role']) !== 'super admin') {
                    $admins = db_one("SELECT COUNT(*) AS total FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE r.nama_role = 'super admin' AND u.status=1 AND r.status=1");
                    if ((int)$admins['total'] <= 1) throw new RuntimeException('Minimal satu akun Super Admin harus tetap ada.');
                }
            }
            if ($isEdit && $masterKey === 'user' && $id === (int)user_aktif()['iduser'] && isset($data['idrole'])) {
                $current = db_one('SELECT idrole FROM `user` WHERE iduser = ?', [$id]);
                if ((string)$data['idrole'] !== (string)$current['idrole']) throw new RuntimeException('Tidak dapat mengubah role akun yang sedang dipakai.');
            }
            if ($masterKey === 'user' && isset($data['status']) && $data['status'] === '0' && $isEdit) {
                if ($id === (int)user_aktif()['iduser']) throw new RuntimeException('Tidak bisa menonaktifkan akun sendiri.');
                $oldRole = db_one('SELECT r.nama_role FROM `user` u JOIN `role` r ON r.idrole=u.idrole WHERE u.iduser=?', [$id]);
                if ($oldRole && $oldRole['nama_role'] === 'super admin') {
                    $n = db_one("SELECT COUNT(*) AS n FROM `user` u JOIN `role` r ON r.idrole=u.idrole WHERE r.nama_role='super admin' AND u.status=1 AND r.status=1");
                    if ((int)$n['n'] <= 1) throw new RuntimeException('Super Admin aktif terakhir tidak boleh dinonaktifkan.');
                }
            }
            if ($masterKey === 'role' && ($data['status'] ?? '') === '0' && $isEdit) {
                $n = db_one('SELECT COUNT(*) AS n FROM `user` WHERE idrole=? AND status=1', [$id]);
                if ((int)$n['n'] > 0) throw new RuntimeException('Nonaktifkan semua pengguna pada role ini lebih dahulu.');
            }
            if ($masterKey === 'user' && isset($data['idrole'])) {
                $targetRole = db_one('SELECT status FROM `role` WHERE idrole=?', [$data['idrole']]);
                if (!$targetRole || (int)$targetRole['status'] !== 1) throw new RuntimeException('Role harus aktif.');
            }
            if ($isEdit) {
                $assignments = implode(', ', array_map(fn($k) => "`{$k}` = ?", array_keys($data)));
                db_run("UPDATE {$table} SET {$assignments} WHERE {$pk} = ?", [...array_values($data), $id]);
            } else {
                $keys = array_keys($data);
                $cols = implode(', ', array_map(fn($k) => "`{$k}`", $keys));
                $marks = implode(', ', array_fill(0, count($keys), '?'));
                db_run("INSERT INTO {$table} ({$cols}) VALUES ({$marks})", array_values($data));
            }
            flash('success', $isEdit ? 'Perubahan berhasil disimpan.' : 'Data baru berhasil ditambahkan.');
            pergi($self);
        }
        if ($action === 'toggle' && $c['status'] && $id) {
            $old = db_one("SELECT status FROM {$table} WHERE {$pk} = ?", [$id]);
            if (!$old) throw new RuntimeException('Data tidak ditemukan.');
            $new = (string)$old['status'] === '1' ? '0' : '1';
            if ($new === '0' && $masterKey === 'user') {
                if ($id === (int)user_aktif()['iduser']) throw new RuntimeException('Tidak bisa menonaktifkan akun sendiri.');
                $r = db_one('SELECT r.nama_role FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE u.iduser = ?', [$id]);
                if ($r && $r['nama_role'] === 'super admin') {
                    $n = db_one("SELECT COUNT(*) AS n FROM `user` u JOIN `role` r ON r.idrole=u.idrole WHERE r.nama_role='super admin' AND u.status=1 AND r.status=1");
                    if ((int)$n['n'] <= 1) throw new RuntimeException('Super Admin aktif terakhir tidak boleh dinonaktifkan.');
                }
            }
            if ($new === '0' && $masterKey === 'role') {
                $users = db_one('SELECT COUNT(*) AS n FROM `user` WHERE idrole = ? AND status = 1', [$id]);
                if ((int)$users['n'] > 0) throw new RuntimeException('Nonaktifkan pengguna role ini terlebih dahulu.');
            }
            db_run("UPDATE {$table} SET status = ? WHERE {$pk} = ?", [$new, $id]);
            flash('success', 'Status berhasil diperbarui.');
            pergi($self);
        }
        if ($action === 'delete' && $id && !$c['status']) {
            if ($masterKey === 'user' && $id === (int)user_aktif()['iduser']) throw new RuntimeException('Akun yang sedang digunakan tidak dapat dihapus.');
            if ($masterKey === 'user') {
                $existing = db_one('SELECT r.nama_role FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE u.iduser = ?', [$id]);
                if ($existing && strtolower($existing['nama_role']) === 'super admin') {
                    $admins = db_one("SELECT COUNT(*) AS total FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE r.nama_role = 'super admin' AND u.status=1 AND r.status=1");
                    if ((int)$admins['total'] <= 1) throw new RuntimeException('Super Admin terakhir tidak dapat dihapus.');
                }
            }
            if ($masterKey === 'role') throw new RuntimeException('Role yang menjadi dasar akses sistem tidak dapat dihapus melalui interface.');
            db_run("DELETE FROM {$table} WHERE {$pk} = ?", [$id]);
            flash('success', 'Data berhasil dihapus.');
            pergi($self);
        }
        throw new RuntimeException('Aksi tidak tersedia.');
    } catch (Throwable $error) {
        flash('error', error_db($error));
        pergi($self . (isset($_POST['id']) && ctype_digit((string)$_POST['id']) ? '?edit=' . (int)$_POST['id'] : ''));
    }
}

$options = [];
if ($masterKey === 'barang') {
    $options['idsatuan'] = array_column(db_all('SELECT idsatuan, nama_satuan FROM v_satuan WHERE status = 1 OR idsatuan IN (SELECT idsatuan FROM barang) ORDER BY nama_satuan'), 'nama_satuan', 'idsatuan');
}
if ($masterKey === 'user') {
    $options['idrole'] = array_column(db_all('SELECT idrole, nama_role FROM v_role WHERE status = 1 ORDER BY idrole'), 'nama_role', 'idrole');
}
$editId = isset($_GET['edit']) ? max(0, (int)$_GET['edit']) : 0;
$editing = $editId ? db_one("SELECT * FROM {$table} WHERE {$pk} = ?", [$editId]) : null;
$filter = in_array((string)($_GET['status'] ?? ''), ['1','0'], true) ? (string)$_GET['status'] : '';
$viewName = $c['view'];
if ($filter !== '') {
    $viewName = $c['view'] . ($filter === '1' ? '_aktif' : '_nonaktif');
}
$rows = db_all("SELECT * FROM {$viewName} ORDER BY {$pk} DESC LIMIT 500");
$headAction = $canWrite ? '<a class="btn btn-primary" href="' . $self . '?add=1">' . ikon('plus', 18) . ' Tambah ' . e($c['title']) . '</a>' : '';
require __DIR__ . '/header.php';
?>
<div class="page-grid <?= ($canWrite && (isset($_GET['add']) || $editing)) ? 'with-form' : '' ?>">
  <section class="surface-card"><div class="card-top"><div><h2>Daftar <?= e($c['title']) ?></h2></div><div class="master-tools"><form method="get"><select name="status" class="status-filter" aria-label="Filter status" onchange="this.form.submit()"><option value="">Semua status</option><option value="1" <?= $filter==='1'?'selected':'' ?>>Aktif</option><option value="0" <?= $filter==='0'?'selected':'' ?>>Nonaktif</option></select></form><label class="table-search"><?= ikon('search', 17) ?><input data-table-filter="master-table" type="search" placeholder="Cari data..." aria-label="Cari data"></label></div></div>
  <div class="table-wrap"><table class="data-table" id="master-table"><thead><tr><?php foreach ($c['columns'] as $label): ?><th><?= e($label) ?></th><?php endforeach; ?><?php if ($canWrite): ?><th class="td-actions">Aksi</th><?php endif; ?></tr></thead><tbody>
  <?php foreach ($rows as $r): ?><tr><?php foreach ($c['columns'] as $key => $label): ?><td><?php
    if ($key === 'status_label') echo status_chip($r[$key]);
    elseif ($key === 'harga') echo e(rupiah($r[$key]));
    elseif ($key === 'jenis') echo e((string)$r[$key] === '1' ? 'Sembako' : 'Rumah tangga');
    elseif ($key === 'badan_hukum') echo e((string)$r[$key] === 'Y' ? 'Ya' : 'Tidak');
    elseif ($key === 'stok_tersedia') echo '<strong class="stock-num">' . e($r[$key]) . '</strong>';
    else echo e($r[$key]);
  ?></td><?php endforeach; ?><?php if ($canWrite): ?><td class="td-actions"><div class="row-actions"><a href="<?= e($self) ?>?edit=<?= (int)$r[$pk] ?>" class="btn btn-text btn-sm" title="Edit"><?= ikon('edit',15) ?> Edit</a>
    <?php if ($c['status']): ?><form method="post" class="inline-form"><?= csrf_field() ?><input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="<?= (int)$r[$pk] ?>"><button type="submit" class="btn btn-text btn-sm"><?= (string)$r['status'] === '1' ? 'Nonaktifkan' : 'Aktifkan' ?></button></form><?php endif; ?>
    <?php if ($masterKey === 'user' && !$c['status'] && (int)$r[$pk] !== (int)user_aktif()['iduser']): ?><form method="post" class="inline-form" data-confirm="Yakin hapus akun ini?"><?= csrf_field() ?><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<?= (int)$r[$pk] ?>"><button class="btn btn-text btn-sm danger-text" type="submit">Hapus</button></form><?php endif; ?></div></td><?php endif; ?></tr><?php endforeach; ?>
  </tbody></table></div><?php if (!$rows) echo kosong('Data belum tersedia.'); ?>



  </section>
  <?php if ($canWrite && (isset($_GET['add']) || $editing)): ?><aside class="surface-card editor-panel"><div class="card-top"><div><h2><?= $editing ? 'Edit ' : 'Tambah ' ?><?= e($c['title']) ?></h2></div><a class="icon-btn" href="<?= e($self) ?>" title="Tutup">×</a></div>
  <form method="post" class="editor-form"><?= csrf_field() ?><input type="hidden" name="action" value="save"><input type="hidden" name="id" value="<?= $editing ? (int)$editing[$pk] : 0 ?>">
  <?php foreach ($c['fields'] as $key => $label): $current = $editing[$key] ?? ($key === 'status' ? '1' : ''); ?>
    <?php if ($key === 'status'): ?><?= pilihan_field('status', 'Status', ['1' => 'Aktif', '0' => 'Tidak aktif'], $current) ?>
    <?php elseif ($key === 'jenis'): ?><?= pilihan_field('jenis', $label, ['1' => 'Sembako', '2' => 'Kebutuhan rumah tangga'], $current) ?>
    <?php elseif ($key === 'badan_hukum'): ?><?= pilihan_field('badan_hukum', $label, ['Y' => 'Ya', 'N' => 'Tidak'], $current ?: 'N') ?>
    <?php elseif (isset($options[$key])): ?><?= pilihan_field($key, $label, $options[$key], $current) ?>
    <?php elseif ($key === 'password'): ?><?= field($key, $editing ? 'Kata sandi baru (kosongkan jika tetap)' : 'Kata sandi (minimal 8 karakter)', '', 'password', $editing ? 'autocomplete="new-password" minlength="8"' : 'required autocomplete="new-password" minlength="8"') ?>
    <?php elseif ($key === 'harga'): ?><?= field($key, $label . ' (Rp)', $current ?: '0', 'number', 'min="0" step="1" required') ?>
    <?php else: ?><?= field($key, $label, $current, 'text', 'required maxlength="100"') ?>
    <?php endif; ?>
  <?php endforeach; ?>
  <div class="form-actions"><a href="<?= e($self) ?>" class="btn btn-outline">Batal</a><button class="btn btn-primary" type="submit"><?= ikon('check',17) ?> Simpan</button></div></form></aside><?php endif; ?>
</div>
<?php require __DIR__ . '/footer.php'; ?>
