import 'package:pariba/domain/entities/join_request.dart';

class JoinRequestModel extends JoinRequest {
  const JoinRequestModel({
    required super.id,
    required super.groupId,
    required super.groupName,
    required super.personId,
    required super.personName,
    required super.personPhone,
    super.personPhoto,
    required super.status,
    super.message,
    super.reviewedBy,
    super.reviewedAt,
    super.reviewNote,
    required super.createdAt,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>?;
    final reviewedBy = json['reviewedBy'] as Map<String, dynamic>?;

    return JoinRequestModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      personId: person?['id'] as String? ?? '',
      personName: '${person?['prenom'] ?? ''} ${person?['nom'] ?? ''}'.trim(),
      personPhone: person?['phone'] as String? ?? '',
      personPhoto: person?['photo'] as String?,
      status: json['status'] as String,
      message: json['message'] as String?,
      reviewedBy: reviewedBy != null
          ? '${reviewedBy['prenom'] ?? ''} ${reviewedBy['nom'] ?? ''}'.trim()
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewNote: json['reviewNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'status': status,
      'message': message,
      'reviewNote': reviewNote,
      'createdAt': createdAt.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    };
  }
}
