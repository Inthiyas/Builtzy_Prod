class Subcontractor {
  final String id;
  final String userId;
  final String username;
  final String companyName;
  final String contactPerson;
  final String phoneNumber;
  final int totalManpower;
  final int totalEquipment;

  const Subcontractor({
    required this.id,
    required this.userId,
    required this.username,
    required this.companyName,
    required this.contactPerson,
    required this.phoneNumber,
    this.totalManpower = 0,
    this.totalEquipment = 0,
  });

  factory Subcontractor.fromJson(Map<String, dynamic> json) {
    return Subcontractor(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      companyName: json['companyName'],
      contactPerson: json['contactPerson'],
      phoneNumber: json['phoneNumber'],
      totalManpower: json['totalManpower'] ?? 0,
      totalEquipment: json['totalEquipment'] ?? 0,
    );
  }
}
