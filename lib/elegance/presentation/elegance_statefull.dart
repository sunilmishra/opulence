import 'package:aurora_demo/elegance/domain/elegance_model.dart';
import 'package:aurora_demo/elegance/domain/repository.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

/**
 * If we don't want to use any state management library,
 * we can use a simple StatefulWidget to manage the state.
 * I would not recommend this approach for complex applications.
 */

/// A stateful widget that displays elegance images with dynamic background colors.
class EleganceStatefull extends StatefulWidget {
  const EleganceStatefull({super.key, required this.repository});

  final EleganceRepository repository;

  @override
  State<EleganceStatefull> createState() => _EleganceStatefullState();
}

class _EleganceStatefullState extends State<EleganceStatefull> {
  bool loading = false;
  String? error;
  late EleganceEntity eleganceEntity;
  Color? bgColor;

  @override
  void initState() {
    super.initState();
    _fetchRandomImage();
  }

  Future<void> _fetchRandomImage() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      eleganceEntity = await widget.repository.getRandomImage();
      await _loadBgColor(eleganceEntity.url);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadBgColor(String imageUrl) async {
    final imageProvider = NetworkImage(imageUrl);
    final paletteGenerator = await PaletteGeneratorMaster.fromImageProvider(
      imageProvider,
    );
    bgColor = paletteGenerator.dominantColor?.color;
  }

  @override
  Widget build(BuildContext context) {
    /// Build the UI
    final textTheme = Theme.of(context).textTheme;
    final palleteColor = bgColor ?? Theme.of(context).scaffoldBackgroundColor;

    /// Determine text color based on background brightness
    /// to ensure readability
    final brightness = ThemeData.estimateBrightnessForColor(palleteColor);
    final isDark = brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade100 : Colors.grey.shade900;

    return Scaffold(
      backgroundColor: palleteColor,
      appBar: _Appbar(bgColor: palleteColor, textColor: textColor),
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        color: palleteColor,
        curve: Curves.easeIn, // <-- Easing for smooth transition
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A state of refined richness and elegance in life.',
                style: textTheme.titleMedium?.copyWith(color: textColor),
              ),
              const Spacer(),
              _Content(imageUrl: eleganceEntity.url),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async => await _fetchRandomImage(),
                  child: Text(
                    'Load Another Image',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// App bar widget with dynamic background and text colors.
class _Appbar extends StatelessWidget implements PreferredSizeWidget {
  const _Appbar({required this.bgColor, required this.textColor});

  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: bgColor,
      title: Text(
        'opulence',
        style: textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Content widget that displays the elegance image or loading/error states.
class _Content extends StatelessWidget {
  const _Content({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: double.infinity,
            height: 250,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const _ErrorView();
        },
      ),
    );
  }
}

/// Show an error view when image loading fails.
class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 120, color: Colors.red.shade900),
        const SizedBox(height: 8),
        Text(
          'Unable to load this image, try another one.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.red.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
