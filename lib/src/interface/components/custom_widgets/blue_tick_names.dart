import 'package:flutter/material.dart';

import '../../../data/services/hex_to_color.dart';

class VerifiedName extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;
  final Color? labelColor;
  final double? iconSize;
  final bool showBlueTick;

  final String? tickColor;

  const VerifiedName({
    super.key,
    required this.label,
    this.textStyle,
    this.labelColor,
    this.tickColor,
    this.iconSize = 16,
    this.showBlueTick = false,
  });

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
        if (tickColor != null && tickColor != '')
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.verified,
              color: hexToColor(tickColor ?? ''),
              size: iconSize,
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
