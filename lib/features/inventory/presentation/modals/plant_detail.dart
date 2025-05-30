import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import '../../domain/entities/plant.dart';

class PlantDetailModal extends StatefulWidget {
  final Plant plant;

  const PlantDetailModal({super.key, required this.plant});

  @override
  State<PlantDetailModal> createState() => _PlantDetailModalState();
}

class _PlantDetailModalState extends State<PlantDetailModal> {
  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _error;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.plant.name.toUpperCase(),
    );
    _stockController = TextEditingController(
      text: widget.plant.stock.toString(),
    );
    _priceController = TextEditingController(
      text: widget.plant.price.toString(),
    );
    _categoryController = TextEditingController(
      text: widget.plant.category ?? '',
    );
    _fetchCategories(); // Cargar categorías
  }

  Future<void> _fetchCategories() async {
    final response = await Supabase.instance.client
        .schema('inventory')
        .from('categories')
        .select('name');

    final data = response as List;
    setState(() {
      _categories = data.map((e) => e['name'] as String).toList();
    });
  }

  Future<void> _updatePlant() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updated = {
        'name': _nameController.text,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'category': _categoryController.text,
      };

      final response = await Supabase.instance.client
          .schema('inventory')
          .from('plants')
          .update(updated)
          .eq('id', widget.plant.id);

      if (!mounted) return;
      if (response == null) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Editado exitosamente')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al editar el registro')));
      }
    } catch (e) {
      setState(() => _error = 'Error al guardar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          widget.plant.name,
          style: TextStyle(color: AppColors.third),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, 'Nombre'),
            _buildTextField(_stockController, 'Stock', isNumber: true),
            _buildTextField(_priceController, 'Precio', isNumber: true),
            _buildCategoryDropdown(),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.secondary, // Cambia aquí el color de fondo
                  foregroundColor:
                      AppColors.textPrimary, // Color del texto o íconos
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              SizedBox(width: 20),
              if (!_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.third, // Cambia aquí el color de fondo
                    foregroundColor: Colors.white, // Color del texto o íconos
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('Editar'),
                ),
              if (_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary, // Cambia aquí el color de fondo
                    foregroundColor: Colors.white, // Color del texto o íconos
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updatePlant,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Guardar'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: !_isEditing,

        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textPrimary),
          floatingLabelStyle: TextStyle(color: AppColors.primary),
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.third, width: 1),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value:
            _categoryController.text.isNotEmpty
                ? _categoryController.text
                : null,
        items:
            _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
        onChanged:
            _isEditing
                ? (value) => setState(() {
                  _categoryController.text = value!;
                })
                : null,
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
    );
  }
}
