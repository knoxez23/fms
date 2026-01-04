import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import '../domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  @override
  Future<void> addProduct(Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    // try to parse numeric values when available
    double? unitPrice;
    if (product['price'] is num) {
      unitPrice = (product['price'] as num).toDouble();
    } else if (product['price'] is String) {
      final cleaned = (product['price'] as String).replaceAll(RegExp(r'[^0-9\.]'), '');
      unitPrice = double.tryParse(cleaned);
    }

    double? quantity;
    if (product['quantity'] is num) {
      quantity = (product['quantity'] as num).toDouble();
    } else if (product['quantity'] is String) {
      quantity = double.tryParse(product['quantity']);
    }

    final totalValue = (unitPrice != null && quantity != null) ? unitPrice * quantity : null;

    await db.insert('inventory', {
      'item_name': product['name'] ?? product['item'] ?? 'Unnamed',
      'category': product['category'] ?? 'Unclassified',
      'quantity': quantity,
      'unit': product['unit'] ?? product['uom'],
      'unit_price': unitPrice,
      'total_value': totalValue,
      'supplier': product['supplier'],
      'expiry_date': product['expiry_date'],
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    final int? parsed = int.tryParse(id);
    if (parsed == null) return;
    await db.delete('inventory', where: 'id = ?', whereArgs: [parsed]);
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
        // Prefer persisted marketplace/inventory records when available
        final db = await _dbHelper.database;
        final List<Map<String, dynamic>> maps = await db.query('inventory');
        if (maps.isNotEmpty) {
      return maps.map((m) => {
        'id': '${m['id']}',
        'name': m['item_name'],
        'price': m['unit_price'],
        'image': m['image'],
        'category': m['category'] ?? 'Uncategorized',
        'quantity': m['quantity'],
        'unit': m['unit'],
          }).toList();
        }

        // Fallback to LocalData cache
        final prices = await LocalData.getMarketPrices();
        return prices.map((p) => {
          'id': '${p['item']}',
          'name': p['item'],
          'price': p['price'],
          'image': null,
          'category': 'Crops',
        }).toList();
  }

  @override
  Future<void> updateProduct(Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    final id = product['id'] is int ? product['id'] : int.tryParse('${product['id']}');
    if (id == null) return;

    double? unitPrice;
    if (product['price'] is num) {
      unitPrice = (product['price'] as num).toDouble();
    } else if (product['price'] is String) {
      final cleaned = (product['price'] as String).replaceAll(RegExp(r'[^0-9\.]'), '');
      unitPrice = double.tryParse(cleaned);
    }

    double? quantity;
    if (product['quantity'] is num) {
      quantity = (product['quantity'] as num).toDouble();
    } else if (product['quantity'] is String) {
      quantity = double.tryParse(product['quantity']);
    }

    final totalValue = (unitPrice != null && quantity != null) ? unitPrice * quantity : null;

    await db.update(
      'inventory',
      {
        'item_name': product['name'] ?? product['item'] ?? 'Unnamed',
        'category': product['category'] ?? 'Unclassified',
        'quantity': quantity,
        'unit': product['unit'] ?? product['uom'],
        'unit_price': unitPrice,
        'total_value': totalValue,
        'supplier': product['supplier'],
        'expiry_date': product['expiry_date'],
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
