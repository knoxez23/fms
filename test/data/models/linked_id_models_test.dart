import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/data/models/inventory_dto.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';

void main() {
  test('inventory dto includes supplier_id in api payload', () {
    final dto = InventoryDto.fromEntity(
      InventoryItem(
        id: '1',
        clientUuid: 'client-1',
        itemName: 'Dairy Meal',
        category: 'Feed',
        quantity: 10,
        unit: 'kg',
        minStock: 2,
        supplier: 'Agro Vet Ltd',
        supplierId: '42',
        lastRestock: DateTime(2026, 2, 23),
      ),
    );

    final api = dto.toApi();
    expect(api['supplier_id'], equals(42));
  });

  test('task map includes staff_member_id when present', () {
    final task = Task(
      id: 5,
      title: 'Vaccinate herd',
      assignedTo: 'Field Officer',
      staffMemberId: 7,
    );

    final map = task.toMap();
    expect(map['staff_member_id'], equals(7));
  });

  test('task map includes approval workflow fields when present', () {
    final task = Task(
      id: 6,
      title: 'Approve generator repair spend',
      approvalRequired: true,
      approvalStatus: 'pending',
      approvedBy: '12',
      approvedAt: '2026-03-14T09:30:00.000Z',
    );

    final map = task.toMap();
    expect(map['approval_required'], equals(1));
    expect(map['approval_status'], equals('pending'));
    expect(map['approved_by'], equals('12'));
    expect(map['approved_at'], equals('2026-03-14T09:30:00.000Z'));
  });
}
