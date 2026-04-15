import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbButtonMaincolor extends StatefulWidget {

  String      label;
  Function    function;
  bool?       disable         = false;
  Color?      color;
  Color?      textColor;
  bool?       fullWidth       = false;

  SbButtonMaincolor(
    {
      super.key,
      required this.label,
      required this.function,
      this.color,
      this.textColor,
      this.disable,
      this.fullWidth,
    }
  );

  @override
  State<SbButtonMaincolor> createState() => _SbButtonMaincolorState();
}

class _SbButtonMaincolorState extends State<SbButtonMaincolor> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.fullWidth == true ? double.infinity : null,
      child: ElevatedButton(
        
        style: ElevatedButton.styleFrom(
          // primary: Colors.blue,  // Colore di sfondo del pulsante
          // onPrimary: Colors.white,  // Colore del testo quando il pulsante è attivo
          backgroundColor: widget.disable != true ? ( widget.color ?? mainColor) : grayLight,
          elevation: 1,  // Ombra del pulsante
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Forma arrotondata
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0), // Padding
          // side: BorderSide(color: Colors.blue, width: 2), // Bordo
        ),
        onPressed: () {
          widget.function();
        },
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.textColor ?? Colors.white,
            fontSize: textMidHight,
            fontWeight: FontWeight.w700
          ),
        ),
      ),
    );
  }
}


