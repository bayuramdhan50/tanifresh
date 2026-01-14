# TROUBLESHOOTING GUIDE

## Issue 1: Analytics - "Token tidak valid" ❌

### Problem
Error 401: Token expired atau tidak valid

### Root Cause
JWT token memiliki expiration time. Setelah waktu tertentu, token menjadi invalid.

### Solutions

#### Quick Fix: Login Ulang
1. Logout dari aplikasi
2. Login kembali
3. Token baru akan di-generate
4. Analytics akan berfungsi

#### Permanent Fix: Implement Token Refresh
Untuk production, tambahkan auto-refresh token di `auth_provider.dart`

---

## Issue 2: Chat Tidak Muncul di Admin ❌

### Problem
- Client kirim chat, tapi admin list kosong
- Di Firebase: `senderId: ""` (empty)

### Root Cause
`userId` tidak tersimpan di SharedPreferences saat login

### Fix yang Sudah Dilakukan ✅

**1. auth_provider.dart** - Sekarang menyimpan userId:
```dart
await prefs.setString('userId', _user!.id.toString());
```

**2. chat_screen.dart** - Check multiple keys untuk userId:
```dart
_currentUserId = prefs.getString('userId') ?? 
                 prefs.getString('user_id') ?? 
                 prefs.getInt('userId')?.toString() ?? 
                 '';
```

**3. admin_chat_list_screen.dart** - Better parsing untuk handle empty senderId

### Testing Steps

#### Test Chat Functionality:
1. **Logout semua users** (penting!)
2. **Login ulang sebagai client**
   - Email: client@test.com
   - Password: password
3. **Kirim chat ke admin**
4. **Cek console log** - harus tampil:
   ```
   🔍 Current User ID: 1 (atau angka lain, bukan kosong!)
   ```
5. **Login sebagai admin**
6. **Buka Chat dengan Client**
7. **Seharusnya tampil list client** ✅

---

## Debug Checklist

### For Chat Issues:

- [ ] User sudah logout & login ulang (PENTING!)
- [ ] Check console log user ID (tidak kosong)
- [ ] Check Firebase database - senderId terisi
- [ ] Admin chat list menampilkan client

### For Analytics Issues:

- [ ] Backend server running (`node backend/server.js`)
- [ ] User sudah login dengan token valid
- [ ] Database punya data orders untuk ditampilkan
- [ ] Network connection OK

---

## Important Notes

⚠️ **HARUS LOGIN ULANG!**  
Perubahan di `auth_provider.dart` hanya aktif saat login baru. User yang sudah login sebelumnya belum punya userId di SharedPreferences.

📝 **Firebase Structure:**
```
messages/
  ├── _admin-001/
  │     ├── -message1
  │     │    ├── senderId: "1"  ✅ (sekarang terisi!)
  │     │    ├── receiverId: "admin-001"
  │     │    ├── message: "Hello"
  │     │    └── timestamp: 123456
  ```

🔐 **Token Management:**
- Tokens expire setelah waktu tertentu
- Untuk fix permanent: implement refresh token mechanism
- Quick fix: just re-login

---

## Quick Commands

### Run Backend:
```bash
cd e:\Bayu\Koding\Joki\tanifresh\backend
node server.js
```

### Flutter Hot Restart (after logout/login):
Di terminal yang running flutter, tekan **R** (capital R)

---

## Summary

✅ **Fixed:**
1. userId sekarang disimpan saat login
2. Chat screen check userId dari multiple sources  
3. Admin chat list handle empty senderId better

⚠️ **Action Required:**
1. **LOGOUT & LOGIN ULANG** semua users
2. Test chat functionality
3. For analytics: pastikan backend running & login valid

🎯 **Expected Result:**
- Client chat → Firebase senderId terisi
- Admin list → tampil client yang chat
- Analytics → token valid setelah login ulang
