import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/order_model.dart';
import '../../domain/entities/order_item_model.dart';
import 'package:vivero_lavega/features/customers/domain/entities/customer.dart';
import 'package:vivero_lavega/features/inventory/domain/entities/plant.dart';


Future<void> generateAndSharePdf({
  required Order order,
  required List<OrderItem> items,
  required List<Customer> customers,
  required List<Plant> plants,
}) async {
  final pdf = pw.Document();

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

  // Construir datos para la tabla
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

  pdf.addPage(
    pw.Page(
      build:
          (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Nota de Venta',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),

              pw.SizedBox(height: 12),
              pw.Text('Cliente: ${customer.firstName} ${customer.lastName}'),
              pw.Text('Tipo: ${order.status}'),
              pw.Text(
                'Fecha: ${order.createdAt.toLocal().toString().split(' ')[0]}',
              ),
              pw.SizedBox(height: 12),
              pw.Text('Productos:', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
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
                  0: pw.Alignment.centerLeft, // Producto
                  1: pw.Alignment.center, // Cantidad
                  2: pw.Alignment.center, // Precio
                  3: pw.Alignment.center, // Total alineado a la izquierda
                },
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
    ),
  );

  // Guardar archivo temporal
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/pedido_${order.id}.pdf');
  await file.writeAsBytes(await pdf.save());

  // Compartir por WhatsApp u otra app
  await Share.shareXFiles([XFile(file.path)], text: 'Detalles del pedido');
}
