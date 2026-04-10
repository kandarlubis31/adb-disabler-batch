# ADB Disabler (Space Manager v2.0)

![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-2.0-orange.svg)

Script PowerShell sederhana buat matiin aplikasi background di Android via ADB pas lu lagi main game. Tujuannya simpel: ngurangin beban RAM dan CPU biar HP bisa fokus 100% ke game yang lagi dimainin.

Versi ini udah **Portable**. File eksekusi ADB udah dibundle langsung di dalem folder, jadi lu gak perlu repot install ADB manual atau ngatur environment variable di Windows. Tinggal klik dan jalan.

---

## Preview

<div align="center">
  <img width="48%" alt="Menu Utama" src="https://github.com/user-attachments/assets/684ba6f1-f84d-46e1-8f98-e7213d5ab5ee" />
  <img width="48%" alt="Konfirmasi Disable" src="https://github.com/user-attachments/assets/92e0ff6e-3ecc-4ef9-81c8-ed166de1c1f9" />
  <img width="48%" alt="Status" src="https://github.com/user-attachments/assets/dcd5540e-384a-4970-9e54-c6203a6f5b65" />
  <img width="48%" alt="Sukses" src="https://github.com/user-attachments/assets/6a1075c2-55d7-47d9-bbe5-bfa87f2a39fd" />
</div>
<br>
<div align="center">
  <img width="40%" alt="App Drawer Kosong" src="https://github.com/user-attachments/assets/56079dd1-37ce-4923-9c47-89f19968a69f" />
</div>

---

## Fitur

- **Portable & Langsung Jalan:** File ADB bawaan udah ada di dalam paket.
- **Fast Execution:** Eksekusi command langsung di-push ke sistem buat matiin aplikasi background sekaligus.
- **Aman Anti-Bootloop:** Proses krusial (System UI, Network, dll) udah dikunci otomatis dan gak bakal ikut mati.
- **Smart Whitelist:** Bebas tambahin package game atau app penting biar tetep jalan.

---

## Persyaratan

1. PC dengan OS Windows 10 atau 11.
2. HP Android (merk apa saja).
3. Kabel USB data yang berfungsi normal.

---

## Cara Pakai

1. Download dan ekstrak folder project ini.
2. Buka pengaturan HP, masuk ke *Developer Options*, lalu aktifin **USB Debugging**.
3. Colok HP ke PC pakai kabel USB.
4. Kalau muncul notifikasi "Allow USB debugging" di layar HP, pilih **Allow**.
5. Di PC, buka folder hasil ekstrak dan klik dua kali `Jalankan.bat`.
6. Di menu utama, ketik `[1]` atau `[2]` buat masukin package game lu ke daftar whitelist.
7. Pilih menu `[3]` buat mengaktifkan Game Mode (semua app background di luar whitelist akan dimatikan).
8. Selesai main, buka lagi tool ini dan pilih menu `[4]` buat mengembalikan semua aplikasi ke keadaan semula.

---

## Struktur File

```text
adb-disabler/
├── adb.exe               # File core ADB
├── AdbWinApi.dll         # Library ADB
├── AdbWinUsbApi.dll      # Library ADB USB
├── Jalankan.bat          # File eksekusi utama
├── SpaceManager.ps1      # Source script PowerShell
└── README.md             # Dokumentasi ini
