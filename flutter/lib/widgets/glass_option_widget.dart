
import 'package:flutter/material.dart';

class GlassOptionWidget extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const GlassOptionWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height * 0.4;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.red.withValues(alpha: .8) : Colors.white24,
            width: isSelected ? 3 : 1.5,
          ),
          color: Colors.white.withValues(alpha: .1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [          
              // Image
              Image.network(
                imagePath,
                height: cardHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                color: isSelected ? null : Colors.black.withValues(alpha: .5),
                colorBlendMode: BlendMode.darken,
              ),
              // Title Overlay
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
