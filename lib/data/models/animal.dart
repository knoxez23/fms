class Animal {
  final int? id;
  final String name;
  final String type;
  final String? breed;
  final int? age;
  final double? weight;
  final String? healthStatus;
  final String? dateAcquired;
  final String? notes;
  final int? userId;

  Animal({
    this.id,
    required this.name,
    required this.type,
    this.breed,
    this.age,
    this.weight,
    this.healthStatus,
    this.dateAcquired,
    this.notes,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'weight': weight,
      'health_status': healthStatus,
      'date_acquired': dateAcquired,
      'notes': notes,
      'user_id': userId,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      breed: map['breed'],
      age: map['age'],
      weight: map['weight'],
      healthStatus: map['health_status'],
      dateAcquired: map['date_acquired'],
      notes: map['notes'],
      userId: map['user_id'],
    );
  }
}