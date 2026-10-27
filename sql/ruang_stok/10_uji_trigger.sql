-- uji trigger memakai transaksi; datanya dibatalkan di akhir
-- jalankan hanya setelah file 05 dibuat
USE pbd_ruang_stok;

START TRANSACTION;

INSERT INTO kartu_stok
(idkartu_stok, jenis_transaksi, masuk, keluar, stock,
 created_at, idtransaksi, idbarang)
VALUES (900001, 'M', 5, 0, 5, NOW(), NULL, 1);

SELECT * FROM kartu_stok WHERE idkartu_stok = 900001;

ROLLBACK;

-- tes penolakan dijalankan terpisah jika ingin melihat pesan error:
-- INSERT INTO kartu_stok
-- (idkartu_stok, jenis_transaksi, masuk, keluar, stock, created_at, idtransaksi, idbarang)
-- VALUES (900002, 'M', -2, 0, -2, NOW(), NULL, 1);
