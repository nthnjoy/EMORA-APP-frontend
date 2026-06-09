# 📋 PANDUAN TESTING FITUR BARU

## Status Perbaikan

✅ **Notification System**: Fixed - Ready for testing  
✅ **Gender-Based Theme**: Fixed - Ready for testing  
✅ **Compilation**: Success - No errors

---

## 🔔 TEST 1: NOTIFIKASI REAL-TIME

### Objective
Memastikan notifikasi popup muncul **tepat pada waktu yang ditentukan**, bukan random atau tidak muncul.

### Prerequisites
- Aplikasi sudah di-install di device fisik
- Device memiliki internet connection
- Battery Saver/Doze Mode dimatikan (untuk testing akurat)

### Test Steps

#### Step 1: Buka Notification Page
```
1. Buka app → Tab Notifikasi
2. Lihat section "Atur Pengingat Harian"
3. Ada switch "Aktifkan Pengingat" dan tombol "Ubah Waktu"
```

#### Step 2: Set Notifikasi 1 Menit ke Depan
```
1. Catat jam sekarang (misal: 10:45 AM)
2. Tap "Ubah Waktu"
3. Set waktu ke 1 menit ke depan (misal: 10:46 AM)
4. Tap "Simpan Waktu"
5. Harapkan SnackBar: "Pengingat diatur untuk pukul 10:46"
```

#### Step 3: Wait & Verify Notification
```
1. Jangan tutup app
2. Tunggu sampai 10:46 AM
3. Notification harus POP UP dengan:
   - Title: "EMOLENS - Waktunya Check-in!"
   - Body: "Jangan lupa catat mood dan ceritamu hari ini ya."
   - Sound & Vibration aktif
```

#### Step 4: Verifikasi dengan Logs
```
Buka terminal & run:
adb logcat | grep -E "⏰|✅|❌"

Expected output:
⏰ Scheduling daily notification for: 2026-06-05 10:46:00.000 +07:00
⏰ Current time: 2026-06-05 10:45:30.123 +07:00
✅ Notifikasi berhasil dijadwalkan!
```

#### Step 5: Test Recurring (Optional)
```
1. Set notification untuk besok jam yang sama
2. Matikan app completely
3. Esok hari, pada jam tersebut → notification harus muncul
```

### Expected Results ✅
- [x] Notification muncul tepat pada waktu setting
- [x] Title & message sesuai
- [x] Vibration & sound aktif
- [x] Dapat di-click untuk buka app
- [x] Recurring setiap hari pada jam yang sama

### Troubleshooting ❌

| Masalah | Solusi |
|---------|--------|
| Notifikasi tidak muncul | Pastikan device clock akurat, check battery saver off |
| Notifikasi muncul lambat | Normal untuk `inexactAllowWhileIdle` (max 15 menit delay) |
| No sound/vibration | Check notification settings di Android Settings |
| Logs tidak terlihat | App mungkin crash, check adb logcat error |

---

## 🎨 TEST 2: GENDER-BASED THEME

### Objective
Memastikan tema otomatis berubah ke **Soft Pink** saat user (terutama perempuan) memilih gender, dan **tetap Green** untuk laki-laki.

### Test Scenario A: NEW USER (First Time Login)

#### Step 1: Fresh Login
```
1. Clear app data / Uninstall & reinstall
2. Login dengan akun baru
3. Gender dialog harus appear otomatis
```

#### Step 2: Select Perempuan
```
1. Tap icon Perempuan di dialog
2. Highlight harus berubah pink
3. Tap "Simpan"
4. Harapkan:
   - Dialog close
   - Tema ENTIRE APP langsung berubah ke SOFT PINK
   - All UI elements (buttons, accent colors) = pink tone
```

