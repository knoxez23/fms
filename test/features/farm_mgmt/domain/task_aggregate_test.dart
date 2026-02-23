import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_aggregate.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';

void main() {
  test('complete preserves source metadata', () {
    final aggregate = TaskAggregate(
      TaskEntity(
        id: '1',
        title: TaskTitle('Restock Feed'),
        sourceEventType: 'InventoryLowStock',
        sourceEventId: 'inv-1',
      ),
    );

    final completed = aggregate.complete();
    expect(completed.isCompleted, isTrue);
    expect(completed.sourceEventType, 'InventoryLowStock');
    expect(completed.sourceEventId, 'inv-1');
  });
}
