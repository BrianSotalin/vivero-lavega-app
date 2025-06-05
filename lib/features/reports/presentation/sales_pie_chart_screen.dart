import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vivero_lavega/features/sales/domain/entities/order_model.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
// import 'package:intl/intl.dart';
import 'pie_chart_by_plant_screen.dart';
import 'package:vivero_lavega/features/inventory/domain/entities/plant.dart';
import 'package:vivero_lavega/features/inventory/data/repositories/plant_service.dart';
import 'package:vivero_lavega/features/sales/domain/entities/order_item_model.dart';
import 'package:vivero_lavega/features/sales/data/repositories/order_item_service.dart';

class PieChartScreen extends StatelessWidget {
  final List<Order> orders;

  const PieChartScreen({super.key, required this.orders});

  String getNombreMes(int mes) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return meses[mes - 1];
  }

  Map<String, dynamic> getChartData() {
    final ventas = orders.where((o) => o.status == 'VENTA');
    final Map<String, double> salesByMonth = {};
    for (var order in ventas) {
      final monthKey =
          "${getNombreMes(order.orderDate.month)} ${order.orderDate.year}";

      salesByMonth.update(
        monthKey,
        (value) => value + order.totalAmount,
        ifAbsent: () => order.totalAmount,
      );
    }

    int index = 0;
    final List<PieChartSectionData> sections = [];
    final List<_LegendItem> legendItems = [];

    salesByMonth.forEach((monthKey, total) {
      final color = Colors.primaries[index % Colors.primaries.length];
      // final split = monthKey.split('-');
      // final monthName = DateFormat.MMM().format(
      //   DateTime(0, int.parse(split[0])),
      // );
      // final year = split[1];
      final label = monthKey; // Ej: "Junio 2025"

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

      legendItems.add(_LegendItem(color: color, label: label));

      index++;
    });

    return {'sections': sections, 'legend': legendItems};
  }

  @override
  Widget build(BuildContext context) {
    final chartData = getChartData();
    final sections = chartData['sections'] as List<PieChartSectionData>;
    final legendItems = chartData['legend'] as List<_LegendItem>;
    // Calcular total de ventas
    final total = sections.fold<double>(0, (sum, s) => sum + s.value);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'VENTAS POR MES',
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children:
                legendItems
                    .map(
                      (item) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(item.label),
                        ],
                      ),
                    )
                    .toList(),
          ),
          const Spacer(), // Empuja el botón hacia abajo

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                onPressed: () async {
                  // Aquí debes tener tus datos reales:
                  final List<OrderItem> orderItems =
                      await OrderItemService()
                          .getAllOrderItems(); // necesitas obtenerlos
                  final List<Plant> plants = await PlantService().fetchPlants();
                  // también necesitas obtenerlos

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => PieChartByPlantScreen(
                            orderItems: orderItems,
                            plants: plants,
                            orders: orders,
                          ),
                    ),
                  );
                },
                child: const Text('VENTAS POR PRODUCTO'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;

  _LegendItem({required this.color, required this.label});
}
