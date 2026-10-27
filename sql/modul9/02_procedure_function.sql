USE pbd_modul9_latihan;

-- soal 1 - pegawai berdasarkan pekerjaan dan gaji
DROP PROCEDURE IF EXISTS proc_lat1;
DELIMITER $$
CREATE PROCEDURE proc_lat1()
BEGIN
    SELECT CONCAT(first_name, ' ', last_name) AS nama_pegawai,
           job_id AS pekerjaan,
           salary AS gaji
    FROM employees
    WHERE job_id IN ('IT_PROG', 'FI_ACCOUNT')
      AND salary NOT IN (4800, 6000, 9000)
    ORDER BY job_id, first_name, last_name;
END$$
DELIMITER ;

-- soal 2 - bawahan berdasarkan nama manajer
DROP PROCEDURE IF EXISTS proc_lat2;
DELIMITER $$
CREATE PROCEDURE proc_lat2(IN p_nama_manajer VARCHAR(100))
BEGIN
    SELECT CONCAT(e.first_name, ' ', e.last_name) AS nama_pegawai,
           e.salary AS gaji
    FROM employees e
    JOIN employees m ON e.manager_id = m.employee_id
    WHERE CONCAT(m.first_name, ' ', m.last_name) = p_nama_manajer
    ORDER BY e.first_name, e.last_name;
END$$
DELIMITER ;

-- soal 3 - gaji dan komisi tahunan berdasarkan departemen
DROP PROCEDURE IF EXISTS proc_lat3;
DELIMITER $$
CREATE PROCEDURE proc_lat3(IN p_nama_departemen VARCHAR(100))
BEGIN
    SELECT CONCAT(e.first_name, ' ', e.last_name) AS nama_pegawai,
           d.department_name AS nama_departemen,
           e.salary * 12 AS gaji_setahun,
           COALESCE(e.salary * e.commission_pct * 12, 0) AS komisi_setahun
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = p_nama_departemen
    ORDER BY e.first_name, e.last_name;
END$$
DELIMITER ;

-- soal 4 - volume tabung
DROP FUNCTION IF EXISTS fn_volume_tabung;
DELIMITER $$
CREATE FUNCTION fn_volume_tabung(p_jari_jari DECIMAL(10,2), p_tinggi DECIMAL(10,2))
RETURNS DECIMAL(15,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(PI() * p_jari_jari * p_jari_jari * p_tinggi, 2);
END$$
DELIMITER ;

-- soal 5 - konversi celsius ke fahrenheit
DROP FUNCTION IF EXISTS fn_celsius_fahrenheit;
DELIMITER $$
CREATE FUNCTION fn_celsius_fahrenheit(p_celsius DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND((p_celsius * 9 / 5) + 32, 2);
END$$
DELIMITER ;

-- soal 6 - nama lengkap dan gaji pegawai
DROP FUNCTION IF EXISTS fn_detail_gaji;
DELIMITER $$
CREATE FUNCTION fn_detail_gaji(p_employee_id INT)
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE v_hasil VARCHAR(255) DEFAULT NULL;

    SELECT CONCAT(first_name, ' ', last_name, ' gajinya ',
                  CAST(CAST(salary AS DECIMAL(12,2)) AS CHAR))
    INTO v_hasil
    FROM employees
    WHERE employee_id = p_employee_id
    LIMIT 1;

    RETURN COALESCE(v_hasil, 'Pegawai tidak ditemukan');
END$$
DELIMITER ;

-- soal 7 - lama kerja dalam bulan
DROP FUNCTION IF EXISTS fn_lama_kerja;
DELIMITER $$
CREATE FUNCTION fn_lama_kerja(p_employee_id INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_tanggal_masuk DATE DEFAULT NULL;

    SELECT hire_date INTO v_tanggal_masuk
    FROM employees
    WHERE employee_id = p_employee_id
    LIMIT 1;

    IF v_tanggal_masuk IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN TIMESTAMPDIFF(MONTH, v_tanggal_masuk, CURDATE());
END$$
DELIMITER ;

-- soal 8 - revisi gaji berdasarkan jenis pekerjaan
DROP FUNCTION IF EXISTS fn_revisi_gaji;
DELIMITER $$
CREATE FUNCTION fn_revisi_gaji(p_employee_id INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_job VARCHAR(30) DEFAULT NULL;
    DECLARE v_gaji DECIMAL(12,2) DEFAULT NULL;
    DECLARE v_kenaikan DECIMAL(5,2);

    SELECT job_id, salary INTO v_job, v_gaji
    FROM employees
    WHERE employee_id = p_employee_id
    LIMIT 1;

    IF v_gaji IS NULL THEN
        RETURN NULL;
    END IF;

    IF v_job LIKE '%VIP%' THEN
        SET v_kenaikan = 0.35;
    ELSEIF v_job LIKE '%MAN%' THEN
        SET v_kenaikan = 0.30;
    ELSEIF v_job LIKE '%ACCOUNT%' THEN
        SET v_kenaikan = 0.20;
    ELSE
        SET v_kenaikan = 0.10;
    END IF;

    RETURN ROUND(v_gaji * (1 + v_kenaikan), 2);
END$$
DELIMITER ;
