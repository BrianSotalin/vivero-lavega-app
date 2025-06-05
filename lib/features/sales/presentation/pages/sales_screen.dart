import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
//import '../modals/create_order_with_items_modal.dart';
import '../../domain/entities/order_model.dart';
import '../../data/repositories/order_service.dart';
import '../pages/create_order_screen.dart';
import '../pages/edit_order_screen.dart';
import 'package:vivero_lavega/shared/widgets/month_filter_dropdown.dart';
import 'package:vivero_lavega/features/reports/presentation/sales_pie_chart_screen.dart';
import 'package:vivero_lavega/shared/widgets/qr_modal.dart';
import 'package:vivero_lavega/features/reports/presentation/pdf_sales_report.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final OrderService _orderService = OrderService();

  final List<String> _statusFilters = ['TODAS', 'VENTA', 'PROFORMA'];
  String _selectedStatus = 'TODAS';

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    final orders = await _orderService.getOrders();
    setState(() {
      _allOrders = orders;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Order> temp = _allOrders;

    // Filtro por estado
    if (_selectedStatus != 'TODAS') {
      temp =
          temp
              .where(
                (o) =>
                    o.status.trim().toUpperCase() ==
                    _selectedStatus.toUpperCase(),
              )
              .toList();
    }

    // Filtro por rango de fecha si está aplicado
    if (_filterStartDate != null && _filterEndDate != null) {
      temp =
          temp.where((o) {
            final created = o.orderDate.toLocal();
            return created.isAfter(
                  _filterStartDate!.subtract(const Duration(seconds: 1)),
                ) &&
                created.isBefore(
                  _filterEndDate!.add(const Duration(seconds: 1)),
                );
          }).toList();
    }

    _filteredOrders = temp;
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  void _onDateRangeSelected(DateTime? start, DateTime? end) {
    setState(() {
      _filterStartDate = start;
      _filterEndDate = end;
      _applyFilters();
    });
  }

  Future<void> _refreshOrders() async {
    final orders = await _orderService.getOrders();
    setState(() {
      _allOrders = orders;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'V E N T A S',
          style: TextStyle(color: AppColors.third),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,

        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.third,
            ), // Cambia el ícono si prefieres otro

            onSelected: (value) async {
              if (value == 'pdf') {
                await generateAndSharePdfFromOrders(orders: _allOrders);
              } else if (value == 'qr') {
                showQrDialog(context);
              } else if (value == 'create') {
                // final result = await showDialog(
                //   context: context,
                //   builder: (_) => const CreateOrderWithItemsModal(),
                // );
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateOrderWithItemsScreen(),
                  ),
                );

                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Venta creado exitosamente')),
                  );

                  _refreshOrders();
                }
              } else if (value == 'graphics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PieChartScreen(orders: _allOrders),
                  ),
                );
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
                  const PopupMenuItem(
                    value: 'create',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Nueva Venta'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'graphics',
                    child: Row(
                      children: [
                        Icon(Icons.pie_chart, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Estadisticas'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          _allOrders.isEmpty
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                ),
              )
              : RefreshIndicator(
                onRefresh: _refreshOrders,
                color: Colors.teal,
                child: Column(
                  children: [
                    // Filtros estado
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children:
                            _statusFilters.map((status) {
                              final isSelected = _selectedStatus == status;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: ChoiceChip(
                                  label: Text(status),
                                  selected: isSelected,
                                  onSelected: (_) => _onStatusChanged(status),
                                  selectedColor: AppColors.third,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.third,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    // Dropdown de meses
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: MonthFilterDropdown(
                          onDateRangeSelected: _onDateRangeSelected,
                        ),
                      ),
                    ),

                    // Lista de pedidos filtrados
                    // Expanded(
                    //   child:
                    //       _filteredOrders.isEmpty
                    //           ? const Center(
                    //             child: Text('No hay pedidos registrados'),
                    //           )
                    //           : ListView.builder(
                    //             itemCount: _filteredOrders.length,
                    //             itemBuilder: (context, index) {
                    //               final order = _filteredOrders[index];
                    //               return ListTile(
                    //                 leading: const Icon(
                    //                   Icons.shopping_cart,
                    //                   color: AppColors.primary,
                    //                 ),
                    //                 title: Text(
                    //                   '${order.status}# ${order.orderDate.toLocal().toString().split(' ')[0]}$index',
                    //                 ),
                    //                 subtitle: Text(
                    //                   'Fecha: ${order.orderDate.toLocal().toString().split(' ')[0]}',
                    //                 ),
                    //                 trailing: Text(
                    //                   '\$${order.totalAmount.toStringAsFixed(2)}',
                    //                   style: TextStyle(
                    //                     color: AppColors.third,
                    //                     fontSize: 16,
                    //                   ),
                    //                 ),
                    //                 onTap: () async {
                    //                   // Navegar a la pantalla de edición y esperar el resultado
                    //                   final result = await Navigator.push<bool>(
                    //                     context,
                    //                     MaterialPageRoute(
                    //                       builder:
                    //                           (_) => EditOrderScreen(
                    //                             orderId: order.id,
                    //                           ),
                    //                     ),
                    //                   );

                    //                   if (result == true) {
                    //                     // Aquí puedes refrescar la lista si el pedido fue actualizado
                    //                     // por ejemplo, llamar a setState o recargar datos
                    //                     setState(() {
                    //                       // Código para refrescar la lista
                    //                     });
                    //                   }
                    //                 },
                    //               );
                    //             },
                    //           ),
                    // ),
                    Expanded(
                      child:
                          _filteredOrders.isEmpty
                              ? const Center(
                                child: Text(
                                  'No hay ventas con los filtros especificos',
                                ),
                              )
                              : ListView.builder(
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];

                                  return Dismissible(
                                    key: Key(order.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Center(
                                                child: const Text(
                                                  'Eliminar Venta',
                                                ),
                                              ),
                                              content: Text(
                                                '¿Estás seguro de eliminar \n${order.status}# ${order.orderDate.toLocal().toString().split(' ')[0]}$index?',
                                              ),
                                              actions: [
                                                Center(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .textPrimary, // Cambia aquí el color de fondo
                                                            foregroundColor:
                                                                Colors
                                                                    .white, // Color del texto o íconos
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      24,
                                                                  vertical: 12,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    30,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent, // Cambia aquí el color de fondo
                                                            foregroundColor:
                                                                Colors
                                                                    .white, // Color del texto o íconos
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      24,
                                                                  vertical: 12,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    30,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                          child: const Text(
                                                            'Eliminar',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      return confirm ?? false;
                                    },
                                    onDismissed: (direction) async {
                                      try {
                                        await _orderService.deleteOrderAndItems(
                                          order.id,
                                        );

                                        setState(() {
                                          _filteredOrders.removeAt(index);
                                          _allOrders.removeWhere(
                                            (o) => o.id == order.id,
                                          );
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Venta eliminada exitosamente',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        debugPrint('$e');
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Venta eliminada exitosamente',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.shopping_cart,
                                        color: AppColors.primary,
                                      ),
                                      title: Text(
                                        '${order.status}# ${order.orderDate.toLocal().toString().split(' ')[0]}$index',
                                      ),
                                      subtitle: Text(
                                        'Fecha: ${order.orderDate.toLocal().toString().split(' ')[0]}',
                                      ),
                                      trailing: Text(
                                        '\$${order.totalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.third,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () async {
                                        final result =
                                            await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => EditOrderScreen(
                                                      orderId: order.id,
                                                    ),
                                              ),
                                            );

                                        if (result == true) {
                                          _refreshOrders();
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
