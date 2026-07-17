# OHSE Enterprise — Aplikasi Mobile HSSE (Flutter)

Aplikasi Android (Flutter) untuk manajemen **HSSE** (Health, Safety, Security &
Environment) yang terhubung ke backend **OHSE Enterprise** (Laravel + Filament)
melalui REST API + token (Laravel Sanctum).

Terinspirasi dari konsep "Aplikasi Management HSSE Berbasis Online": dashboard
real-time, pelaporan insiden/near-miss, Permit to Work (PTW), dan inspeksi.

## ✨ Fitur

| Modul | Keterangan |
|-------|-----------|
| **Login** | Autentikasi email/password → token Sanctum, disimpan lokal |
| **Dashboard** | KPI insiden/PTW/inspeksi/observasi, grafik insiden per keparahan, insiden terbaru |
| **Insiden** | Daftar + filter keparahan, detail lengkap, **form lapor insiden** (jenis, keparahan, lokasi, waktu, **foto kamera disimpan ke penyimpanan internal**) |
| **Izin Kerja (PTW)** | Daftar izin kerja, detail (bahaya, pengendalian, masa berlaku), tombol **Setujui** |
| **Inspeksi** | Daftar inspeksi + skor & jumlah temuan |
| **Profil** | Info user, role, alamat server, logout |

Desain: **Material 3, tema hijau-safety modern** (hijau `#1B9C56` + aksen oranye `#FF7A00`).

## 🧱 Arsitektur

```
Flutter (Riverpod + Dio)  ──REST/JSON──►  Laravel 13 API (Sanctum)  ──►  MariaDB
```

- **State management:** `flutter_riverpod`
- **HTTP:** `dio` dengan interceptor token + normalisasi error
- **Grafik:** `fl_chart`
- **Penyimpanan token:** `shared_preferences`

```
lib/
├─ core/        config, theme, api_client, token_storage, labels
├─ models/      user, incident, permit, inspection, dashboard_stats, named_ref
├─ services/    ohse_api.dart  (repository semua endpoint)
├─ providers/   providers.dart, auth_controller.dart  (Riverpod)
├─ widgets/     common.dart  (chip, loading, error, empty)
└─ screens/     splash, login, home, dashboard, incidents/, permits/, inspections/, profile
```

## 🔌 Backend API

Endpoint sudah ditambahkan di project Laravel `/root/ohse-enterprise`
(`routes/api.php` + `app/Http/Controllers/Api/*` + `app/Http/Resources/*`):

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| POST | `/api/login` | Login, mengembalikan `token` + `user` |
| GET | `/api/me` | Profil user saat ini |
| POST | `/api/logout` | Hapus token |
| GET | `/api/dashboard` | Statistik ringkas untuk beranda |
| GET | `/api/incidents` | Daftar insiden (filter `severity`, `status`, `search`) |
| GET | `/api/incidents/{id}` | Detail insiden |
| POST | `/api/incidents` | Buat insiden baru |
| GET | `/api/permits` | Daftar izin kerja (filter `status`, `risk_level`) |
| POST | `/api/permits/{id}/approve` | Setujui izin kerja |
| GET | `/api/inspections` | Daftar inspeksi |
| GET | `/api/observations` | Daftar observasi BBS |
| GET | `/api/lookups/sites` `/companies` | Data dropdown |

Semua endpoint (kecuali `/login`) dilindungi `auth:sanctum`.

### Menjalankan backend

```bash
cd /root/ohse-enterprise

# 1. Start MariaDB (env ini tidak menjalankannya sebagai service)
mariadbd-safe --datadir=/var/lib/mariadb &

# 2. (opsional) migrate + seed data contoh
php artisan migrate --seed

# 3. Jalankan API. Gunakan 0.0.0.0 agar bisa diakses HP/emulator.
php artisan serve --host=0.0.0.0 --port=8000
```

Login default panel/API: **`admin@ohse.test` / `password`**.

## 📱 Menjalankan aplikasi Flutter

> Butuh Flutter SDK **>= 3.27** + Android SDK. Cek dengan `flutter doctor`.

```bash
cd ohse_mobile

# Lengkapi berkas platform yang di-generate Flutter (gradle wrapper, dll).
# Aman — perintah ini hanya menambah berkas yang belum ada, kode di lib/ tetap.
flutter create --org com.ohse --project-name ohse_mobile --platforms=android .

flutter pub get
flutter run
```

### Mengatur alamat server API

Base URL diatur lewat `--dart-define` (default `http://10.0.2.2:8000/api`):

| Perangkat | Base URL |
|-----------|----------|
| **Emulator Android** | `http://10.0.2.2:8000/api` (default — `10.0.2.2` = localhost host) |
| **HP fisik (USB/WiFi)** | `http://<IP-LAN-komputer>:8000/api`, mis. `http://192.168.1.10:8000/api` |

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

### Build APK

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## ⚠️ Catatan / batasan

- **Foto insiden** diambil dari kamera dan ditampilkan di form, namun endpoint
  unggah lampiran insiden belum tersedia di backend — foto belum ikut terkirim.
  (Tabel `permit_attachments` sudah ada; endpoint upload bisa jadi langkah lanjutan.)
- `android/local.properties` di-generate otomatis oleh Flutter (berisi path SDK)
  dan sengaja tidak di-commit.
- `usesCleartextTraffic="true"` diaktifkan agar bisa uji coba via HTTP di jaringan
  lokal. Untuk produksi, gunakan HTTPS dan matikan opsi ini.
