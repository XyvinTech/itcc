import 'package:flutter/material.dart';

class VerifiedName extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;
  final Color? labelColor;
  final double? iconSize;
  final bool showBlueTick;

  const VerifiedName({
    Key? key,
    required this.label,
    this.textStyle,
    this.labelColor,
    this.iconSize = 16,
    this.showBlueTick = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: textStyle?.copyWith(color: labelColor) ??
                TextStyle(color: labelColor ?? Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
        if (showBlueTick)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.verified,
              color: const Color.fromARGB(255, 67, 166, 247),
              size: iconSize,
            ),
          ),
      ],
    );
  }
}
