/// Enum peran pengguna sesuai backend WarisTech.
/// Nilai string harus cocok persis dengan backend (case-insensitive).
enum UserRole {
  basic,
  pewaris,
  ahliWaris,
  notaris,
  admin,
  guest;

  /// Konversi string dari backend ke enum [UserRole].
  static UserRole fromBackendString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PEWARIS':
        return UserRole.pewaris;
      case 'AHLI_WARIS':
        return UserRole.ahliWaris;
      case 'NOTARIS':
        return UserRole.notaris;
      case 'ADMIN':
        return UserRole.admin;
      case 'GUEST':
        return UserRole.guest;
      default:
        return UserRole.basic;
    }
  }

  /// Nama rute dashboard untuk setiap peran.
  String get dashboardRoute {
    switch (this) {
      case UserRole.pewaris:
        return 'pewaris-dashboard';
      case UserRole.ahliWaris:
        return 'ahli-waris-dashboard';
      case UserRole.notaris:
        return 'verifikator-dashboard';
      default:
        return 'login';
    }
  }

  /// Label tampilan untuk setiap peran.
  String get displayLabel {
    switch (this) {
      case UserRole.pewaris:
        return 'Pewaris';
      case UserRole.ahliWaris:
        return 'Ahli Waris';
      case UserRole.notaris:
        return 'Notaris';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.guest:
        return 'Tamu';
      default:
        return 'Pengguna';
    }
  }
}

/// Entitas domain pengguna.
/// Plain Dart class — tidak memerlukan code generation.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
  });

  /// Buat [UserEntity] dari respons login/me/profile backend.
  factory UserEntity.fromBackendJson(Map<String, dynamic> raw) {
    // Tangani wrapper data dari TransformInterceptor
    final envelope = raw['data'] ?? raw;
    final userData = (envelope is Map<String, dynamic>
        ? (envelope['user'] as Map<String, dynamic>? ?? envelope)
        : raw);

    final rawFullName = userData['fullName']?.toString().trim();
    final rawName = userData['name']?.toString().trim();
    final rawEmail = userData['email']?.toString().trim();

    String resolvedName = 'Pengguna';
    if (rawFullName != null && rawFullName.isNotEmpty) {
      resolvedName = rawFullName;
    } else if (rawName != null && rawName.isNotEmpty) {
      resolvedName = rawName;
    } else if (rawEmail != null && rawEmail.isNotEmpty) {
      resolvedName = rawEmail;
    }

    final rawPhone = userData['phoneNumber']?.toString().trim() ??
        userData['phone']?.toString().trim();

    return UserEntity(
      id: userData['id']?.toString() ?? userData['sub']?.toString() ?? '',
      name: resolvedName,
      email: rawEmail ?? '',
      phone: (rawPhone != null && rawPhone.isNotEmpty) ? rawPhone : null,
      role: UserRole.fromBackendString(userData['role']?.toString()),
      avatarUrl: userData['avatarUrl']?.toString(),
    );
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserEntity &&
      other.id == id &&
      other.email == email &&
      other.role == role;

  @override
  int get hashCode => Object.hash(id, email, role);

  @override
  String toString() => 'UserEntity(id: $id, name: $name, role: ${role.name})';
}
