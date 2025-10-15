import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import 'animal.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _species = 'Dairy Cow';
  int _age = 24;
  double _prod = 1.0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen:false);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Animal')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Name/Tag'), onSaved: (v)=> _name = v ?? ''),
            const SizedBox(height:12),
            DropdownButtonFormField<String>(
              initialValue: _species,
              items: ['Dairy Cow','Goat','Beef','Chicken'].map((s)=> DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v)=> setState(()=> _species = v ?? _species),
              decoration: const InputDecoration(labelText: 'Species'),
            ),
            const SizedBox(height:12),
            Text('Age (months): $_age'),
            Slider(value: _age.toDouble(), min: 1, max: 180, divisions: 179, onChanged: (v)=> setState(()=> _age = v.toInt())),
            const SizedBox(height:12),
            Text('Daily production: ${_prod.toStringAsFixed(1)}'),
            Slider(value: _prod, min: 0, max: 20, divisions: 40, onChanged: (v)=> setState(()=> _prod = v)),
            const SizedBox(height:20),
            ElevatedButton(onPressed: () {
              _formKey.currentState?.save();
              if(_name.isNotEmpty) {
                state.addAnimal(Animal(name: _name, species: _species, ageMonths: _age, production: _prod));
                Navigator.pop(context);
              }
            }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)), child: const Text('Save')),
          ]),
        ),
      ),
    );
  }
}