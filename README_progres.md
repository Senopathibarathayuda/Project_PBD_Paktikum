# Progres Praktikum Pemrograman Basis Data

Nama: Senopathi Barathayuda  
NIM: 434251104  
Kelas: TI - B6

## Struktur berkas

- `sql/ruang_stok/`: SQL DDL, data master, View, Trigger, Stored Procedure, Function, Index (opsional), dan pengujian untuk database `pbd_ruang_stok`.
- `sql/modul9/`: SQL persiapan, 3 Stored Procedure, 5 Function, dan query pengujian untuk Modul 9.
- `dokumen/`: laporan Modul 9 dan logbook progres.

## Cara menggunakan SQL

Database Ruang Stok: jalankan file bernomor sesuai urutan setelah memeriksa apakah database sudah ada. Jangan menjalankan ulang INSERT jika datanya sudah masuk.

Modul 9: `01_persiapan.sql` membutuhkan database sumber `hr_2023` yang memiliki tabel `employees` dan `departments`. Jika `pbd_modul9_latihan` sudah ada dan berisi datanya, lewati file persiapan. `02_procedure_function.sql` membuat 3 Procedure dan 5 Function; `03_uji_dan_ss.sql` berisi pengujian.

Paket ini adalah dokumen progres SQL. Kode interface Laravel lokal bisa disalin secara terpisah. File `.env`, folder `vendor`, dan `node_modules` tidak boleh diunggah.
