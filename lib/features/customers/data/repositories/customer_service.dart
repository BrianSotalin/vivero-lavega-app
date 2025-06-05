import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/customer.dart';

class CustomerService {
  Future<List<Customer>> fetchCustomers() async {
    final response =
        await Supabase.instance.client
            .schema('customers')
            .from('customers')
            .select();

    if (response is List) {
      return response.map((c) => Customer.fromMap(c)).toList();
    } else {
      throw Exception('Error al obtener los clientes');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    final Map<String, dynamic> updates = {
      'first_name': customer.firstName,
      'last_name': customer.lastName,
      'phone': customer.phone,
      'address': customer.address,
    };

    if (customer.email != null && customer.email!.isNotEmpty) {
      updates['email'] = customer.email;
    }
    final response =
        await Supabase.instance.client
            .schema('customers')
            .from('customers')
            .update({
              'first_name': customer.firstName,
              'last_name': customer.lastName,
              'email': customer.email,
              'phone': customer.phone,
              'address': customer.address,
            })
            .eq('id', customer.id)
            .select(); // Necesario para obtener respuesta completa

    if ( response.isEmpty) {
      throw Exception('Error al actualizar el cliente');
    }
  }

  Future<void> createCustomer(Customer customer) async {
    final response =
        await Supabase.instance.client
            .schema('customers')
            .from('customers')
            .insert({
              'first_name': customer.firstName,
              'last_name': customer.lastName,
              'email': customer.email,
              'phone': customer.phone,
              'address': customer.address,
            })
            .select();

    if ( response.isEmpty) {
      throw Exception('Error al crear el cliente');
    }
  }

  Future<void> deleteCustomer(String id) async {
    final response = await Supabase.instance.client
        .schema('customers')
        .from('customers')
        .delete()
        .eq('id', id);

    if (response != null) {
      throw Exception('Error al eliminar cliente: ${response.error!.message}');
    }
  }
}
