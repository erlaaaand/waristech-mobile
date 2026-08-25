/// Enum peran pengguna sesuai backend WarisTech.
enum UserRole {
  basic,
  pewaris,
  ahliWaris,
  verifikator;

  /// Konversi string dari backend ke enum [UserRole].
  static UserRole fromBackendString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PEWARIS':
        return UserRole.pewaris;
      case 'AHLI_WARIS':
        return UserRole.ahliWaris;
      case 'VERIFIKATOR':
      case 'NOTARIS':
        return UserRole.verifikator;
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
      case UserRole.verifikator:
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
      case UserRole.verifikator:
        return 'Verifikator / Notaris';
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
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Buat [UserEntity] dari respons JSON backend.
  /// Menangani wrapper `TransformInterceptor` dan variasi field name.
  factory UserEntity.fromBackendJson(Map<String, dynamic> raw) {
    // Tangani wrapper { data: { user: ... } } atau { user: ... } atau { data: ... }
    final data = raw['data'] ?? raw;
    final userData = (data is Map<String, dynamic> ? data['user'] : null) ??
        (data is Map<String, dynamic> ? data : raw);

    return UserEntity(
      id: userData['id']?.toString() ?? userData['userId']?.toString() ?? '',
      name: userData['fullName']?.toString() ??
          userData['name']?.toString() ??
          'User',
      email: userData['email']?.toString() ?? '',
      role: UserRole.fromBackendString(userData['role']?.toString()),
    );
  }

  /// Buat salinan entity dengan field yang diubah.
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
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
