<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;

class RuangStokController extends Controller
{
    private array $master = [
        'satuan' => [
            'judul' => 'Satuan',
            'view' => 'v_satuan',
            'kolom' => [
                'idsatuan' => 'ID Satuan',
                'nama_satuan' => 'Nama Satuan',
                'status' => 'Status',
            ],
        ],
        'vendor' => [
            'judul' => 'Vendor',
            'view' => 'v_vendor',
            'kolom' => [
                'idvendor' => 'ID Vendor',
                'nama_vendor' => 'Nama Vendor',
                'badan_hukum' => 'Badan Hukum',
                'status' => 'Status',
            ],
        ],
        'role' => [
            'judul' => 'Role',
            'view' => 'v_role',
            'kolom' => [
                'idrole' => 'ID Role',
                'nama_role' => 'Nama Role',
            ],
        ],
        'barang' => [
            'judul' => 'Barang',
            'view' => 'v_barang',
            'kolom' => [
                'idbarang' => 'ID Barang',
                'nama' => 'Nama Barang',
                'jenis' => 'Jenis',
                'idsatuan' => 'ID Satuan',
                'harga' => 'Harga',
                'status' => 'Status',
            ],
        ],
        'user' => [
            'judul' => 'User',
            'view' => 'v_user',
            'kolom' => [
                'iduser' => 'ID User',
                'username' => 'Username',
                'idrole' => 'ID Role',
            ],
        ],
        'margin' => [
            'judul' => 'Margin Penjualan',
            'view' => 'v_margin_penjualan',
            'kolom' => [
                'idmargin_penjualan' => 'ID Margin',
                'persen' => 'Persen',
                'status' => 'Status',
                'iduser' => 'ID User',
                'created_at' => 'Dibuat',
                'updated_at' => 'Diperbarui',
            ],
        ],
    ];

    public function index(?string $jenis = null)
    {
        if ($jenis !== null && !isset($this->master[$jenis])) {
            abort(404);
        }

        $aktif = $jenis === null ? null : $this->master[$jenis];
        $data = collect();
        $jumlah = [];

        if ($aktif === null) {
            foreach ($this->master as $key => $item) {
                $jumlah[$key] = DB::table($item['view'])->count();
            }
        } else {
            $data = DB::table($aktif['view'])->get();
        }

        return view('ruang-stok.index', [
            'master' => $this->master,
            'jenis' => $jenis,
            'aktif' => $aktif,
            'data' => $data,
            'jumlah' => $jumlah,
        ]);
    }
}
