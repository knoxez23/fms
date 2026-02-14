class InquiryEntity {
  final String? id;
  final String inquiryType;
  final String productName;
  final String category;
  final String quantity;
  final String? details;
  final DateTime createdAt;

  InquiryEntity({
    this.id,
    required this.inquiryType,
    required this.productName,
    required this.category,
    required this.quantity,
    this.details,
    required this.createdAt,
  }) {
    if (inquiryType.trim().isEmpty) {
      throw ArgumentError('inquiryType cannot be empty');
    }
    if (productName.trim().isEmpty) {
      throw ArgumentError('productName cannot be empty');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('category cannot be empty');
    }
    if (quantity.trim().isEmpty) {
      throw ArgumentError('quantity cannot be empty');
    }
  }
}
