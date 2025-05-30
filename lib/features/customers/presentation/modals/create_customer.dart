import 'package:flutter/material.dart';
import '../../domain/entities/customer.dart';
import '../../data/repositories/customer_service.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart'; // Asegúrate de tener colores definidos

class CreateCustomerModal extends StatefulWidget {
  const CreateCustomerModal({super.key});

  @override
  State<CreateCustomerModal> createState() => _CreateCustomerModalState();
}

class _CreateCustomerModalState extends State<CreateCustomerModal> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newCustomer = Customer(
        id: '', // Supabase lo genera
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.toUpperCase(),
      );

      await _customerService.createCustomer(newCustomer);
      if (!mounted) return; // Devuelve true al cerrar
      Navigator.pop(context, true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Guardado exitosamente')));
    } catch (e) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear cliente: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: const Text(
          'Crear Cliente',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  floatingLabelStyle: TextStyle(color: AppColors.third),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  floatingLabelStyle: TextStyle(color: AppColors.third),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  floatingLabelStyle: TextStyle(color: AppColors.third),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  floatingLabelStyle: TextStyle(color: AppColors.third),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  floatingLabelStyle: TextStyle(color: AppColors.third),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
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
                onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                onPressed: _isSaving ? null : _saveCustomer,
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
