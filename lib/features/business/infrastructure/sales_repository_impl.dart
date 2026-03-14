import 'dart:convert';

import 'package:injectable/injectable.dart';
import '../domain/repositories/sales_repository.dart';
import '../domain/entities/sale_entity.dart';
import '../domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/services/sale_service.dart';
import 'package:pamoja_twalima/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';

@LazySingleton(as: SalesRepository)
class SalesRepositoryImpl implements SalesRepository {
  final SaleService _service;
  final InventoryRepository _inventoryRepository;

  SalesRepositoryImpl(this._service, this._inventoryRepository);

  @override
  Future<List<SaleEntity>> getSales() async {
    try {
      final remote = await _service.list();
      for (final row in remote) {
        await LocalData.upsertSaleFromServer(
          Map<String, dynamic>.from(row as Map),
        );
      }
      return remote
          .map((row) => _mapToEntity(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (_) {
      final local = await LocalData.getSales();
      return local.map(_mapToEntity).toList();
    }
  }

  @override
  Future<SaleEntity> addSale(SaleEntity sale) async {
    final payload = _entityToPayload(sale);
    try {
      final created = await _service.create(payload);
      await LocalData.insertSale(created);
      final entity = _mapToEntity(created);
      await _applyInventoryPlan(_readStockPlan(created));
      return entity;
    } catch (_) {
      final stockPlan = await _buildLocalStockPlan(sale);
      final localId = await LocalData.insertSale({
        ...payload,
        'stock_deduction_plan': stockPlan,
      });
      await _applyInventoryPlan(stockPlan);
      await LocalData.insertPendingSale({
        ...payload,
        'stock_deduction_plan': stockPlan,
        'local_id': localId,
      });
      final entity = SaleEntity(
        id: localId.toString(),
        productName: sale.productName,
        quantity: sale.quantity,
        unit: sale.unit,
        pricePerUnit: sale.pricePerUnit,
        totalAmount: sale.totalAmount,
        customer: sale.customer,
        customerId: sale.customerId,
        paymentStatus: sale.paymentStatus,
        type: sale.type,
        date: sale.date,
        animal: sale.animal,
        notes: sale.notes,
      );
      return entity;
    }
  }

  @override
  Future<SaleEntity> updateSale(SaleEntity sale) async {
    if (sale.id == null) return sale;
    final payload = _entityToPayload(sale);
    final parsedId = int.tryParse(sale.id!);
    if (parsedId == null) return sale;
    final existing = await _findSaleRow(parsedId);
    if (existing != null) {
      await _restoreInventoryPlan(_readStockPlan(existing));
    }
    try {
      final updated = await _service.update(parsedId, payload);
      await LocalData.updateSaleByIdOrServerId(parsedId, updated);
      await _applyInventoryPlan(_readStockPlan(updated));
      return _mapToEntity(updated);
    } catch (_) {
      final stockPlan = await _buildLocalStockPlan(sale);
      await LocalData.updateSaleByIdOrServerId(parsedId, {
        ...payload,
        'stock_deduction_plan': stockPlan,
      });
      await _applyInventoryPlan(stockPlan);
      return sale;
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    final existing = await _findSaleRow(parsed);
    try {
      await _service.delete(parsed);
    } finally {
      if (existing != null) {
        await _restoreInventoryPlan(_readStockPlan(existing));
      }
      await LocalData.deleteSaleByIdOrServerId(parsed);
    }
  }

  Future<List<Map<String, dynamic>>> _buildLocalStockPlan(SaleEntity sale) async {
    final items = await _findMatchingOutputStocks(sale);
    var remaining = sale.quantity.value;
    final plan = <Map<String, dynamic>>[];

    for (final item in items) {
      if (remaining <= 0) break;
      if (item.quantity <= 0) continue;
      final deducted = remaining < item.quantity ? remaining : item.quantity;
      plan.add({
        'inventory_local_id': item.id != null ? int.tryParse(item.id!) : null,
        'inventory_server_id':
            item.id == null ? null : int.tryParse(item.id!),
        'client_uuid': item.clientUuid,
        'quantity': deducted,
        'item_name': item.itemName,
        'unit': item.unit,
        'lot_label': _lotLabelFor(item),
      });
      remaining -= deducted;
    }

    return plan;
  }

  Future<void> _applyInventoryPlan(List<Map<String, dynamic>> plan) async {
    if (plan.isEmpty) return;
    final items = await _inventoryRepository.getItems();
    for (final step in plan) {
      final matched = _findInventoryByPlan(items, step);
      if (matched == null) continue;
      final qty = (step['quantity'] as num?)?.toDouble() ?? 0;
      if (qty <= 0 || matched.quantity < qty) continue;
      await _inventoryRepository.updateItem(
        _copyInventoryWithQuantity(matched, matched.quantity - qty),
      );
    }
  }

  Future<void> _restoreInventoryPlan(List<Map<String, dynamic>> plan) async {
    if (plan.isEmpty) return;
    final items = await _inventoryRepository.getItems();
    for (final step in plan) {
      final matched = _findInventoryByPlan(items, step);
      if (matched == null) continue;
      final qty = (step['quantity'] as num?)?.toDouble() ?? 0;
      if (qty <= 0) continue;
      await _inventoryRepository.updateItem(
        _copyInventoryWithQuantity(matched, matched.quantity + qty),
      );
    }
  }

  Future<List<InventoryItem>> _findMatchingOutputStocks(SaleEntity sale) async {
    if (!_isOutputProduct(sale.productName)) return const [];
    final items = await _inventoryRepository.getItems();
    final normalizedProduct = sale.productName.trim().toLowerCase();
    final normalizedCategory = _outputCategoryFor(sale.productName);
    final filtered = items.where((item) {
      if (item.unit.trim().toLowerCase() != sale.unit.trim().toLowerCase()) {
        return false;
      }
      final itemName = item.itemName.trim().toLowerCase();
      final itemCategory = item.category.trim().toLowerCase();
      return itemName == normalizedProduct && itemCategory == normalizedCategory;
    }).toList();
    filtered.sort((a, b) {
      final aTime = a.lastRestock ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastRestock ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    return filtered;
  }

  InventoryItem? _findInventoryByPlan(
    List<InventoryItem> items,
    Map<String, dynamic> step,
  ) {
    final localId = step['inventory_local_id']?.toString();
    final serverId = step['inventory_server_id']?.toString();
    final clientUuid = (step['client_uuid'] ?? '').toString();

    for (final item in items) {
      if (localId != null && localId.isNotEmpty && item.id == localId) {
        return item;
      }
      if (serverId != null && serverId.isNotEmpty && item.id == serverId) {
        return item;
      }
      if (clientUuid.isNotEmpty && item.clientUuid == clientUuid) {
        return item;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _findSaleRow(int id) async {
    final rows = await LocalData.getSales();
    for (final row in rows) {
      final localId = row['id'];
      final serverId = row['server_id'];
      if (localId == id || serverId == id) {
        return Map<String, dynamic>.from(row);
      }
    }
    return null;
  }

  bool _isOutputProduct(String productName) {
    final normalized = productName.trim().toLowerCase();
    return normalized == 'milk' || normalized == 'eggs';
  }

  String _lotLabelFor(InventoryItem item) {
    final date = item.lastRestock;
    if (date == null) return 'Current lot';
    final month = _monthLabel(date.month);
    return 'Lot from $month ${date.day}';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _outputCategoryFor(String productName) {
    switch (productName.trim().toLowerCase()) {
      case 'milk':
        return 'dairy';
      case 'eggs':
        return 'poultry';
      default:
        return '';
    }
  }

  SaleEntity _mapToEntity(Map<String, dynamic> map) {
    final qty = (map['quantity'] as num?)?.toDouble() ?? 0;
    final price = (map['price'] as num?)?.toDouble() ?? 0;
    final total = (map['total_amount'] as num?)?.toDouble() ?? qty * price;
    final dateString = map['sale_date'] ?? map['date'];

    return SaleEntity(
      id: (map['server_id'] ?? map['id'])?.toString(),
      productName: map['product_name'] ?? map['product'] ?? '',
      quantity: BusinessQuantity(qty),
      unit: map['unit'] ?? '',
      pricePerUnit: Money(price),
      totalAmount: Money(total),
      customer: map['customer_name'] ?? map['customer'] ?? '-',
      customerId: map['customer_id']?.toString(),
      paymentStatus: map['payment_status'] ?? map['paymentStatus'] ?? 'Pending',
      type: map['type'] ?? 'Other',
      animal: map['animal'],
      date: dateString != null ? DateTime.tryParse(dateString) : null,
      notes: map['notes'],
    );
  }

  List<Map<String, dynamic>> _readStockPlan(Map<String, dynamic> map) {
    final raw = map['stock_deduction_plan'];
    if (raw is List) {
      return raw.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      }
    }
    return const [];
  }

  InventoryItem _copyInventoryWithQuantity(InventoryItem item, double quantity) {
    return InventoryItem(
      id: item.id,
      clientUuid: item.clientUuid,
      supplierId: item.supplierId,
      itemName: item.itemName,
      category: item.category,
      quantity: quantity,
      unit: item.unit,
      minStock: item.minStock,
      unitPrice: item.unitPrice,
      totalValue: item.unitPrice != null ? quantity * item.unitPrice! : item.totalValue,
      supplier: item.supplier,
      expiryDate: item.expiryDate,
      lastRestock: item.lastRestock,
      isSynced: false,
      hasConflict: item.hasConflict,
    );
  }

  Map<String, dynamic> _entityToPayload(SaleEntity sale) {
    return {
      'product_name': sale.productName,
      'quantity': sale.quantity.value,
      'unit': sale.unit,
      'price': sale.pricePerUnit.value,
      'total_amount': sale.totalAmount.value,
      'customer_name': sale.customer,
      'customer_id': sale.customerId != null ? int.tryParse(sale.customerId!) : null,
      'payment_status': sale.paymentStatus,
      'type': sale.type,
      'sale_date': sale.date?.toIso8601String(),
      'animal': sale.animal,
      'notes': sale.notes,
    };
  }
}
