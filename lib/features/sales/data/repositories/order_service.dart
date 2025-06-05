import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_model.dart';

class OrderService {
  final _client = Supabase.instance.client;

  Future<Order> createOrder({
    String? customerId,
    required double totalAmount,
    required String status,
  }) async {
    final response =
        await _client
            .schema('sales')
            .from('orders')
            .insert({
              if (customerId != null && customerId.isNotEmpty)
                'customer_id': customerId,
              'total_amount': totalAmount,
              'status': status,
            })
            .select()
            .single();

    return Order.fromJson(response);
  }

  Future<String?> createOrderWithItems({
    required String customerId,
    required double totalAmount,
    required String status,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response =
          await _client
              .rpc(
                'create_order_with_items',
                params: {
                  'p_customer_id': customerId,
                  'p_total_amount': totalAmount,
                  'p_status': status,
                  'p_items': items,
                },
              )
              .select();

      if (response != null && response is List && response.isNotEmpty) {
        return response.first as String;
      } else {
        // print('No se recibió UUID del pedido.');
        return null;
      }
    } catch (e) {
      // print('Error al crear pedido con ítems: $e');
      return null;
    }
  }

  Future<List<Order>> getOrders() async {
    final response = await _client
        .schema('sales')
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    if (response is List) {
      return response.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las órdenes');
    }
  }

  // Future<void> updateOrder(Order order) async {
  //   final response = await _client
  //       .from('orders')
  //       .update({
  //         'customer_id': order.customerId,
  //         'order_date': order.orderDate.toIso8601String(),
  //         'total_amount': order.totalAmount,
  //         'status': order.status,
  //       })
  //       .eq('id', order.id);

  //   if (response != null) {
  //     throw Exception('Error al actualizar pedido: ${response}');
  //   }
  // }

  Future<void> deleteOrderAndItems(String orderId) async {
    try {
      final deleteOrderResponse = await _client
          .schema('sales')
          .from('orders')
          .delete()
          .eq('id', orderId);

      if (deleteOrderResponse.error != null) {
        throw Exception(
          'Error deleting order: ${deleteOrderResponse.error!.message}',
        );
      }
    } catch (e) {
      //print('Error in deleteOrderAndItems: $e');
      rethrow;
    }
  }

  /// Obtener un pedido por su ID
  Future<Order> getOrderById(String orderId) async {
    final response =
        await _client
            .schema('sales')
            .from('orders')
            .select()
            .eq('id', orderId)
            .single();

    return Order.fromJson(response);
  }

  /// Actualizar el pedido (en este ejemplo, solo actualizamos el estado)
  Future<void> updateOrder(Order order) async {
    await _client
        .schema('sales')
        .from('orders')
        .update({
          'customer_id': order.customerId,
          'status': order.status,
          'total_amount': order.totalAmount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', order.id);
  }
}
