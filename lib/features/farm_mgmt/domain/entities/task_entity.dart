import '../value_objects/value_objects.dart';

class TaskEntity {
  final String? id;
  final TaskTitle title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? assignedTo;
  final String? staffMemberId;
  final String? sourceEventType;
  final String? sourceEventId;
  final bool approvalRequired;
  final String approvalStatus;
  final String? approvedBy;
  final DateTime? approvedAt;

  TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.assignedTo,
    this.staffMemberId,
    this.sourceEventType,
    this.sourceEventId,
    this.approvalRequired = false,
    this.approvalStatus = 'not_required',
    this.approvedBy,
    this.approvedAt,
  });

  bool get isOverdue {
    if (dueDate == null) return false;
    return !isCompleted && DateTime.now().isAfter(dueDate!);
  }

  bool get isAwaitingApproval =>
      approvalRequired && approvalStatus.toLowerCase() == 'pending';

  bool get isApproved =>
      approvalRequired && approvalStatus.toLowerCase() == 'approved';

  bool get isRejected =>
      approvalRequired && approvalStatus.toLowerCase() == 'rejected';
}
