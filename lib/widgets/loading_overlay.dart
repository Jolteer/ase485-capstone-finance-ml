import 'package:flutter/material.dart';

/// A semi-transparent overlay that blocks interaction and shows a
/// [CircularProgressIndicator] while [isLoading] is true.
///
/// Wrap any screen body with this widget:
/// ```dart
/// LoadingOverlay(
///   isLoading: provider.isLoading,
///   child: MyContent(),
/// )
/// ```
///
/// When [isLoading] is false, only the [child] is rendered. When true,
/// a dark-tinted container is stacked on top of the child to block
/// touches and display the spinner.
class LoadingOverlay extends StatelessWidget {
  /// Whether the overlay and spinner should be visible.
  final bool isLoading;

  /// The normal page content displayed underneath the overlay.
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main content is always rendered underneath.
        child,
        // Semi-transparent overlay + spinner, only shown when loading.
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
