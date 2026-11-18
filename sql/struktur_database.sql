-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: pbd_ruang_stok_baru
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
  `harga` int NOT NULL DEFAULT '0',
  `stok_tersedia` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`idbarang`),
  KEY `fk_barang_satuan` (`idsatuan`),
  KEY `idx_barang_nama` (`nama`),
  CONSTRAINT `fk_barang_satuan` FOREIGN KEY (`idsatuan`) REFERENCES `satuan` (`idsatuan`),
  CONSTRAINT `ck_barang_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `jumlah_terima` int NOT NULL,
  `harga_satuan_terima` int NOT NULL,
  `sub_total_terima` int NOT NULL,
  PRIMARY KEY (`iddetail_penerimaan`),
  UNIQUE KEY `uk_penerimaan_barang` (`idpenerimaan`,`barang_idbarang`),
  KEY `fk_detail_penerimaan_barang` (`barang_idbarang`),
  CONSTRAINT `fk_detail_penerimaan_barang` FOREIGN KEY (`barang_idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `fk_detail_penerimaan_penerimaan` FOREIGN KEY (`idpenerimaan`) REFERENCES `penerimaan` (`idpenerimaan`),
  CONSTRAINT `ck_detail_penerimaan_valid` CHECK (((`jumlah_terima` >= 0) and (`harga_satuan_terima` >= 0) and (`sub_total_terima` = (cast(`jumlah_terima` as signed) * cast(`harga_satuan_terima` as signed)))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detail_pengadaan`
--

DROP TABLE IF EXISTS `detail_pengadaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_pengadaan` (
  `iddetail_pengadaan` bigint NOT NULL AUTO_INCREMENT,
  `harga_satuan` int NOT NULL,
  `jumlah` int NOT NULL,
  `sub_total` int NOT NULL,
  `idbarang` int NOT NULL,
  `idpengadaan` bigint NOT NULL,
  PRIMARY KEY (`iddetail_pengadaan`),
  UNIQUE KEY `uk_pengadaan_barang` (`idpengadaan`,`idbarang`),
  KEY `fk_detail_pengadaan_barang` (`idbarang`),
  CONSTRAINT `fk_detail_pengadaan_barang` FOREIGN KEY (`idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `fk_detail_pengadaan_pengadaan` FOREIGN KEY (`idpengadaan`) REFERENCES `pengadaan` (`idpengadaan`),
  CONSTRAINT `ck_detail_pengadaan_valid` CHECK (((`jumlah` > 0) and (`harga_satuan` >= 0) and (`sub_total` = (cast(`jumlah` as signed) * cast(`harga_satuan` as signed)))))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detail_penjualan`
--

DROP TABLE IF EXISTS `detail_penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_penjualan` (
  `iddetail_penjualan` bigint NOT NULL AUTO_INCREMENT,
  `harga_satuan` int NOT NULL,
  `jumlah` int NOT NULL,
  `subtotal` int NOT NULL,
  `penjualan_idpenjualan` int NOT NULL,
  `idbarang` int NOT NULL,
  PRIMARY KEY (`iddetail_penjualan`),
  UNIQUE KEY `uk_penjualan_barang` (`penjualan_idpenjualan`,`idbarang`),
  KEY `fk_detail_penjualan_barang` (`idbarang`),
  CONSTRAINT `fk_detail_penjualan_barang` FOREIGN KEY (`idbarang`) REFERENCES `barang` (`idbarang`),
  CONSTRAINT `fk_detail_penjualan_penjualan` FOREIGN KEY (`penjualan_idpenjualan`) REFERENCES `penjualan` (`idpenjualan`),
  CONSTRAINT `ck_detail_penjualan_valid` CHECK (((`jumlah` > 0) and (`harga_satuan` >= 0) and (`subtotal` = (cast(`jumlah` as signed) * cast(`harga_satuan` as signed)))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  UNIQUE KEY `uk_retur_detail` (`idretur`,`iddetail_penerimaan`),
  KEY `fk_detail_retur_penerimaan` (`iddetail_penerimaan`),
  CONSTRAINT `fk_detail_retur_penerimaan` FOREIGN KEY (`iddetail_penerimaan`) REFERENCES `detail_penerimaan` (`iddetail_penerimaan`),
  CONSTRAINT `fk_detail_retur_retur` FOREIGN KEY (`idretur`) REFERENCES `retur` (`idretur`),
  CONSTRAINT `ck_detail_retur_valid` CHECK (((`jumlah` > 0) and (char_length(trim(`alasan`)) > 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `idtransaksi` bigint DEFAULT NULL,
  `idbarang` int NOT NULL,
  `sumber_transaksi` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idkartu_stok`),
  UNIQUE KEY `uk_mutasi_sumber` (`sumber_transaksi`,`idtransaksi`),
  KEY `fk_kartu_stok_barang` (`idbarang`),
  CONSTRAINT `fk_kartu_stok_barang` FOREIGN KEY (`idbarang`) REFERENCES `barang` (`idbarang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_hitung_sisa_stok` BEFORE INSERT ON `kartu_stok` FOR EACH ROW BEGIN
 DECLARE v_stok INT;
 IF NEW.masuk < 0 OR NEW.keluar < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jumlah masuk dan keluar tidak boleh negatif';
    END IF;

    IF (NEW.masuk = 0 AND NEW.keluar = 0)
       OR (NEW.masuk > 0 AND NEW.keluar > 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Isi hanya salah satu: masuk atau keluar';
    END IF;

    IF NEW.jenis_transaksi NOT IN ('M', 'K') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jenis transaksi harus M atau K';
    END IF;

    IF (NEW.jenis_transaksi = 'M' AND NEW.keluar > 0)
       OR (NEW.jenis_transaksi = 'K' AND NEW.masuk > 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jenis transaksi tidak sesuai arah stok';
    END IF;
 IF NEW.sumber_transaksi IS NULL OR NEW.sumber_transaksi NOT IN ('PENERIMAAN','PENJUALAN','RETUR') OR NEW.idtransaksi IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Mutasi harus mempunyai sumber transaksi'; END IF;
 IF (NEW.sumber_transaksi='PENERIMAAN' AND NEW.jenis_transaksi<>'M') OR (NEW.sumber_transaksi IN ('PENJUALAN','RETUR') AND NEW.jenis_transaksi<>'K') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Arah stok tidak cocok dengan sumber'; END IF;
 IF NEW.sumber_transaksi='PENERIMAAN' AND NOT EXISTS(SELECT 1 FROM detail_penerimaan d JOIN penerimaan p ON p.idpenerimaan=d.idpenerimaan WHERE d.iddetail_penerimaan=NEW.idtransaksi AND p.status='1' AND d.barang_idbarang=NEW.idbarang AND d.jumlah_terima=NEW.masuk) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sumber penerimaan tidak cocok'; END IF;
 IF NEW.sumber_transaksi='PENJUALAN' AND NOT EXISTS(SELECT 1 FROM detail_penjualan d JOIN penjualan p ON p.idpenjualan=d.penjualan_idpenjualan WHERE d.iddetail_penjualan=NEW.idtransaksi AND p.status='1' AND d.idbarang=NEW.idbarang AND d.jumlah=NEW.keluar) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sumber penjualan tidak cocok'; END IF;
 IF NEW.sumber_transaksi='RETUR' AND NOT EXISTS(SELECT 1 FROM detail_retur d JOIN retur r ON r.idretur=d.idretur JOIN detail_penerimaan p ON p.iddetail_penerimaan=d.iddetail_penerimaan WHERE d.iddetail_retur=NEW.idtransaksi AND r.status='1' AND p.barang_idbarang=NEW.idbarang AND d.jumlah=NEW.keluar) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sumber retur tidak cocok'; END IF;
 UPDATE barang SET stok_tersedia=stok_tersedia+NEW.masuk-NEW.keluar WHERE idbarang=NEW.idbarang AND stok_tersedia+NEW.masuk-NEW.keluar BETWEEN 0 AND 2147483647;
 IF ROW_COUNT()<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sisa stok tidak mencukupi atau melebihi batas'; END IF;
 SELECT stok_tersedia INTO v_stok FROM barang WHERE idbarang=NEW.idbarang;
 SET NEW.stock=v_stok;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_kartu_tolak_update` BEFORE UPDATE ON `kartu_stok` FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Riwayat stok tidak boleh diubah atau dihapus' */;;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_kartu_tolak_delete` BEFORE DELETE ON `kartu_stok` FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Riwayat stok tidak boleh diubah atau dihapus' */;;
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
  `persen` double NOT NULL,
  `status` tinyint NOT NULL DEFAULT '0',
  `iduser` int NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`idmargin_penjualan`),
  UNIQUE KEY `uk_margin_aktif` (((case when (`status` = 1) then 1 else NULL end))),
  KEY `fk_margin_user` (`iduser`),
  CONSTRAINT `fk_margin_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_margin_penjualan_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `penerimaan`
--

DROP TABLE IF EXISTS `penerimaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `penerimaan` (
  `idpenerimaan` bigint NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `idpengadaan` bigint NOT NULL,
  `iduser` int NOT NULL,
  PRIMARY KEY (`idpenerimaan`),
  KEY `fk_penerimaan_pengadaan` (`idpengadaan`),
  KEY `fk_penerimaan_user` (`iduser`),
  CONSTRAINT `fk_penerimaan_pengadaan` FOREIGN KEY (`idpengadaan`) REFERENCES `pengadaan` (`idpengadaan`),
  CONSTRAINT `fk_penerimaan_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_penerimaan_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_penerimaan_induk_update` BEFORE UPDATE ON `penerimaan` FOR EACH ROW BEGIN IF OLD.status<>'0' AND (NEW.idpengadaan<>OLD.idpengadaan OR NEW.iduser<>OLD.iduser) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi sudah dikunci'; END IF; IF OLD.status='1' AND NEW.status<>'1' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi selesai tidak dapat dibuka kembali'; END IF; IF NEW.idpengadaan<>OLD.idpengadaan AND EXISTS(SELECT 1 FROM detail_penerimaan WHERE idpenerimaan=OLD.idpenerimaan) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pengadaan asal tidak dapat diganti'; END IF; END */;;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_terima_otomatis_kartu_stok` AFTER UPDATE ON `penerimaan` FOR EACH ROW BEGIN
 DECLARE v_status CHAR(1);
 IF OLD.status='0' AND NEW.status='1' THEN
 SELECT status INTO v_status FROM pengadaan WHERE idpengadaan=NEW.idpengadaan FOR UPDATE;
 IF v_status NOT IN ('1','2') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pengadaan belum dipesan atau sudah ditutup'; END IF;
 IF NOT EXISTS(SELECT 1 FROM detail_penerimaan WHERE idpenerimaan=NEW.idpenerimaan) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pemeriksaan belum diisi'; END IF;
 IF EXISTS(SELECT 1 FROM detail_pengadaan o WHERE o.idpengadaan=NEW.idpengadaan AND
   o.jumlah>COALESCE((SELECT SUM(d.jumlah_terima) FROM detail_penerimaan d JOIN penerimaan p ON p.idpenerimaan=d.idpenerimaan WHERE p.idpengadaan=NEW.idpengadaan AND p.status='1' AND p.idpenerimaan<>NEW.idpenerimaan AND d.barang_idbarang=o.idbarang),0)
   AND NOT EXISTS(SELECT 1 FROM detail_penerimaan z WHERE z.idpenerimaan=NEW.idpenerimaan AND z.barang_idbarang=o.idbarang)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Semua barang yang masih kurang harus diperiksa'; END IF;
 IF EXISTS(SELECT 1 FROM detail_pengadaan o WHERE o.idpengadaan=NEW.idpengadaan AND fn_sisa_pengadaan(NEW.idpengadaan,o.idbarang)<0) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Jumlah penerimaan melebihi pesanan'; END IF;
 INSERT INTO kartu_stok(jenis_transaksi,masuk,keluar,idbarang,sumber_transaksi,idtransaksi)
 SELECT 'M',jumlah_terima,0,barang_idbarang,'PENERIMAAN',iddetail_penerimaan FROM detail_penerimaan WHERE idpenerimaan=NEW.idpenerimaan AND jumlah_terima>0 ORDER BY barang_idbarang;
 UPDATE pengadaan SET status=CASE WHEN NOT EXISTS(SELECT 1 FROM detail_pengadaan o WHERE o.idpengadaan=NEW.idpengadaan AND fn_sisa_pengadaan(NEW.idpengadaan,o.idbarang)>0) THEN '3' WHEN EXISTS(SELECT 1 FROM detail_penerimaan d JOIN penerimaan p ON p.idpenerimaan=d.idpenerimaan WHERE p.idpengadaan=NEW.idpengadaan AND p.status='1' AND d.jumlah_terima>0) THEN '2' ELSE '1' END WHERE idpengadaan=NEW.idpengadaan;
 END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pengadaan`
--

DROP TABLE IF EXISTS `pengadaan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pengadaan` (
  `idpengadaan` bigint NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_iduser` int NOT NULL,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `vendor_idvendor` int NOT NULL,
  `subtotal_nilai` int NOT NULL DEFAULT '0',
  `ppn` int NOT NULL DEFAULT '0',
  `total_nilai` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`idpengadaan`),
  KEY `fk_pengadaan_user` (`user_iduser`),
  KEY `fk_pengadaan_vendor` (`vendor_idvendor`),
  CONSTRAINT `fk_pengadaan_user` FOREIGN KEY (`user_iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `fk_pengadaan_vendor` FOREIGN KEY (`vendor_idvendor`) REFERENCES `vendor` (`idvendor`),
  CONSTRAINT `ck_pengadaan_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1',_utf8mb4'2',_utf8mb4'3',_utf8mb4'4')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pengadaan_induk_update` BEFORE UPDATE ON `pengadaan` FOR EACH ROW BEGIN IF OLD.status<>'0' AND (NEW.vendor_idvendor<>OLD.vendor_idvendor OR NEW.user_iduser<>OLD.user_iduser OR NEW.subtotal_nilai<>OLD.subtotal_nilai OR NEW.ppn<>OLD.ppn OR NEW.total_nilai<>OLD.total_nilai) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi sudah dikunci'; END IF; IF OLD.status='0' AND NEW.status='1' THEN SET NEW.subtotal_nilai=(SELECT COALESCE(SUM(sub_total),0) FROM detail_pengadaan WHERE idpengadaan=OLD.idpengadaan); SET NEW.total_nilai=NEW.subtotal_nilai+NEW.ppn;
 IF NOT EXISTS(SELECT 1 FROM detail_pengadaan WHERE idpengadaan=OLD.idpengadaan) OR NOT EXISTS(SELECT 1 FROM vendor WHERE idvendor=NEW.vendor_idvendor AND status='1') OR EXISTS(SELECT 1 FROM detail_pengadaan d JOIN barang b ON b.idbarang=d.idbarang WHERE d.idpengadaan=OLD.idpengadaan AND b.status<>1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pesanan kosong atau master tidak aktif'; END IF;
 END IF;
 IF NOT ((OLD.status='0' AND NEW.status IN ('0','1')) OR (OLD.status='1' AND NEW.status IN ('1','2','3','4')) OR (OLD.status='2' AND NEW.status IN ('2','3','4')) OR (OLD.status IN ('3','4') AND NEW.status=OLD.status)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Perubahan status pengadaan tidak valid'; END IF; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `penjualan`
--

DROP TABLE IF EXISTS `penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `penjualan` (
  `idpenjualan` int NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal_nilai` int NOT NULL DEFAULT '0',
  `ppn` int NOT NULL DEFAULT '0',
  `total_nilai` int NOT NULL DEFAULT '0',
  `iduser` int NOT NULL,
  `idmargin_penjualan` int NOT NULL,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`idpenjualan`),
  KEY `fk_penjualan_user` (`iduser`),
  KEY `fk_penjualan_margin` (`idmargin_penjualan`),
  CONSTRAINT `fk_penjualan_margin` FOREIGN KEY (`idmargin_penjualan`) REFERENCES `margin_penjualan` (`idmargin_penjualan`),
  CONSTRAINT `fk_penjualan_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_penjualan_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_penjualan_induk_update` BEFORE UPDATE ON `penjualan` FOR EACH ROW BEGIN IF OLD.status<>'0' AND (NEW.iduser<>OLD.iduser OR NEW.idmargin_penjualan<>OLD.idmargin_penjualan OR NEW.subtotal_nilai<>OLD.subtotal_nilai OR NEW.ppn<>OLD.ppn OR NEW.total_nilai<>OLD.total_nilai) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi sudah dikunci'; END IF; IF OLD.status='0' AND NEW.idmargin_penjualan<>OLD.idmargin_penjualan AND (EXISTS(SELECT 1 FROM detail_penjualan WHERE penjualan_idpenjualan=OLD.idpenjualan) OR NOT EXISTS(SELECT 1 FROM margin_penjualan WHERE idmargin_penjualan=NEW.idmargin_penjualan AND status=1)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Margin transaksi tidak dapat diganti'; END IF; IF OLD.status='0' AND NEW.status='1' THEN SET NEW.subtotal_nilai=(SELECT COALESCE(SUM(subtotal),0) FROM detail_penjualan WHERE penjualan_idpenjualan=OLD.idpenjualan); SET NEW.total_nilai=NEW.subtotal_nilai+NEW.ppn; END IF; IF OLD.status='1' AND NEW.status<>'1' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi selesai tidak dapat dibuka kembali'; END IF; END */;;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_jual_otomatis_kartu_stok` AFTER UPDATE ON `penjualan` FOR EACH ROW BEGIN
 IF OLD.status='0' AND NEW.status='1' THEN
 IF NOT EXISTS(SELECT 1 FROM detail_penjualan WHERE penjualan_idpenjualan=NEW.idpenjualan) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Penjualan belum memiliki detail'; END IF;
 IF EXISTS(SELECT 1 FROM detail_penjualan d JOIN barang b ON b.idbarang=d.idbarang WHERE d.penjualan_idpenjualan=NEW.idpenjualan AND b.status<>1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Barang penjualan tidak aktif'; END IF;
 INSERT INTO kartu_stok(jenis_transaksi,masuk,keluar,idbarang,sumber_transaksi,idtransaksi)
 SELECT 'K',0,jumlah,idbarang,'PENJUALAN',iddetail_penjualan FROM detail_penjualan WHERE penjualan_idpenjualan=NEW.idpenjualan ORDER BY idbarang;
 END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `retur`
--

DROP TABLE IF EXISTS `retur`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `retur` (
  `idretur` bigint NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idpenerimaan` bigint NOT NULL,
  `iduser` int NOT NULL,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`idretur`),
  KEY `fk_retur_penerimaan` (`idpenerimaan`),
  KEY `fk_retur_user` (`iduser`),
  CONSTRAINT `fk_retur_penerimaan` FOREIGN KEY (`idpenerimaan`) REFERENCES `penerimaan` (`idpenerimaan`),
  CONSTRAINT `fk_retur_user` FOREIGN KEY (`iduser`) REFERENCES `user` (`iduser`),
  CONSTRAINT `ck_retur_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_retur_induk_update` BEFORE UPDATE ON `retur` FOR EACH ROW BEGIN IF OLD.status<>'0' AND (NEW.idpenerimaan<>OLD.idpenerimaan OR NEW.iduser<>OLD.iduser) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi sudah dikunci'; END IF; IF OLD.status='1' AND NEW.status<>'1' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transaksi selesai tidak dapat dibuka kembali'; END IF; IF NEW.idpenerimaan<>OLD.idpenerimaan AND EXISTS(SELECT 1 FROM detail_retur WHERE idretur=OLD.idretur) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Penerimaan asal tidak dapat diganti'; END IF; END */;;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_retur_otomatis_kartu_stok` AFTER UPDATE ON `retur` FOR EACH ROW BEGIN
 DECLARE v_asal BIGINT;
 IF OLD.status='0' AND NEW.status='1' THEN
 SELECT idpenerimaan INTO v_asal FROM penerimaan WHERE idpenerimaan=NEW.idpenerimaan AND status='1' FOR UPDATE;
 IF v_asal IS NULL OR NOT EXISTS(SELECT 1 FROM detail_retur WHERE idretur=NEW.idretur) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Retur belum lengkap atau penerimaan belum selesai'; END IF;
 IF EXISTS(SELECT 1 FROM detail_retur d WHERE d.idretur=NEW.idretur AND fn_sisa_retur(d.iddetail_penerimaan)<0) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Jumlah retur melebihi penerimaan'; END IF;
 INSERT INTO kartu_stok(jenis_transaksi,masuk,keluar,idbarang,sumber_transaksi,idtransaksi)
 SELECT 'K',0,d.jumlah,p.barang_idbarang,'RETUR',d.iddetail_retur FROM detail_retur d JOIN detail_penerimaan p ON p.iddetail_penerimaan=d.iddetail_penerimaan WHERE d.idretur=NEW.idretur ORDER BY p.barang_idbarang,d.iddetail_retur;
 END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `idrole` int NOT NULL AUTO_INCREMENT,
  `nama_role` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idrole`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  CONSTRAINT `ck_satuan_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  PRIMARY KEY (`iduser`),
  UNIQUE KEY `uk_user_username` (`username`),
  KEY `fk_user_role` (`idrole`),
  CONSTRAINT `fk_user_role` FOREIGN KEY (`idrole`) REFERENCES `role` (`idrole`)
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
 1 AS `barang_idbarang`,
 1 AS `jumlah_terima`,
 1 AS `harga_satuan_terima`,
 1 AS `sub_total_terima`*/;
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
 1 AS `harga_satuan`,
 1 AS `jumlah`,
 1 AS `sub_total`,
 1 AS `idbarang`,
 1 AS `nama_barang`,
 1 AS `idpengadaan`*/;
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
 1 AS `harga_satuan`,
 1 AS `jumlah`,
 1 AS `subtotal`,
 1 AS `penjualan_idpenjualan`,
 1 AS `idbarang`*/;
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
 1 AS `jumlah`,
 1 AS `alasan`,
 1 AS `idretur`,
 1 AS `iddetail_penerimaan`*/;
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
 1 AS `jenis_transaksi`,
 1 AS `masuk`,
 1 AS `keluar`,
 1 AS `stock`,
 1 AS `created_at`,
 1 AS `idtransaksi`,
 1 AS `idbarang`,
 1 AS `sumber_transaksi`*/;
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
 1 AS `iduser`,
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
 1 AS `status`,
 1 AS `idpengadaan`,
 1 AS `iduser`*/;
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
 1 AS `user_iduser`,
 1 AS `status`,
 1 AS `vendor_idvendor`,
 1 AS `nama_vendor`,
 1 AS `subtotal_nilai`,
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
 1 AS `subtotal_nilai`,
 1 AS `ppn`,
 1 AS `total_nilai`,
 1 AS `iduser`,
 1 AS `idmargin_penjualan`,
 1 AS `status`*/;
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
 1 AS `status`*/;
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
 1 AS `nama_role`*/;
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
 1 AS `status`*/;
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
 1 AS `nama_role`*/;
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
 1 AS `status`*/;
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
  `badan_hukum` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`idvendor`),
  CONSTRAINT `ck_vendor_status` CHECK ((`status` in (_utf8mb4'0',_utf8mb4'1')))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'pbd_ruang_stok_baru'
--

--
-- Dumping routines for database 'pbd_ruang_stok_baru'
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
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_harga_jual`(p_harga INT, p_persen DOUBLE) RETURNS decimal(15,2)
    NO SQL
    DETERMINISTIC
BEGIN
    RETURN ROUND(p_harga + (p_harga * p_persen / 100), 2);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_sisa_pengadaan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_sisa_pengadaan`(p_pengadaan BIGINT,p_barang INT) RETURNS bigint
    READS SQL DATA
BEGIN
 RETURN COALESCE((SELECT SUM(jumlah) FROM detail_pengadaan WHERE idpengadaan=p_pengadaan AND idbarang=p_barang),0) - COALESCE((SELECT SUM(d.jumlah_terima) FROM detail_penerimaan d JOIN penerimaan p ON p.idpenerimaan=d.idpenerimaan WHERE p.idpengadaan=p_pengadaan AND p.status='1' AND d.barang_idbarang=p_barang),0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_sisa_retur` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_sisa_retur`(p_detail BIGINT) RETURNS bigint
    READS SQL DATA
BEGIN
 RETURN COALESCE((SELECT jumlah_terima FROM detail_penerimaan WHERE iddetail_penerimaan=p_detail),0) - COALESCE((SELECT SUM(d.jumlah) FROM detail_retur d JOIN retur r ON r.idretur=d.idretur WHERE d.iddetail_penerimaan=p_detail AND r.status='1'),0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_subtotal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_subtotal`(p_jumlah INT,p_harga INT) RETURNS bigint
    NO SQL
    DETERMINISTIC
RETURN CAST(p_jumlah AS SIGNED)*CAST(p_harga AS SIGNED) ;;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_aktifkan_margin`(IN p_margin INT, IN p_user INT)
    MODIFIES SQL DATA
BEGIN
 IF NOT EXISTS(SELECT 1 FROM margin_penjualan WHERE idmargin_penjualan=p_margin) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Margin tidak ditemukan'; END IF;
 UPDATE margin_penjualan SET status=IF(idmargin_penjualan=p_margin,1,0),iduser=IF(idmargin_penjualan=p_margin,p_user,iduser),updated_at=NOW()
 WHERE status=1 OR idmargin_penjualan=p_margin ORDER BY status DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_audit_kartu_stok` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_audit_kartu_stok`()
    READS SQL DATA
BEGIN
 SELECT b.idbarang,b.nama,b.stok_tersedia,COALESCE(s.hitung,0) AS stok_hitung,COALESCE(k.stock,0) AS stok_terakhir,
 CASE WHEN b.stok_tersedia=COALESCE(s.hitung,0) AND b.stok_tersedia=COALESCE(k.stock,0) THEN 'Sesuai' ELSE 'Tidak sesuai' END AS hasil_audit
 FROM barang b LEFT JOIN (SELECT idbarang,SUM(masuk-keluar) hitung,MAX(idkartu_stok) terakhir FROM kartu_stok GROUP BY idbarang) s ON s.idbarang=b.idbarang LEFT JOIN kartu_stok k ON k.idkartu_stok=s.terakhir ORDER BY b.nama;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_barang_stok_menipis` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_barang_stok_menipis`(IN p_batas INT)
    READS SQL DATA
BEGIN
 IF p_batas IS NULL OR p_batas<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Batas stok tidak valid'; END IF;
 SELECT idbarang,nama,nama_satuan,stok_tersedia FROM v_barang WHERE status=1 AND stok_tersedia<=p_batas ORDER BY stok_tersedia,nama;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_finalisasi_transaksi` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_finalisasi_transaksi`(IN p_jenis VARCHAR(15),IN p_id BIGINT)
    MODIFIES SQL DATA
BEGIN
 DECLARE v_status CHAR(1); DECLARE v_asal BIGINT; DECLARE v_lock BIGINT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
 START TRANSACTION;
 CASE p_jenis
 WHEN 'pengadaan' THEN
   SELECT status INTO v_status FROM pengadaan WHERE idpengadaan=p_id FOR UPDATE;
   IF v_status IS NULL OR v_status<>'0' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pengadaan bukan draft'; END IF;
   IF EXISTS(SELECT 1 FROM detail_pengadaan WHERE idpengadaan=p_id AND (jumlah<=0 OR harga_satuan<0 OR sub_total<>fn_subtotal(jumlah,harga_satuan))) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Detail pengadaan tidak valid'; END IF;
   UPDATE pengadaan SET status='1' WHERE idpengadaan=p_id;
 WHEN 'penerimaan' THEN
   SELECT idpengadaan INTO v_asal FROM penerimaan WHERE idpenerimaan=p_id;
   SELECT idpengadaan INTO v_lock FROM pengadaan WHERE idpengadaan=v_asal FOR UPDATE;
   SELECT status INTO v_status FROM penerimaan WHERE idpenerimaan=p_id FOR UPDATE;
   IF NOT EXISTS(SELECT 1 FROM penerimaan WHERE idpenerimaan=p_id AND idpengadaan=v_asal) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Asal transaksi berubah; ulangi konfirmasi'; END IF;
   IF v_status IS NULL OR v_status<>'0' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Penerimaan bukan draft'; END IF;
   IF EXISTS(SELECT 1 FROM detail_penerimaan d LEFT JOIN detail_pengadaan o ON o.idpengadaan=v_asal AND o.idbarang=d.barang_idbarang WHERE d.idpenerimaan=p_id AND (o.iddetail_pengadaan IS NULL OR d.jumlah_terima<0 OR d.harga_satuan_terima<0 OR d.sub_total_terima<>fn_subtotal(d.jumlah_terima,d.harga_satuan_terima))) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Detail penerimaan tidak valid'; END IF;
   UPDATE penerimaan SET status='1' WHERE idpenerimaan=p_id;
 WHEN 'penjualan' THEN
   SELECT status INTO v_status FROM penjualan WHERE idpenjualan=p_id FOR UPDATE;
   IF v_status IS NULL OR v_status<>'0' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Penjualan bukan draft'; END IF;
   IF EXISTS(SELECT 1 FROM detail_penjualan WHERE penjualan_idpenjualan=p_id AND (jumlah<=0 OR harga_satuan<0 OR subtotal<>fn_subtotal(jumlah,harga_satuan))) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Detail penjualan tidak valid'; END IF;
   UPDATE penjualan SET status='1' WHERE idpenjualan=p_id;
 WHEN 'retur' THEN
   SELECT idpenerimaan INTO v_asal FROM retur WHERE idretur=p_id;
   SELECT idpenerimaan INTO v_lock FROM penerimaan WHERE idpenerimaan=v_asal FOR UPDATE;
   SELECT status INTO v_status FROM retur WHERE idretur=p_id FOR UPDATE;
   IF NOT EXISTS(SELECT 1 FROM retur WHERE idretur=p_id AND idpenerimaan=v_asal) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Asal transaksi berubah; ulangi konfirmasi'; END IF;
   IF v_status IS NULL OR v_status<>'0' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Retur bukan draft'; END IF;
   IF EXISTS(SELECT 1 FROM detail_retur d JOIN detail_penerimaan p ON p.iddetail_penerimaan=d.iddetail_penerimaan WHERE d.idretur=p_id AND (p.idpenerimaan<>v_asal OR d.jumlah<=0 OR TRIM(d.alasan)='')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Detail retur tidak valid'; END IF;
   UPDATE retur SET status='1' WHERE idretur=p_id;
 ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Jenis transaksi tidak valid';
 END CASE;
 COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_riwayat_stok_per_barang` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_riwayat_stok_per_barang`(
    IN p_idbarang INT
)
BEGIN
    SELECT *
    FROM v_kartu_stok
    WHERE idbarang = p_idbarang
    ORDER BY idkartu_stok DESC;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verifikasi_penerimaan`(IN p_pengadaan BIGINT)
    READS SQL DATA
BEGIN
 SELECT d.idbarang,b.nama AS nama_barang,d.jumlah AS dipesan,d.harga_satuan,
 d.jumlah-fn_sisa_pengadaan(p_pengadaan,d.idbarang) AS diterima,
 fn_sisa_pengadaan(p_pengadaan,d.idbarang) AS sisa,
 CASE WHEN fn_sisa_pengadaan(p_pengadaan,d.idbarang)=0 THEN 'Lengkap' WHEN fn_sisa_pengadaan(p_pengadaan,d.idbarang)=d.jumlah THEN 'Belum diterima' ELSE 'Sebagian' END AS hasil_verifikasi
 FROM detail_pengadaan d JOIN barang b ON b.idbarang=d.idbarang WHERE d.idpengadaan=p_pengadaan ORDER BY b.nama;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_barang`
--

/*!50001 DROP VIEW IF EXISTS `v_barang`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_barang` AS select `b`.`idbarang` AS `idbarang`,`b`.`jenis` AS `jenis`,`b`.`nama` AS `nama`,`b`.`idsatuan` AS `idsatuan`,`s`.`nama_satuan` AS `nama_satuan`,`b`.`status` AS `status`,`b`.`harga` AS `harga`,`b`.`stok_tersedia` AS `stok_tersedia` from (`barang` `b` join `satuan` `s` on((`s`.`idsatuan` = `b`.`idsatuan`))) */;
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
/*!50001 VIEW `v_detail_penerimaan` AS select `detail_penerimaan`.`iddetail_penerimaan` AS `iddetail_penerimaan`,`detail_penerimaan`.`idpenerimaan` AS `idpenerimaan`,`detail_penerimaan`.`barang_idbarang` AS `barang_idbarang`,`detail_penerimaan`.`jumlah_terima` AS `jumlah_terima`,`detail_penerimaan`.`harga_satuan_terima` AS `harga_satuan_terima`,`detail_penerimaan`.`sub_total_terima` AS `sub_total_terima` from `detail_penerimaan` */;
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
/*!50001 VIEW `v_detail_pengadaan` AS select `d`.`iddetail_pengadaan` AS `iddetail_pengadaan`,`d`.`harga_satuan` AS `harga_satuan`,`d`.`jumlah` AS `jumlah`,`d`.`sub_total` AS `sub_total`,`d`.`idbarang` AS `idbarang`,`b`.`nama` AS `nama_barang`,`d`.`idpengadaan` AS `idpengadaan` from (`detail_pengadaan` `d` join `barang` `b` on((`d`.`idbarang` = `b`.`idbarang`))) */;
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
/*!50001 VIEW `v_detail_penjualan` AS select `detail_penjualan`.`iddetail_penjualan` AS `iddetail_penjualan`,`detail_penjualan`.`harga_satuan` AS `harga_satuan`,`detail_penjualan`.`jumlah` AS `jumlah`,`detail_penjualan`.`subtotal` AS `subtotal`,`detail_penjualan`.`penjualan_idpenjualan` AS `penjualan_idpenjualan`,`detail_penjualan`.`idbarang` AS `idbarang` from `detail_penjualan` */;
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
/*!50001 VIEW `v_detail_retur` AS select `detail_retur`.`iddetail_retur` AS `iddetail_retur`,`detail_retur`.`jumlah` AS `jumlah`,`detail_retur`.`alasan` AS `alasan`,`detail_retur`.`idretur` AS `idretur`,`detail_retur`.`iddetail_penerimaan` AS `iddetail_penerimaan` from `detail_retur` */;
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
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_kartu_stok` AS select `kartu_stok`.`idkartu_stok` AS `idkartu_stok`,`kartu_stok`.`jenis_transaksi` AS `jenis_transaksi`,`kartu_stok`.`masuk` AS `masuk`,`kartu_stok`.`keluar` AS `keluar`,`kartu_stok`.`stock` AS `stock`,`kartu_stok`.`created_at` AS `created_at`,`kartu_stok`.`idtransaksi` AS `idtransaksi`,`kartu_stok`.`idbarang` AS `idbarang`,`kartu_stok`.`sumber_transaksi` AS `sumber_transaksi` from `kartu_stok` */;
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
/*!50001 VIEW `v_margin_penjualan` AS select `margin_penjualan`.`idmargin_penjualan` AS `idmargin_penjualan`,`margin_penjualan`.`created_at` AS `created_at`,`margin_penjualan`.`persen` AS `persen`,`margin_penjualan`.`status` AS `status`,`margin_penjualan`.`iduser` AS `iduser`,`margin_penjualan`.`updated_at` AS `updated_at` from `margin_penjualan` */;
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
/*!50001 VIEW `v_penerimaan` AS select `penerimaan`.`idpenerimaan` AS `idpenerimaan`,`penerimaan`.`created_at` AS `created_at`,`penerimaan`.`status` AS `status`,`penerimaan`.`idpengadaan` AS `idpengadaan`,`penerimaan`.`iduser` AS `iduser` from `penerimaan` */;
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
/*!50001 VIEW `v_pengadaan` AS select `p`.`idpengadaan` AS `idpengadaan`,`p`.`timestamp` AS `timestamp`,`p`.`user_iduser` AS `user_iduser`,`p`.`status` AS `status`,`p`.`vendor_idvendor` AS `vendor_idvendor`,`v`.`nama_vendor` AS `nama_vendor`,`p`.`subtotal_nilai` AS `subtotal_nilai`,`p`.`ppn` AS `ppn`,`p`.`total_nilai` AS `total_nilai` from (`pengadaan` `p` join `vendor` `v` on((`p`.`vendor_idvendor` = `v`.`idvendor`))) */;
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
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_penjualan` AS select `penjualan`.`idpenjualan` AS `idpenjualan`,`penjualan`.`created_at` AS `created_at`,`penjualan`.`subtotal_nilai` AS `subtotal_nilai`,`penjualan`.`ppn` AS `ppn`,`penjualan`.`total_nilai` AS `total_nilai`,`penjualan`.`iduser` AS `iduser`,`penjualan`.`idmargin_penjualan` AS `idmargin_penjualan`,`penjualan`.`status` AS `status` from `penjualan` */;
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
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_retur` AS select `retur`.`idretur` AS `idretur`,`retur`.`created_at` AS `created_at`,`retur`.`idpenerimaan` AS `idpenerimaan`,`retur`.`iduser` AS `iduser`,`retur`.`status` AS `status` from `retur` */;
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
/*!50001 VIEW `v_role` AS select `role`.`idrole` AS `idrole`,`role`.`nama_role` AS `nama_role` from `role` */;
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
/*!50001 VIEW `v_satuan` AS select `satuan`.`idsatuan` AS `idsatuan`,`satuan`.`nama_satuan` AS `nama_satuan`,`satuan`.`status` AS `status` from `satuan` */;
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
/*!50001 VIEW `v_user` AS select `u`.`iduser` AS `iduser`,`u`.`username` AS `username`,`u`.`idrole` AS `idrole`,`r`.`nama_role` AS `nama_role` from (`user` `u` join `role` `r` on((`u`.`idrole` = `r`.`idrole`))) */;
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
/*!50001 VIEW `v_vendor` AS select `vendor`.`idvendor` AS `idvendor`,`vendor`.`nama_vendor` AS `nama_vendor`,`vendor`.`badan_hukum` AS `badan_hukum`,`vendor`.`status` AS `status` from `vendor` */;
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

-- Dump completed on 2026-11-18 19:05:37
