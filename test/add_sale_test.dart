import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/business/presentation/sales/add_sale_screen.dart';
import 'package:pamoja_twalima/business/domain/entities/sale_entity.dart';

void main() {
  testWidgets('AddSale returns new sale on Save', (tester) async {
    dynamic result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddSaleScreen()),
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
        find.widgetWithText(TextFormField, 'Quantity *'), '5');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Price per Unit (KSh) *'), '50');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Customer Name *'), 'Customer A');

    // Invoke Save button callback directly to avoid hit-test issues in test environment
    final saveButton =
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Save'));
    saveButton.onPressed?.call();
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, isA<SaleEntity>());
    expect((result as SaleEntity).productName.isNotEmpty, isTrue);
  });
}
