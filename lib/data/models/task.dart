class Task {
  final int? id;
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
  final bool? isSynced;

  Task({
    this.id,
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
    this.isSynced,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
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
      'is_synced': isSynced == null ? null : (isSynced! ? 1 : 0),
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
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
      isSynced: map['is_synced'] == null ? null : (map['is_synced'] == 1),
    );
  }

  Task copyWith({
    int? id,
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
    bool? isSynced,
  }) {
    return Task(
      id: id ?? this.id,
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
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
