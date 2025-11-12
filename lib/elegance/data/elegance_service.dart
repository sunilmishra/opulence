import 'dart:convert';

import 'package:aurora_demo/elegance/data/elagance_dto.dart';
import 'package:http/http.dart' as http;

/// Service responsible for fetching elegance images from a remote source.
class EleganceService {
  EleganceService({required this.client});

  final http.Client client;

  static const imageUrl =
      'https://november7-730026606190.europe-west1.run.app/image/';

  Future<EleganceDto> fetchRandomImage() async {
    final response = await client.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return EleganceDto.fromJson(json);
    } else {
      throw Exception('Failed to fetch image...');
    }
  }
}
