class GroupShareLinkModel {
  final String groupId;
  final String groupName;
  final String shareLink;
  final String shareText;

  const GroupShareLinkModel({
    required this.groupId,
    required this.groupName,
    required this.shareLink,
    required this.shareText,
  });

  factory GroupShareLinkModel.fromJson(Map<String, dynamic> json) {
    return GroupShareLinkModel(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      shareLink: json['shareLink'] as String,
      shareText: json['shareText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'shareLink': shareLink,
      'shareText': shareText,
    };
  }
}
