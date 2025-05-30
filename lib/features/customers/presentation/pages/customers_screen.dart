import 'package:flutter/material.dart';
import '../../domain/entities/customer.dart';
import '../../data/repositories/customer_service.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
// import '../modals/phone_actions_modal.dart';
// import '../modals/customer_detail.dart';
import '../modals/create_customer.dart';
import '../modals/dismissible_customer_tile.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomersScreen> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _customers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _customerService.fetchCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar clientes: $e')));
    }
  }

  List<Customer> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((customer) {
      final fullName =
          '${customer.firstName} ${customer.lastName}'.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'C L I E N T E S',
          style: TextStyle(color: AppColors.third),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary, size: 30),
            onPressed: () async {
              final created = await showDialog<bool>(
                context: context,
                builder: (_) => const CreateCustomerModal(),
              );

              if (created == true) {
                _loadCustomers(); // Recargar lista
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadCustomers,
                      child:
                          _customers.isEmpty
                              ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 300),
                                  Center(child: Text('No hay clientes.')),
                                ],
                              )
                              : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _filteredCustomers.length,
                                itemBuilder: (context, index) {
                                  final customer = _filteredCustomers[index];
                                  return buildDismissibleCustomerTile(
                                    context: context,
                                    customer: customer,
                                    index: index,
                                    customerList: _customers,
                                    onUpdated: () => setState(() {}),
                                  );
                                },
                              ),
                      // ? ListView(
                      //   physics: const AlwaysScrollableScrollPhysics(),
                      //   children: const [
                      //     SizedBox(height: 300),
                      //     Center(child: Text('No hay clientes.')),
                      //   ],
                      // )
                      // : ListView.builder(
                      //   physics: const AlwaysScrollableScrollPhysics(),
                      //   itemCount: _filteredCustomers.length,
                      //   itemBuilder: (context, index) {
                      //     final customer = _filteredCustomers[index];
                      //     return ListTile(
                      //       leading: const Icon(
                      //         Icons.person,
                      //         color: AppColors.primary,
                      //         size: 30,
                      //       ),
                      //       title: Text(
                      //         '${customer.firstName} ${customer.lastName}',
                      //       ),
                      //       subtitle: Column(
                      //         crossAxisAlignment:
                      //             CrossAxisAlignment.start,
                      //         children: [
                      //           // if (customer.email != null)
                      //           //   Text('Email: ${customer.email}'),
                      //           // if (customer.phone != null)
                      //           //   Text('Teléfono: ${customer.phone}'),
                      //           if (customer.address != null)
                      //             Text('${customer.address}'),
                      //         ],
                      //       ),
                      //       trailing:
                      //           customer.phone != null &&
                      //                   customer.phone!.isNotEmpty
                      //               ? IconButton(
                      //                 icon: const Icon(
                      //                   Icons.phone,
                      //                   color: AppColors.primary,
                      //                 ),
                      //                 onPressed:
                      //                     () => showPhoneActionsModal(
                      //                       context,
                      //                       customer.phone!,
                      //                     ),
                      //               )
                      //               : null,
                      //       onTap: () async {
                      //         final updated = await showDialog<bool>(
                      //           context: context,
                      //           builder:
                      //               (_) => CustomerDetailModal(
                      //                 customer: customer,
                      //               ),
                      //         );

                      //         if (updated == true) {
                      //           ScaffoldMessenger.of(
                      //             context,
                      //           ).showSnackBar(
                      //             SnackBar(
                      //               content: Text(
                      //                 'Editado exitosamente',
                      //               ),
                      //             ),
                      //           );
                      //           _loadCustomers(); // Recarga los datos si se actualizó
                      //         }
                      //       },
                      //     );
                      //   },
                      // ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.third),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 70),
                ],
              ),
    );
  }
}
