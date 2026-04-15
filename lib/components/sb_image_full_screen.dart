import 'package:flutter/material.dart';

class ImageFullscreen extends StatelessWidget {
  final String imageUrl;
  const ImageFullscreen({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1,
              maxScale: 5,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}