import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
import 'package:vivero_lavega/features/sales/domain/entities/order_item_model.dart';
import 'package:vivero_lavega/features/sales/domain/entities/order_model.dart';
import 'package:vivero_lavega/features/inventory/domain/entities/plant.dart';

class PieChartByPlantScreen extends StatelessWidget {
  final List<OrderItem> orderItems;
  final List<Plant> plants;
  final List<Order> orders;

  const PieChartByPlantScreen({
    super.key,
    required this.orderItems,
    required this.plants,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final data = getChartData();
    final sections = data['sections'] as List<PieChartSectionData>;
    final legend = data['legend'] as List<_LegendItem>;
    // Calcular total de ventas
    final total = sections.fold<double>(0, (sum, s) => sum + s.value);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'VENTAS POR PLANTA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Wrap(
                spacing: 20,
                runSpacing: 12,
                children:
                    legend.map((item) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(item.label),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getChartData() {
    final Map<String, double> salesByPlant = {};

    final ventaOrderIds =
        orders
            .where((order) => order.status == 'VENTA')
            .map((order) => order.id)
            .toSet();

    for (var item in orderItems) {
      if (!ventaOrderIds.contains(item.orderId)) continue;
      salesByPlant.update(
        item.plantId,
        (value) => value + (item.priceAtSale * item.quantity),
        ifAbsent: () => item.priceAtSale * item.quantity,
      );
    }

    int index = 0;
    final List<PieChartSectionData> sections = [];
    final List<_LegendItem> legendItems = [];

    salesByPlant.forEach((plantId, total) {
      final color = Colors.primaries[index % Colors.primaries.length];
      final plantName =
          plants
              .firstWhere(
                (p) => p.id == plantId,
                orElse:
                    () => Plant(
                      id: plantId,
                      name: 'Desconocida',
                      price: 0,
                      stock: 0,
                    ),
              )
              .name;

      sections.add(
        PieChartSectionData(
          color: color,
          value: total,
          title: "\$${total.toStringAsFixed(0)}",
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legendItems.add(_LegendItem(color: color, label: plantName));
      index++;
    });

    return {'sections': sections, 'legend': legendItems};
  }
}

class _LegendItem {
  final Color color;
  final String label;
  _LegendItem({required this.color, required this.label});
}
