class Crop {
  final int? id;
  final String name;
  final String? variety;
  final String plantedDate;
  final String? expectedHarvestDate;
  final double area;
  final String status;
  final String? notes;

  Crop({
    this.id,
    required this.name,
    this.variety,
    required this.plantedDate,
    this.expectedHarvestDate,
    required this.area,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'variety': variety,
      'planted_date': plantedDate,
      'expected_harvest_date': expectedHarvestDate,
      'area': area,
      'status': status,
      'notes': notes,
    };
  }

  factory Crop.fromMap(Map<String, dynamic> map) {
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Crop(
      id: parseInt(map['id']),
      name: map['name']?.toString() ?? '',
      variety: map['variety']?.toString(),
      plantedDate: map['planted_date']?.toString() ?? '',
      expectedHarvestDate: map['expected_harvest_date']?.toString(),
      area: parseDouble(map['area']),
      status: map['status']?.toString() ?? 'unknown',
      notes: map['notes']?.toString(),
    );
  }
}
