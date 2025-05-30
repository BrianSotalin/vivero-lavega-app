import '../entities/plant.dart';

abstract class PlantsRepository {
  Future<List<Plant>> getPlants();
}

