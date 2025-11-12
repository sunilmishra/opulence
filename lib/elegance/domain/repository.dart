import 'elegance_model.dart';

/// Repository interface for elegance data operations.
abstract interface class EleganceRepository {
  Future<EleganceEntity> getRandomImage();
}
