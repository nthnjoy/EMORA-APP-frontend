# Database Cleanup Guide

## Objective
Membersihkan semua data Mood dan Perasaan yang telah di-input pada tanggal 5 Juni 2026 dari seluruh user dalam database.

## Option 1: Menggunakan Backend API (Recommended)

### Langkah 1: Buat Endpoint di Backend
Tambahkan endpoint berikut di Laravel backend (`routes/api.php`):

```php
Route::middleware(['api', 'auth:sanctum'])->prefix('admin')->group(function () {
    Route::post('cleanup-moods-by-date', [AdminController::class, 'cleanupMoodsByDate']);
    Route::post('cleanup-feelings-by-date', [AdminController::class, 'cleanupFeelingsByDate']);
});
```

### Langkah 2: Buat Controller Method di Backend
Tambahkan ke `app/Http/Controllers/AdminController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Mood;
use App\Models\Feeling;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    public function cleanupMoodsByDate(Request $request)
    {
        $date = $request->input('date'); // Format: YYYY-MM-DD
        
        if (!$date) {
            return response()->json([
                'success' => false,
                'message' => 'Date parameter required'
            ], 400);
        }

        try {
            $start = $date . ' 00:00:00';
            $end = $date . ' 23:59:59';

            $count = Mood::whereBetween('created_at', [$start, $end])->delete();

            return response()->json([
                'success' => true,
                'message' => "Berhasil menghapus {$count} mood data dari tanggal {$date}",
                'deleted_count' => $count
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function cleanupFeelingsByDate(Request $request)
    {
        $date = $request->input('date'); // Format: YYYY-MM-DD
        
        if (!$date) {
            return response()->json([
                'success' => false,
                'message' => 'Date parameter required'
            ], 400);
        }

        try {
            $start = $date . ' 00:00:00';
            $end = $date . ' 23:59:59';

            $count = Feeling::whereBetween('created_at', [$start, $end])->delete();

            return response()->json([
                'success' => true,
                'message' => "Berhasil menghapus {$count} feeling data dari tanggal {$date}",
                'deleted_count' => $count
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}
```

### Langkah 3: Jalankan dari Terminal

```bash
# Bersihkan mood data dari 2026-06-05
curl -X POST https://api-url/api/admin/cleanup-moods-by-date \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"date": "2026-06-05"}'

# Bersihkan feeling data dari 2026-06-05
curl -X POST https://api-url/api/admin/cleanup-feelings-by-date \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"date": "2026-06-05"}'
```

## Option 2: Direct Database Query (Jika Akses Direct ke DB)

```sql
-- Bersihkan semua mood data dari 2026-06-05
DELETE FROM moods 
WHERE DATE(created_at) = '2026-06-05';

-- Bersihkan semua feeling/perasaan data dari 2026-06-05
DELETE FROM feelings 
WHERE DATE(created_at) = '2026-06-05';

-- Verify deleted records
SELECT COUNT(*) as remaining_moods FROM moods WHERE DATE(created_at) = '2026-06-05';
SELECT COUNT(*) as remaining_feelings FROM feelings WHERE DATE(created_at) = '2026-06-05';
```

## Option 3: Menggunakan Frontend Helper (Limited)

Dari Flutter app, panggil:

```dart
import 'services/database_cleanup_service.dart';

// Bersihkan data untuk current user hari ini
final result = await DatabaseCleanupService.clearCurrentUserTodayData();
print(result['message']);
```

## Important Notes

1. **Backup Database**: Selalu backup database sebelum menjalankan cleanup
2. **Authorization**: Pastikan user memiliki permission admin untuk menjalankan cleanup
3. **Date Format**: Gunakan format YYYY-MM-DD untuk konsistensi
4. **Verification**: Setelah cleanup, verify bahwa data telah dihapus dengan benar

## Created Date: 2026-06-05
Status: Data cleanup untuk mood dan feeling dari tanggal 2026-06-05 telah disiapkan
