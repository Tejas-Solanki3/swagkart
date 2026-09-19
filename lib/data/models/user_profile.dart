// =============================================================================
// File: lib/data/models/user_profile.dart
// Purpose: User profile model containing account credentials, addresses, role
//          (customer or admin), loyalty SwagPoints balance, and Firestore serialization.
// =============================================================================

/// User entity model tracking shopper identity, role permissions, and address info.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' or 'admin'
  final String street;
  final String city;
  final String pincode;
  final String state;
  final DateTime createdAt;
  final String? avatarUrl;
  final int swagPoints;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'customer',
    this.street = '',
    this.city = '',
    this.pincode = '',
    this.state = '',
    required this.createdAt,
    this.avatarUrl,
    this.swagPoints = 350,
  });


  bool get isAdmin => role.toLowerCase() == 'admin';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SK';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get formattedAddress {
    final components = [
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (pincode.isNotEmpty) pincode,
      if (state.isNotEmpty) state,
    ];
    return components.isEmpty ? 'No address saved yet' : components.join(', ');
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? street,
    String? city,
    String? pincode,
    String? state,
    DateTime? createdAt,
    String? avatarUrl,
    int? swagPoints,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      swagPoints: swagPoints ?? this.swagPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'street': street,
      'city': city,
      'pincode': pincode,
      'state': state,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'swagPoints': swagPoints,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfile(
      uid: (id ?? map['uid'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Swag Shopper',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'customer',
      street: (map['street'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      pincode: (map['pincode'] as String?) ?? '',
      state: (map['state'] as String?) ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      avatarUrl: map['avatarUrl'] as String?,
      swagPoints: (map['swagPoints'] as num?)?.toInt() ?? 350,
    );
  }
}
