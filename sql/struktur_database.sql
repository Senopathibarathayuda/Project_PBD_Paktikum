-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: pbd_toko_sembako
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `pbd_toko_sembako`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pbd_toko_sembako` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `pbd_toko_sembako`;

--
-- Table structure for table `barang`
--

DROP TABLE IF EXISTS `barang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `barang` (
  `idbarang` int NOT NULL AUTO_INCREMENT,
  `jenis` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idsatuan` int NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `harga` bigint NOT NULL DEFAULT '0',
  `stok_tersedia` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`idbarang`),
  KEY `ix_barang_satuan` (`idsatuan`),
  CONSTRAINT `fk_barang_satuan` FOREIGN KEY (`idsatuan`) REFERENCES `satuan` (`idsatuan`),
  CONSTRAINT `ck_barang_harga` CHECK ((`harga` >= 0)),
  CONSTRAINT `ck_barang_jenis` CHECK ((`jenis` in (_utf8mb4'1',_utf8mb4'2'))),
  CONSTRAINT `ck_barang_status` CHECK ((`status` in (0,1))),
  CONSTRAINT `ck_barang_stok` CHECK ((`stok_tersedia` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detail_penerimaan`
--

DROP TABLE IF EXISTS `detail_penerimaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_penerimaan` (
  `iddetail_penerimaan` bigint NOT NULL AUTO_INCREMENT,
  `idpenerimaan` bigint NOT NULL,
  `barang_idbarang` int NOT NULL,
  `jumlah_terima` int NOT NULL DEFAULT '0',
  `harga_satuan_terima` bigint NOT NULL DEFAULT '0',
  `sub_total_terima` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`iddetail_penerimaan`),
  UNIQUE KEY `uk_penerimaan_barang` (`idpenerimaan`,`barang_idbarang`),
  KEY `fk_dpenerimaan_barang` (`barang_idbarang`),
  CONSTRAINT `fk_dpenerimaan_barang` FOREIGN KEY (`barang_idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `fk_dpenerimaan_induk` FOREIGN KEY (`idpenerimaan`) REFERENCES `penerimaan` (`idpenerimaan`),
  CONSTRAINT `ck_dpenerimaan_harga` CHECK (((`harga_satuan_terima` >= 0) and (`sub_total_terima` >= 0))),
  CONSTRAINT `ck_dpenerimaan_jumlah` CHECK ((`jumlah_terima` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detail_pengadaan`
--

DROP TABLE IF EXISTS `detail_pengadaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_pengadaan` (
  `iddetail_pengadaan` bigint NOT NULL AUTO_INCREMENT,
  `harga_satuan` bigint NOT NULL,
  `jumlah` int NOT NULL,
  `sub_total` bigint NOT NULL DEFAULT '0',
  `idbarang` int NOT NULL,
  `idpengadaan` bigint NOT NULL,
  PRIMARY KEY (`iddetail_pengadaan`),
  UNIQUE KEY `uk_pesanan_barang` (`idpengadaan`,`idbarang`),
  KEY `fk_dpengadaan_barang` (`idbarang`),
  CONSTRAINT `fk_dpengadaan_barang` FOREIGN KEY (`idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `fk_dpengadaan_induk` FOREIGN KEY (`idpengadaan`) REFERENCES `pengadaan` (`idpengadaan`),
  CONSTRAINT `ck_dpengadaan_harga` CHECK (((`harga_satuan` >= 0) and (`sub_total` >= 0))),
  CONSTRAINT `ck_dpengadaan_jumlah` CHECK ((`jumlah` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detail_penjualan`
--

DROP TABLE IF EXISTS `detail_penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_penjualan` (
  `iddetail_penjualan` bigint NOT NULL AUTO_INCREMENT,
  `harga_satuan` bigint NOT NULL DEFAULT '0',
  `jumlah` int NOT NULL,
  `subtotal` bigint NOT NULL DEFAULT '0',
  `penjualan_idpenjualan` int NOT NULL,
  `idbarang` int NOT NULL,
  PRIMARY KEY (`iddetail_penjualan`),
  UNIQUE KEY `uk_penjualan_barang` (`penjualan_idpenjualan`,`idbarang`),
  KEY `fk_dpenjualan_barang` (`idbarang`),
  CONSTRAINT `fk_dpenjualan_barang` FOREIGN KEY (`idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `fk_dpenjualan_induk` FOREIGN KEY (`penjualan_idpenjualan`) REFERENCES `penjualan` (`idpenjualan`),
  CONSTRAINT `ck_dpenjualan_jumlah` CHECK ((`jumlah` > 0)),
  CONSTRAINT `ck_dpenjualan_nilai` CHECK (((`harga_satuan` >= 0) and (`subtotal` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detail_retur`
--

DROP TABLE IF EXISTS `detail_retur`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_retur` (
  `iddetail_retur` int NOT NULL AUTO_INCREMENT,
  `jumlah` int NOT NULL,
  `alasan` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idretur` bigint NOT NULL,
  `iddetail_penerimaan` bigint NOT NULL,
  PRIMARY KEY (`iddetail_retur`),
  UNIQUE KEY `uk_retur_detail_penerimaan` (`idretur`,`iddetail_penerimaan`),
  KEY `fk_dretur_dpenerimaan` (`iddetail_penerimaan`),
  CONSTRAINT `fk_dretur_dpenerimaan` FOREIGN KEY (`iddetail_penerimaan`) REFERENCES `detail_penerimaan` (`iddetail_penerimaan`),
  CONSTRAINT `fk_dretur_induk` FOREIGN KEY (`idretur`) REFERENCES `retur` (`idretur`),
  CONSTRAINT `ck_dretur_jumlah` CHECK ((`jumlah` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kartu_stok`
--

DROP TABLE IF EXISTS `kartu_stok`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kartu_stok` (
  `idkartu_stok` bigint NOT NULL AUTO_INCREMENT,
  `jenis_transaksi` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `masuk` int NOT NULL DEFAULT '0',
  `keluar` int NOT NULL DEFAULT '0',
  `stock` int NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idtransaksi` bigint NOT NULL,
  `idbarang` int NOT NULL,
  `sumber_transaksi` enum('PENERIMAAN','PENJUALAN','RETUR') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idkartu_stok`),
  UNIQUE KEY `uk_gerakan_sekali` (`sumber_transaksi`,`idtransaksi`),
  KEY `ix_kartu_barang` (`idbarang`,`idkartu_stok`),
  CONSTRAINT `fk_kartu_barang` FOREIGN KEY (`idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `ck_kartu_angka` CHECK (((`masuk` >= 0) and (`keluar` >= 0) and (`stock` >= 0))),
  CONSTRAINT `ck_kartu_jenis` CHECK ((`jenis_transaksi` in (_utf8mb4'M',_utf8mb4'K')))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_kartu_stok_hitung` BEFORE INSERT ON `kartu_stok` FOR EACH ROW BEGIN
    DECLARE v_sisa INT DEFAULT NULL;
    IF NEW.masuk < 0 OR NEW.keluar < 0 OR
        (NEW.jenis_transaksi = 'M' AND (NEW.masuk <= 0 OR NEW.keluar <> 0)) OR
        (NEW.jenis_transaksi = 'K' AND (NEW.keluar <= 0 OR NEW.masuk <> 0)) OR
        NEW.jenis_transaksi NOT IN ('M', 'K') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pergerakan kartu stok tidak valid';
    END IF;
    IF NEW.sumber_transaksi NOT IN ('PENERIMAAN', 'PENJUALAN', 'RETUR') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sumber transaksi tidak valid';
    END IF;
    IF (NEW.sumber_transaksi = 'PENERIMAAN' AND NEW.jenis_transaksi <> 'M') OR
          (NEW.sumber_transaksi IN ('PENJUALAN', 'RETUR') AND NEW.jenis_transaksi <> 'K') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Arah stok tidak cocok dengan sumber transaksi';
    END IF;
    UPDATE barang
    SET stok_tersedia = stok_tersedia+NEW.masuk-NEW.keluar
    WHERE idbarang = NEW.idbarang
        AND stok_tersedia+NEW.masuk-NEW.keluar >= 0;
    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok tidak cukup atau barang tidak ditemukan';
    END IF;
    SELECT stok_tersedia INTO v_sisa FROM barang WHERE idbarang = NEW.idbarang;
    SET NEW.stock = v_sisa;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_kartu_stok_tolak_update` BEFORE UPDATE ON `kartu_stok` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Riwayat kartu stok tidak boleh diedit';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_kartu_stok_tolak_delete` BEFORE DELETE ON `kartu_stok` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Riwayat kartu stok tidak boleh dihapus';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `margin_penjualan`
--

DROP TABLE IF EXISTS `margin_penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `margin_penjualan` (
  `idmargin_penjualan` int NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `persen` decimal(5,2) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '0',
  `iduser` int NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `aktif_marker` tinyint GENERATED ALWAYS AS ((case when (`status` = 1) then 1 else NULL end)) STORED,
  PRIMARY KEY (`idmargin_penjualan`),
  UNIQUE KEY `uk_satu_margin_aktif` (`aktif_marker`),
  KEY `fk_margin_user` (`iduser`),
  CONSTRAINT `fk_margin_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_margin_persen` CHECK (((`persen` >= 0) and (`persen` <= 100))),
  CONSTRAINT `ck_margin_status` CHECK ((`status` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_margin_jaga_histori` BEFORE UPDATE ON `margin_penjualan` FOR EACH ROW BEGIN
    DECLARE v_jumlah INT DEFAULT 0;
    IF NEW.persen <> OLD.persen THEN
        SELECT COUNT(*) INTO v_jumlah
        FROM penjualan
        WHERE idmargin_penjualan = OLD.idmargin_penjualan AND status = 'S';
        IF v_jumlah > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Margin yang sudah dipakai penjualan selesai tidak boleh diubah';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `penerimaan`
--

DROP TABLE IF EXISTS `penerimaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `penerimaan` (
  `idpenerimaan` bigint NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'P',
  `idpengadaan` bigint NOT NULL,
  `iduser` int NOT NULL,
  PRIMARY KEY (`idpenerimaan`),
  KEY `fk_penerimaan_pengadaan` (`idpengadaan`),
  KEY `fk_penerimaan_user` (`iduser`),
  CONSTRAINT `fk_penerimaan_pengadaan` FOREIGN KEY (`idpengadaan`) REFERENCES `pengadaan` (`idpengadaan`),
  CONSTRAINT `fk_penerimaan_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_penerimaan_status` CHECK ((`status` in (_utf8mb4'P',_utf8mb4'S')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pengadaan`
--

DROP TABLE IF EXISTS `pengadaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pengadaan` (
  `idpengadaan` bigint NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dikonfirmasi_at` timestamp NULL DEFAULT NULL,
  `user_iduser` int NOT NULL,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'P',
  `vendor_idvendor` int NOT NULL,
  `subtotal_nilai` bigint DEFAULT NULL,
  `tarif_ppn` decimal(5,2) NOT NULL DEFAULT '12.00',
  `ppn` bigint DEFAULT NULL,
  `total_nilai` bigint DEFAULT NULL,
  PRIMARY KEY (`idpengadaan`),
  KEY `fk_pengadaan_user` (`user_iduser`),
  KEY `fk_pengadaan_vendor` (`vendor_idvendor`),
  CONSTRAINT `fk_pengadaan_user` FOREIGN KEY (`user_iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `fk_pengadaan_vendor` FOREIGN KEY (`vendor_idvendor`) REFERENCES `vendor` (`idvendor`),
  CONSTRAINT `ck_pengadaan_nilai` CHECK (((`subtotal_nilai` >= 0) and (`ppn` >= 0) and (`total_nilai` >= 0))),
  CONSTRAINT `ck_pengadaan_status` CHECK ((`status` in (_utf8mb4'P',_utf8mb4'S'))),
  CONSTRAINT `ck_pengadaan_tarif_ppn` CHECK ((`tarif_ppn` between 0 and 100))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `penjualan`
--

DROP TABLE IF EXISTS `penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `penjualan` (
  `idpenjualan` int NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'D',
  `subtotal_nilai` bigint DEFAULT NULL,
  `tarif_ppn` decimal(5,2) NOT NULL DEFAULT '11.00',
  `ppn` bigint DEFAULT NULL,
  `total_nilai` bigint DEFAULT NULL,
  `iduser` int NOT NULL,
  `idmargin_penjualan` int NOT NULL,
  PRIMARY KEY (`idpenjualan`),
  KEY `fk_penjualan_user` (`iduser`),
  KEY `fk_penjualan_margin` (`idmargin_penjualan`),
  CONSTRAINT `fk_penjualan_margin` FOREIGN KEY (`idmargin_penjualan`) REFERENCES `margin_penjualan` (`idmargin_penjualan`),
  CONSTRAINT `fk_penjualan_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_penjualan_status` CHECK ((`status` in (_utf8mb4'D',_utf8mb4'S'))),
  CONSTRAINT `ck_penjualan_tarif_ppn` CHECK ((`tarif_ppn` between 0 and 100)),
  CONSTRAINT `ck_penjualan_total` CHECK (((`subtotal_nilai` >= 0) and (`ppn` >= 0) and (`total_nilai` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `retur`
--

DROP TABLE IF EXISTS `retur`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `retur` (
  `idretur` bigint NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'D',
  `idpenerimaan` bigint NOT NULL,
  `iduser` int NOT NULL,
  PRIMARY KEY (`idretur`),
  KEY `fk_retur_penerimaan` (`idpenerimaan`),
  KEY `fk_retur_user` (`iduser`),
  CONSTRAINT `fk_retur_penerimaan` FOREIGN KEY (`idpenerimaan`) REFERENCES `penerimaan` (`idpenerimaan`),
  CONSTRAINT `fk_retur_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_retur_status` CHECK ((`status` in (_utf8mb4'D',_utf8mb4'S')))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `idrole` int NOT NULL AUTO_INCREMENT,
  `nama_role` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`idrole`),
  UNIQUE KEY `uk_role_nama` (`nama_role`),
  CONSTRAINT `ck_role_status` CHECK ((`status` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `satuan`
--

DROP TABLE IF EXISTS `satuan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `satuan` (
  `idsatuan` int NOT NULL AUTO_INCREMENT,
  `nama_satuan` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`idsatuan`),
  UNIQUE KEY `uk_satuan_nama` (`nama_satuan`),
  CONSTRAINT `ck_satuan_status` CHECK ((`status` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `iduser` int NOT NULL AUTO_INCREMENT,
  `username` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idrole` int NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`iduser`),
  UNIQUE KEY `uk_user_username` (`username`),
  KEY `fk_user_role` (`idrole`),
  CONSTRAINT `fk_user_role` FOREIGN KEY (`idrole`) REFERENCES `role` (`idrole`),
  CONSTRAINT `ck_user_status` CHECK ((`status` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_barang`
--

DROP TABLE IF EXISTS `v_barang`;
/*!50001 DROP VIEW IF EXISTS `v_barang`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_barang` AS SELECT 
 1 AS `idbarang`,
 1 AS `jenis`,
 1 AS `nama`,
 1 AS `idsatuan`,
 1 AS `nama_satuan`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `harga`,
 1 AS `stok_tersedia`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_barang_aktif`
--

DROP TABLE IF EXISTS `v_barang_aktif`;
/*!50001 DROP VIEW IF EXISTS `v_barang_aktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_barang_aktif` AS SELECT 
 1 AS `idbarang`,
 1 AS `jenis`,
 1 AS `nama`,
 1 AS `idsatuan`,
 1 AS `nama_satuan`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `harga`,
 1 AS `stok_tersedia`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_barang_nonaktif`
--

DROP TABLE IF EXISTS `v_barang_nonaktif`;
/*!50001 DROP VIEW IF EXISTS `v_barang_nonaktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_barang_nonaktif` AS SELECT 
 1 AS `idbarang`,
 1 AS `jenis`,
 1 AS `nama`,
 1 AS `idsatuan`,
 1 AS `nama_satuan`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `harga`,
 1 AS `stok_tersedia`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_detail_penerimaan`
--

DROP TABLE IF EXISTS `v_detail_penerimaan`;
/*!50001 DROP VIEW IF EXISTS `v_detail_penerimaan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_detail_penerimaan` AS SELECT 
 1 AS `iddetail_penerimaan`,
 1 AS `idpenerimaan`,
 1 AS `idbarang`,
 1 AS `nama_barang`,
 1 AS `jumlah_terima`,
 1 AS `harga_satuan_terima`,
 1 AS `sub_total_terima`,
 1 AS `kondisi_pengiriman`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_detail_pengadaan`
--

DROP TABLE IF EXISTS `v_detail_pengadaan`;
/*!50001 DROP VIEW IF EXISTS `v_detail_pengadaan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_detail_pengadaan` AS SELECT 
 1 AS `iddetail_pengadaan`,
 1 AS `idpengadaan`,
 1 AS `idbarang`,
 1 AS `nama_barang`,
 1 AS `jumlah`,
 1 AS `harga_satuan`,
 1 AS `sub_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_detail_penjualan`
--

DROP TABLE IF EXISTS `v_detail_penjualan`;
/*!50001 DROP VIEW IF EXISTS `v_detail_penjualan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_detail_penjualan` AS SELECT 
 1 AS `iddetail_penjualan`,
 1 AS `penjualan_idpenjualan`,
 1 AS `idbarang`,
 1 AS `nama_barang`,
 1 AS `harga_satuan`,
 1 AS `jumlah`,
 1 AS `subtotal`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_detail_retur`
--

DROP TABLE IF EXISTS `v_detail_retur`;
/*!50001 DROP VIEW IF EXISTS `v_detail_retur`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_detail_retur` AS SELECT 
 1 AS `iddetail_retur`,
 1 AS `idretur`,
 1 AS `iddetail_penerimaan`,
 1 AS `idbarang`,
 1 AS `nama_barang`,
 1 AS `jumlah`,
 1 AS `alasan`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_kartu_stok`
--

DROP TABLE IF EXISTS `v_kartu_stok`;
/*!50001 DROP VIEW IF EXISTS `v_kartu_stok`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_kartu_stok` AS SELECT 
 1 AS `idkartu_stok`,
 1 AS `idbarang`,
 1 AS `nama_barang`,
 1 AS `jenis_transaksi`,
 1 AS `masuk`,
 1 AS `keluar`,
 1 AS `stock`,
 1 AS `created_at`,
 1 AS `sumber_transaksi`,
 1 AS `idtransaksi`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_margin_penjualan`
--

DROP TABLE IF EXISTS `v_margin_penjualan`;
/*!50001 DROP VIEW IF EXISTS `v_margin_penjualan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_margin_penjualan` AS SELECT 
 1 AS `idmargin_penjualan`,
 1 AS `created_at`,
 1 AS `persen`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `iduser`,
 1 AS `username`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_margin_penjualan_aktif`
--

DROP TABLE IF EXISTS `v_margin_penjualan_aktif`;
/*!50001 DROP VIEW IF EXISTS `v_margin_penjualan_aktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_margin_penjualan_aktif` AS SELECT 
 1 AS `idmargin_penjualan`,
 1 AS `created_at`,
 1 AS `persen`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `iduser`,
 1 AS `username`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_margin_penjualan_nonaktif`
--

DROP TABLE IF EXISTS `v_margin_penjualan_nonaktif`;
/*!50001 DROP VIEW IF EXISTS `v_margin_penjualan_nonaktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_margin_penjualan_nonaktif` AS SELECT 
 1 AS `idmargin_penjualan`,
 1 AS `created_at`,
 1 AS `persen`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `iduser`,
 1 AS `username`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_penerimaan`
--

DROP TABLE IF EXISTS `v_penerimaan`;
/*!50001 DROP VIEW IF EXISTS `v_penerimaan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_penerimaan` AS SELECT 
 1 AS `idpenerimaan`,
 1 AS `created_at`,
 1 AS `idpengadaan`,
 1 AS `iduser`,
 1 AS `username`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_pengadaan`
--

DROP TABLE IF EXISTS `v_pengadaan`;
/*!50001 DROP VIEW IF EXISTS `v_pengadaan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pengadaan` AS SELECT 
 1 AS `idpengadaan`,
 1 AS `timestamp`,
 1 AS `dikonfirmasi_at`,
 1 AS `user_iduser`,
 1 AS `username`,
 1 AS `vendor_idvendor`,
 1 AS `nama_vendor`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `subtotal_nilai`,
 1 AS `tarif_ppn`,
 1 AS `ppn`,
 1 AS `total_nilai`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_penjualan`
--

DROP TABLE IF EXISTS `v_penjualan`;
/*!50001 DROP VIEW IF EXISTS `v_penjualan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_penjualan` AS SELECT 
 1 AS `idpenjualan`,
 1 AS `created_at`,
 1 AS `iduser`,
 1 AS `username`,
 1 AS `idmargin_penjualan`,
 1 AS `margin_persen`,
 1 AS `status`,
 1 AS `status_label`,
 1 AS `subtotal_nilai`,
 1 AS `tarif_ppn`,
 1 AS `ppn`,
 1 AS `total_nilai`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_retur`
--

DROP TABLE IF EXISTS `v_retur`;
/*!50001 DROP VIEW IF EXISTS `v_retur`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_retur` AS SELECT 
 1 AS `idretur`,
 1 AS `created_at`,
 1 AS `idpenerimaan`,
 1 AS `iduser`,
 1 AS `username`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_role`
--

DROP TABLE IF EXISTS `v_role`;
/*!50001 DROP VIEW IF EXISTS `v_role`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_role` AS SELECT 
 1 AS `idrole`,
 1 AS `nama_role`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_role_aktif`
--

DROP TABLE IF EXISTS `v_role_aktif`;
/*!50001 DROP VIEW IF EXISTS `v_role_aktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_role_aktif` AS SELECT 
 1 AS `idrole`,
 1 AS `nama_role`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_role_nonaktif`
--

DROP TABLE IF EXISTS `v_role_nonaktif`;
/*!50001 DROP VIEW IF EXISTS `v_role_nonaktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_role_nonaktif` AS SELECT 
 1 AS `idrole`,
 1 AS `nama_role`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_satuan`
--

DROP TABLE IF EXISTS `v_satuan`;
/*!50001 DROP VIEW IF EXISTS `v_satuan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_satuan` AS SELECT 
 1 AS `idsatuan`,
 1 AS `nama_satuan`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_satuan_aktif`
--

DROP TABLE IF EXISTS `v_satuan_aktif`;
/*!50001 DROP VIEW IF EXISTS `v_satuan_aktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_satuan_aktif` AS SELECT 
 1 AS `idsatuan`,
 1 AS `nama_satuan`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_satuan_nonaktif`
--

DROP TABLE IF EXISTS `v_satuan_nonaktif`;
/*!50001 DROP VIEW IF EXISTS `v_satuan_nonaktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_satuan_nonaktif` AS SELECT 
 1 AS `idsatuan`,
 1 AS `nama_satuan`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_user`
--

DROP TABLE IF EXISTS `v_user`;
/*!50001 DROP VIEW IF EXISTS `v_user`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_user` AS SELECT 
 1 AS `iduser`,
 1 AS `username`,
 1 AS `idrole`,
 1 AS `nama_role`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_user_aktif`
--

DROP TABLE IF EXISTS `v_user_aktif`;
/*!50001 DROP VIEW IF EXISTS `v_user_aktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_user_aktif` AS SELECT 
 1 AS `iduser`,
 1 AS `username`,
 1 AS `idrole`,
 1 AS `nama_role`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_user_nonaktif`
--

DROP TABLE IF EXISTS `v_user_nonaktif`;
/*!50001 DROP VIEW IF EXISTS `v_user_nonaktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_user_nonaktif` AS SELECT 
 1 AS `iduser`,
 1 AS `username`,
 1 AS `idrole`,
 1 AS `nama_role`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_vendor`
--

DROP TABLE IF EXISTS `v_vendor`;
/*!50001 DROP VIEW IF EXISTS `v_vendor`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_vendor` AS SELECT 
 1 AS `idvendor`,
 1 AS `nama_vendor`,
 1 AS `badan_hukum`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_vendor_aktif`
--

DROP TABLE IF EXISTS `v_vendor_aktif`;
/*!50001 DROP VIEW IF EXISTS `v_vendor_aktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_vendor_aktif` AS SELECT 
 1 AS `idvendor`,
 1 AS `nama_vendor`,
 1 AS `badan_hukum`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_vendor_nonaktif`
--

DROP TABLE IF EXISTS `v_vendor_nonaktif`;
/*!50001 DROP VIEW IF EXISTS `v_vendor_nonaktif`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_vendor_nonaktif` AS SELECT 
 1 AS `idvendor`,
 1 AS `nama_vendor`,
 1 AS `badan_hukum`,
 1 AS `status`,
 1 AS `status_label`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `vendor`
--

DROP TABLE IF EXISTS `vendor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor` (
  `idvendor` int NOT NULL AUTO_INCREMENT,
  `nama_vendor` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `badan_hukum` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N',
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`idvendor`),
  CONSTRAINT `ck_vendor_badan` CHECK ((`badan_hukum` in (_utf8mb4'Y',_utf8mb4'N'))),
  CONSTRAINT `ck_vendor_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'pbd_toko_sembako'
--

--
-- Dumping routines for database 'pbd_toko_sembako'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_harga_jual` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_harga_jual`(p_harga BIGINT, p_persen DECIMAL(5, 2)) RETURNS bigint
    NO SQL
    DETERMINISTIC
BEGIN
    IF p_harga IS NULL OR p_persen IS NULL
          OR p_harga < 0 OR p_persen < 0 OR p_persen > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Harga atau margin tidak valid';
    END IF;
    RETURN ROUND(p_harga * (1 + p_persen/100), 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_subtotal_transaksi` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_subtotal_transaksi`(
    p_jenis CHAR(1),
    p_id BIGINT
) RETURNS bigint
    READS SQL DATA
BEGIN
    DECLARE v_subtotal BIGINT DEFAULT 0;

    IF p_jenis = 'P' THEN
        SELECT COALESCE(SUM(sub_total), 0)
        INTO v_subtotal
        FROM detail_pengadaan
        WHERE idpengadaan = p_id;

    ELSEIF p_jenis = 'J' THEN
        SELECT COALESCE(SUM(subtotal), 0)
        INTO v_subtotal
        FROM detail_penjualan
        WHERE penjualan_idpenjualan = p_id;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jenis transaksi tidak valid';
    END IF;

    RETURN v_subtotal;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_total_dengan_ppn` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_dengan_ppn`(p_subtotal BIGINT, p_tarif_ppn DECIMAL(5, 2)) RETURNS bigint
    NO SQL
    DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(30, 0);
    IF p_subtotal IS NULL OR p_tarif_ppn IS NULL
          OR p_subtotal < 0 OR p_tarif_ppn < 0 OR p_tarif_ppn > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Subtotal atau tarif PPN tidak valid';
    END IF;
    SET v_total = ROUND(CAST(p_subtotal AS DECIMAL(30, 0))*(1+p_tarif_ppn/100), 0);
    IF v_total > 9223372036854775807 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total termasuk PPN terlalu besar';
    END IF;
    RETURN CAST(v_total AS SIGNED);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_aktifkan_margin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_aktifkan_margin`(IN p_idmargin INT, IN p_iduser INT)
BEGIN
    DECLARE v_margin INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    SELECT idmargin_penjualan INTO v_margin
    FROM margin_penjualan WHERE idmargin_penjualan = p_idmargin FOR UPDATE;
    IF v_margin IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID margin tidak ditemukan';
    END IF;
    UPDATE margin_penjualan
    SET status = 0, updated_at = NOW()
    WHERE status = 1 AND idmargin_penjualan <> p_idmargin;
    UPDATE margin_penjualan
    SET status = 1, iduser = p_iduser, updated_at = NOW()
    WHERE idmargin_penjualan = p_idmargin;
    COMMIT;
    SELECT p_idmargin AS idmargin_penjualan, 'Aktif' AS hasil;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_konfirmasi_penerimaan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_konfirmasi_penerimaan`(IN p_idpenerimaan BIGINT)
BEGIN
    DECLARE v_po BIGINT DEFAULT NULL;
    DECLARE v_status CHAR(1) DEFAULT NULL;
    DECLARE v_po_status CHAR(1) DEFAULT NULL;
    DECLARE v_konfirmasi TIMESTAMP DEFAULT NULL;
    DECLARE v_pesan INT DEFAULT 0;
    DECLARE v_periksa INT DEFAULT 0;
    DECLARE v_salah INT DEFAULT 0;
    DECLARE v_belum INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT idpengadaan, status INTO v_po, v_status
    FROM penerimaan WHERE idpenerimaan = p_idpenerimaan FOR UPDATE;
    IF v_status IS NULL OR v_status <> 'P' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Penerimaan sudah selesai atau tidak ditemukan';
    END IF;

    SELECT status, dikonfirmasi_at INTO v_po_status, v_konfirmasi
    FROM pengadaan WHERE idpengadaan = v_po FOR UPDATE;
    IF v_po_status <> 'P' OR v_konfirmasi IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pengadaan belum dikonfirmasi atau sudah selesai';
    END IF;

    SELECT COUNT(*) INTO v_pesan
    FROM detail_pengadaan WHERE idpengadaan = v_po;

    SELECT COUNT(*) INTO v_periksa
    FROM detail_penerimaan WHERE idpenerimaan = p_idpenerimaan;
    IF v_pesan <> v_periksa THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Periksa seluruh barang, termasuk yang tidak datang';
    END IF;

    SELECT COUNT(*) INTO v_salah
    FROM detail_penerimaan d
    WHERE d.idpenerimaan = p_idpenerimaan
    AND NOT EXISTS (
        SELECT 1 FROM detail_pengadaan o
        WHERE o.idpengadaan = v_po AND o.idbarang = d.barang_idbarang
    );
    IF v_salah > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Barang tidak sesuai pengadaan';
    END IF;

    SELECT COUNT(*) INTO v_salah
    FROM detail_pengadaan o
    JOIN detail_penerimaan d
        ON d.idpenerimaan = p_idpenerimaan AND d.barang_idbarang = o.idbarang
    LEFT JOIN (
        SELECT d2.barang_idbarang, SUM(d2.jumlah_terima) AS sudah
        FROM penerimaan r2
        JOIN detail_penerimaan d2 ON d2.idpenerimaan = r2.idpenerimaan
        WHERE r2.idpengadaan = v_po AND r2.status = 'S'
        GROUP BY d2.barang_idbarang
    ) prev ON prev.barang_idbarang = o.idbarang
    WHERE o.idpengadaan = v_po
    AND d.jumlah_terima + COALESCE(prev.sudah, 0) > o.jumlah;
    IF v_salah > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jumlah diterima melebihi sisa pesanan';
    END IF;

    UPDATE detail_penerimaan
    SET sub_total_terima = jumlah_terima * harga_satuan_terima
    WHERE idpenerimaan = p_idpenerimaan;

    INSERT INTO kartu_stok
        (jenis_transaksi, masuk, keluar, idtransaksi, idbarang, sumber_transaksi)
    SELECT 'M', jumlah_terima, 0, iddetail_penerimaan, barang_idbarang, 'PENERIMAAN'
    FROM detail_penerimaan
    WHERE idpenerimaan = p_idpenerimaan AND jumlah_terima > 0
    ORDER BY barang_idbarang, iddetail_penerimaan;

    UPDATE barang b
    JOIN detail_penerimaan d ON d.barang_idbarang = b.idbarang
    SET b.harga = d.harga_satuan_terima
    WHERE d.idpenerimaan = p_idpenerimaan AND d.jumlah_terima > 0;

    UPDATE penerimaan SET status = 'S' WHERE idpenerimaan = p_idpenerimaan;

    SELECT COUNT(*) INTO v_belum
    FROM detail_pengadaan o
    LEFT JOIN (
        SELECT d2.barang_idbarang, SUM(d2.jumlah_terima) AS sudah
        FROM penerimaan r2
        JOIN detail_penerimaan d2 ON d2.idpenerimaan = r2.idpenerimaan
        WHERE r2.idpengadaan = v_po AND r2.status = 'S'
        GROUP BY d2.barang_idbarang
    ) got ON got.barang_idbarang = o.idbarang
    WHERE o.idpengadaan = v_po
    AND COALESCE(got.sudah, 0) < o.jumlah;

    IF v_belum = 0 THEN
        UPDATE pengadaan SET status = 'S' WHERE idpengadaan = v_po;
    END IF;

    COMMIT;
    SELECT p_idpenerimaan AS idpenerimaan, 'Selesai' AS hasil;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_konfirmasi_pengadaan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_konfirmasi_pengadaan`(
    IN p_idpengadaan BIGINT
)
BEGIN
    DECLARE v_status CHAR(1) DEFAULT NULL;
    DECLARE v_konfirmasi TIMESTAMP DEFAULT NULL;
    DECLARE v_vendor INT DEFAULT NULL;
    DECLARE v_vendor_status CHAR(1) DEFAULT NULL;
    DECLARE v_baris INT DEFAULT 0;
    DECLARE v_tidak_aktif INT DEFAULT 0;
    DECLARE v_subtotal BIGINT DEFAULT 0;
    DECLARE v_total BIGINT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status, dikonfirmasi_at, vendor_idvendor
    INTO v_status, v_konfirmasi, v_vendor
    FROM pengadaan
    WHERE idpengadaan = p_idpengadaan
    FOR UPDATE;

    IF v_status IS NULL OR v_status <> 'P'
       OR v_konfirmasi IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pengadaan tidak dapat dikonfirmasi ulang';
    END IF;

    SELECT status INTO v_vendor_status
    FROM vendor
    WHERE idvendor = v_vendor;

    IF v_vendor_status IS NULL OR v_vendor_status <> '1' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vendor tidak aktif';
    END IF;

    SELECT COUNT(*) INTO v_baris
    FROM detail_pengadaan
    WHERE idpengadaan = p_idpengadaan;

    IF v_baris = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Detail pengadaan belum diisi';
    END IF;

    SELECT COUNT(*) INTO v_tidak_aktif
    FROM detail_pengadaan d
    JOIN barang b ON b.idbarang = d.idbarang
    WHERE d.idpengadaan = p_idpengadaan
    AND b.status <> 1;

    IF v_tidak_aktif > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ada barang tidak aktif';
    END IF;

    UPDATE detail_pengadaan
    SET sub_total = jumlah * harga_satuan
    WHERE idpengadaan = p_idpengadaan;

    SET v_subtotal = fn_subtotal_transaksi('P', p_idpengadaan);
    SET v_total = fn_total_dengan_ppn(v_subtotal, 12.00);

    UPDATE pengadaan
    SET subtotal_nilai = v_subtotal,
        tarif_ppn = 12.00,
        ppn = v_total - v_subtotal,
        total_nilai = v_total,
        dikonfirmasi_at = NOW()
    WHERE idpengadaan = p_idpengadaan;

    COMMIT;

    SELECT p_idpengadaan AS idpengadaan,
           'Dalam Proses' AS hasil;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_konfirmasi_penjualan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_konfirmasi_penjualan`(
    IN p_idpenjualan INT
)
BEGIN
    DECLARE v_status CHAR(1) DEFAULT NULL;
    DECLARE v_margin_id INT DEFAULT NULL;
    DECLARE v_persen DECIMAL(5,2) DEFAULT NULL;
    DECLARE v_baris INT DEFAULT 0;
    DECLARE v_nonaktif INT DEFAULT 0;
    DECLARE v_subtotal BIGINT DEFAULT 0;
    DECLARE v_total BIGINT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status INTO v_status
    FROM penjualan
    WHERE idpenjualan = p_idpenjualan
    FOR UPDATE;

    IF v_status IS NULL OR v_status <> 'D' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Penjualan harus berstatus Draft';
    END IF;

    SELECT idmargin_penjualan, persen
    INTO v_margin_id, v_persen
    FROM margin_penjualan
    WHERE status = 1
    LIMIT 1 FOR UPDATE;

    IF v_margin_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Belum ada margin aktif';
    END IF;

    SELECT COUNT(*) INTO v_baris
    FROM detail_penjualan
    WHERE penjualan_idpenjualan = p_idpenjualan;

    IF v_baris = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Detail penjualan belum diisi';
    END IF;

    SELECT COUNT(*) INTO v_nonaktif
    FROM detail_penjualan d
    JOIN barang b ON b.idbarang = d.idbarang
    WHERE d.penjualan_idpenjualan = p_idpenjualan
    AND b.status <> 1;

    IF v_nonaktif > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Barang tidak aktif tidak bisa dijual';
    END IF;

    UPDATE detail_penjualan d
    JOIN barang b ON b.idbarang = d.idbarang
    SET d.harga_satuan = fn_harga_jual(b.harga, v_persen),
        d.subtotal = d.jumlah * fn_harga_jual(b.harga, v_persen)
    WHERE d.penjualan_idpenjualan = p_idpenjualan;

    SET v_subtotal = fn_subtotal_transaksi('J', p_idpenjualan);
    SET v_total = fn_total_dengan_ppn(v_subtotal, 11.00);

    INSERT INTO kartu_stok (
        jenis_transaksi,
        masuk,
        keluar,
        idtransaksi,
        idbarang,
        sumber_transaksi
    )
    SELECT
        'K',
        0,
        jumlah,
        iddetail_penjualan,
        idbarang,
        'PENJUALAN'
    FROM detail_penjualan
    WHERE penjualan_idpenjualan = p_idpenjualan
    ORDER BY idbarang, iddetail_penjualan;

    UPDATE penjualan
    SET idmargin_penjualan = v_margin_id,
        subtotal_nilai = v_subtotal,
        tarif_ppn = 11.00,
        ppn = v_total - v_subtotal,
        total_nilai = v_total,
        status = 'S'
    WHERE idpenjualan = p_idpenjualan;

    COMMIT;

    SELECT p_idpenjualan AS idpenjualan,
           'Selesai' AS hasil;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_konfirmasi_retur` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_konfirmasi_retur`(IN p_idretur BIGINT)
BEGIN
    DECLARE v_penerimaan BIGINT DEFAULT NULL;
    DECLARE v_status CHAR(1) DEFAULT NULL;
    DECLARE v_status_penerimaan CHAR(1) DEFAULT NULL;
    DECLARE v_baris INT DEFAULT 0;
    DECLARE v_salah INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT idpenerimaan, status INTO v_penerimaan, v_status
    FROM retur WHERE idretur = p_idretur FOR UPDATE;
    IF v_status IS NULL OR v_status <> 'D' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Retur harus berstatus Draft';
    END IF;
    SELECT status INTO v_status_penerimaan
    FROM penerimaan WHERE idpenerimaan = v_penerimaan FOR UPDATE;
    IF v_status_penerimaan <> 'S' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Retur harus merujuk penerimaan selesai';
    END IF;
    SELECT COUNT(*) INTO v_baris FROM detail_retur WHERE idretur = p_idretur;
    IF v_baris = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Retur belum memiliki detail';
    END IF;
    SELECT COUNT(*) INTO v_salah
    FROM detail_retur d JOIN detail_penerimaan dp
        ON dp.iddetail_penerimaan = d.iddetail_penerimaan
    WHERE d.idretur = p_idretur AND dp.idpenerimaan <> v_penerimaan;
    IF v_salah > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Detail retur bukan dari penerimaan yang sama';
    END IF;
    SELECT COUNT(*) INTO v_salah
    FROM detail_retur d
    JOIN detail_penerimaan dp ON dp.iddetail_penerimaan = d.iddetail_penerimaan
    LEFT JOIN (
        SELECT r2.iddetail_penerimaan, SUM(r2.jumlah) AS sudah_retur
        FROM detail_retur r2 JOIN retur induk ON induk.idretur = r2.idretur
        WHERE induk.status = 'S' AND induk.idpenerimaan = v_penerimaan
        GROUP BY r2.iddetail_penerimaan
    ) prev ON prev.iddetail_penerimaan = d.iddetail_penerimaan
    WHERE d.idretur = p_idretur AND d.jumlah+COALESCE(prev.sudah_retur, 0) > dp.jumlah_terima;
    IF v_salah > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jumlah retur melebihi barang diterima';
    END IF;
    INSERT INTO kartu_stok
        (jenis_transaksi, masuk, keluar, idtransaksi, idbarang, sumber_transaksi)
    SELECT 'K', 0, d.jumlah, d.iddetail_retur, p.barang_idbarang, 'RETUR'
    FROM detail_retur d JOIN detail_penerimaan p
        ON p.iddetail_penerimaan = d.iddetail_penerimaan
    WHERE d.idretur = p_idretur
    ORDER BY p.barang_idbarang, d.iddetail_retur;
    UPDATE retur SET status = 'S' WHERE idretur = p_idretur;
    COMMIT;
    SELECT p_idretur AS idretur, 'Selesai' AS hasil;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_verifikasi_penerimaan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verifikasi_penerimaan`(IN p_idpenerimaan BIGINT)
BEGIN
    SELECT
        d.idbarang, b.nama AS nama_barang, d.jumlah AS jumlah_dipesan,
        COALESCE(prev.jumlah, 0) AS sudah_diterima_sebelumnya,
        dt.jumlah_terima AS diterima_pada_pemeriksaan_ini,
        GREATEST(d.jumlah-COALESCE(prev.jumlah, 0), 0) AS sisa_sebelum_pemeriksaan,
        CASE
            WHEN dt.iddetail_penerimaan IS NULL THEN 'BELUM_DIPERIKSA'
            WHEN dt.jumlah_terima = 0 THEN 'TIDAK_DATANG'
            WHEN dt.jumlah_terima > d.jumlah-COALESCE(prev.jumlah, 0) THEN 'MELEBIHI_PESANAN'
            WHEN dt.jumlah_terima < d.jumlah-COALESCE(prev.jumlah, 0) THEN 'DITERIMA_SEBAGIAN'
            ELSE 'LENGKAP'
        END AS hasil_verifikasi
    FROM penerimaan p
    JOIN detail_pengadaan d ON d.idpengadaan = p.idpengadaan
    JOIN barang b ON b.idbarang = d.idbarang
    LEFT JOIN (
        SELECT r.idpengadaan, dp.barang_idbarang, SUM(dp.jumlah_terima) AS jumlah
        FROM penerimaan r JOIN detail_penerimaan dp ON dp.idpenerimaan = r.idpenerimaan
        WHERE r.status = 'S' AND r.idpenerimaan <> p_idpenerimaan
        GROUP BY r.idpengadaan, dp.barang_idbarang
    ) prev ON prev.idpengadaan = p.idpengadaan AND prev.barang_idbarang = d.idbarang
    LEFT JOIN detail_penerimaan dt ON dt.idpenerimaan = p.idpenerimaan AND dt.barang_idbarang = d.idbarang
    WHERE p.idpenerimaan = p_idpenerimaan
    ORDER BY d.iddetail_pengadaan;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `pbd_toko_sembako`
--

USE `pbd_toko_sembako`;

--
-- Final view structure for view `v_barang`
--

/*!50001 DROP VIEW IF EXISTS `v_barang`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_barang` AS select `b`.`idbarang` AS `idbarang`,`b`.`jenis` AS `jenis`,`b`.`nama` AS `nama`,`b`.`idsatuan` AS `idsatuan`,`s`.`nama_satuan` AS `nama_satuan`,`b`.`status` AS `status`,if((`b`.`status` = 1),'Aktif','Tidak Aktif') AS `status_label`,`b`.`harga` AS `harga`,`b`.`stok_tersedia` AS `stok_tersedia` from (`barang` `b` join `satuan` `s` on((`s`.`idsatuan` = `b`.`idsatuan`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_barang_aktif`
--

/*!50001 DROP VIEW IF EXISTS `v_barang_aktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_barang_aktif` AS select `v_barang`.`idbarang` AS `idbarang`,`v_barang`.`jenis` AS `jenis`,`v_barang`.`nama` AS `nama`,`v_barang`.`idsatuan` AS `idsatuan`,`v_barang`.`nama_satuan` AS `nama_satuan`,`v_barang`.`status` AS `status`,`v_barang`.`status_label` AS `status_label`,`v_barang`.`harga` AS `harga`,`v_barang`.`stok_tersedia` AS `stok_tersedia` from `v_barang` where (`v_barang`.`status` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_barang_nonaktif`
--

/*!50001 DROP VIEW IF EXISTS `v_barang_nonaktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_barang_nonaktif` AS select `v_barang`.`idbarang` AS `idbarang`,`v_barang`.`jenis` AS `jenis`,`v_barang`.`nama` AS `nama`,`v_barang`.`idsatuan` AS `idsatuan`,`v_barang`.`nama_satuan` AS `nama_satuan`,`v_barang`.`status` AS `status`,`v_barang`.`status_label` AS `status_label`,`v_barang`.`harga` AS `harga`,`v_barang`.`stok_tersedia` AS `stok_tersedia` from `v_barang` where (`v_barang`.`status` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_detail_penerimaan`
--

/*!50001 DROP VIEW IF EXISTS `v_detail_penerimaan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_detail_penerimaan` AS select `d`.`iddetail_penerimaan` AS `iddetail_penerimaan`,`d`.`idpenerimaan` AS `idpenerimaan`,`d`.`barang_idbarang` AS `idbarang`,`b`.`nama` AS `nama_barang`,`d`.`jumlah_terima` AS `jumlah_terima`,`d`.`harga_satuan_terima` AS `harga_satuan_terima`,`d`.`sub_total_terima` AS `sub_total_terima`,if((`d`.`jumlah_terima` = 0),'Tidak Datang','Datang') AS `kondisi_pengiriman` from (`detail_penerimaan` `d` join `barang` `b` on((`b`.`idbarang` = `d`.`barang_idbarang`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_detail_pengadaan`
--

/*!50001 DROP VIEW IF EXISTS `v_detail_pengadaan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_detail_pengadaan` AS select `d`.`iddetail_pengadaan` AS `iddetail_pengadaan`,`d`.`idpengadaan` AS `idpengadaan`,`d`.`idbarang` AS `idbarang`,`b`.`nama` AS `nama_barang`,`d`.`jumlah` AS `jumlah`,`d`.`harga_satuan` AS `harga_satuan`,`d`.`sub_total` AS `sub_total` from (`detail_pengadaan` `d` join `barang` `b` on((`b`.`idbarang` = `d`.`idbarang`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_detail_penjualan`
--

/*!50001 DROP VIEW IF EXISTS `v_detail_penjualan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_detail_penjualan` AS select `d`.`iddetail_penjualan` AS `iddetail_penjualan`,`d`.`penjualan_idpenjualan` AS `penjualan_idpenjualan`,`d`.`idbarang` AS `idbarang`,`b`.`nama` AS `nama_barang`,`d`.`harga_satuan` AS `harga_satuan`,`d`.`jumlah` AS `jumlah`,`d`.`subtotal` AS `subtotal` from (`detail_penjualan` `d` join `barang` `b` on((`b`.`idbarang` = `d`.`idbarang`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_detail_retur`
--

/*!50001 DROP VIEW IF EXISTS `v_detail_retur`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_detail_retur` AS select `d`.`iddetail_retur` AS `iddetail_retur`,`d`.`idretur` AS `idretur`,`d`.`iddetail_penerimaan` AS `iddetail_penerimaan`,`p`.`barang_idbarang` AS `idbarang`,`b`.`nama` AS `nama_barang`,`d`.`jumlah` AS `jumlah`,`d`.`alasan` AS `alasan` from ((`detail_retur` `d` join `detail_penerimaan` `p` on((`p`.`iddetail_penerimaan` = `d`.`iddetail_penerimaan`))) join `barang` `b` on((`b`.`idbarang` = `p`.`barang_idbarang`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_kartu_stok`
--

/*!50001 DROP VIEW IF EXISTS `v_kartu_stok`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_kartu_stok` AS select `k`.`idkartu_stok` AS `idkartu_stok`,`k`.`idbarang` AS `idbarang`,`b`.`nama` AS `nama_barang`,`k`.`jenis_transaksi` AS `jenis_transaksi`,`k`.`masuk` AS `masuk`,`k`.`keluar` AS `keluar`,`k`.`stock` AS `stock`,`k`.`created_at` AS `created_at`,`k`.`sumber_transaksi` AS `sumber_transaksi`,`k`.`idtransaksi` AS `idtransaksi` from (`kartu_stok` `k` join `barang` `b` on((`b`.`idbarang` = `k`.`idbarang`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_margin_penjualan`
--

/*!50001 DROP VIEW IF EXISTS `v_margin_penjualan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_margin_penjualan` AS select `m`.`idmargin_penjualan` AS `idmargin_penjualan`,`m`.`created_at` AS `created_at`,`m`.`persen` AS `persen`,`m`.`status` AS `status`,if((`m`.`status` = 1),'Aktif','Tidak Aktif') AS `status_label`,`m`.`iduser` AS `iduser`,`u`.`username` AS `username`,`m`.`updated_at` AS `updated_at` from (`margin_penjualan` `m` join `user` `u` on((`u`.`iduser` = `m`.`iduser`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_margin_penjualan_aktif`
--

/*!50001 DROP VIEW IF EXISTS `v_margin_penjualan_aktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_margin_penjualan_aktif` AS select `v_margin_penjualan`.`idmargin_penjualan` AS `idmargin_penjualan`,`v_margin_penjualan`.`created_at` AS `created_at`,`v_margin_penjualan`.`persen` AS `persen`,`v_margin_penjualan`.`status` AS `status`,`v_margin_penjualan`.`status_label` AS `status_label`,`v_margin_penjualan`.`iduser` AS `iduser`,`v_margin_penjualan`.`username` AS `username`,`v_margin_penjualan`.`updated_at` AS `updated_at` from `v_margin_penjualan` where (`v_margin_penjualan`.`status` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_margin_penjualan_nonaktif`
--

/*!50001 DROP VIEW IF EXISTS `v_margin_penjualan_nonaktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_margin_penjualan_nonaktif` AS select `v_margin_penjualan`.`idmargin_penjualan` AS `idmargin_penjualan`,`v_margin_penjualan`.`created_at` AS `created_at`,`v_margin_penjualan`.`persen` AS `persen`,`v_margin_penjualan`.`status` AS `status`,`v_margin_penjualan`.`status_label` AS `status_label`,`v_margin_penjualan`.`iduser` AS `iduser`,`v_margin_penjualan`.`username` AS `username`,`v_margin_penjualan`.`updated_at` AS `updated_at` from `v_margin_penjualan` where (`v_margin_penjualan`.`status` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_penerimaan`
--

/*!50001 DROP VIEW IF EXISTS `v_penerimaan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_penerimaan` AS select `p`.`idpenerimaan` AS `idpenerimaan`,`p`.`created_at` AS `created_at`,`p`.`idpengadaan` AS `idpengadaan`,`p`.`iduser` AS `iduser`,`u`.`username` AS `username`,`p`.`status` AS `status`,if((`p`.`status` = 'P'),'Dalam Proses','Selesai') AS `status_label` from (`penerimaan` `p` join `user` `u` on((`u`.`iduser` = `p`.`iduser`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pengadaan`
--

/*!50001 DROP VIEW IF EXISTS `v_pengadaan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pengadaan` AS select `p`.`idpengadaan` AS `idpengadaan`,`p`.`timestamp` AS `timestamp`,`p`.`dikonfirmasi_at` AS `dikonfirmasi_at`,`p`.`user_iduser` AS `user_iduser`,`u`.`username` AS `username`,`p`.`vendor_idvendor` AS `vendor_idvendor`,`v`.`nama_vendor` AS `nama_vendor`,`p`.`status` AS `status`,if((`p`.`status` = 'P'),'Dalam Proses','Selesai') AS `status_label`,`p`.`subtotal_nilai` AS `subtotal_nilai`,`p`.`tarif_ppn` AS `tarif_ppn`,`p`.`ppn` AS `ppn`,`p`.`total_nilai` AS `total_nilai` from ((`pengadaan` `p` join `user` `u` on((`u`.`iduser` = `p`.`user_iduser`))) join `vendor` `v` on((`v`.`idvendor` = `p`.`vendor_idvendor`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_penjualan`
--

/*!50001 DROP VIEW IF EXISTS `v_penjualan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_penjualan` AS select `p`.`idpenjualan` AS `idpenjualan`,`p`.`created_at` AS `created_at`,`p`.`iduser` AS `iduser`,`u`.`username` AS `username`,`p`.`idmargin_penjualan` AS `idmargin_penjualan`,(case when (`p`.`status` = 'D') then coalesce((select `aktif`.`persen` from `margin_penjualan` `aktif` where (`aktif`.`status` = 1) limit 1),`m`.`persen`) else `m`.`persen` end) AS `margin_persen`,`p`.`status` AS `status`,if((`p`.`status` = 'D'),'Draft','Selesai') AS `status_label`,`p`.`subtotal_nilai` AS `subtotal_nilai`,`p`.`tarif_ppn` AS `tarif_ppn`,`p`.`ppn` AS `ppn`,`p`.`total_nilai` AS `total_nilai` from ((`penjualan` `p` join `user` `u` on((`u`.`iduser` = `p`.`iduser`))) join `margin_penjualan` `m` on((`m`.`idmargin_penjualan` = `p`.`idmargin_penjualan`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_retur`
--

/*!50001 DROP VIEW IF EXISTS `v_retur`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_retur` AS select `r`.`idretur` AS `idretur`,`r`.`created_at` AS `created_at`,`r`.`idpenerimaan` AS `idpenerimaan`,`r`.`iduser` AS `iduser`,`u`.`username` AS `username`,`r`.`status` AS `status`,if((`r`.`status` = 'D'),'Draft','Selesai') AS `status_label` from (`retur` `r` join `user` `u` on((`u`.`iduser` = `r`.`iduser`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_role`
--

/*!50001 DROP VIEW IF EXISTS `v_role`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_role` AS select `role`.`idrole` AS `idrole`,`role`.`nama_role` AS `nama_role`,`role`.`status` AS `status`,if((`role`.`status` = 1),'Aktif','Tidak Aktif') AS `status_label` from `role` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_role_aktif`
--

/*!50001 DROP VIEW IF EXISTS `v_role_aktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_role_aktif` AS select `v_role`.`idrole` AS `idrole`,`v_role`.`nama_role` AS `nama_role`,`v_role`.`status` AS `status`,`v_role`.`status_label` AS `status_label` from `v_role` where (`v_role`.`status` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_role_nonaktif`
--

/*!50001 DROP VIEW IF EXISTS `v_role_nonaktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_role_nonaktif` AS select `v_role`.`idrole` AS `idrole`,`v_role`.`nama_role` AS `nama_role`,`v_role`.`status` AS `status`,`v_role`.`status_label` AS `status_label` from `v_role` where (`v_role`.`status` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_satuan`
--

/*!50001 DROP VIEW IF EXISTS `v_satuan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_satuan` AS select `satuan`.`idsatuan` AS `idsatuan`,`satuan`.`nama_satuan` AS `nama_satuan`,`satuan`.`status` AS `status`,if((`satuan`.`status` = 1),'Aktif','Tidak Aktif') AS `status_label` from `satuan` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_satuan_aktif`
--

/*!50001 DROP VIEW IF EXISTS `v_satuan_aktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_satuan_aktif` AS select `v_satuan`.`idsatuan` AS `idsatuan`,`v_satuan`.`nama_satuan` AS `nama_satuan`,`v_satuan`.`status` AS `status`,`v_satuan`.`status_label` AS `status_label` from `v_satuan` where (`v_satuan`.`status` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_satuan_nonaktif`
--

/*!50001 DROP VIEW IF EXISTS `v_satuan_nonaktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_satuan_nonaktif` AS select `v_satuan`.`idsatuan` AS `idsatuan`,`v_satuan`.`nama_satuan` AS `nama_satuan`,`v_satuan`.`status` AS `status`,`v_satuan`.`status_label` AS `status_label` from `v_satuan` where (`v_satuan`.`status` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user`
--

/*!50001 DROP VIEW IF EXISTS `v_user`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user` AS select `u`.`iduser` AS `iduser`,`u`.`username` AS `username`,`u`.`idrole` AS `idrole`,`r`.`nama_role` AS `nama_role`,`u`.`status` AS `status`,if((`u`.`status` = 1),'Aktif','Tidak Aktif') AS `status_label` from (`user` `u` join `role` `r` on((`r`.`idrole` = `u`.`idrole`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_aktif`
--

/*!50001 DROP VIEW IF EXISTS `v_user_aktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_aktif` AS select `v_user`.`iduser` AS `iduser`,`v_user`.`username` AS `username`,`v_user`.`idrole` AS `idrole`,`v_user`.`nama_role` AS `nama_role`,`v_user`.`status` AS `status`,`v_user`.`status_label` AS `status_label` from `v_user` where (`v_user`.`status` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_nonaktif`
--

/*!50001 DROP VIEW IF EXISTS `v_user_nonaktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_nonaktif` AS select `v_user`.`iduser` AS `iduser`,`v_user`.`username` AS `username`,`v_user`.`idrole` AS `idrole`,`v_user`.`nama_role` AS `nama_role`,`v_user`.`status` AS `status`,`v_user`.`status_label` AS `status_label` from `v_user` where (`v_user`.`status` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_vendor`
--

/*!50001 DROP VIEW IF EXISTS `v_vendor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_vendor` AS select `vendor`.`idvendor` AS `idvendor`,`vendor`.`nama_vendor` AS `nama_vendor`,`vendor`.`badan_hukum` AS `badan_hukum`,`vendor`.`status` AS `status`,if((`vendor`.`status` = '1'),'Aktif','Tidak Aktif') AS `status_label` from `vendor` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_vendor_aktif`
--

/*!50001 DROP VIEW IF EXISTS `v_vendor_aktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_vendor_aktif` AS select `v_vendor`.`idvendor` AS `idvendor`,`v_vendor`.`nama_vendor` AS `nama_vendor`,`v_vendor`.`badan_hukum` AS `badan_hukum`,`v_vendor`.`status` AS `status`,`v_vendor`.`status_label` AS `status_label` from `v_vendor` where (`v_vendor`.`status` = '1') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_vendor_nonaktif`
--

/*!50001 DROP VIEW IF EXISTS `v_vendor_nonaktif`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_vendor_nonaktif` AS select `v_vendor`.`idvendor` AS `idvendor`,`v_vendor`.`nama_vendor` AS `nama_vendor`,`v_vendor`.`badan_hukum` AS `badan_hukum`,`v_vendor`.`status` AS `status`,`v_vendor`.`status_label` AS `status_label` from `v_vendor` where (`v_vendor`.`status` = '0') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-24 13:28:34
