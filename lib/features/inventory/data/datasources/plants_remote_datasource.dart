import 'package:supabase_flutter/supabase_flutter.dart';

// class PlantsRemoteDataSource {
//   final SupabaseClient client;
//   PlantsRemoteDataSource(this.client);
//   Future<List<Map<String, dynamic>>> fetchPlants() async {
//     final response = await client.from('plants').select();
//     if (response == null) throw Exception('Error fetching plants');
//     return List<Map<String, dynamic>>.from(response);
//   }
// }
class PlantsRemoteDataSource {
  final SupabaseClient client;
  PlantsRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> fetchPlants() async {
    try {
      final PostgrestList response = await client.from('plants').select();
      // If select() was successful, 'response' will be a PostgrestList (List<Map<String, dynamic>>)
      // It will be an empty list if no plants are found, but never null.
      return response;
    } on PostgrestException catch (e) {
      // Handle Supabase specific errors (e.g., network issues, invalid queries, permissions)
      throw Exception('Supabase Error fetching plants: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Unknown Error fetching plants: $e');
    }
  }
}
