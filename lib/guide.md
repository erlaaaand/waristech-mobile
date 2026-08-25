# WarisTech Mobile — Architecture Guide

## Clean Architecture Layers

```
lib/
├── core/
│   ├── error/
│   │   └── exceptions.dart        ← AppException, UnauthorizedException, DataParseException
│   ├── network/
│   │   ├── dio_client.dart        ← HTTP singleton dengan interceptors
│   │   └── base_remote_data_source.dart  ← Base class DRY: safeCall + unwrapData
│   ├── routing/
│   │   └── app_router.dart        ← GoRouter provider + redirect guard
│   ├── theme/
│   │   ├── app_colors.dart        ← Token warna terpusat
│   │   └── app_theme.dart         ← MaterialTheme light/dark
│   └── widgets/
│       └── wt_widgets.dart        ← Shared UI: WtLogo, WtBottomNav, WtInfoCard, WtStatCard, dll.
│
└── features/
    ├── auth/
    │   ├── domain/
    │   │   ├── entities/user_entity.dart     ← Plain class + fromBackendJson + UserRole.dashboardRoute
    │   │   └── repositories/auth_repository.dart  ← Abstract contract
    │   ├── data/
    │   │   ├── datasources/auth_remote_data_source.dart  ← extends BaseRemoteDataSource
    │   │   └── repositories/auth_repository_impl.dart    ← implements AuthRepository
    │   └── presentation/
    │       ├── providers/auth_provider.dart  ← StateNotifier + AsyncValue.guard
    │       └── screens/login_screen.dart     ← Split builder methods, ref.listen error
    │
    └── assets/
        ├── domain/
        │   ├── entities/asset_entity.dart    ← Plain class + fromJson
        │   └── repositories/asset_repository.dart  ← Abstract contract
        ├── data/
        │   ├── datasources/asset_remote_data_source.dart
        │   └── repositories/asset_repository_impl.dart
        └── presentation/
            └── providers/asset_provider.dart  ← Provider<AssetRepository>
```

## Prinsip yang Diterapkan

| Prinsip | Implementasi |
|---------|-------------|
| **OOP — Enkapsulasi** | `_storage`, `_remoteDataSource` semua `private final` |
| **OOP — Abstraksi** | `AuthRepository`, `AssetRepository` sebagai kontrak domain |
| **OOP — Inheritance** | Semua DataSource extends `BaseRemoteDataSource` |
| **OOP — Polimorfisme** | Provider menyimpan `AuthRepository` bukan `AuthRepositoryImpl` |
| **DRY** | `safeCall`, `unwrapData`, `AppException.fromDioError`, `UserRole.dashboardRoute` |
| **Single Responsibility** | `DioClient` hanya HTTP; `clearSession` didelegasi ke sana |
| **Dependency Inversion** | Presentation bergantung pada abstrak, bukan konkret |
| **Immutability** | `late final Dio dio`, `const` constructors |

## Error Handling Flow

```
DioException → AppException.fromDioError → AsyncValue.error → ref.listen → SnackBar
```

## Auth State Flow

```
LoginScreen → authProvider.login() → AsyncValue.guard → UserRole.dashboardRoute → GoRouter.redirect
```

## Menambah Fitur Baru

1. Buat `domain/entities/new_entity.dart` (plain class + fromJson)
2. Buat `domain/repositories/new_repository.dart` (abstract)
3. Buat `data/datasources/new_remote_data_source.dart` (`extends BaseRemoteDataSource`)
4. Buat `data/repositories/new_repository_impl.dart` (`implements NewRepository`)
5. Buat `presentation/providers/new_provider.dart` (`Provider<NewRepository>`)
