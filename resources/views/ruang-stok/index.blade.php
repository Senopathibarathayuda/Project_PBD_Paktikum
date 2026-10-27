<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ruang Stok</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; color: #24362e; background: #f5f7f5; }
        .layout { display: flex; min-height: 100vh; }
        .sidebar { width: 245px; flex-shrink: 0; padding: 28px 16px; background: #254c3b; color: #fff; }
        .brand { margin: 0 12px 8px; font-size: 24px; font-weight: bold; }
        .subtitle { margin: 0 12px 30px; font-size: 12px; color: #cadfd3; }
        .navtitle { margin: 22px 12px 9px; font-size: 11px; letter-spacing: 1px; color: #b6d1c1; }
        .navlink { display: block; padding: 12px; border-radius: 8px; color: #ecf6ef; text-decoration: none; margin-bottom: 3px; }
        .navlink:hover, .navlink.active { background: #3b6a53; }
        .content { flex: 1; min-width: 0; padding: 36px; }
        .heading { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; margin-bottom: 25px; }
        h1 { font-size: 27px; margin: 0 0 8px; }
        .desc { color: #718179; margin: 0; font-size: 14px; }
        .tag { background: #e8f2ea; color: #2f6b48; padding: 8px 12px; border-radius: 20px; white-space: nowrap; font-size: 12px; }
        .cards { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 15px; }
        .card { background: white; padding: 22px; border: 1px solid #e1e8e2; border-radius: 12px; text-decoration: none; color: inherit; }
        a.card:hover { border-color: #92b5a0; }
        .card .label { color: #647b6a; margin: 0 0 12px; font-size: 14px; }
        .card .number { margin: 0; font-size: 28px; font-weight: bold; }
        .panel { background: white; border: 1px solid #e1e8e2; border-radius: 12px; overflow: hidden; }
        .panelhead { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; padding: 22px; }
        .panelhead h2 { margin: 0 0 6px; font-size: 18px; }
        .panelhead p { margin: 0; font-size: 13px; color: #75847a; }
        .count { font-size: 13px; color: #55695d; }
        .tablewrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 14px; }
        th { background: #f1f5f2; color: #45604e; font-weight: bold; }
        th, td { padding: 14px 20px; border-top: 1px solid #e8ece8; text-align: left; white-space: nowrap; }
        tr:hover td { background: #fbfcfb; }
        .empty { margin: 0; padding: 25px; color: #718179; }
        .note { margin-top: 16px; font-size: 12px; color: #7a8c80; }
        @media (max-width: 850px) {
            .layout { display: block; }
            .sidebar { width: 100%; padding: 16px; }
            .brand { font-size: 20px; }
            .subtitle { margin-bottom: 10px; }
            .navtitle { margin-top: 12px; }
            .navlink { display: inline-block; margin-right: 4px; }
            .content { padding: 22px 16px; }
            .cards { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 460px) { .cards { grid-template-columns: 1fr; } .heading { display: block; } .tag { display: inline-block; margin-top: 12px; } }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand">Ruang Stok</div>
        <p class="subtitle">Sistem data persediaan</p>

        <a class="navlink {{ $jenis === null ? 'active' : '' }}" href="{{ route('ruang-stok.index') }}">Dashboard</a>

        <div class="navtitle">DATA MASTER</div>
        @foreach ($master as $key => $item)
            <a class="navlink {{ $jenis === $key ? 'active' : '' }}"
               href="{{ route('ruang-stok.index', ['jenis' => $key]) }}">
                {{ $item['judul'] }}
            </a>
        @endforeach
    </aside>

    <main class="content">
        @if ($aktif === null)
            <div class="heading">
                <div>
                    <h1>Dashboard</h1>
                    <p class="desc">Ringkasan data master Ruang Stok</p>
                </div>
                <span class="tag">Data dari SQL View</span>
            </div>

            <div class="cards">
                @foreach ($master as $key => $item)
                    <a class="card" href="{{ route('ruang-stok.index', ['jenis' => $key]) }}">
                        <p class="label">{{ $item['judul'] }}</p>
                        <p class="number">{{ $jumlah[$key] }}</p>
                    </a>
                @endforeach
            </div>
            <p class="note">Klik salah satu data master untuk melihat isinya.</p>
        @else
            <div class="heading">
                <div>
                    <h1>Data {{ $aktif['judul'] }}</h1>
                    <p class="desc">Daftar data dari View {{ $aktif['view'] }}</p>
                </div>
                <span class="tag">Hanya tampil data</span>
            </div>

            <div class="panel">
                <div class="panelhead">
                    <div>
                        <h2>{{ $aktif['judul'] }}</h2>
                        <p>Sumber: {{ $aktif['view'] }}</p>
                    </div>
                    <span class="count">{{ $data->count() }} data</span>
                </div>
                @if ($data->isEmpty())
                    <p class="empty">Belum ada data.</p>
                @else
                    <div class="tablewrap">
                        <table>
                            <thead>
                                <tr>
                                    @foreach ($aktif['kolom'] as $label)
                                        <th>{{ $label }}</th>
                                    @endforeach
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($data as $baris)
                                    <tr>
                                        @foreach ($aktif['kolom'] as $namaKolom => $label)
                                            <td>
                                                @if ($namaKolom === 'harga' && $baris->{$namaKolom} !== null)
                                                    Rp {{ number_format((float) $baris->{$namaKolom}, 0, ',', '.') }}
                                                @elseif ($namaKolom === 'persen' && $baris->{$namaKolom} !== null)
                                                    {{ $baris->{$namaKolom} }}%
                                                @else
                                                    {{ $baris->{$namaKolom} ?? '-' }}
                                                @endif
                                            </td>
                                        @endforeach
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </div>
            <p class="note">Data pada halaman ini dibaca dari View MySQL. Belum ada fitur tambah, edit, atau hapus.</p>
        @endif
    </main>
</div>
</body>
</html>
