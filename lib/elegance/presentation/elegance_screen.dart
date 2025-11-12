import 'package:aurora_demo/di.dart';
import 'package:aurora_demo/elegance/domain/repository.dart';
import 'package:aurora_demo/elegance/presentation/elegance_controller.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

/// Screen widget that displays elegance images with dynamic background colors.
class EleganceScreen extends StatelessWidget with WatchItMixin {
  const EleganceScreen({super.key});

  /// Pushes a new scope of the controller for this screen.
  void _pushScope() {
    pushScope(
      init: (getIt) {
        final controller = EleganceController(
          repository: dependencyContext.getIt<EleganceRepository>(),
        );
        getIt.registerLazySingleton(() => controller..loadRandomImage());
      },
      dispose: () {
        dependencyContext.get<EleganceController>().dispose();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Initialize the scope for dependency injection
    _pushScope();

    /// initialize the controller
    final controller = watchIt<EleganceController>();

    /// Build the UI
    final textTheme = Theme.of(context).textTheme;
    final palleteColor = controller.bgColor ?? Colors.purple.shade50;

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
              Semantics(
                hint: 'Describes the concept of elegance',
                child: Text(
                  'A state of refined richness and elegance in life.',
                  style: textTheme.titleMedium?.copyWith(color: textColor),
                ),
              ),
              const Spacer(),
              _Content(controller: controller),
              const Spacer(),
              _LoadImageButton(controller: controller, textColor: textColor),
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
  const _Content({required this.controller});

  final EleganceController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (controller.error != null) {
      return const _ErrorView();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        controller.elegance.url,
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
          if (stackTrace != null) {
            controller.updateDefaultBgColor();
          }
          return const _ErrorView();
        },
      ),
    );
  }
}

class _LoadImageButton extends StatelessWidget {
  const _LoadImageButton({required this.controller, required this.textColor});

  final EleganceController controller;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Load Another Image',
      hint: 'Loads a new elegance image',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () async => await controller.loadRandomImage(),
          child: Text(
            'Load Another Image',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Show an error view when image loading fails.
class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error loading image',
      hint: 'Unable to load the image, please try another one',
      child: Column(
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
      ),
    );
  }
}
