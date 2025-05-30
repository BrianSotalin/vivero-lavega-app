import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import '../../domain/entities/customer.dart';
//import 'package:vivero_lavega/shared/themes/app_colors.dart';
import '../../data/repositories/customer_service.dart';

class CustomerDetailModal extends StatefulWidget {
  final Customer customer;

  const CustomerDetailModal({super.key, required this.customer});

  @override
  State<CustomerDetailModal> createState() => _CustomerDetailModalState();
}

class _CustomerDetailModalState extends State<CustomerDetailModal> {
  final CustomerService _customerService = CustomerService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.customer.firstName,
    );
    _lastNameController = TextEditingController(text: widget.customer.lastName);
    _emailController = TextEditingController(text: widget.customer.email ?? '');
    _phoneController = TextEditingController(text: widget.customer.phone ?? '');
    _addressController = TextEditingController(
      text: widget.customer.address ?? '',
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final updatedCustomer = Customer(
        id: widget.customer.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text.toUpperCase(),
      );

      await _customerService.updateCustomer(updatedCustomer);

      if (mounted) {
        Navigator.pop(context, true); // Devuelve true si se actualizó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          '${widget.customer.firstName} ${widget.customer.lastName}',
          style: TextStyle(color: AppColors.third),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildField('Nombre', _firstNameController),
            _buildField('Apellido', _lastNameController),
            _buildField('Email', _emailController),
            _buildField('Teléfono', _phoneController),
            _buildField('Dirección', _addressController),
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
                child: const Text('Cerrar'),
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
                  onPressed: _isLoading ? null : _saveChanges,
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

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textPrimary),
          floatingLabelStyle: TextStyle(color: AppColors.third),
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
