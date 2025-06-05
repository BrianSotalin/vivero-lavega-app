import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import '../../data/repositories/order_service.dart';
import '../../data/repositories/order_item_service.dart';
import '../../domain/entities/order_model.dart';
import '../../domain/entities/order_item_model.dart';
import '../utils/pdf_generator.dart';
import 'package:vivero_lavega/features/customers/data/repositories/customer_service.dart';
import 'package:vivero_lavega/features/customers/domain/entities/customer.dart';
import 'package:vivero_lavega/features/inventory/domain/entities/plant.dart';
import 'package:vivero_lavega/features/inventory/data/repositories/plant_service.dart';
import 'package:vivero_lavega/shared/widgets/qr_modal.dart';

class EditOrderScreen extends StatefulWidget {
  final String orderId;

  const EditOrderScreen({super.key, required this.orderId});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final OrderService _orderService = OrderService();
  final OrderItemService _orderItemService = OrderItemService();
  String _selectedStatus = 'VENTA';

  Order? _order;
  List<OrderItem> _items = [];
  List<Customer> _clients = [];
  List<Plant> _plants = [];
  double get _totalAmount {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity * item.priceAtSale,
    );
  }

  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    final order = await _orderService.getOrderById(widget.orderId);
    final items = await _orderItemService.getItemsByOrderId(widget.orderId);
    final clients = await CustomerService().fetchCustomers();
    final plants = await PlantService().fetchPlants();

    setState(() {
      _order = order;
      _items = items;
      _clients = clients;
      _plants = plants;
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Recalcular el total
      double total = _items.fold(
        0,
        (sum, item) => sum + (item.quantity * item.priceAtSale),
      );

      // Copiar el estado y total al objeto order
      _order = _order!.copyWith(totalAmount: total, status: _selectedStatus);

      await _orderService.updateOrder(_order!);

      for (var item in _items) {
        //await _orderItemService.updateOrderItem(item);
        await _orderItemService.replaceOrderItems(_order!.id, _items);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pedido actualizado')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _order == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Pedido'),
        backgroundColor: AppColors.background,

        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.primary,
            ), // Cambia el ícono si prefieres otro
            onSelected: (value) {
              if (value == 'pdf') {
                generateAndSharePdf(
                  order: _order!,
                  items: _items,
                  customers: _clients,
                  plants: _plants,
                );
              } else if (value == 'qr') {
                showQrDialog(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Imprimir PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'qr',
                    child: Row(
                      children: [
                        Icon(Icons.qr_code, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Código QR'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Cliente
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _order!.customerId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items:
                    _clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client.id,
                        child: Text('${client.firstName} ${client.lastName}'),
                      );
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    _order = _order!.copyWith(customerId: val!);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Estado
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                decoration: const InputDecoration(labelText: 'Tipo'),
                value: _order!.status,
                items: const [
                  DropdownMenuItem(value: 'VENTA', child: Text('VENTA')),
                  DropdownMenuItem(value: 'PROFORMA', child: Text('PROFORMA')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Productos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 8),

              ..._items.map((item) {
                final index = _items.indexOf(item);
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),

                        // Planta
                        DropdownButtonFormField<String>(
                          value: item.plantId,
                          decoration: const InputDecoration(
                            labelText: 'Planta',
                          ),

                          items:
                              _plants.map((plant) {
                                return DropdownMenuItem<String>(
                                  value: plant.id,
                                  child: Text(plant.name),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _items[index] = item.copyWith(plantId: val!);
                            });
                          },
                          //onChanged: null,
                        ),
                        const SizedBox(height: 8),

                        // Cantidad
                        TextFormField(
                          initialValue: item.quantity.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Cantidad',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            final qty = int.tryParse(val ?? '');
                            if (qty == null || qty < 1) {
                              return 'Cantidad inválida';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            final newQty = int.tryParse(val);
                            if (newQty != null) {
                              setState(() {
                                _items[index] = item.copyWith(quantity: newQty);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Precio
                        TextFormField(
                          initialValue: item.priceAtSale.toStringAsFixed(2),
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) {
                            final price = double.tryParse(val ?? '');
                            if (price == null || price < 0) {
                              return 'Precio inválido';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            final newPrice = double.tryParse(val);
                            if (newPrice != null) {
                              setState(() {
                                _items[index] = item.copyWith(
                                  priceAtSale: newPrice,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              ElevatedButton.icon(
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
                onPressed: () {
                  setState(() {
                    _items.add(
                      OrderItem(
                        id: '',
                        orderId: _order!.id,
                        plantId: _plants.first.id,
                        quantity: 1,
                        priceAtSale: 0.0,
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Producto'),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Total: \$${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ElevatedButton(
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary, // Cambia aquí el color de fondo
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
                      onPressed: _saveChanges,

                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
