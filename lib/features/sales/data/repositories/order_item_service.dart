import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_item_model.dart';

class OrderItemService {
  final _client = Supabase.instance.client;

  Future<OrderItem> createOrderItem({
    required String orderId,
    required String plantId,
    required int quantity,
    required double priceAtSale,
  }) async {
    final response =
        await _client
            .schema('sales')
            .from('order_items')
            .insert({
              'order_id': orderId,
              'plant_id': plantId,
              'quantity': quantity,
              'price_at_sale': priceAtSale,
            })
            .select()
            .single();

    return OrderItem.fromJson(response);
  }

  // Future<void> updateOrderItem(OrderItem item) async {
  //   final response = await _client
  //       .schema('sales')
  //       .from('order_items')
  //       .update({
  //         'plant_id': item.plantId,
  //         'quantity': item.quantity,
  //         'price_at_sale': item.priceAtSale,
  //       })
  //       .eq('id', item.id);

  //   if (response != null) {
  //     throw Exception('Error al actualizar item: ${response}');
  //   }
  // }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final response = await _client
        .schema('sales')
        .from('order_items')
        .select()
        .eq('order_id', orderId);

    if (response.isEmpty) {
      return [];
    }

    return (response as List).map((json) => OrderItem.fromJson(json)).toList();
  }

  /// Obtener todos los items de un pedido
  Future<List<OrderItem>> getItemsByOrderId(String orderId) async {
    final response = await _client
        .schema('sales')
        .from('order_items')
        .select()
        .eq('order_id', orderId);

    return (response as List).map((item) => OrderItem.fromJson(item)).toList();
  }

  /// Actualizar un item del pedido
  // Future<void> updateOrderItem(OrderItem item) async {
  //   // await _client
  //   //     .schema('sales')
  //   //     .from('order_items')
  //   //     .update({'quantity': item.quantity, 'price_at_sale': item.priceAtSale})
  //   //     .eq('id', item.id);

  // }

  Future<void> replaceOrderItems(String orderId, List<OrderItem> items) async {
    // 1. Borra todos los items asociados a ese pedido
    await _client
        .schema('sales')
        .from('order_items')
        .delete()
        .eq('order_id', orderId);

    // 2. Inserta los nuevos items (Postgres genera el UUID)
    for (var item in items) {
      await _client.schema('sales').from('order_items').insert({
        'order_id': orderId,
        'plant_id': item.plantId,
        'quantity': item.quantity,
        'price_at_sale': item.priceAtSale,
        // 'created_at' si lo manejas en DB, lo puedes omitir
      });
    }
  }
  Future<List<OrderItem>> getAllOrderItems() async {
  final response = await _client
      .schema('sales')
      .from('order_items')
      .select();

  if (response.isEmpty) {
    return [];
  }

  return (response as List)
      .map((json) => OrderItem.fromJson(json))
      .toList();
}

}
