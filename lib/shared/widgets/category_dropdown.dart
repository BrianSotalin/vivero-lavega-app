import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';

class CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final bool isEnabled;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white, // Fondo blanco del dropdown
        ),
        child: DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(30),
          value: selectedCategory,
          items:
              categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
          onChanged: isEnabled ? onChanged : null,
          decoration: InputDecoration(
            labelText: 'Categoría',
            labelStyle: TextStyle(color: AppColors.textPrimary),
            floatingLabelStyle: TextStyle(color: AppColors.primary),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.third, width: 1),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}
