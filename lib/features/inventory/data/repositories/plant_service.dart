import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/plant.dart';

class PlantService {
  Future<List<Plant>> fetchPlants() async {
    final response =
        await Supabase.instance.client
            .schema('inventory')
            .from('plants')
            .select();

    if (response is List) {
      return response.map((c) => Plant.fromMap(c)).toList();
    } else {
      throw Exception('Error al obtener las plantas');
    }
  }
}
