// domain/entities/invitation.dart - MIS À JOUR
class Invitation {
  final String id;
  final String linkCode;
  final String? groupId;
  final String? groupName;
  final String? targetEmail;
  final String? targetPhone;
  final String? status;
  final String? invitationLink;
  final String? whatsappLink;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final String? inviterName; // Ajouté pour l'UI
  final String? inviterId; // Ajouté

  Invitation({
    required this.id,
    required this.linkCode,
    this.groupId,
    this.groupName,
    this.targetEmail,
    this.targetPhone,
    this.status,
    this.invitationLink,
    this.whatsappLink,
    this.createdAt,
    this.expiresAt,
    this.inviterName,
    this.inviterId,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] ?? '',
      linkCode: json['linkCode'] ?? '',
      groupId: json['groupId'],
      groupName: json['groupName'],
      targetEmail: json['targetEmail'],
      targetPhone: json['targetPhone'],
      status: json['status'],
      invitationLink: json['invitationLink'],
      whatsappLink: json['whatsappLink'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      inviterName: json['inviterName'], // Peut être null
      inviterId: json['inviterId'], // Peut être null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkCode': linkCode,
      if (groupId != null) 'groupId': groupId,
      if (groupName != null) 'groupName': groupName,
      if (targetEmail != null) 'targetEmail': targetEmail,
      if (targetPhone != null) 'targetPhone': targetPhone,
      if (status != null) 'status': status,
      if (invitationLink != null) 'invitationLink': invitationLink,
      if (whatsappLink != null) 'whatsappLink': whatsappLink,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (inviterName != null) 'inviterName': inviterName,
      if (inviterId != null) 'inviterId': inviterId,
    };
  }
}
