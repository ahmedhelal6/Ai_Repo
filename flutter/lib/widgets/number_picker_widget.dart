import 'package:flutter/material.dart';

class NumberPickerWidget extends StatefulWidget {
  const NumberPickerWidget({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
  });

  final int min;
  final int max;
  final int initialValue;
  final String unit;
  final Function(int) onChanged;

  @override
  State<NumberPickerWidget> createState() => _NumberPickerWidgetState();
}

class _NumberPickerWidgetState extends State<NumberPickerWidget> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            itemExtent: 60,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.2,

            onSelectedItemChanged: (index) {
              setState(() {
                selectedValue = widget.min + index;
              });

              widget.onChanged(selectedValue);
            },

            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.max - widget.min + 1,
              builder: (context, index) {
                final value = widget.min + index;

                return Center(
                  child: Text(
                    widget.unit.isEmpty
                        ? "$value"
                        : "$value ${widget.unit}",
                    style: TextStyle(
                      color: value == selectedValue
                          ? Colors.white
                          : Colors.white38,
                      fontSize: value == selectedValue ? 32 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          /// Highlight box
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 60),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}