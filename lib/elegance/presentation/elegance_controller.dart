import 'package:aurora_demo/elegance/domain/elegance_model.dart';
import 'package:aurora_demo/elegance/domain/repository.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

/// Controller for managing elegance state and data.
class EleganceController extends ChangeNotifier {
  EleganceController({required this.repository});

  final EleganceRepository repository;

  bool _loading = false;
  bool get loading => _loading;

  late EleganceEntity _elegance;
  EleganceEntity get elegance => _elegance;

  Object? _error;
  Object? get error => _error;

  Color? _bgColor;
  Color? get bgColor => _bgColor;

  Future<void> loadRandomImage() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final eleganceEntity = await repository.getRandomImage();
      _elegance = eleganceEntity;

      /// Load background color based on image palette
      await _loadBgColor(_elegance.url);
    } catch (e) {
      _error = e;
      _bgColor = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Loads the dominant color from the image to use as background color.
  Future<void> _loadBgColor(String imageUrl) async {
    final imageProvider = NetworkImage(imageUrl);
    final paletteGenerator = await PaletteGeneratorMaster.fromImageProvider(
      imageProvider,
    );
    _bgColor = paletteGenerator.dominantColor?.color;
  }

  void updateDefaultBgColor() {
    _bgColor = null;
    notifyListeners();
  }
}
