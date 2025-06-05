import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vivero_lavega/features/sales/domain/entities/order_model.dart';
// import 'package:vivero_lavega/features/sales/domain/entities/order_item_model.dart';
import 'package:vivero_lavega/features/inventory/domain/entities/plant.dart';
import 'package:vivero_lavega/features/sales/data/repositories/order_item_service.dart';
import 'package:vivero_lavega/features/customers/domain/entities/customer.dart';
import 'package:vivero_lavega/features/customers/data/repositories/customer_service.dart';
import 'package:vivero_lavega/features/inventory/data/repositories/plant_service.dart';

// Instancias globales o inyectadas previamente
final service = OrderItemService();
final customersList = <Customer>[]; // O método para obtenerlos
final plantsList = <Plant>[]; // O método para obtenerlos
Future<void> generateAndSharePdfFromOrders({
  required List<Order> orders,
}) async {
  final pdf = pw.Document();

  final customers = await CustomerService().fetchCustomers();
  final plants = await PlantService().fetchPlants();

  final allWidgets = <pw.Widget>[]; // <- Aquí juntamos todo en una sola página

  for (final order in orders) {
    final items = await service.getOrderItems(order.id);

    final customer = customers.firstWhere(
      (c) => c.id == order.customerId,
      orElse:
          () => Customer(
            id: '',
            firstName: 'Desconocido',
            lastName: '',
            phone: '',
            address: '',
          ),
    );

    final headers = ['Producto', 'Cantidad', 'Precio', 'Total'];
    final data =
        items.map((item) {
          final plant = plants.firstWhere(
            (p) => p.id == item.plantId,
            orElse:
                () => Plant(id: '', name: 'Desconocida', price: 0.0, stock: 0),
          );
          return [
            plant.name,
            item.quantity.toString(),
            '\$${item.priceAtSale.toStringAsFixed(2)}',
            '\$${(item.quantity * item.priceAtSale).toStringAsFixed(2)}',
          ];
        }).toList();

    allWidgets.addAll([
      pw.Center(
        child: pw.Text(
          'Nota de Venta - Orden ${order.id}',
          style: pw.TextStyle(fontSize: 20),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Text('Cliente: ${customer.firstName} ${customer.lastName}'),
      pw.Text('Estado: ${order.status}'),
      pw.Text('Fecha: ${order.createdAt.toLocal().toString().split(' ')[0]}'),
      pw.SizedBox(height: 10),
      pw.Text('Productos:', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 8),
      if (data.isNotEmpty)
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
          },
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
          },
        )
      else
        pw.Text('No hay productos para esta orden.'),
      pw.Divider(),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'Total: \$${order.totalAmount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
    ]);
  }

  // Ahora sí: una sola página
  pdf.addPage(pw.Page(build: (context) => pw.Column(children: allWidgets)));

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/reporte_ventas_historial.pdf');
  await file.writeAsBytes(await pdf.save());

  await Share.shareXFiles([
    XFile(file.path),
  ], text: 'Reporte de ventas de varias órdenes');
}
