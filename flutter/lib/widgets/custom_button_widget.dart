import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Widget navigateTo;
  final bool isEnabled;

  final double? horizontalPadding;
  final double? verticalPadding;

  const CustomButton({
    super.key,
    required this.text,
    required this.navigateTo,
    this.isEnabled = true,
    this.horizontalPadding,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 0,
        vertical: verticalPadding ?? 0,
      ),
      child: SizedBox(
        height: 65,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? Colors.white : const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: isEnabled
              ? () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (_, _, _) => navigateTo,
                      transitionsBuilder: (_, animation, _, child) {
                        const begin = Offset(1, 0);
                        const end = Offset.zero;
                        final tween = Tween(begin: begin, end: end);
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        );
                        return SlideTransition(
                          position: tween.animate(curved),
                          child: child,
                        );
                      },
                    ),
                  );
                }
              : null,
          child: Text(
            text,
            style: TextStyle(
              color: isEnabled ? Colors.black : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