**Verification Points**:
- [ ] Primary color all elements = Pink (#C2185B)
- [ ] Background color = Light pink tone
- [ ] Menu buttons = Pink accent
- [ ] All text colors consistent with pink theme

#### Step 3: Verify in Profile
```
1. Go to Profile tab
2. "Jenis Kelamin" row harus show "Perempuan"
3. All theme colors = pink
```

---

### Test Scenario B: EXISTING USER (Change Gender)

#### Step 1: Login Existing Account
```
1. Login dengan akun yang sudah ada
2. Lihat tema saat ini (misal: Green/Default)
3. Go to Profile tab
```

#### Step 2: Change Gender
```
1. Tap "Jenis Kelamin" row → Gender dialog opens
2. Select gender berbeda dari sebelumnya
3. Tap "Simpan"
4. Harapkan:
   - Dialog close
   - Refresh profile
   - Tema LANGSUNG BERUBAH sesuai gender baru
```

**Case 1: Change to Perempuan**
- [ ] Tema berubah ke Soft Pink
- [ ] All UI elements pink tone
- [ ] No crash atau error

**Case 2: Change to Laki-laki**
- [ ] Tema berubah ke Green (Default)
- [ ] All UI elements green tone
- [ ] No crash atau error

---

### Test Scenario C: THEME OVERRIDE (Purchased Theme)

#### Step 1: User Perempuan Beli Tema Lain
```
1. Pastikan user gender = Perempuan (tema = Pink)
2. Go to Profile → "Tema" button
3. Select tema lain misal "Blue" (harus cukup point)
4. Tap "Beli"
5. Tema berubah ke Blue (override pink default)
```

#### Step 2: Change Gender Kembali
```
1. Go back to Profile → "Jenis Kelamin"
2. Change gender ke Laki-laki
3. Harapkan:
   - Tema TETAP BLUE (tidak kembali ke green)
   - Purchased theme take precedence
```

**Verification**:
- [ ] Purchased theme overrides gender default ✅
- [ ] Gender change doesn't revert to default theme
- [ ] No crash atau UI issue

---

### Test Scenario D: Theme Refresh

#### Step 1: Buka Tema Modal
```
1. Go to Profile → "Tema" button
2. Modal berisi semua tema tersedia
3. Active tema harus ada border/highlight
```

#### Step 2: Verify Active Theme
```
Jika user perempuan:
- [ ] "Soft Pink" theme punya visual indicator (border/highlight)
- Jika user laki-laki:
- [ ] "Original Green" theme punya visual indicator
- Jika user beli tema lain:
- [ ] Tema yang dibeli punya highlight (not gender default)
```

---

## 🧪 COMPLETE TEST CHECKLIST

### Notification
- [ ] Set reminder → notification pops at exact time
- [ ] Sound & vibration aktif
- [ ] Can click notification to open app
- [ ] Recurring daily on same time
- [ ] Logs show scheduling confirmation

### Gender Theme - New User
- [ ] Dialog appears on first login
- [ ] Select female → theme = pink
- [ ] Select male → theme = green
- [ ] Theme applies to entire app

### Gender Theme - Existing User
- [ ] Can change gender in profile
- [ ] Theme updates immediately
- [ ] Female → pink, Male → green
- [ ] No crash or error

### Theme Override
- [ ] Can buy other themes when have points
- [ ] Purchased theme overrides gender default
- [ ] Change gender doesn't revert to default theme

### General
- [ ] No compilation errors
- [ ] No runtime errors in logs
- [ ] All UI renders correctly
- [ ] No memory leaks or performance issues

---

## 📱 Testing Device Info

Fill in your testing details:
```
Device Model: ___________________
Android Version: ___________________
App Version: ___________________
Test Date: ___________________
Tester Name: ___________________
```

---

## 📝 Bug Report Template

If you find issue, copy-paste ini ke chat:

```
## Bug Found
**Fitur**: [Notification / Theme]
**Severity**: [Critical / High / Medium / Low]
**Device**: [Model]
**Steps to Reproduce**:
1. ...
2. ...

**Expected**: 
Apa yang seharusnya terjadi

**Actual**: 
Apa yang benar-benar terjadi

**Logs/Error**:
[Copy error message dari logcat]

**Screenshot**:
[If possible]
```

---

## ✅ Sign-Off

Setelah semua test passed:

- [ ] All tests completed
- [ ] No critical bugs found
- [ ] Features working as expected
- [ ] Ready for production

**Tested By**: ___________________  
**Date**: ___________________  
**Status**: [ ] Pass / [ ] Fail

---

## 💡 Notes

- Notification delay up to 15 menit adalah normal (inexact alarm)
- Gender theme check backend returns `jenis_kelamin` field
- Theme persistence uses `active_theme` field in user object
- All theme files: `lib/utils/theme_colors.dart`
