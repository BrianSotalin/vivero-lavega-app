import 'package:flutter/material.dart';
import '../../domain/entities/customer.dart';
import '../../data/repositories/customer_service.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import '../modals/phone_actions_modal.dart';
import '../modals/customer_detail.dart';

Widget buildDismissibleCustomerTile({
  required BuildContext context,
  required Customer customer,
  required int index,
  required List<Customer> customerList,
  required VoidCallback onUpdated,
}) {
  final CustomerService _customerService = CustomerService();

  return Dismissible(
    key: ValueKey(customer.id),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    confirmDismiss: (_) async {
      return await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: Center(child: const Text('Eliminar Cliente')),
              content: Text(
                '¿Estas seguro de eliminar este cliente "${customer.firstName} ${customer.lastName}"?',
              ),
              actions: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors
                                  .textPrimary, // Cambia aquí el color de fondo
                          foregroundColor:
                              Colors.white, // Color del texto o íconos
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.redAccent, // Cambia aquí el color de fondo
                          foregroundColor:
                              Colors.white, // Color del texto o íconos
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      );
    },
    onDismissed: (_) async {
      try {
        await _customerService.deleteCustomer(customer.id);

        customerList.removeAt(index);
        onUpdated(); // actualiza el estado del widget padre

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    },
    child: ListTile(
      leading: const Icon(Icons.person, color: AppColors.primary, size: 30),
      title: Text('${customer.firstName} ${customer.lastName}'),
      subtitle: customer.address != null ? Text('${customer.address}') : null,
      trailing:
          customer.phone != null && customer.phone!.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.phone, color: AppColors.primary),
                onPressed:
                    () => showPhoneActionsModal(context, customer.phone!),
              )
              : null,
      onTap: () async {
        final updated = await showDialog<bool>(
          context: context,
          builder: (_) => CustomerDetailModal(customer: customer),
        );

        if (updated == true) {
          onUpdated();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Editado exitosamente')),
            );
          }
        }
      },
    ),
  );
}
