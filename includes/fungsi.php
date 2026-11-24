<?php
function e($value): string
{
    return htmlspecialchars((string)($value ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
function rupiah($value): string
{
    return 'Rp ' . number_format((float)$value, 0, ',', '.');
}
function rupiah_tahan($value): string
{
    return $value === null ? '—' : rupiah($value);
}
function tanggal($value): string
{
    if (!$value) return '-';
    return date('d M Y, H:i', strtotime((string)$value));
}
function db_one(string $sql, array $params = []): ?array
{
    global $pdo;
    $st = $pdo->prepare($sql);
    $st->execute($params);
    $result = $st->fetch();
    $st->closeCursor();
    return $result ?: null;
}
function db_all(string $sql, array $params = []): array
{
    global $pdo;
    $st = $pdo->prepare($sql);
    $st->execute($params);
    $result = $st->fetchAll();
    $st->closeCursor();
    return $result;
}
function db_run(string $sql, array $params = []): int
{
    global $pdo;
    $st = $pdo->prepare($sql);
    $st->execute($params);
    $count = $st->rowCount();
    $st->closeCursor();
    return $count;
}
function panjang_teks(string $text): int
{
    return function_exists('mb_strlen') ? mb_strlen($text, 'UTF-8') : strlen($text);
}
function nilai_int($value, int $min = 0): int
{
    if (filter_var($value, FILTER_VALIDATE_INT) === false || (int)$value < $min) {
        throw new RuntimeException('Isi angka bulat minimal ' . $min . '.');
    }
    return (int)$value;
}
function nilai_uang($value): int
{
    return nilai_int($value, 0);
}
function nilai_persen($value): string
{
    if (!is_scalar($value) || !is_numeric($value) || (float)$value < 0 || (float)$value > 100) {
        throw new RuntimeException('Persentase harus antara 0 dan 100.');
    }
    return number_format((float)$value, 2, '.', '');
}
function pilih(string $value, array $allowed): string
{
    if (!in_array($value, $allowed, true)) {
        throw new RuntimeException('Pilihan tidak dikenal.');
    }
    return $value;
}
function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(24));
    return $_SESSION['csrf'];
}
function csrf_field(): string
{
    return '<input type="hidden" name="csrf" value="' . e(csrf_token()) . '">';
}
function validasi_csrf(): void
{
    if (!hash_equals(csrf_token(), (string)($_POST['csrf'] ?? ''))) {
        throw new RuntimeException('Sesi formulir tidak valid. Refresh halaman, lalu ulangi.');
    }
}
function flash(string $type, string $message): void
{
    $_SESSION['flash'] = ['type' => $type, 'message' => $message];
}
function flash_tampil(): string
{
    if (empty($_SESSION['flash'])) return '';
    $flash = $_SESSION['flash'];
    unset($_SESSION['flash']);
    $cls = $flash['type'] === 'error' ? 'danger' : 'success';
    return '<div class="notice notice-' . $cls . '" role="status">' . e($flash['message']) . '</div>';
}
function pergi(string $url): never
{
    header('Location: ' . $url);
    exit;
}
function user_aktif(): ?array
{
    return $_SESSION['auth'] ?? null;
}
function wajib_login(): void
{
    if (!user_aktif()) pergi('login.php');
}
function role_sekarang(): string
{
    return strtolower(trim((string)(user_aktif()['nama_role'] ?? '')));
}
function izin(string $halaman, bool $ubah = false): bool
{
    $role = role_sekarang();
    if ($role === 'super admin') return true;
    $baca = [
        'manager' => ['index', 'satuan', 'vendor', 'barang', 'margin_penjualan', 'pengadaan', 'penerimaan', 'penjualan', 'retur', 'kartu_stok'],
        'petugas gudang' => ['index', 'satuan', 'vendor', 'barang', 'pengadaan', 'penerimaan', 'retur', 'kartu_stok'],
        'kasir' => ['index', 'barang', 'penjualan', 'kartu_stok'],
    ];
    $tulis = [
        'manager' => ['satuan', 'vendor', 'barang', 'margin_penjualan', 'pengadaan', 'penerimaan', 'penjualan', 'retur'],
        'petugas gudang' => ['penerimaan', 'retur'],
        'kasir' => ['penjualan'],
    ];
    return in_array($halaman, ($ubah ? $tulis : $baca)[$role] ?? [], true);
}
function wajib_izin(string $halaman, bool $ubah = false): void
{
    wajib_login();
    if (!izin($halaman, $ubah)) {
        http_response_code(403);
        exit('Akses ditolak. <a href="index.php">Kembali ke dashboard</a>');
    }
}
function error_db(Throwable $e): string
{
    if ($e instanceof PDOException) {
        $info = $e->errorInfo;
        $mysqlCode = (int)($info[1] ?? 0);
        if ($mysqlCode === 1062) return 'Data tersebut sudah ada. Gunakan nilai yang berbeda.';
        if ($mysqlCode === 1451) return 'Data sedang dipakai oleh tabel lain, sehingga tidak dapat dihapus.';
        if ($mysqlCode === 1452) return 'Referensi data tidak ditemukan. Periksa pilihan pada formulir.';
        if ($mysqlCode === 3819) return 'Data tidak memenuhi aturan validasi database.';
        if ($mysqlCode === 1644) return (string)($info[2] ?? 'Transaksi ditolak oleh database.');
        return 'Operasi database gagal. Periksa data dan keterkaitan transaksi.';
    }
    if ($e instanceof RuntimeException) return $e->getMessage();
    return 'Terjadi kesalahan saat memproses permintaan.';
}
function status_chip($value, bool $textOnly = false): string
{
    $label = (string)$value;
    $kind = match (strtolower($label)) {
        'aktif', 'selesai', 'datang', 'lengkap' => 'green',
        'tidak aktif', 'tidak datang', 'ditolak' => 'gray',
        'perlu restok', 'melebihi_pesanan' => 'amber',
        'draft', 'd' => 'blue',
        'dipesan / proses', 'dipesan', 'dalam proses', 'p' => 'amber',
        default => 'gray',
    };
    if ($textOnly) return $label;
    return '<span class="chip chip-' . $kind . '">' . e($label) . '</span>';
}
function ikon(string $name, int $size = 20): string
{
    $paths = [
        'grid' => '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
        'package' => '<path d="m12 3 9 5-9 5-9-5 9-5Z"/><path d="M3 8v8l9 5 9-5V8M12 13v8"/>',
        'cart' => '<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l3 15h12l3-11H6"/>',
        'truck' => '<path d="M3 5h11v12H3zM14 9h4l3 4v4h-7z"/><circle cx="7" cy="18" r="2"/><circle cx="18" cy="18" r="2"/>',
        'check' => '<path d="m5 12 4 4L19 6"/>',
        'back' => '<path d="m15 18-6-6 6-6"/>',
        'arrow' => '<path d="M5 12h14m-6-6 6 6-6 6"/>',
        'plus' => '<path d="M12 5v14M5 12h14"/>',
        'search' => '<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
        'logout' => '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>',
        'users' => '<path d="M16 21v-2a4 4 0 0 0-4-4H4a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
        'layers' => '<path d="m12 2 9 5-9 5-9-5 9-5Zm-9 10 9 5 9-5M3 17l9 5 9-5"/>',
        'settings' => '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l-1.8 1.8a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6H9a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-1.8-1.8a1.7 1.7 0 0 0 .3-1.9 1.7 1.7 0 0 0-1.6-1V10a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9l1.8-1.8a1.7 1.7 0 0 0 1.9.3A1.7 1.7 0 0 0 9 4h5a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l1.8 1.8a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1v4a1.7 1.7 0 0 0-1.6 1Z"/>',
        'wallet' => '<rect x="3" y="6" width="18" height="14" rx="2"/><path d="M3 10h18M7 6V4h12"/>',
        'clipboard' => '<rect x="5" y="4" width="14" height="18" rx="2"/><path d="M9 2h6v4H9zM9 11h6m-6 4h6"/>',
        'return' => '<path d="M9 14 4 9l5-5M4 9h9a7 7 0 0 1 0 14h-3"/>',
        'shield' => '<path d="m12 2 9 4v6c0 5-4 9-9 10C7 21 3 17 3 12V6l9-4Z"/><path d="m9 12 2 2 4-4"/>',
        'menu' => '<path d="M4 6h16M4 12h16M4 18h16"/>',
        'edit' => '<path d="m14 4 6 6M3 21l4-1 13-13a2 2 0 0 0-3-3L4 17l-1 4Z"/>',
        'trash' => '<path d="M3 6h18M8 6V4h8v2M6 6l1 15h10l1-15M10 10v7m4-7v7"/>',
        'info' => '<circle cx="12" cy="12" r="10"/><path d="M12 11v6M12 7h.01"/>',
        'calendar' => '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18"/>',
    ];
    $body = $paths[$name] ?? $paths['grid'];
    return '<svg aria-hidden="true" width="' . $size . '" height="' . $size . '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">' . $body . '</svg>';
}
function field(string $name, string $label, $value = '', string $type = 'text', string $extra = ''): string
{
    return '<label class="field"><span>' . e($label) . '</span><input name="' . e($name) . '" type="' . e($type) . '" value="' . e($value) . '" ' . $extra . '></label>';
}
function pilihan_field(string $name, string $label, array $options, $selected = null, bool $required = true): string
{
    $html = '<label class="field"><span>' . e($label) . '</span><select name="' . e($name) . '" ' . ($required ? 'required' : '') . '>';
    $html .= '<option value="">Pilih ' . e(strtolower($label)) . '</option>';
    foreach ($options as $key => $value) {
        $html .= '<option value="' . e($key) . '" ' . ((string)$key === (string)$selected ? 'selected' : '') . '>' . e($value) . '</option>';
    }
    return $html . '</select></label>';
}
function kosong(string $message = 'Belum ada data.'): string
{
    return '<div class="empty">' . ikon('package', 29) . '<p>' . e($message) . '</p></div>';
}
