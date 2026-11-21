import 'package:flutter/material.dart';

/// A convenience widget that adds padding with a fixed height.
/// Equivalent to `SizedBox(height: height)`.
class Gap extends StatelessWidget {
  final double height;
  final double? width;

  const Gap(this.height, {super.key, this.width});

  const Gap.w(this.width, {super.key}) : height = 0;

  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: width);
}
