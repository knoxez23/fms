import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import '../domain/repositories/marketplace_repository.dart';
import '../domain/entities/product_entity.dart';
import '../domain/entities/inquiry_entity.dart';
import '../domain/value_objects/value_objects.dart';

@LazySingleton(as: MarketplaceRepository)
class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  @override
  Future<ProductEntity> addProduct(ProductEntity product) async {
    final db = await _dbHelper.database;
    await db.insert('inventory', {
      'item_name': product.name.value,
      'category': product.category,
      'quantity': product.quantity,
      'unit': product.unit,
      'unit_price': product.price.value,
      'total_value': product.price.value * product.quantity,
      'last_updated': DateTime.now().toIso8601String(),
    });

    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    final int? parsed = int.tryParse(id);
    if (parsed == null) return;
    await db.delete('inventory', where: 'id = ?', whereArgs: [parsed]);
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    // Prefer persisted marketplace/inventory records when available
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('inventory');
    if (maps.isNotEmpty) {
      return maps.map(_mapToEntity).toList();
    }

    // Fallback to LocalData cache
    final prices = await LocalData.getMarketPrices();
    return prices.map((p) {
      final name = (p['item'] ?? 'Unknown').toString();
      final rawPrice = (p['price'] ?? '').toString();
      final parsed = _parsePrice(rawPrice);
      return ProductEntity(
        id: name,
        name: ProductName(name),
        category: 'Crops',
        price: Price(parsed),
        quantity: 0,
        unit: 'bag',
      );
    }).toList();
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final db = await _dbHelper.database;
    final id = int.tryParse(product.id ?? '');
    if (id == null) return product;

    await db.update(
      'inventory',
      {
        'item_name': product.name.value,
        'category': product.category,
        'quantity': product.quantity,
        'unit': product.unit,
        'unit_price': product.price.value,
        'total_value': product.price.value * product.quantity,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return product;
  }

  @override
  Future<InquiryEntity> submitInquiry(InquiryEntity inquiry) async {
    final db = await _dbHelper.database;
    final id = await db.insert('marketplace_inquiries', {
      'inquiry_type': inquiry.inquiryType,
      'product_name': inquiry.productName,
      'category': inquiry.category,
      'quantity': inquiry.quantity,
      'details': inquiry.details,
      'created_at': inquiry.createdAt.toIso8601String(),
    });

    return InquiryEntity(
      id: id.toString(),
      inquiryType: inquiry.inquiryType,
      productName: inquiry.productName,
      category: inquiry.category,
      quantity: inquiry.quantity,
      details: inquiry.details,
      createdAt: inquiry.createdAt,
    );
  }

  ProductEntity _mapToEntity(Map<String, dynamic> map) {
    final name = (map['item_name'] ?? 'Unnamed').toString();
    return ProductEntity(
      id: map['id']?.toString(),
      name: ProductName(name),
      category: (map['category'] ?? 'Uncategorized').toString(),
      price: Price((map['unit_price'] as num?)?.toDouble() ?? 0),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: (map['unit'] ?? '').toString(),
    );
  }

  double _parsePrice(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\\.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}
