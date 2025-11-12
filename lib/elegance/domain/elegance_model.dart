import 'package:aurora_demo/elegance/data/elagance_dto.dart';

/// Model representing an elegance entity.
class EleganceEntity {
  EleganceEntity({required this.url});

  final String url;
}

extension EleganceDtoX on EleganceDto {
  EleganceEntity toEntity() {
    return EleganceEntity(url: url);
  }
}
