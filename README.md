# My Wallet - Aplikasi Manajemen Keuangan Pribadi

Aplikasi manajemen keuangan pribadi berbasis Flutter yang membantu pengguna melacak pendapatan, mengalokasikan anggaran, dan mengelola transaksi dengan efisien.

## Fitur

### 🚀 Splash Screen
- Logo aplikasi yang menarik
- Transisi halus ke halaman login

### 🔐 Autentikasi
- Integrasi Firebase Authentication
- Login dengan Google Sign-In
- Manajemen sesi pengguna yang aman

### 💰 Manajemen Pendapatan
- Set pendapatan bulanan
- Pelacakan pendapatan berdasarkan tanggal
- Kalkulator alokasi pendapatan otomatis

### 📊 Alokasi Anggaran (Berdasarkan Aturan 50/20/20/10)
- **Biaya Hidup & Kewajiban (50%)**
  - Tempat Tinggal & Utilitas (25%)
  - Makanan & Transport (15%)
  - Asuransi Kesehatan (5%)
  - Pengeluaran Rutin Lainnya (5%)

- **Tabungan & Investasi (20%)**
  - Dana Darurat (5%)
  - Investasi Jangka Panjang (15%)

- **Cicilan & Komitmen (20%)**
  - Diluar KPR (10%)
  - Cicilan Kartu Kredit (5%)
  - Cicilan Lainnya (5%)

- **Pengembangan & Gaya Hidup (10%)**
  - Kesehatan & Fitness (3%)
  - Skill & Pendidikan (4%)
  - Hiburan (3%)

### 💳 Manajemen Transaksi
- Catat transaksi per kategori
- Perhitungan saldo real-time
- Validasi transaksi terhadap alokasi yang tersedia
- Pengurangan otomatis dari anggaran yang dialokasikan

### 📜 Riwayat Transaksi
- Lihat transaksi berdasarkan bulan dan tahun
- Month picker dengan navigasi
- Cari dan filter transaksi
- Detail transaksi dengan kategori, tanggal, dan jumlah
- Empty state untuk transaksi kosong

### 🏠 Beranda
- Overview status wallet
- Akses cepat ke fitur utama
- Informasi profil pengguna
- Bottom navigation bar dengan animasi

## Tech Stack

- **Framework**: Flutter SDK ^3.10.4
- **Language**: Dart
- **Database**: Hive (Local NoSQL Database)
- **Authentication**: Firebase Auth
- **State Management**: Provider
- **UI Components**: 
  - Curved Navigation Bar
  - Custom Bottom Navigation
  - Month Picker Bottom Sheet
  - Multi-currency formatter
  - Custom splash screen

## Dependencies

```yaml
firebase_core: ^3.15.2
firebase_auth: ^5.1.2
google_sign_in: ^6.1.0
hive: ^2.2.3
hive_flutter: ^1.1.0
flutter_secure_storage: ^10.0.0
path_provider: ^2.1.5
provider: ^6.1.5+1
intl: ^0.20.2
curved_navigation_bar: ^1.0.6
flutter_multi_formatter: ^2.13.10
cupertino_icons: ^1.0.8
```

## Dev Dependencies

```yaml
flutter_lints: ^6.0.0
hive_generator
build_runner
flutter_launcher_icons: ^0.14.2
flutter_native_splash: ^2.4.3
```

## Struktur Proyek

```
lib/
├── core/
│   ├── constants/        # Konstanta aplikasi
│   ├── theme/           # Tema dan styling
│   └── utils/           # Fungsi utility
├── data/
│   ├── local/           # Setup Hive database
│   └── models/          # Data models (Transaction, AllocationPost, MonthlyIncome)
│       ├── transaction.dart & transaction.g.dart
│       ├── allocation_post.dart & allocation_post.g.dart
│       └── monthly_income.dart & monthly_income.g.dart
├── presentation/
│   ├── screens/         # Layar aplikasi
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── wallet_screen.dart
│   │   ├── transaction_screen.dart
│   │   └── history_trasaction_screen.dart
│   └── widgets/         # Widget yang dapat digunakan ulang
│       └── common/      # Widget umum
└── services/
    └── auth_service.dart # Service autentikasi

assets/
├── background.jpeg      # Background image
├── google_logo.png      # Logo Google untuk login
└── logo.png            # Logo aplikasi
```

## Memulai

### Prasyarat

- Flutter SDK (3.10.4 atau lebih tinggi)
- Dart SDK
- Android Studio / VS Code
- Akun Firebase

### Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/yulius98/my-wallet.git
   cd my_wallet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build
   ```
   atau untuk clean build:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Konfigurasi Firebase**
   - Tambahkan `google-services.json` ke `android/app/`
   - Tambahkan `GoogleService-Info.plist` ke `ios/Runner/`

5. **Generate splash screen dan launcher icons (opsional)**
   ```bash
   flutter pub run flutter_native_splash:create
   flutter pub run flutter_launcher_icons
   ```

6. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## Cara Penggunaan

1. **Login**: Masuk menggunakan autentikasi Google
2. **Set Pendapatan**: Navigasi ke layar Wallet dan masukkan pendapatan bulanan Anda
3. **Alokasi Anggaran**: Gunakan tombol "Income Allocation" untuk menghitung distribusi anggaran secara otomatis
4. **Catat Transaksi**: Buka layar Transaction, pilih kategori, dan tambahkan item transaksi
5. **Lihat Riwayat**: Cek riwayat transaksi per bulan di layar History

## Model Data

### Transaction
- Email (identifikasi pengguna)
- Date (tanggal transaksi)
- Category (kategori transaksi)
- Item name (nama item)
- Amount (jumlah)

### AllocationPost
- Email (identifikasi pengguna)
- Category (kategori alokasi)
- Amount (jumlah alokasi)
- Date (tanggal alokasi)

### MonthlyIncome
- Income amount (jumlah pendapatan)
- Date (tanggal pendapatan)

## Fitur yang Sedang Dikembangkan

- [ ] Analitik dan laporan
- [ ] Perbandingan budget vs aktual
- [ ] Export data ke CSV/PDF
- [ ] Dukungan multi-currency
- [ ] Transaksi berulang
- [ ] Notifikasi anggaran

## Kontribusi

Kontribusi sangat diterima! Silakan ajukan Pull Request.

## Lisensi

Proyek ini bersifat pribadi dan tidak dilisensikan untuk penggunaan publik.

## Dukungan

Untuk dukungan, email ke yulius.wijaya98@gmail.com atau buat issue di repository.

---

**Catatan**: Ini adalah alat manajemen keuangan pribadi. Pastikan Anda mem-backup data secara teratur karena data disimpan secara lokal di perangkat Anda.
