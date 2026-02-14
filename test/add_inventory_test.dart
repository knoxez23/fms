import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/inventory/presentation/add_inventory_screen.dart';

void main() {
  testWidgets('AddInventory returns new item on Save', (tester) async {
    dynamic result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
              );
            },
            child: const Text('Open'),
          );
        }),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Fill required fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Item Name *'), 'Test Item');
    await tester.pump();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity *'), '10');
    await tester.pump();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Minimum Stock Level *'), '2');
    await tester.pump();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Supplier *'), 'Test Supplier');
    await tester.pump();

    // Invoke Save button callback directly to avoid hit-test issues in test environment
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result['itemName'] == 'Test Item', isTrue);
  });
}
