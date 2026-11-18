# Ruang Stok

Aplikasi pengelolaan barang dan transaksi menggunakan **PHP Native, PDO, dan MySQL**.

## Ruang lingkup

- Master: satuan, barang, vendor, role, user, dan margin penjualan.
- Transaksi: pengadaan, penerimaan, penjualan, dan retur beserta detailnya.
- Pencatatan dan pemeriksaan persediaan melalui kartu stok.
- Pemanfaatan View, Stored Procedure, Function, dan Trigger di MySQL.

## Menjalankan di Laragon

1. Letakkan kode pada `C:\laragon\www\ruang-stok-belajar`.
2. Jalankan Apache dan MySQL di Laragon.
3. Siapkan database `pbd_ruang_stok_baru` pada MySQL. Jika tersedia, gunakan `sql/struktur_database.sql` untuk struktur/objek SQL tanpa data master.
4. Sesuaikan koneksi di `config/koneksi.php` jika konfigurasi MySQL berbeda, atau gunakan variabel lingkungan `RUANG_STOK_DB_HOST`, `RUANG_STOK_DB_PORT`, `RUANG_STOK_DB_NAMA`, `RUANG_STOK_DB_USER`, `RUANG_STOK_DB_PASSWORD`.
5. Buka `http://localhost:8080/ruang-stok-belajar/` jika Apache menggunakan port 8080.

## Catatan

File SQL, jika tersedia, berisi **struktur database tanpa data baris**, termasuk objek database yang dapat diekspor oleh `mysqldump`. Definisi objek yang benar-benar terpasang harus dikonfirmasi dari database lokal.

Berkas audit dan pemasang database lokal tidak disertakan dalam repository publik.
