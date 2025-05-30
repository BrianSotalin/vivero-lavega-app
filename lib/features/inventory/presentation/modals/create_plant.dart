import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import 'package:vivero_lavega/shared/widgets/category_dropdown.dart';

class CreatePlantModal extends StatefulWidget {
  const CreatePlantModal({super.key});

  @override
  State<CreatePlantModal> createState() => _CreatePlantModalState();
}

class _CreatePlantModalState extends State<CreatePlantModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0;
  int _stock = 0;
  String? _selectedCategory;
  List<String> _categories = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
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

  Future<void> _savePlant() async {
    try {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      final response = await Supabase.instance.client
          .schema('inventory')
          .from('plants')
          .insert({
            'name': _name.toUpperCase(),
            'price': _price,
            'stock': _stock,
            'category': _selectedCategory,
          });

      setState(() => _isLoading = false);
      if (!mounted) return;
      if (response == null) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Guardado exitosamente')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar el registro')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Agregar Nueva Planta',
        style: TextStyle(color: AppColors.primary),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                  ), // Opcional: cambia el color del texto label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onSaved: (value) => _name = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
              ),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                  ), // Opcional: cambia el color del texto label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.tryParse(value ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                  ), // Opcional: cambia el color del texto label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _stock = int.tryParse(value ?? '0') ?? 0,
              ),
              CategoryDropdown(
                categories: _categories,
                selectedCategory: _selectedCategory,
                isEnabled: true,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
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
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              SizedBox(width: 20),
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
                onPressed: _isLoading ? null : _savePlant,
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
}
