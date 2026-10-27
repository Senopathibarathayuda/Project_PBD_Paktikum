-- contoh index pada nama barang (opsional)
USE pbd_ruang_stok;

CREATE INDEX idx_barang_nama ON barang (nama);

SHOW INDEX FROM barang;
