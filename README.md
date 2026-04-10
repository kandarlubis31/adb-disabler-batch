# Space Manager v2.0 - ADB Game Mode CLI

![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-2.0-orange.svg)

Space Manager adalah skrip PowerShell sederhana untuk membantu menonaktifkan aplikasi background di Android saat main game. Tujuannya supaya HP lebih fokus ke game dan kinerja terasa lebih ringan.

Versi ini portable. ADB sudah disertakan dalam folder, jadi tidak perlu instalasi ADB tambahan atau konfigurasi environment variable di Windows.

> **Screenshot Preview:**
> *(Tempel gambar CLI ke folder `assets`, lalu ganti link ini jika perlu)*
> `![Menu Utama](assets/screenshot-menu.png)`

---

## Fitur

- **Portable & langsung jalan:** ADB sudah ada di dalam paket.
- **Nonaktifkan aplikasi background:** Memilih aplikasi yang berjalan di latar belakang untuk mengurangi beban.
- **Aman untuk sistem:** Beberapa proses penting seperti System UI dan konektivitas tidak akan dinonaktifkan.
- **Whitelist:** Tambahkan game atau aplikasi penting yang ingin tetap berjalan.

---

## Persyaratan

1. Windows 10 atau 11.
2. HP Android.
3. Kabel USB data yang berfungsi.

---

## Cara Pakai

1. Unduh dan ekstrak folder project.
2. Aktifkan **USB Debugging** di pengaturan Developer Options Android.
3. Hubungkan HP ke PC dengan kabel USB.
4. Jika muncul notifikasi "Allow USB debugging", izinkan.
5. Jalankan `Jalankan.bat`.
6. Gunakan menu di CLI untuk menambahkan package game ke whitelist, lalu aktifkan Game Mode.
7. Saat selesai, pakai menu untuk mengembalikan semua aplikasi ke keadaan semula.

---

## Struktur File

```text
SpaceManager/
├── adb.exe               # file ADB
├── AdbWinApi.dll         # library ADB
├── AdbWinUsbApi.dll      # library ADB USB
├── Jalankan.bat          # eksekusi utama
├── SpaceManager.ps1      # script PowerShell
└── README.md             # dokumentasi ini
```