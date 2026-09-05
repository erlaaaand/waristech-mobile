Berikut adalah panduan teknis dan komprehensif dalam format Markdown mengenai standar pengkodean strict, implementasi Object-Oriented Programming (OOP) yang tepat, teknik refactoring, dan pembuatan komponen *reusable* di ekosistem Flutter.

---

# Panduan Teknis Arsitektur & Clean Code Flutter

Dokumen ini mendefinisikan standar teknis untuk pengembangan aplikasi Flutter, berfokus pada ketatnya tipe data (*strict typing*), prinsip OOP, arsitektur yang modular, dan komponen UI yang dapat digunakan kembali (*reusable*).

---

## 1. Aturan Pengkodean Strict (Strict Coding Standards)

Flutter (Dart) memiliki sistem *type-safe* yang kuat. Untuk memastikan tidak ada kebocoran tipe data atau eksekusi dinamis yang tidak disengaja, aktifkan aturan ketat pada *analyzer*.

### 1.1 Konfigurasi `analysis_options.yaml`

Gunakan konfigurasi linter yang sangat ketat untuk mendeteksi potensi *code smell* sejak fase kompilasi.

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    parameter_assignments: warning

linter:
  rules:
    - always_declare_return_types
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - avoid_print
    - use_key_in_widget_constructors
    - require_trailing_commas

```

### 1.2 Aturan Immutability & Null Safety

* **Gunakan `final` dan `const**`: Semua variabel yang tidak berubah referensinya harus `final`. Semua nilai yang sudah diketahui saat *compile-time* (terutama Widget UI) wajib menggunakan `const`. Ini sangat menghemat *memory footprint* pada proses *rebuilding* UI.
* **Null Safety Defensif**: Jangan gunakan operator *bang* (`!`) secara sembarangan. Gunakan *null-aware operators* (`?.`, `??`) atau pengecekan eksplisit (`if (x != null)`).

---

## 2. Implementasi OOP yang Tepat di Flutter

Prinsip OOP (Enkapsulasi, Abstraksi, Pewarisan, Polimorfisme) harus diterapkan pada level arsitektur (*domain* dan *data layer*), bukan pada *UI layer* (karena UI di Flutter lebih condong ke prinsip *Composition*).

### 2.1 Abstraksi (Interfaces)

Gunakan `abstract class` sebagai kontrak (interface) untuk Service atau Repository. Ini memungkinkan penyuntikan dependensi (*Dependency Injection*) dan memudahkan *mocking* saat *unit testing*.

```dart
// domain/repositories/market_data_repository.dart
abstract class MarketDataRepository {
  Future<List<MarketPriceEntry>> fetchLatestPrices();
  Future<void> savePriceEntry(MarketPriceEntry entry);
}

```

### 2.2 Polimorfisme & Enkapsulasi

Implementasikan interface tersebut di *data layer*. Sembunyikan *state* internal atau instance yang rentan dengan menggunakan *underscore* (`_`).

```dart
// data/repositories/market_data_repository_impl.dart
class MarketDataRepositoryImpl implements MarketDataRepository {
  // Enkapsulasi: private API client
  final ApiClient _apiClient;

  MarketDataRepositoryImpl({required ApiClient apiClient}) 
      : _apiClient = apiClient;

  @override
  Future<List<MarketPriceEntry>> fetchLatestPrices() async {
    try {
      final response = await _apiClient.get('/prices');
      return (response.data as List)
          .map((json) => MarketPriceEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw CustomException('Failed to fetch market prices: $e');
    }
  }

  // ... implementasi lainnya
}

```

### 2.3 Pewarisan (Inheritance) vs Komposisi (Composition)

* **Gunakan Inheritance** untuk entitas *core* atau *base class* (misalnya `BaseModel`, `BaseState`).
* **Gunakan Komposisi** untuk UI Widget. Jangan membuat class yang *extends* `Container` atau `Padding`. Buatlah `StatelessWidget` yang me-*return* widget tersebut.

---

## 3. Strategi Refactoring di Flutter

Refactoring bertujuan untuk menghindari "Spaghetti Code" dan "Widget Tree of Doom" (metode `build` yang terlalu panjang dan bersarang).

### 3.1 Extract Widget vs Extract Method

**Aturan Emas:** Selalu gunakan *Extract Widget* (membuat Class `StatelessWidget` baru) daripada *Extract Method* (membuat fungsi yang mereturn `Widget`).

* **Extract Method (Buruk):** Dart *analyzer* tidak mengetahui batas siklus hidup fungsi ini. Saat *parent* di-rebuild, fungsi ini akan selalu dieksekusi ulang seluruhnya.
* **Extract Widget (Baik):** Memiliki `BuildContext` sendiri dan dapat di-cache menggunakan `const`, sehingga Flutter bisa melewati proses *rebuild* jika propertinya tidak berubah.

**Contoh Refactoring (Dari Method ke Class):**

```dart
// ❌ HINDARI: Extract Method
Widget _buildHeader(String title) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text(title),
  );
}

// ✅ GUNAKAN: Extract Widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title),
    );
  }
}

```

### 3.2 Pemisahan State dan UI (Separation of Concerns)

Jangan melakukan *logic* bisnis (pemanggilan API, kalkulasi berat) di dalam method `build()`. Gunakan State Management (seperti BLoC, Riverpod, atau Provider) untuk menangani *logic*. UI hanya bertugas me- *render* *state*.

---

## 4. Membangun Reusable Components

Komponen yang *reusable* harus bersifat **Agnostik** (tidak tahu menahu tentang *business logic*) dan **Fleksibel** (menerima *callback* dan konfigurasi *styling* dari parent).

### 4.1 Merancang Reusable Card Component

Berikut adalah contoh implementasi kartu data yang ketat dan sepenuhnya dapat digunakan kembali di berbagai layar.

```dart
import 'package:flutter/material.dart';

/// Komponen Card reusable untuk menampilkan data item dengan thumbnail.
class ItemDataCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final Widget? trailingIcon;
  final bool isHighlight;

  const ItemDataCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
    this.trailingIcon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHighlight ? 4.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isHighlight ? Theme.of(context).primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildThumbnail(),
              const SizedBox(width: 16.0),
              Expanded(child: _buildTextContent(context)),
              if (trailingIcon != null) trailingIcon!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (imageUrl == null) return const SizedBox.shrink();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

```

### 4.2 Cara Menggunakan Component Secara Efektif

Ketika komponen di atas dipanggil, semua variabel dilempar melalui *constructor*, memastikan komponen ini murni berfungsi sebagai tampilan presentasional:

```dart
// Penggunaan di dalam Screen (UI Layer)
ItemDataCard(
  title: 'Musang King',
  subtitle: 'Kondisi: Segar, Akurasi Keaslian: 98%',
  imageUrl: 'https://example.com/image.png',
  isHighlight: true,
  trailingIcon: const Icon(Icons.chevron_right, color: Colors.blueGrey),
  onTap: () {
    // Navigasi ke detail atau panggil method pada ViewModel/Controller
  },
)

```

Dengan mengadopsi standar di atas, basis kode Flutter akan menjadi *modular*, mudah diuji (*testable*), minim perulangan kode (DRY - *Don't Repeat Yourself*), dan menjamin performa rendering pada *frame rate* maksimal (60/120fps).