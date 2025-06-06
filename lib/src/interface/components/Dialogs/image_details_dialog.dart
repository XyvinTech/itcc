import 'package:flutter/material.dart';
import 'package:itcc/src/data/models/user_model.dart';

class ImageDetailsDialog extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? description;

  const ImageDetailsDialog({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (description != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 25,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showImageDetails({
  required BuildContext context,
  required String imageUrl,
  required String title,
  String? subtitle,
  String? description,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ImageDetailsDialog(
        imageUrl: imageUrl,
        title: title,
        subtitle: subtitle,
        description: description,
      );
    },
  );
}
