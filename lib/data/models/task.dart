class Task {
  final int? id;
  final String title;
  final String? description;
  final String? dueDate;
  final String? priority;
  final String? status;
  final String? category;
  final String? assignedTo;
  final String? createdAt;
  final int? userId;

  Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.category,
    this.assignedTo,
    this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'status': status ?? 'pending',
      'category': category,
      'assigned_to': assignedTo,
      'created_at': createdAt,
      'user_id': userId,
    };
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
      createdAt: map['created_at'],
      userId: map['user_id'],
    );
  }
}