import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbButtonSecondary extends StatefulWidget {

  String label;
  Function function;

  SbButtonSecondary(
    {
      super.key,
      required this.label,
      required this.function,
    }
  );

  @override
  State<SbButtonSecondary> createState() => _SbButtonSecondaryState();
}

class _SbButtonSecondaryState extends State<SbButtonSecondary> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF212938),
        elevation: 1,  // Ombra del pulsante
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Forma arrotondata
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0), // Rimuove spazio verticale
        minimumSize: Size(0, 20), // Imposta l’altezza minima a 40 (puoi abbassarla a piacere)
      ),
      onPressed: () {
        widget.function();
      },
      child: Text(
        widget.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: textLow, // Riduci la dimensione del font se necessario
        ),
      ),
    );
  }
}