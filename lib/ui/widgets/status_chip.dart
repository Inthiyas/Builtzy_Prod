import 'package:flutter/material.dart';
import '../../models/models.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.approval(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return const StatusChip(label: 'Approved', color: Colors.green);
      case ApprovalStatus.pending:
        return const StatusChip(label: 'Pending', color: Colors.orange);
      case ApprovalStatus.rejected:
        return const StatusChip(label: 'Rejected', color: Colors.red);
    }
  }

  factory StatusChip.attendance(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const StatusChip(label: 'Present', color: Colors.blue);
      case AttendanceStatus.absent:
        return const StatusChip(label: 'Absent', color: Colors.redAccent);
      case AttendanceStatus.notMarked:
        return const StatusChip(label: 'Not Marked', color: Colors.grey);
    }
  }

  factory StatusChip.deployment(DeploymentStatus status) {
    switch (status) {
      case DeploymentStatus.deployed:
        return const StatusChip(label: 'Deployed', color: Colors.teal);
      case DeploymentStatus.nonDeployed:
        return const StatusChip(label: 'Non-Deployed', color: Colors.grey);
      case DeploymentStatus.underRepair:
        return const StatusChip(label: 'Under Repair', color: Colors.deepOrange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
