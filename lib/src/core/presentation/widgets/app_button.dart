import 'package:flutter/material.dart';
import 'package:gre_vocabulary/src/core/extensions.dart';
import 'package:gre_vocabulary/src/core/presentation/widgets/app_circular_indicator.dart';

class AppButton extends StatelessWidget {
  final double height;
  final String text;
  final bool isFullWidth;
  final VoidCallback? onPressed;
  final bool isLoading;
  const AppButton({
    Key? key,
    this.height = 42,
    required this.text,
    this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: isLoading
              ? const AppCircularIndicator()
              : Text(
                  text,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
