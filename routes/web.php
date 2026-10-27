<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/ruang-stok/{jenis?}', [\App\Http\Controllers\RuangStokController::class, 'index'])
    ->name('ruang-stok.index');
