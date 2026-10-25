import 'package:flutter/material.dart';

class AppColors {
  // ===== PRIMARY (tombol, FAB, tab aktif, nav aktif) =====
  static const Color primaryBlue   = Color(0xFF3B4EFF); // tombol Simpan (kiri), FAB
  static const Color primaryPurple = Color(0xFF8257FC); // tombol Simpan (kanan)
  static const Color tabActive     = Color(0xFF6C5CFD); // tab "Semua", "Minggu"
  static const Color navActive     = Color(0xFF4A45FE); // ikon & label nav aktif

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryBlue, primaryPurple],
  );

  // ===== SPLASH SCREEN =====
  static const Color splashTop     = Color(0xFF1D347C);
  static const Color splashMid     = Color(0xFF183270);
  static const Color splashBottom  = Color(0xFF2D40AA);
  static const Color splashWaveTeal   = Color(0xFF4496BB);
  static const Color splashWavePurple = Color(0xFF6351E2);
  static const Color splashButton  = Color(0xFFF0F4FF); // tombol "Mulai Sekarang"
  static const Color splashButtonText = Color(0xFF1E2B7A); // perkiraan

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [splashTop, splashMid, splashBottom],
  );

  // ===== PEMASUKAN (hijau) =====
  static const Color income        = Color(0xFF0AB68F); // ikon/aksen
  static const Color incomeText    = Color(0xFF06AF7C); // "+ Rp 2.500.000"
  static const Color incomeLine    = Color(0xFF02B485); // garis grafik
  static const Color incomeIconBg  = Color(0xFFD8F5EB); // lingkaran ikon Gaji
  static const Color incomeCardBg  = Color(0xFFDEF4F1); // kartu "Pemasukan" (Tambah)

  // Kartu Total Saldo (gradient hijau)
  static const Color saldoStart    = Color(0xFF00937C);
  static const Color saldoMid      = Color(0xFF02A085);
  static const Color saldoEnd      = Color(0xFF41C0A9);
  static const LinearGradient saldoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [saldoStart, saldoMid, saldoEnd],
  );

  // ===== PENGELUARAN (merah) =====
  static const Color expense       = Color(0xFFFC4D60); // ikon panah merah
  static const Color expenseText   = Color(0xFFFA3B54); // "- Rp 45.000"
  static const Color expenseLine   = Color(0xFFF8636F); // garis grafik (perkiraan)
  static const Color expenseCardBg = Color(0xFFF8DDDD); // kartu "Pengeluaran" & tombol Keluar
  static const Color logoutText    = Color(0xFFFB4A5E); // teks "Keluar" (perkiraan)

  // ===== HEADER BIRU =====
  static const Color balanceBlue   = Color(0xFF1B7BF7); // kartu saldo biru solid
  static const Color secondaryAccent   = Color(0xFFF3EFEF); // kartu saldo biru solid

  // ===== BACKGROUND & SURFACE =====
  static const Color background    = Color(0xFFFAFCFE); // latar layar
  static const Color surface       = Color(0xFFFFFFFF); // kartu
  static const Color border        = Color(0xFFE3EDFB); // garis tepi kartu
  static const Color tabContainer  = Color(0xFFECF4FC); // wadah tab & track progress
  static const Color progressTrack = Color(0xFFEBF2FB);
  static const Color addScreenBg   = Color(0xFFE3F6F4); // tint mint layar Tambah Pengeluaran

  // ===== TEKS (perkiraan, terpengaruh anti-aliasing) =====
  static const Color textPrimary   = Color(0xFF0F1B4D); // judul, nominal
  static const Color textSecondary = Color(0xFF6B7FB0); // subteks, label
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ===== KATEGORI =====
  // Makanan & Minuman
  static const Color catFood       = Color(0xFFFEA534);
  static const Color catFoodBg     = Color(0xFFFEE5E7);
  // Transportasi
  static const Color catTransport  = Color(0xFF487CFA);
  static const Color catTransportBg= Color(0xFFDEE6FE);
  // Belanja
  static const Color catShopping   = Color(0xFF9770F7);
  static const Color catShoppingBg = Color(0xFFE7DFFE);
  // Hiburan
  static const Color catEntertain  = Color(0xFFFEAF18);
  static const Color catEntertainBg= Color(0xFFFDECD8);

}
