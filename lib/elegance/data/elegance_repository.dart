import 'package:aurora_demo/elegance/data/elegance_service.dart';
import 'package:aurora_demo/elegance/domain/elegance_model.dart';
import 'package:aurora_demo/elegance/domain/repository.dart';

/// Implementation of EleganceRepository that fetches data from EleganceService.
class EleganceRepositoryImpl implements EleganceRepository {
  EleganceRepositoryImpl({required this.service});

  final EleganceService service;

  @override
  Future<EleganceEntity> getRandomImage() async {
    final dto = await service.fetchRandomImage();
    return dto.toEntity();
  }
}
