<?php
require_once __DIR__ . '/includes/bootstrap.php';
wajib_izin('margin_penjualan');
$canWrite = izin('margin_penjualan', true);
$halaman = 'margin_penjualan';
$judul = 'Margin Penjualan';
$subjudul = 'Satu margin aktif; pergantian menggunakan Stored Procedure.';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        wajib_izin('margin_penjualan', true);
        validasi_csrf();
        $action = (string)($_POST['action'] ?? '');
        if ($action === 'create') {
            $persen = nilai_persen($_POST['persen'] ?? '');
            db_run('INSERT INTO margin_penjualan (persen, status, iduser) VALUES (?, 0, ?)', [$persen, user_aktif()['iduser']]);
            flash('success', 'Margin baru tersimpan sebagai tidak aktif.');
        } elseif ($action === 'edit') {
            $id = nilai_int($_POST['id'] ?? '', 1);
            $persen = nilai_persen($_POST['persen'] ?? '');
            $old = db_one('SELECT status FROM margin_penjualan WHERE idmargin_penjualan = ?', [$id]);
            if (!$old || (int)$old['status'] === 1) throw new RuntimeException('Nonaktifkan margin terlebih dahulu dengan mengaktifkan margin lain.');
            db_run('UPDATE margin_penjualan SET persen = ?, iduser = ?, updated_at = NOW() WHERE idmargin_penjualan = ?', [$persen, user_aktif()['iduser'], $id]);
            flash('success', 'Persentase margin diperbarui.');
        } elseif ($action === 'activate') {
            $id = nilai_int($_POST['id'] ?? '', 1);
            $stmt = $pdo->prepare('CALL sp_aktifkan_margin(?, ?)');
            $stmt->execute([$id, (int)user_aktif()['iduser']]);
            $stmt->closeCursor();
            flash('success', 'Margin aktif berhasil diganti melalui Stored Procedure.');
        } else throw new RuntimeException('Aksi tidak dikenal.');
        pergi('margin_penjualan.php');
    } catch (Throwable $e) {
        flash('error', error_db($e));
        pergi('margin_penjualan.php');
    }
}
$filter = in_array((string)($_GET['status'] ?? ''), ['1','0'], true) ? (string)$_GET['status'] : '';
$viewName = $filter === '1' ? 'v_margin_penjualan_aktif' : ($filter === '0' ? 'v_margin_penjualan_nonaktif' : 'v_margin_penjualan');
$rows = db_all("SELECT * FROM {$viewName} ORDER BY idmargin_penjualan DESC");
$edit = isset($_GET['edit']) ? db_one('SELECT * FROM margin_penjualan WHERE idmargin_penjualan = ?', [(int)$_GET['edit']]) : null;
$headAction = $canWrite ? '<a href="margin_penjualan.php?add=1" class="btn btn-primary">' . ikon('plus',18) . ' Tambah margin</a>' : '';
require __DIR__ . '/includes/header.php';
?>
<div class="page-grid <?= ($canWrite && (isset($_GET['add']) || $edit)) ? 'with-form' : '' ?>"><section class="surface-card"><div class="card-top"><div><h2>Riwayat margin</h2></div><form method="get"><select class="status-filter" name="status" aria-label="Filter status margin" onchange="this.form.submit()"><option value="">Semua status</option><option value="1" <?= $filter==='1'?'selected':'' ?>>Aktif</option><option value="0" <?= $filter==='0'?'selected':'' ?>>Nonaktif</option></select></form></div>
<div class="table-wrap"><table class="data-table"><thead><tr><th>ID</th><th>Margin</th><th>Status</th><th>Diatur oleh</th><th>Dibuat</th><th>Diperbarui</th><?php if ($canWrite): ?><th>Aksi</th><?php endif; ?></tr></thead><tbody>
<?php foreach ($rows as $r): ?><tr><td>#<?= (int)$r['idmargin_penjualan'] ?></td><td class="num-strong"><?= e($r['persen']) ?>%</td><td><?= status_chip($r['status_label']) ?></td><td><?= e($r['username']) ?></td><td><?= e(tanggal($r['created_at'])) ?></td><td><?= e(tanggal($r['updated_at'])) ?></td>
<?php if ($canWrite): ?><td class="td-actions"><div class="row-actions">
<?php if ((int)$r['status'] !== 1): ?><a class="btn btn-text btn-sm" href="margin_penjualan.php?edit=<?= (int)$r['idmargin_penjualan'] ?>">Edit</a><form method="post" class="inline-form" data-confirm="Jadikan margin ini aktif untuk penjualan baru?"><?= csrf_field() ?><input type="hidden" name="action" value="activate"><input type="hidden" name="id" value="<?= (int)$r['idmargin_penjualan'] ?>"><button type="submit" class="btn btn-text btn-sm">Aktifkan</button></form><?php else: ?><span class="muted mini">Digunakan sekarang</span><?php endif; ?></div></td><?php endif; ?></tr><?php endforeach; ?>
</tbody></table></div><?php if (!$rows) echo kosong('Belum ada margin.'); ?><div class="card-note">Margin aktif tidak dapat diedit langsung. Aktifkan margin lain terlebih dahulu agar histori penjualan tetap konsisten.</div></section>
<?php if ($canWrite && (isset($_GET['add']) || $edit)): ?><aside class="surface-card editor-panel"><div class="card-top"><div><h2><?= $edit ? 'Edit margin' : 'Margin baru' ?></h2></div><a href="margin_penjualan.php" class="icon-btn">×</a></div><form class="editor-form" method="post"><?= csrf_field() ?><input type="hidden" name="action" value="<?= $edit ? 'edit' : 'create' ?>"><input type="hidden" name="id" value="<?= (int)($edit['idmargin_penjualan'] ?? 0) ?>"><?= field('persen','Persentase margin (%)',$edit['persen'] ?? '10.00','number','min="0" max="100" step="0.01" required') ?><div class="form-actions"><a class="btn btn-outline" href="margin_penjualan.php">Batal</a><button type="submit" class="btn btn-primary">Simpan</button></div></form></aside><?php endif; ?></div>
<?php require __DIR__ . '/includes/footer.php'; ?>
