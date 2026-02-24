import 'enums.dart';

class ManpowerEntry {
  final String id;
  final String subcontractorId;
  final String name;
  final ApprovalStatus approvalStatus;
  final AttendanceStatus attendanceStatus;
  final DateTime date;

  const ManpowerEntry({
    required this.id,
    required this.subcontractorId,
    required this.name,
    this.approvalStatus = ApprovalStatus.pending,
    this.attendanceStatus = AttendanceStatus.notMarked,
    required this.date,
  });

  ManpowerEntry copyWith({
    String? id,
    String? subcontractorId,
    String? name,
    ApprovalStatus? approvalStatus,
    AttendanceStatus? attendanceStatus,
    DateTime? date,
  }) {
    return ManpowerEntry(
      id: id ?? this.id,
      subcontractorId: subcontractorId ?? this.subcontractorId,
      name: name ?? this.name,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      date: date ?? this.date,
    );
  }
}
