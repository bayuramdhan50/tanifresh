# TaniFresh - Marketplace Bahan Baku

Aplikasi mobile marketplace B2B yang menghubungkan restoran dengan petani/supplier menggunakan Flutter dan Node.js.

## 🎯 Fitur Utama

### Client (Restoran)
- ✅ Registrasi & Login dengan approval system
- ✅ Dashboard dengan statistik pesanan
- ✅ Katalog produk bahan baku
- ✅ Keranjang belanja dengan kalkulator harga otomatis
- ✅ **Perhitungan diskon:**
  - Diskon 5% untuk pembelian >50kg
  - Diskon 10% untuk pembelian >Rp 1.000.000
  - PPN 11% otomatis
- ✅ Riwayat pesanan dengan status tracking
- ✅ Profil pengguna
- ✅ **Halaman Tentang Aplikasi** dengan info developer

### Admin (Petani/Supplier)
- ✅ Dashboard dengan statistik
- ✅ **Widget cuaca** (OpenWeather API) untuk monitoring pengiriman
- ✅ Approval pengguna baru
- ✅ Manajemen produk (CRUD)
- ✅ Manajemen pesanan
- ✅ Update status pesanan
- ✅ **Halaman Tentang Aplikasi** dengan info developer dan fitur
- ✅ **Link YouTube Demo** untuk demo aplikasi

## 🎥 Demo Aplikasi

Tonton video demo TaniFresh di YouTube:
👉 **[Video Demo TaniFresh](https://youtu.be/j2TiVELO6L0?si=uxBI43FcC1Fvwdwo)**

## 🛠️ Tech Stack

### Frontend (Mobile)
- **Framework:** Flutter 3.x
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** shared_preferences
- **Design:** Material 3 dengan custom theming

### Backend (API)
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MySQL
- **Authentication:** JWT (jsonwebtoken)
- **Password Hashing:** bcryptjs
- **External API:** OpenWeather API

## 📁 Struktur Folder

```
tanifresh/
├── lib/
│   ├── core/                       # Core utilities
│   │   ├── theme/                  # App theme & colors
│   │   ├── constants/              # Constants & API endpoints
│   │   ├── utils/                  # Validators, formatters, calculator
│   │   └── network/                # API client
│   ├── features/                   # Feature modules
│   │   ├── auth/                   # Authentication
│   │   ├── client/                 # Client features
│   │   └── admin/                  # Admin features
│   ├── shared/                     # Shared components
│   │   ├── widgets/                # Reusable widgets
│   │   └── models/                 # Data models
│   └── main.dart
├── backend/
│   ├── server.js                   # Express server
│   ├── database.sql                # Database schema
│   ├── package.json
│   └── .env
└── README.md
```

## 🚀 Cara Menjalankan

### 1. Setup Database

```bash
# Buka MySQL dan jalankan
mysql -u root -p < backend/database.sql
```

### 2. Setup Backend

```bash
cd backend
npm install
npm run dev
```

Server akan berjalan di `http://localhost:3000`

### 3. Setup Flutter

```bash
cd ..
flutter pub get
flutter run
```

## 🔑 Kredensial Default

### Admin
- Email: `admin@tanifresh.com`
- Password: `admin123`

### Testing
- Daftar sebagai **Client** (Restoran)
- Tunggu approval dari admin
- Login dan mulai berbelanja

## 📊 Database Schema

### Users
- Menyimpan data pengguna (client & admin)
- Field: id, name, email, password, role, is_active, address, phone

### Products
- Katalog produk bahan baku
- Field: id, name, description, price, unit, stock, category

### Orders
- Data pesanan
- Field: id, user_id, subtotal, discount, tax, total, status, notes

### Order Items
- Detail item per pesanan
- Field: id, order_id, product_id, product_name, price, quantity, unit

## 🌤️ OpenWeather API Integration

Widget cuaca di admin dashboard menggunakan OpenWeather API untuk:
- Menampilkan suhu saat ini
- Kondisi cuaca (cerah/hujan/berawan)
- **Rekomendasi pengiriman:**
  - ✅ **Aman** - Cuaca baik
  - ⚠️ **Tunda** - Hujan/badai

API Key sudah dikonfigurasi di `.env`

## 💰 Logika Perhitungan Harga

```dart
Subtotal = Σ (harga × quantity)

Diskon:
- Jika total berat ≥ 50kg → Diskon 5%
- Jika subtotal ≥ Rp 1.000.000 → Diskon 10%

Pajak = (Subtotal - Diskon) × 11%

Total = Subtotal - Diskon + Pajak
```

## 🎨 Design System

### Colors
- **Primary:** Green (#4CAF50) - Fresh produce
- **Accent:** Orange (#FF9800) - Energy & warmth
- **Background:** Light Gray (#F5F5F5)

### Typography
- **Headings:** Poppins (Bold)
- **Body:** Inter (Regular)

### Components
- Custom buttons (primary, outlined, text)
- Custom text fields dengan validasi
- Loading indicators
- Cards & list items

## 📱 Screenshots

(Tambahkan screenshot aplikasi di sini)

## 🔐 API Endpoints

### Authentication
- `POST /api/auth/register` - Registrasi user
- `POST /api/auth/login` - Login
- `GET /api/auth/profile` - Get profile

### Products
- `GET /api/products` - Get all products
- `POST /api/products` - Create product (admin)

### Orders
- `POST /api/orders` - Create order
- `GET /api/orders` - Get orders
- `PUT /api/orders/:id/status` - Update status (admin)

### Admin
- `GET /api/admin/pending-users` - Pending users
- `PUT /api/admin/users/:id/approve` - Approve user
- `DELETE /api/admin/users/:id/reject` - Reject user

### Weather
- `GET /api/weather?city=Bandung` - Get weather

## 🧪 Testing

1. Jalankan backend
2. Buka aplikasi Flutter
3. Register sebagai Client
4. Login sebagai Admin untuk approve
5. Login kembali sebagai Client
6. Tambah produk ke keranjang (>50kg untuk diskon)
7. Checkout dan lihat perhitungan otomatis
8. Cek status pesanan

## 📝 Catatan Pengembangan

- Clean code architecture
- Feature-based folder structure
- Reusable components
- Type-safe API calls
- Form validation
- Error handling
- JWT authentication
- Password hashing
- SQL injection prevention

## 👥 Tim Pengembang

**Developer 1:**
- Nama: Fadhlan Rahman Permana
- NPM: 152021032

**Developer 2:**
- Nama: Wibi Ataya Sani
- NPM: 152022063

## 📺 Demo Aplikasi

Video demo aplikasi dapat diakses langsung dari aplikasi melalui menu "Tentang Aplikasi" di halaman Profil (Client) atau Quick Actions (Admin).

Link YouTube: *Segera hadir*

## 📄 License

MIT License
