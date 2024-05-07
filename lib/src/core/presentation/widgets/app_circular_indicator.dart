import 'package:flutter/material.dart';
import 'package:gre_vocabulary/src/core/extensions.dart';

class AppCircularIndicator extends StatelessWidget {
  final Size size;
  const AppCircularIndicator({
    Key? key,
    this.size = const Size(24, 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: CircularProgressIndicator(
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
