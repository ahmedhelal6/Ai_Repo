import 'dart:ui';
import 'package:flutter/material.dart';

class BlurWidget extends StatelessWidget {
  const BlurWidget({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.color = const Color.fromRGBO(0, 0, 0, 0.3),
    this.sigmaX = 5,
    this.sigmaY = 5,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color color;
  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          padding: padding,
          color: color,
          child: child,
        ),
      ),
    );
  }
}