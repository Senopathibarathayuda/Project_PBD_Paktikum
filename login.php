<?php
require_once __DIR__ . '/includes/bootstrap.php';
if (user_aktif()) pergi('index.php');
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        validasi_csrf();
        $username = trim((string)($_POST['username'] ?? ''));
        $password = (string)($_POST['password'] ?? '');
        $row = db_one('SELECT u.iduser, u.username, u.password, r.nama_role FROM `user` u JOIN `role` r ON r.idrole = u.idrole WHERE u.username = ? AND u.status = 1 AND r.status = 1', [$username]);
        if (!$row || !password_verify($password, $row['password'])) throw new RuntimeException('Username atau kata sandi tidak sesuai.');
        session_regenerate_id(true);
        $_SESSION['auth'] = ['iduser' => (int)$row['iduser'], 'username' => $row['username'], 'nama_role' => $row['nama_role']];
        pergi('index.php');
    } catch (Throwable $e) { $error = error_db($e); }
}
?><!doctype html>
<html lang="id"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Masuk | Toko Sembako</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="assets/style.css?v=2">
</head>
<body class="login-body">
<div class="login-layout"><section class="login-form-wrap">
<form class="login-card" method="post" autocomplete="on">
<?= csrf_field() ?>
<div class="login-brand"><span class="brand-mark"><?= ikon('package', 26) ?></span><strong>Toko Sembako</strong></div>
<h1>Masuk</h1>
<?php if ($error): ?><div class="notice notice-danger" role="alert"><?= e($error) ?></div><?php endif; ?>
<?= field('username', 'Username', $_POST['username'] ?? '', 'text', 'required autofocus autocomplete="username" maxlength="45"') ?>
<?= field('password', 'Kata sandi', '', 'password', 'required autocomplete="current-password"') ?>
<button class="btn btn-primary btn-full" type="submit">Masuk <?= ikon('arrow', 18) ?></button>
</form></section></div>
</body></html>
