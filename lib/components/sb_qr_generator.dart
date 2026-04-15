import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SbQrGenerator extends StatefulWidget {
  String string;

  SbQrGenerator({
    super.key,
    required this.string,
  });

  @override
  State<SbQrGenerator> createState() => _SbQrGeneratorState();
}

class _SbQrGeneratorState extends State<SbQrGenerator> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: QrImageView(
          data: widget.string, // La tua stringa
          version: QrVersions.auto,
          size: 200.0,
        ),
      );
    
  }
}