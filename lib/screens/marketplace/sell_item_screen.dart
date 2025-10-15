import 'package:flutter/material.dart';

class SellItemScreen extends StatefulWidget {
  const SellItemScreen({super.key});

  @override
  State<SellItemScreen> createState() => _SellItemScreenState();
}

class _SellItemScreenState extends State<SellItemScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String name = '';
  String category = 'Crops';
  double? price;
  String desc = '';
  String imagePath = 'assets/images/placeholder.jpg';

  final List<String> categories = ['Crops', 'Vegetables', 'Livestock', 'Dairy', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell an Item"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _prevStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 1 ? 'Submit' : 'Next'),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Back", style: TextStyle(color: Colors.grey)),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text("Item Details"),
            isActive: _currentStep == 0,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Product Name"),
                    validator: (val) => val == null || val.isEmpty ? 'Enter product name' : null,
                    onSaved: (val) => name = val ?? '',
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: "Category"),
                    initialValue: category,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => category = val!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Price (Ksh)"),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
                    onSaved: (val) => price = double.tryParse(val ?? ''),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                    onSaved: (val) => desc = val ?? '',
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text("Preview"),
            isActive: _currentStep == 1,
            content: _buildPreviewCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(imagePath, height: 150, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Unnamed Product' : name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc.isEmpty ? 'No description provided' : desc,
                    style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ksh ${price?.toStringAsFixed(0) ?? '--'}',
                        style: const TextStyle(
                            color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14)),
                    Chip(
                      label: Text(category),
                      backgroundColor: const Color(0xFFFF9800).withOpacity(0.15),
                      labelStyle:
                      const TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        setState(() => _currentStep = 1);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item submitted successfully!")),
      );
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }
}
