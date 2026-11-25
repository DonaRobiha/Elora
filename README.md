
# ELORA - Education Administration & Information System

**ELORA** adalah aplikasi mobile berbasis Flutter yang dikembangkan untuk membantu pengelolaan administrasi dan penyampaian informasi pendidikan pada yayasan yang memiliki beberapa institusi pendidikan di lokasi berbeda.

Aplikasi ini dirancang untuk memudahkan siswa dalam memantau tagihan pendidikan, memperoleh informasi administrasi, serta berkomunikasi dengan asisten AI melalui satu platform terintegrasi.

## Tentang Proyek

ELORA dikembangkan sebagai proyek mata kuliah Pemrograman Aplikasi Mobile. Aplikasi ini mengintegrasikan teknologi mobile, cloud database, location-based services, dan Artificial Intelligence untuk memberikan pengalaman pengelolaan administrasi pendidikan yang lebih praktis dan terpusat.

ELORA memiliki dua jenis pengguna:
- **Admin:** Mengelola informasi administrasi dan data yang berkaitan dengan institusi.
- **Siswa:** Mengakses informasi administrasi, memantau tagihan, dan menggunakan layanan informasi ELORA AI.

## Fitur Utama

### 1. Dashboard
Menampilkan ringkasan informasi administrasi dan aktivitas pengguna.

### 2. Monitoring Tagihan Pendidikan
- Melihat daftar tagihan berdasarkan periode.
- Memantau nominal tagihan.
- Melihat jumlah pembayaran dan sisa tagihan.
- Mengetahui status pembayaran.
- Membuka riwayat SPP yang sudah lunas dan mengunduh kuitansi PDF.

### 3. Multi-Institution Management
Mendukung pengelolaan beberapa institusi pendidikan dalam satu yayasan yang memiliki lokasi berbeda.

### 4. ELORA AI
Asisten AI berbasis Google Gemini yang dapat menjawab pertanyaan umum dan membantu informasi ELORA. Jawaban tentang tagihan menggunakan data akun yang sedang login.

### 5. Location-Based Services (LBS)
Memanfaatkan informasi lokasi untuk membantu pengguna mengenali dan menemukan institusi pendidikan yang berada di bawah yayasan.

### 6. Notification
Menyediakan notifikasi aplikasi dan push notification untuk pembaruan status pembayaran SPP, serta informasi dari admin.

### 7. Profile Management
Menyediakan informasi profil pengguna serta pengelolaan data akun.

## Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Pengembangan aplikasi mobile |
| Dart | Bahasa pemrograman aplikasi |
| Supabase | Backend, database, dan autentikasi |
| PostgreSQL | Penyimpanan data aplikasi |
| Supabase Edge Functions | Proses backend dan integrasi AI |
| Google Gemini API | Layanan kecerdasan buatan ELORA AI |
| Firebase Cloud Messaging | Push notification |
| Geolocator | Mengakses informasi lokasi perangkat |
| Sensors Plus | Mengakses sensor perangkat |

## Arsitektur Sistem

ELORA menggunakan Flutter sebagai frontend dan Supabase sebagai backend utama.

Alur komunikasi sistem:

1. Pengguna mengakses aplikasi melalui Flutter.
2. Autentikasi dilakukan menggunakan Supabase Auth.
3. Data administrasi disimpan dan dikelola melalui Supabase Database.
4. ELORA AI berkomunikasi dengan Google Gemini melalui Supabase Edge Functions.
5. Notifikasi dikirim menggunakan Firebase Cloud Messaging.

API Key dan kredensial sensitif disimpan pada konfigurasi server, bukan ditanam langsung di aplikasi Flutter.

## Struktur Folder

```text
elora_school/
├── android/
├── ios/
├── lib/
│   ├── config/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── widgets/
│   └── main.dart
├── supabase/
│   └── functions/
│       ├── elora-ai/
│       │   └── index.ts
│       └── send-notifications/
│           └── index.ts
├── web/
├── windows/
├── linux/
├── macos/
├── pubspec.yaml
└── README.md
```

## Persyaratan Sistem

- Flutter SDK
- Dart SDK
- Visual Studio Code atau IDE sejenis
- Supabase Project
- Firebase Project
- Google Gemini API Key

## Instalasi dan Menjalankan Proyek

### 1. Clone Repository

```bash
git clone https://github.com/Cintasir18/Project-mobile.git
```

### 2. Masuk ke Direktori Proyek

```bash
cd Project-mobile
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Konfigurasi Supabase

Siapkan Supabase Project dan sesuaikan konfigurasi koneksi Supabase pada file konfigurasi proyek.

Pastikan URL proyek dan Publishable Key sudah diatur dengan benar.

### 5. Konfigurasi Firebase

Hubungkan aplikasi dengan Firebase Project dan sesuaikan konfigurasi Firebase untuk platform yang digunakan.

### 6. Konfigurasi Gemini API

Tambahkan Gemini API Key pada Supabase Edge Function Secrets menggunakan nama:

```text
GEMINI_API_KEY
```

Jangan memasukkan API Key ke source code atau repository GitHub.

### 7. Deploy Supabase Edge Functions

Pastikan Supabase CLI sudah terpasang dan proyek sudah terhubung.

```bash
npx supabase login
npx supabase link --project-ref PROJECT_ID
npx supabase functions deploy elora-ai
npx supabase functions deploy send-notifications
```

Ganti `PROJECT_ID` dengan ID proyek Supabase milikmu.

### 8. Jalankan Aplikasi

```bash
flutter run
```

## Keamanan

- Tidak menyimpan API Key Gemini di dalam source code Flutter.
- Menggunakan Supabase Auth untuk autentikasi pengguna.
- Menggunakan Supabase Edge Functions untuk menangani proses backend yang membutuhkan kredensial rahasia.
- Menggunakan autentikasi dan kebijakan akses database untuk membatasi akses data pengguna.

## Pengembang

**ELORA - Education Administration & Information System**

Dikembangkan sebagai proyek akademik Program Studi Sistem Informasi, Universitas Pembangunan Nasional "Veteran" Yogyakarta.


## ELORA UI Rework
Versi ini menyesuaikan UI/fitur dengan referensi desain:
- Home tanpa Boarding Jadwal.
- Bottom navigation bergaya glass/transparan.
- Presensi dengan QR scanner kamera.
- Data Pribadi dan Wali Murid (wajib isi sebelum dianggap tersedia).
- Riwayat SPP tanpa fitur Blockchain.
- Kwitansi pembayaran dinamis berdasarkan data pembayaran.
- Personalisasi ELORA dengan Mode Gelap.
- Menu Time Converter, Currency Converter, dan Mini Game tetap tersedia.
- Fitur chat/ELORA AI dan pengingat jadwal dihapus dari UI utama.
