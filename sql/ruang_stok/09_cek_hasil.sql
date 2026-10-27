-- cek semua objek dan data tanpa mengubah database
USE pbd_ruang_stok;

SELECT DATABASE() AS database_aktif;

SELECT COUNT(*) AS jumlah_tabel
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE';

SELECT COUNT(*) AS jumlah_view
FROM information_schema.views
WHERE table_schema = DATABASE();

SHOW FULL TABLES WHERE Table_type = 'VIEW';

SELECT * FROM v_satuan;
SELECT * FROM v_vendor;
SELECT * FROM v_role;
SELECT * FROM v_user;
SELECT * FROM v_barang;
SELECT * FROM v_margin_penjualan;

SELECT COUNT(*) AS jumlah_pengadaan FROM v_pengadaan;
SELECT COUNT(*) AS jumlah_penerimaan FROM v_penerimaan;
SELECT COUNT(*) AS jumlah_retur FROM v_retur;
SELECT COUNT(*) AS jumlah_penjualan FROM v_penjualan;
SELECT COUNT(*) AS jumlah_kartu_stok FROM v_kartu_stok;

SHOW TRIGGERS;
SHOW PROCEDURE STATUS WHERE Db = 'pbd_ruang_stok';
SHOW FUNCTION STATUS WHERE Db = 'pbd_ruang_stok';

CALL sp_barang_per_satuan(1);
SELECT fn_harga_jual(32000, 10) AS harga_jual_contoh;
