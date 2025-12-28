# Firebase Setup Checklist untuk Kasirly

## ✅ Konfigurasi yang Sudah Dilakukan

1. **File google-services.json**
   - ✅ Sudah ada di `android/app/google-services.json`
   - ✅ Project ID: `kasirly-eccf2`
   - ✅ Package Name: `com.example.project_coba`
   - ✅ OAuth Client sudah dikonfigurasi untuk Google Sign-In

2. **Gradle Configuration**
   - ✅ Plugin `com.google.gms.google-services` sudah ditambahkan di `android/app/build.gradle.kts`
   - ✅ Plugin version sudah ditambahkan di `android/settings.gradle.kts`

3. **Flutter Code**
   - ✅ `Firebase.initializeApp()` sudah dipanggil di `main.dart`
   - ✅ AuthService sudah dikonfigurasi untuk Google Sign-In

## 🔧 Langkah-langkah Setup di Firebase Console

Pastikan Anda sudah melakukan hal berikut di [Firebase Console](https://console.firebase.google.com/):

### 1. Authentication - Sign-in Methods
Pastikan method berikut sudah **diaktifkan**:

- ✅ **Email/Password** - Enable
- ✅ **Google** - Enable
  - Pastikan Support email sudah diisi
  - Pastikan OAuth consent screen sudah dikonfigurasi

### 2. Firestore Database
- ✅ Buat database Firestore (jika belum ada)
- ✅ Pilih mode: **Production mode** atau **Test mode**
- ✅ Pilih region (disarankan: `asia-southeast2` untuk Indonesia)

### 3. Android App Configuration
- ✅ Package name: `com.example.project_coba`
- ✅ SHA-1 certificate hash sudah ditambahkan (untuk Google Sign-In)
  - Untuk debug: `71d80250c5354691fab8ed2c5f12806643f4cf52` (sudah ada di google-services.json)
  - Untuk release: Tambahkan SHA-1 dari keystore release Anda

## 🚀 Testing

Setelah semua konfigurasi selesai:

1. **Clean build:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run aplikasi:**
   ```bash
   flutter run
   ```

3. **Test Authentication:**
   - Test Email/Password login
   - Test Email/Password register
   - Test Google Sign-In
   - Test Forgot Password

## ⚠️ Troubleshooting

### Error: "Google Sign-In failed"
- Pastikan Google Sign-In method sudah diaktifkan di Firebase Console
- Pastikan SHA-1 certificate hash sudah ditambahkan di Firebase Console
- Untuk mendapatkan SHA-1 debug:
  ```bash
  keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
  ```

### Error: "Firebase not initialized"
- Pastikan `google-services.json` ada di `android/app/`
- Pastikan plugin `com.google.gms.google-services` sudah ditambahkan di `build.gradle.kts`
- Jalankan `flutter clean` dan build ulang

### Error: "Email/Password authentication failed"
- Pastikan Email/Password method sudah diaktifkan di Firebase Console
- Pastikan email sudah terdaftar (untuk login) atau belum terdaftar (untuk register)

## 📝 Catatan Penting

- File `google-services.json` sudah dikonfigurasi dengan benar
- Semua sign-in methods harus diaktifkan di Firebase Console sebelum digunakan
- Untuk production, pastikan menggunakan keystore release dan tambahkan SHA-1 release ke Firebase Console



