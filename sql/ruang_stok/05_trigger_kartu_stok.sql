-- satu trigger: periksa jumlah masuk dan keluar sebelum dicatat
USE pbd_ruang_stok;

DELIMITER $$

CREATE TRIGGER trg_cek_kartu_stok
BEFORE INSERT ON kartu_stok
FOR EACH ROW
BEGIN
    IF COALESCE(NEW.masuk, 0) < 0 OR COALESCE(NEW.keluar, 0) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Jumlah masuk atau keluar tidak boleh negatif';
    END IF;

    IF (COALESCE(NEW.masuk, 0) = 0 AND COALESCE(NEW.keluar, 0) = 0)
       OR (COALESCE(NEW.masuk, 0) > 0 AND COALESCE(NEW.keluar, 0) > 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Isi salah satu: masuk atau keluar';
    END IF;
END $$

DELIMITER ;
