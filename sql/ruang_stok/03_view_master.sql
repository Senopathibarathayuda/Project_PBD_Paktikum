-- enam view untuk data master
USE pbd_ruang_stok;

CREATE OR REPLACE VIEW v_satuan AS
SELECT idsatuan, nama_satuan, status
FROM satuan;

CREATE OR REPLACE VIEW v_vendor AS
SELECT idvendor, nama_vendor, badan_hukum, status
FROM vendor;

CREATE OR REPLACE VIEW v_role AS
SELECT idrole, nama_role
FROM `role`;

CREATE OR REPLACE VIEW v_user AS
SELECT iduser, username, idrole
FROM `user`;

CREATE OR REPLACE VIEW v_barang AS
SELECT idbarang, jenis, nama, idsatuan, status, harga
FROM barang;

CREATE OR REPLACE VIEW v_margin_penjualan AS
SELECT idmargin_penjualan, created_at, persen, status, iduser, updated_at
FROM margin_penjualan;
