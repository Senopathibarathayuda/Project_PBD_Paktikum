-- sembilan view untuk tabel transaksi
-- tabel transaksi belum diisi; hasil view boleh kosong
USE pbd_ruang_stok;

CREATE OR REPLACE VIEW v_pengadaan AS
SELECT idpengadaan, `timestamp`, user_iduser, status,
       vendor_idvendor, subtotal_nilai, ppn, total_nilai
FROM pengadaan;

CREATE OR REPLACE VIEW v_detail_pengadaan AS
SELECT iddetail_pengadaan, harga_satuan, jumlah, sub_total,
       idbarang, idpengadaan
FROM detail_pengadaan;

CREATE OR REPLACE VIEW v_penerimaan AS
SELECT idpenerimaan, created_at, status, idpengadaan, iduser
FROM penerimaan;

CREATE OR REPLACE VIEW v_detail_penerimaan AS
SELECT iddetail_penerimaan, idpenerimaan, barang_idbarang,
       jumlah_terima, harga_satuan_terima, sub_total_terima
FROM detail_penerimaan;

CREATE OR REPLACE VIEW v_retur AS
SELECT idretur, created_at, idpenerimaan, iduser
FROM retur;

CREATE OR REPLACE VIEW v_detail_retur AS
SELECT iddetail_retur, jumlah, alasan, idretur, iddetail_penerimaan
FROM detail_retur;

CREATE OR REPLACE VIEW v_penjualan AS
SELECT idpenjualan, created_at, subtotal_nilai, ppn,
       total_nilai, iduser, idmargin_penjualan
FROM penjualan;

CREATE OR REPLACE VIEW v_detail_penjualan AS
SELECT iddetail_penjualan, harga_satuan, jumlah, subtotal,
       penjualan_idpenjualan, idbarang
FROM detail_penjualan;

CREATE OR REPLACE VIEW v_kartu_stok AS
SELECT idkartu_stok, jenis_transaksi, masuk, keluar, stock,
       created_at, idtransaksi, idbarang
FROM kartu_stok;
