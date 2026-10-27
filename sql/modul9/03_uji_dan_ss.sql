USE pbd_modul9_latihan;

-- cek jumlah procedure dan function
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'pbd_modul9_latihan'
ORDER BY routine_type, routine_name;

-- lihat nama manajer yang bisa dipakai untuk soal 2
SELECT CONCAT(m.first_name, ' ', m.last_name) AS nama_manajer,
       COUNT(*) AS jumlah_bawahan
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.first_name, m.last_name
ORDER BY jumlah_bawahan DESC, nama_manajer
LIMIT 10;

-- lihat nama departemen yang bisa dipakai untuk soal 3
SELECT d.department_name AS nama_departemen,
       COUNT(e.employee_id) AS jumlah_pegawai
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY jumlah_pegawai DESC, nama_departemen
LIMIT 15;

-- soal 1
CALL proc_lat1();

-- soal 2 (ganti nama jika tidak ada pada hasil pencarian)
CALL proc_lat2('Steven King');

-- soal 3 (ganti departemen jika diperlukan)
CALL proc_lat3('Sales');

-- soal 4
SELECT fn_volume_tabung(7, 10) AS volume_tabung;

-- soal 5
SELECT fn_celsius_fahrenheit(30) AS fahrenheit;

-- soal 6
SELECT fn_detail_gaji(100) AS detail_gaji;

-- soal 7
SELECT fn_lama_kerja(100) AS lama_kerja_bulan;

-- soal 8
SELECT employee_id, job_id, salary,
       fn_revisi_gaji(employee_id) AS revised_salary
FROM employees
WHERE employee_id IN (100, 103, 145, 200)
ORDER BY employee_id;
