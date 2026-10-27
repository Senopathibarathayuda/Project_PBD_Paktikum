-- data contoh untuk enam tabel master
-- jalankan satu kali setelah tabel dibuat
-- username pada tabel user hanya untuk contoh data, belum dipakai login

USE pbd_ruang_stok;

INSERT INTO satuan (idsatuan, nama_satuan, status) VALUES
(1, 'Pcs', 1),
(2, 'Dus', 1),
(3, 'Kg', 1),
(4, 'Liter', 1),
(5, 'Botol', 1);

INSERT INTO `role` (idrole, nama_role) VALUES
(1, 'Administrator'),
(2, 'Staf Gudang'),
(3, 'Staf Penjualan');

INSERT INTO vendor (idvendor, nama_vendor, badan_hukum, status) VALUES
(1, 'PT Sumber Niaga', 'Y', '1'),
(2, 'CV Mitra Distribusi', 'Y', '1'),
(3, 'Toko Sejahtera', 'N', '1');

INSERT INTO barang (idbarang, jenis, nama, idsatuan, status, harga) VALUES
(1, '1', 'Kopi Bubuk 250 g', 1, 1, 32000),
(2, '1', 'Gula Pasir', 3, 1, 17500),
(3, '1', 'Air Mineral 600 ml', 5, 1, 5000),
(4, '1', 'Tisu Gulung', 1, 1, 12500),
(5, '1', 'Sabun Cair', 4, 1, 23000);

INSERT INTO `user` (iduser, username, password, idrole) VALUES
(1, 'admin_pbd', '$2y$12$s55PS2QiRkaYwGaNaMT5j.Y.lqaGaQT2qbTnnRd.LsmWgb6qPLkMi', 1),
(2, 'gudang_pbd', '$2y$12$TjLYuRgzPA9xH2ZY4DLXx..uL35XyO2f3/7GiJQqhDZ0Olw47qb7O', 2);

INSERT INTO margin_penjualan
(idmargin_penjualan, created_at, persen, status, iduser, updated_at) VALUES
(1, CURRENT_TIMESTAMP, 10.0, 1, 1, CURRENT_TIMESTAMP),
(2, CURRENT_TIMESTAMP, 15.0, 0, 1, CURRENT_TIMESTAMP),
(3, CURRENT_TIMESTAMP, 20.0, 0, 1, CURRENT_TIMESTAMP),
(4, CURRENT_TIMESTAMP, 25.0, 0, 1, CURRENT_TIMESTAMP),
(5, CURRENT_TIMESTAMP, 30.0, 0, 1, CURRENT_TIMESTAMP);

SELECT COUNT(*) AS jumlah_satuan FROM satuan;
SELECT COUNT(*) AS jumlah_role FROM `role`;
SELECT COUNT(*) AS jumlah_vendor FROM vendor;
SELECT COUNT(*) AS jumlah_barang FROM barang;
SELECT COUNT(*) AS jumlah_user FROM `user`;
SELECT COUNT(*) AS jumlah_margin FROM margin_penjualan;
