# 🚀 TaniFresh - Quick Setup Guide

Panduan cepat untuk menjalankan aplikasi TaniFresh pertama kali.

## Prerequisites

- ✅ Flutter SDK (3.0+): https://flutter.dev/docs/get-started/install
- ✅ Node.js (16+): https://nodejs.org/
- ✅ MySQL (8.0+): https://dev.mysql.com/downloads/
- ✅ Android Studio / VS Code
- ✅ Android Emulator / iOS Simulator / Physical Device

## Step 1: Clone & Navigate

```bash
cd e:\Bayu\Koding\Joki\tanifresh
```

## Step 2: Setup Database

### 2.1 Start MySQL
```bash
# Windows (jika MySQL service belum jalan)
net start MySQL80

# Atau buka MySQL Workbench
```

### 2.2 Import Schema
```bash
# Via command line
mysql -u root -p < backend/database.sql

# Atau via MySQL Workbench:
# File > Open SQL Script > backend/database.sql > Execute
```

### 2.3 Verify
```sql
USE tanifresh;
SHOW TABLES;
# Harus muncul: users, products, orders, order_items

SELECT * FROM users WHERE role = 'admin';
# Harus ada: admin@tanifresh.com
```

## Step 3: Setup Backend

### 3.1 Install Dependencies
```bash
cd backend
npm install
```

### 3.2 Configure Environment
Edit `backend/.env` jika perlu:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=      # Isi jika ada password MySQL
DB_NAME=tanifresh
```

### 3.3 Start Server
```bash
npm run dev
```

✅ **Output yang diharapkan:**
```
✅ TaniFresh Backend running on http://localhost:3000
📊 Database: tanifresh
```

**Jangan tutup terminal ini!**

## Step 4: Setup Flutter App

### 4.1 Buka Terminal Baru
```bash
cd e:\Bayu\Koding\Joki\tanifresh
```

### 4.2 Install Dependencies
```bash
flutter pub get
```

### 4.3 Check Devices
```bash
flutter devices
```

Pastikan ada device (emulator/phone) yang terdeteksi.

### 4.4 Run App
```bash
flutter run
```

Atau via VS Code/Android Studio: **F5** atau tombol **Run**

## Step 5: Testing

### Test 1: Login sebagai Admin
1. Buka app
2. Tap **"Daftar Sekarang"** (untuk lihat form)
3. Kembali dan tap **"Masuk"**
4. Email: `admin@tanifresh.com`
5. Password: `admin123`
6. ✅ Harus masuk ke **Admin Dashboard**
7. ✅ Lihat **Weather Widget** (cuaca Bandung)

### Test 2: Register Client Baru
1. Logout dari admin
2. Tap **"Daftar Sekarang"**
3. Pilih **"Restoran"** card
4. Isi semua form:
   - Nama: `Restoran Padang Sederhana`
   - Email: `padang@example.com`
   - Password: `password123`
   - Phone: `08123456789`
   - Alamat: `Jl. Merdeka No. 123, Bandung`
5. Centang agreement
6. Tap **"Daftar"**
7. ✅ Harus muncul dialog: **"Registrasi Berhasil! Menunggu approval..."**

### Test 3: Approve User
1. Login kembali sebagai admin (`admin@tanifresh.com`)
2. Di dashboard, lihat **"Pending Users: 5"**
3. (Untuk full testing, tambahkan UI approval screen)

### Test 4: Login sebagai Client
1. Logout dari admin
2. Login dengan `padang@example.com` / `password123`
3. Jika belum di-approve: **Error "Akun belum disetujui"**
4. Jika sudah di-approve: ✅ Masuk ke **Client Dashboard**

### Test 5: Weather API
1. Login sebagai admin
2. Dashboard auto-load weather
3. ✅ Harus muncul:
   - Suhu (contoh: 28°C)
   - Badge: "Aman" (hijau) atau "Tunda" (merah jika hujan)
   - Deskripsi: "langit cerah" atau status lain
   - Kota: "Bandung"

## Troubleshooting

### ❌ Backend Error: "Cannot connect to MySQL"
**Solution:**
```bash
# Check MySQL service
net start MySQL80

# Verify credentials di .env
DB_USER=root
DB_PASSWORD=
```

### ❌ Flutter Error: "Target of URI doesn't exist"
**Solution:**
```bash
flutter clean
flutter pub get
# Restart IDE (VS Code/Android Studio)
```

### ❌ Weather tidak muncul
**Solution:**
- Check internet connection
- Verify API key di `backend/.env`:
  ```
  OPENWEATHER_API_KEY=0b42924c0348700e9eef5dc2d62e889b
  ```
- Check backend console untuk error logs

### ❌ "Email sudah terdaftar"
**Solution:**
```sql
# Reset database
USE tanifresh;
DELETE FROM users WHERE email = 'padang@example.com';
```

## API Testing (Optional)

### Via Thunder Client / Postman

**1. Register:**
```http
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "role": "client",
  "phone": "08123456789",
  "address": "Jl. Test No. 1"
}
```

**2. Login:**
```http
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "admin@tanifresh.com",
  "password": "admin123"
}
```

Copy `token` dari response.

**3. Get Products:**
```http
GET http://localhost:3000/api/products
Authorization: Bearer <paste_token_here>
```

**4. Get Weather:**
```http
GET http://localhost:3000/api/weather?city=Bandung
```

## Next Steps

Setelah setup berhasil, kamu bisa:

1. ✅ Explore client dashboard
2. ✅ Lihat data produk sample (Kentang, Wortel, Tomat, dll)
3. ✅ Test weather widget dengan kota berbeda
4. ✅ Develop fitur tambahan (cart, checkout, order history)

## Default Credentials

**Admin:**
- Email: `admin@tanifresh.com`
- Password: `admin123`

**Sample Products:**
- Kentang: Rp 15.000/Kg
- Wortel: Rp 12.000/Kg
- Tomat: Rp 8.000/Kg
- Bawang Merah: Rp 25.000/Kg
- Cabai Merah: Rp 35.000/Kg
- Selada: Rp 10.000/Kg

## Support

Jika ada masalah, check:
1. **Backend logs** di terminal backend
2. **Flutter logs** di terminal flutter / IDE console
3. **MySQL logs** di MySQL error log

Happy coding! 🚀
