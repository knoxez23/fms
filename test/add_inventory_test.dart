import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pamoja_twalima/inventory/presentation/add_inventory_screen.dart';

class FakeAuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;
}

void main() {
  testWidgets('AddInventory returns new item on Save', (tester) async {
    dynamic result;

    await tester.pumpWidget(
      ChangeNotifierProvider<FakeAuthProvider>(
        create: (_) => FakeAuthProvider(),
        child: MaterialApp(
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
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Fill required fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Item Name *'), 'Test Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity *'), '10');
    await tester.enterText(find.widgetWithText(TextFormField, 'Minimum Stock Level *'), '2');

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result['item_name'] == 'Test Item', isTrue);
  });
}
