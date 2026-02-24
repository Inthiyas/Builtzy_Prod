import 'enums.dart';

class EquipmentEntry {
  final String id;
  final String subcontractorId;
  final String name;
  final String type;
  final ApprovalStatus approvalStatus;
  final DeploymentStatus deploymentStatus;
  final DateTime date;

  const EquipmentEntry({
    required this.id,
    required this.subcontractorId,
    required this.name,
    required this.type,
    this.approvalStatus = ApprovalStatus.pending,
    this.deploymentStatus = DeploymentStatus.nonDeployed,
    required this.date,
  });

  EquipmentEntry copyWith({
    String? id,
    String? subcontractorId,
    String? name,
    String? type,
    ApprovalStatus? approvalStatus,
    DeploymentStatus? deploymentStatus,
    DateTime? date,
  }) {
    return EquipmentEntry(
      id: id ?? this.id,
      subcontractorId: subcontractorId ?? this.subcontractorId,
      name: name ?? this.name,
      type: type ?? this.type,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      deploymentStatus: deploymentStatus ?? this.deploymentStatus,
      date: date ?? this.date,
    );
  }
}
