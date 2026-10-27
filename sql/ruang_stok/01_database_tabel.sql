-- buat database dan 15 tabel sesuai ERD
-- jalankan satu kali pada database baru

CREATE DATABASE IF NOT EXISTS pbd_ruang_stok
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE pbd_ruang_stok;

CREATE TABLE satuan (
    idsatuan INT NOT NULL,
    nama_satuan VARCHAR(45),
    status TINYINT,
    PRIMARY KEY (idsatuan)
) ENGINE=InnoDB;

CREATE TABLE vendor (
    idvendor INT NOT NULL,
    nama_vendor VARCHAR(100),
    badan_hukum CHAR(1),
    status CHAR(1),
    PRIMARY KEY (idvendor)
) ENGINE=InnoDB;

CREATE TABLE `role` (
    idrole INT NOT NULL,
    nama_role VARCHAR(100),
    PRIMARY KEY (idrole)
) ENGINE=InnoDB;

CREATE TABLE `user` (
    iduser INT NOT NULL,
    username VARCHAR(45),
    password VARCHAR(100),
    idrole INT,
    PRIMARY KEY (iduser),
    CONSTRAINT fk_user_role
      FOREIGN KEY (idrole) REFERENCES `role` (idrole)
) ENGINE=InnoDB;

CREATE TABLE barang (
    idbarang INT NOT NULL,
    jenis CHAR(1),
    nama VARCHAR(45),
    idsatuan INT,
    status TINYINT,
    harga INT,
    PRIMARY KEY (idbarang),
    CONSTRAINT fk_barang_satuan
      FOREIGN KEY (idsatuan) REFERENCES satuan (idsatuan)
) ENGINE=InnoDB;

CREATE TABLE margin_penjualan (
    idmargin_penjualan INT NOT NULL,
    created_at TIMESTAMP NULL,
    persen DOUBLE,
    status TINYINT,
    iduser INT,
    updated_at TIMESTAMP NULL,
    PRIMARY KEY (idmargin_penjualan),
    CONSTRAINT fk_margin_penjualan_user
      FOREIGN KEY (iduser) REFERENCES `user` (iduser)
) ENGINE=InnoDB;

CREATE TABLE pengadaan (
    idpengadaan BIGINT NOT NULL,
    `timestamp` TIMESTAMP NULL,
    user_iduser INT,
    status CHAR(1),
    vendor_idvendor INT,
    subtotal_nilai INT,
    ppn INT,
    total_nilai INT,
    PRIMARY KEY (idpengadaan),
    CONSTRAINT fk_pengadaan_user
      FOREIGN KEY (user_iduser) REFERENCES `user` (iduser),
    CONSTRAINT fk_pengadaan_vendor
      FOREIGN KEY (vendor_idvendor) REFERENCES vendor (idvendor)
) ENGINE=InnoDB;

CREATE TABLE detail_pengadaan (
    iddetail_pengadaan BIGINT NOT NULL,
    harga_satuan INT,
    jumlah INT,
    sub_total INT,
    idbarang INT,
    idpengadaan INT,
    PRIMARY KEY (iddetail_pengadaan),
    CONSTRAINT fk_detail_pengadaan_barang
      FOREIGN KEY (idbarang) REFERENCES barang (idbarang)
) ENGINE=InnoDB;

CREATE TABLE penerimaan (
    idpenerimaan BIGINT NOT NULL,
    created_at TIMESTAMP NULL,
    status CHAR(1),
    idpengadaan BIGINT,
    iduser INT,
    PRIMARY KEY (idpenerimaan),
    CONSTRAINT fk_penerimaan_pengadaan
      FOREIGN KEY (idpengadaan) REFERENCES pengadaan (idpengadaan),
    CONSTRAINT fk_penerimaan_user
      FOREIGN KEY (iduser) REFERENCES `user` (iduser)
) ENGINE=InnoDB;

CREATE TABLE detail_penerimaan (
    iddetail_penerimaan BIGINT NOT NULL,
    idpenerimaan BIGINT,
    barang_idbarang INT,
    jumlah_terima INT,
    harga_satuan_terima INT,
    sub_total_terima INT,
    PRIMARY KEY (iddetail_penerimaan),
    CONSTRAINT fk_detail_penerimaan_penerimaan
      FOREIGN KEY (idpenerimaan) REFERENCES penerimaan (idpenerimaan),
    CONSTRAINT fk_detail_penerimaan_barang
      FOREIGN KEY (barang_idbarang) REFERENCES barang (idbarang)
) ENGINE=InnoDB;

CREATE TABLE retur (
    idretur BIGINT NOT NULL,
    created_at TIMESTAMP NULL,
    idpenerimaan BIGINT,
    iduser INT,
    PRIMARY KEY (idretur),
    CONSTRAINT fk_retur_penerimaan
      FOREIGN KEY (idpenerimaan) REFERENCES penerimaan (idpenerimaan),
    CONSTRAINT fk_retur_user
      FOREIGN KEY (iduser) REFERENCES `user` (iduser)
) ENGINE=InnoDB;

CREATE TABLE detail_retur (
    iddetail_retur INT NOT NULL,
    jumlah INT,
    alasan VARCHAR(200),
    idretur BIGINT,
    iddetail_penerimaan BIGINT,
    PRIMARY KEY (iddetail_retur),
    CONSTRAINT fk_detail_retur_retur
      FOREIGN KEY (idretur) REFERENCES retur (idretur),
    CONSTRAINT fk_detail_retur_detail_penerimaan
      FOREIGN KEY (iddetail_penerimaan)
      REFERENCES detail_penerimaan (iddetail_penerimaan)
) ENGINE=InnoDB;

CREATE TABLE penjualan (
    idpenjualan INT NOT NULL,
    created_at TIMESTAMP NULL,
    subtotal_nilai INT,
    ppn INT,
    total_nilai INT,
    iduser INT,
    idmargin_penjualan INT,
    PRIMARY KEY (idpenjualan),
    CONSTRAINT fk_penjualan_user
      FOREIGN KEY (iduser) REFERENCES `user` (iduser),
    CONSTRAINT fk_penjualan_margin
      FOREIGN KEY (idmargin_penjualan)
      REFERENCES margin_penjualan (idmargin_penjualan)
) ENGINE=InnoDB;

CREATE TABLE detail_penjualan (
    iddetail_penjualan BIGINT NOT NULL,
    harga_satuan INT,
    jumlah INT,
    subtotal INT,
    penjualan_idpenjualan INT,
    idbarang INT,
    PRIMARY KEY (iddetail_penjualan),
    CONSTRAINT fk_detail_penjualan_penjualan
      FOREIGN KEY (penjualan_idpenjualan) REFERENCES penjualan (idpenjualan),
    CONSTRAINT fk_detail_penjualan_barang
      FOREIGN KEY (idbarang) REFERENCES barang (idbarang)
) ENGINE=InnoDB;

CREATE TABLE kartu_stok (
    idkartu_stok BIGINT NOT NULL,
    jenis_transaksi CHAR(1),
    masuk INT,
    keluar INT,
    stock INT,
    created_at TIMESTAMP NULL,
    idtransaksi INT,
    idbarang INT,
    PRIMARY KEY (idkartu_stok),
    CONSTRAINT fk_kartu_stok_barang
      FOREIGN KEY (idbarang) REFERENCES barang (idbarang)
) ENGINE=InnoDB;
