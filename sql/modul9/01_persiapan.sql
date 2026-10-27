-- salinan data untuk latihan modul 9
-- database ruang stok tidak diubah

SHOW DATABASES LIKE 'hr_2023';

CREATE DATABASE IF NOT EXISTS pbd_modul9_latihan;
USE pbd_modul9_latihan;

CREATE TABLE IF NOT EXISTS employees LIKE hr_2023.employees;
CREATE TABLE IF NOT EXISTS departments LIKE hr_2023.departments;

INSERT IGNORE INTO employees SELECT * FROM hr_2023.employees;
INSERT IGNORE INTO departments SELECT * FROM hr_2023.departments;

SELECT 'employees' AS tabel, COUNT(*) AS jumlah FROM employees
UNION ALL
SELECT 'departments', COUNT(*) FROM departments;
