import 'package:flutter/material.dart';

/// Overlay widget displaying a loading indicator over its child.
/// 
/// Shows a centered circular progress indicator on top of the child
/// widget when [isLoading] is true. Useful for indicating async operations.
class LoadingOverlay extends StatelessWidget {
  /// Whether to show the loading indicator.
  final bool isLoading;
  
  /// The child widget to display beneath the loading indicator.
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
        child,
        if (isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
