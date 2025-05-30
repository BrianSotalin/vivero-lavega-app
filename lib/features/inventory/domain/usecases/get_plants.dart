import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class GetPlants {
  final PlantsRepository repository;

  GetPlants(this.repository);

  Future<List<Plant>> call() => repository.getPlants();
}
