import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/order_service.dart';
import '../../data/repositories/order_item_service.dart';
import 'package:vivero_lavega/features/customers/data/repositories/customer_service.dart';
import 'package:vivero_lavega/features/customers/domain/entities/customer.dart';
import 'package:vivero_lavega/features/inventory/domain/entities/plant.dart';
import 'package:vivero_lavega/features/inventory/data/repositories/plant_service.dart';

class CreateOrderWithItemsScreen extends StatefulWidget {
  const CreateOrderWithItemsScreen({super.key});

  @override
  State<CreateOrderWithItemsScreen> createState() =>
      _CreateOrderWithItemsScreenState();
}

class _CreateOrderWithItemsScreenState
    extends State<CreateOrderWithItemsScreen> {
  String? _selectedCustomerId;
  final List<_TempItem> _items = [];

  String? _selectedPlantId;
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  late final OrderService _orderService;
  late final OrderItemService _orderItemService;
  late final CustomerService _customerService;
  late final PlantService _plantService;
  String _selectedStatus = 'VENTA';

  bool _loading = false;
  List<Customer> _customers = [];
  List<Plant> _plants = [];

  double get _totalAmount {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity * item.priceAtSale,
    );
  }

  @override
  void initState() {
    super.initState();

    //final supabaseClient = Supabase.instance.client;

    _orderService = OrderService();
    _orderItemService = OrderItemService();
    _customerService = CustomerService();
    _plantService = PlantService();

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final customers = await _customerService.fetchCustomers();
      final plants = await _plantService.fetchPlants();
      if (!mounted) return;
      setState(() {
        _customers = customers;
        _plants = plants;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
    }
  }

  void _addItem() {
    final plantId = _selectedPlantId;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (plantId == null || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona planta, cantidad y precio válidos'),
        ),
      );
      return;
    }

    final plant = _plants.firstWhere((p) => p.id == plantId);

    setState(() {
      _items.add(
        _TempItem(
          plantId: plantId,
          plantName: plant.name,
          quantity: quantity,
          priceAtSale: price,
        ),
      );
      _selectedPlantId = null;
      _quantityController.clear();
      _priceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _saveOrder() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final order = await _orderService.createOrder(
        customerId: _selectedCustomerId,
        totalAmount: _totalAmount,
        status: _selectedStatus,
      );

      for (final item in _items) {
        await _orderItemService.createOrderItem(
          orderId: order.id,
          plantId: item.plantId,
          quantity: item.quantity,
          priceAtSale: item.priceAtSale,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true); // Regresa a la pantalla anterior con éxito
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Nuevo Pedido',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.background,
              decoration: const InputDecoration(
                labelText: 'Cliente (opcional)',
              ),
              value: _selectedCustomerId,
              items:
                  _customers
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.firstName} ${c.lastName}'),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedCustomerId = v),
              isExpanded: true,
              hint: const Text('Selecciona un cliente'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.background,
              decoration: const InputDecoration(labelText: 'Tipo'),
              value: _selectedStatus,
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

            const SizedBox(height: 16),
            const Text(
              'Agregar Productos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.background,
              decoration: const InputDecoration(labelText: 'Planta'),
              value: _selectedPlantId,
              items:
                  _plants
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedPlantId = v),
              isExpanded: true,
              hint: const Text('Selecciona una planta'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 10),
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
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: Text(
                'Agregar Producto',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            if (_items.isNotEmpty)
              Column(
                children:
                    _items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        color: AppColors.background,
                        child: ListTile(
                          title: Text('Planta: ${item.plantName}'),
                          subtitle: Text(
                            'Cantidad: ${item.quantity}, Precio: \$${item.priceAtSale.toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 20),
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.redAccent, // Cambia aquí el color de fondo
                  foregroundColor: Colors.white, // Color del texto o íconos
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
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
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
                onPressed: _loading ? null : _saveOrder,
                child:
                    _loading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Guardar '),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempItem {
  final String plantId;
  final String plantName;
  final int quantity;
  final double priceAtSale;

  _TempItem({
    required this.plantId,
    required this.plantName,
    required this.quantity,
    required this.priceAtSale,
  });
}
