import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {
  final String personId;
  final String fullName;
  final String? photo;
  final String role;

  const GroupMember({
    required this.personId,
    required this.fullName,
    this.photo,
    required this.role,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      personId: json['person']?['id'] ?? json['personId'] ?? '',
      fullName: json['person']?['fullName'] ?? json['fullName'] ?? 'Membre',
      photo: json['person']?['photo'] ?? json['photo'],
      role: json['role'] ?? 'MEMBER',
    );
  }

  @override
  List<Object?> get props => [personId, fullName, photo, role];
}
