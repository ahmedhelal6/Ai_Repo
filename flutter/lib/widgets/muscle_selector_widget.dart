import 'package:flutter/material.dart';

class MuscleSelector extends StatelessWidget {
  const MuscleSelector({
    super.key,
    required this.data,
    required this.selectedId,
    required this.getMuscleImage,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> data;
  final String? selectedId;
  final String Function(String name) getMuscleImage;
  final void Function(String id, String name) onSelect;

  String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final itemId = _safeString(item['id']);
          final itemName = _safeString(item['name'], fallback: 'Unknown');
          final itemImage = getMuscleImage(itemName);
          final isSelected = selectedId == itemId;

          return GestureDetector(
            onTap: () => onSelect(itemId, itemName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 114,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF4B3A) : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      itemImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF1A1A1A),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: .12),
                            Colors.black.withValues(alpha: .72),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 10,
                      child: Text(
                        itemName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}