import '../../domain/entities/plant.dart';
import '../../domain/repositories/plants_repository.dart';
import '../datasources/plants_remote_datasource.dart';

class PlantsRepositoryImpl implements PlantsRepository {
  final PlantsRemoteDataSource remoteDataSource;

  PlantsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Plant>> getPlants() async {
    final data = await remoteDataSource.fetchPlants();
    return data.map((e) => Plant.fromMap(e)).toList();
  }
}
