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
    return Crop(
      id: map['id'],
      name: map['name'],
      variety: map['variety'],
      plantedDate: map['planted_date'],
      expectedHarvestDate: map['expected_harvest_date'],
      area: (map['area'] as num).toDouble(),
      status: map['status'],
      notes: map['notes'],
    );
  }
}
