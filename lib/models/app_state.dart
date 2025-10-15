import 'package:flutter/material.dart';
import '../screens/farm/animal.dart';

class AppState extends ChangeNotifier {
  List<Animal> animals = [
    Animal(name: 'Bessie', species: 'Dairy Cow', ageMonths: 36, production: 6.0),
    Animal(name: 'Mala', species: 'Goat', ageMonths: 18, production: 2.0),
  ];

  List<Map<String, dynamic>> marketplace = [
    {'title': 'Maize - Grade A', 'price': 60, 'seller': 'John', 'image': 'assets/images/maize.png'},
    {'title': 'Fresh Milk 1L', 'price': 30, 'seller': 'Amina', 'image': 'assets/images/cow.png'},
  ];

  void addAnimal(Animal a) {
    animals.add(a);
    notifyListeners();
  }

  void removeAnimalAt(int idx) {
    animals.removeAt(idx);
    notifyListeners();
  }

  void addMarketplaceItem(Map<String,dynamic> item) {
    marketplace.add(item);
    notifyListeners();
  }
}