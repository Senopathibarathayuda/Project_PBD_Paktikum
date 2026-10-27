-- satu procedure: tampilkan barang berdasarkan satuan
USE pbd_ruang_stok;

DELIMITER $$

CREATE PROCEDURE sp_barang_per_satuan(IN p_idsatuan INT)
BEGIN
    SELECT idbarang, nama, harga, idsatuan
    FROM v_barang
    WHERE idsatuan = p_idsatuan
    ORDER BY nama;
END $$

DELIMITER ;
