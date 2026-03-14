class Task {
  final int? id;
  final String? clientUuid;
  final String title;
  final String? description;
  final String? dueDate;
  final String? priority;
  final String? status;
  final String? category;
  final String? assignedTo;
  final int? staffMemberId;
  final String? createdAt;
  final int? userId;
  final String? sourceEventType;
  final String? sourceEventId;
  final String? completionNotes;
  final bool? approvalRequired;
  final String? approvalStatus;
  final String? approvedBy;
  final String? approvedAt;
  final String? approvalComment;
  final bool? isSynced;

  Task({
    this.id,
    this.clientUuid,
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.category,
    this.assignedTo,
    this.staffMemberId,
    this.createdAt,
    this.userId,
    this.sourceEventType,
    this.sourceEventId,
    this.completionNotes,
    this.approvalRequired,
    this.approvalStatus,
    this.approvedBy,
    this.approvedAt,
    this.approvalComment,
    this.isSynced,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'client_uuid': clientUuid,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'status': status ?? 'pending',
      'category': category,
      'assigned_to': assignedTo,
      'staff_member_id': staffMemberId,
      'created_at': createdAt,
      'user_id': userId,
      'source_event_type': sourceEventType,
      'source_event_id': sourceEventId,
      'completion_notes': completionNotes,
      'approval_required':
          approvalRequired == null ? null : (approvalRequired! ? 1 : 0),
      'approval_status': approvalStatus,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'approval_comment': approvalComment,
      'is_synced': isSynced == null ? null : (isSynced! ? 1 : 0),
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      clientUuid: map['client_uuid']?.toString(),
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'],
      priority: map['priority'],
      status: map['status'],
      category: map['category'],
      assignedTo: map['assigned_to'],
      staffMemberId: map['staff_member_id'] is int
          ? map['staff_member_id'] as int
          : int.tryParse('${map['staff_member_id'] ?? ''}'),
      createdAt: map['created_at'],
      userId: map['user_id'],
      sourceEventType: map['source_event_type'],
      sourceEventId: map['source_event_id'],
      completionNotes: map['completion_notes']?.toString(),
      approvalRequired: map['approval_required'] == null
          ? null
          : (map['approval_required'] == 1 ||
              map['approval_required'] == true ||
              '${map['approval_required']}'.toLowerCase() == 'true'),
      approvalStatus: map['approval_status']?.toString(),
      approvedBy: map['approved_by']?.toString(),
      approvedAt: map['approved_at']?.toString(),
      approvalComment: map['approval_comment']?.toString(),
      isSynced: map['is_synced'] == null ? null : (map['is_synced'] == 1),
    );
  }

  Task copyWith({
    int? id,
    String? clientUuid,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    String? status,
    String? category,
    String? assignedTo,
    int? staffMemberId,
    String? createdAt,
    int? userId,
    String? sourceEventType,
    String? sourceEventId,
    String? completionNotes,
    bool? approvalRequired,
    String? approvalStatus,
    String? approvedBy,
    String? approvedAt,
    String? approvalComment,
    bool? isSynced,
  }) {
    return Task(
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
      staffMemberId: staffMemberId ?? this.staffMemberId,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      sourceEventType: sourceEventType ?? this.sourceEventType,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      completionNotes: completionNotes ?? this.completionNotes,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      approvalComment: approvalComment ?? this.approvalComment,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
