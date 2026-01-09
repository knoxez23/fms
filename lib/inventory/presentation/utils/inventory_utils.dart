import 'package:flutter/material.dart';

class InventoryUtils {
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Fertilizers':
        return Icons.science_outlined;
      case 'Seeds':
        return Icons.grass;
      case 'Animal Feed':
        return Icons.pets;
      case 'Chemicals':
        return Icons.warning_amber_outlined;
      case 'Animal Health':
        return Icons.medical_services_outlined;
      case 'Equipment':
        return Icons.build_outlined;
      case 'Tools':
        return Icons.handyman_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Fertilizers':
        return Colors.green;
      case 'Seeds':
        return Colors.teal;
      case 'Animal Feed':
        return Colors.brown;
      case 'Chemicals':
        return Colors.redAccent;
      case 'Animal Health':
        return Colors.purple;
      case 'Equipment':
        return Colors.blueGrey;
      case 'Tools':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Critical':
        return Colors.red;
      case 'Low Stock':
        return Colors.orange;
      case 'Adequate':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
