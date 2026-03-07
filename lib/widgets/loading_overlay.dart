/// Overlay that shows a semi-transparent barrier and [CircularProgressIndicator] over content when loading.
///
/// Wrap a screen or form with [LoadingOverlay] and set [isLoading] from provider state.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';

/// Displays a semi-transparent barrier with a spinner over [child] when [isLoading] is true.
class LoadingOverlay extends StatelessWidget {
  /// When true, overlay and spinner are shown; otherwise only [child] is visible.
  final bool isLoading;

  /// Content underneath; always built, obscured when [isLoading] is true.
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
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.loadingBarrier,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
