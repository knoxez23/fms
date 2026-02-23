import 'package:injectable/injectable.dart';
import '../domain/repositories/sales_repository.dart';
import '../domain/entities/sale_entity.dart';
import '../domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/services/sale_service.dart';

@LazySingleton(as: SalesRepository)
class SalesRepositoryImpl implements SalesRepository {
  final SaleService _service;

  SalesRepositoryImpl(this._service);

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
      return _mapToEntity(created);
    } catch (_) {
      final localId = await LocalData.insertSale(payload);
      await LocalData.insertPendingSale({
        ...payload,
        'local_id': localId,
      });
      return SaleEntity(
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
    }
  }

  @override
  Future<SaleEntity> updateSale(SaleEntity sale) async {
    if (sale.id == null) return sale;
    final payload = _entityToPayload(sale);
    final parsedId = int.tryParse(sale.id!);
    if (parsedId == null) return sale;
    try {
      final updated = await _service.update(parsedId, payload);
      await LocalData.updateSaleByIdOrServerId(parsedId, updated);
      return _mapToEntity(updated);
    } catch (_) {
      await LocalData.updateSaleByIdOrServerId(parsedId, payload);
      return sale;
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    try {
      await _service.delete(parsed);
    } finally {
      await LocalData.deleteSaleByIdOrServerId(parsed);
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
