-- satu function: hitung harga setelah ditambah margin
USE pbd_ruang_stok;

DELIMITER $$

CREATE FUNCTION fn_harga_jual(p_harga INT, p_persen DOUBLE)
RETURNS DECIMAL(15,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(p_harga + (p_harga * p_persen / 100), 2);
END $$

DELIMITER ;
