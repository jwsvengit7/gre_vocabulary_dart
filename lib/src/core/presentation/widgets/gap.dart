import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double size;
  const Gap({this.size = 16, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
    );
  }
}
