import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import '../../domain/entities/plant.dart';
//import '../../domain/usecases/get_plants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modals/plant_detail.dart';
import '../modals/create_plant.dart';

class InventoryScreen extends StatefulWidget {
  final Future<List<Plant>> Function()? getPlants;

  const InventoryScreen({super.key, this.getPlants});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late TextEditingController _searchController;
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = true;
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadPlants();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPlants = _applyFilters(_allPlants);
    });
  }

  List<Plant> _applyFilters(List<Plant> plants) {
    final query = _searchController.text.toLowerCase();

    return plants.where((plant) {
      final matchesName = plant.name.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null ||
          plant.category?.toLowerCase() == _selectedCategory!.toLowerCase();

      return matchesName && matchesCategory;
    }).toList();
  }

  void _loadPlants() async {
    final fetchPlants =
        widget.getPlants ??
        () async {
          final response =
              await Supabase.instance.client
                  .schema('inventory')
                  .from('plants')
                  .select();

          return (response as List).map((p) => Plant.fromMap(p)).toList();
        };

    final categoryResponse = await Supabase.instance.client
        .schema('inventory')
        .from('categories')
        .select('name');

    final categoryList =
        (categoryResponse as List).map((c) => c['name'].toString()).toList();

    final plants = await fetchPlants();

    setState(() {
      _categories = categoryList;
      _allPlants = plants;
      _filteredPlants = _applyFilters(plants);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'I N V E N T A R I O',
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
                builder: (_) => const CreatePlantModal(),
              );

              if (created == true) {
                _loadPlants(); // Vuelve a cargar la lista
                if (mounted) setState(() {});
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1, // +1 para "Todas"
                        itemBuilder: (context, index) {
                          final category =
                              index == 0 ? null : _categories[index - 1];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ChoiceChip(
                              label: Text(category ?? 'Todas'),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                  _filteredPlants = _applyFilters(_allPlants);
                                });
                              },
                              selectedColor: AppColors.third,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : AppColors.third,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        _loadPlants();
                      },
                      child:
                          _filteredPlants.isEmpty
                              ? const Center(
                                child: Text('No se encontraron resultados'),
                              )
                              : ListView.builder(
                                itemCount: _filteredPlants.length,
                                itemBuilder: (context, index) {
                                  final plant = _filteredPlants[index];
                                  return Dismissible(
                                    key: Key(
                                      plant.id.toString(),
                                    ), // Usa un identificador único
                                    direction:
                                        DismissDirection
                                            .endToStart, // Solo izquierda
                                    background: Container(
                                      color: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      alignment: Alignment.centerRight,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      // Confirmar con el usuario antes de eliminar
                                      return await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Center(
                                                child: const Text(
                                                  'Eliminar Planta',
                                                ),
                                              ),
                                              content: Text(
                                                '¿Estás seguro de eliminar "${plant.name}"?',
                                              ),
                                              actions: [
                                                Center(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors
                                                                  .textPrimary, // Cambia aquí el color de fondo
                                                          foregroundColor:
                                                              Colors
                                                                  .white, // Color del texto o íconos
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 24,
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
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(false),
                                                        child: const Text(
                                                          'Cancelar',
                                                        ),
                                                      ),
                                                      SizedBox(width: 20),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .redAccent, // Cambia aquí el color de fondo
                                                          foregroundColor:
                                                              Colors
                                                                  .white, // Color del texto o íconos
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 24,
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
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(true),
                                                        child: const Text(
                                                          'Eliminar',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    },

                                    onDismissed: (direction) async {
                                      // Supongamos que esto está en un método async, y ya hiciste un await antes
                                      if (!mounted) return;

                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      try {
                                        // 1. Eliminar de Supabase
                                        final response = await Supabase
                                            .instance
                                            .client
                                            .schema('inventory')
                                            .from('plants')
                                            .delete()
                                            .eq('id', plant.id);

                                        // 2. Eliminar del estado local
                                        setState(() {
                                          _allPlants.removeWhere(
                                            (p) => p.id == plant.id,
                                          );
                                          _filteredPlants = _applyFilters(
                                            _allPlants,
                                          );
                                        });

                                        if (response == null) {
                                          // 3. Mostrar mensaje de éxito
                                          // ScaffoldMessenger.of(
                                          //   context,
                                          // ).showSnackBar(
                                          //   SnackBar(
                                          //     content: Text(
                                          //       '${plant.name} eliminada exitosamente',
                                          //     ),
                                          //   ),
                                          // );
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${plant.name} eliminada exitosamente',
                                              ),
                                            ),
                                          );
                                        } else {
                                          // ScaffoldMessenger.of(
                                          //   context,
                                          // ).showSnackBar(
                                          //   SnackBar(
                                          //     content: Text(
                                          //       'Error al guardar el registro',
                                          //     ),
                                          //   ),
                                          // );
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error al guardar el registro',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        // 4. Mostrar error si algo falla
                                        // ScaffoldMessenger.of(
                                        //   context,
                                        // ).showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //       'Error al eliminar: $e',
                                        //     ),
                                        //   ),
                                        // );
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error al eliminar: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },

                                    child: ListTile(
                                      leading:
                                          plant.imageUrl != null
                                              ? Image.network(
                                                plant.imageUrl!,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              )
                                              : Image.asset(
                                                'assets/images/plant-img.png',
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                      title: Text(plant.name),
                                      subtitle: Text(
                                        plant.scientificName ?? '',
                                      ),
                                      trailing: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Stock: ${plant.stock}',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '\$${plant.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: AppColors.third,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        final updated = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (_) => PlantDetailModal(
                                                plant: plant,
                                              ),
                                        );
                                        if (updated == true) {
                                          _loadPlants();
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar planta...',
                        prefixIcon: const Icon(Icons.search),

                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.third),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 70),
                ],
              ),
    );
  }
}
