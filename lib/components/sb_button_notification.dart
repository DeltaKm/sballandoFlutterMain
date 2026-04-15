
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SbButtoNotification extends StatefulWidget {

  String      label;
  Function    function;
  bool?       disable         = false;
  Color?      color;
  Color?      textColor;
  bool?       reverse;

  SbButtoNotification(
    {
      super.key,
      required this.label,
      required this.function,
      this.color,
      this.textColor,
      this.disable,
      this.reverse,
    }
  );

  @override
  State<SbButtoNotification> createState() => _SbButtoNotificationState();
}

class _SbButtoNotificationState extends State<SbButtoNotification> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(500), // Forma arrotondata
          side: BorderSide(
            color: Colors.green,
            width: 1
          )
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Rimuove spazio verticale
        minimumSize: Size(0, 20), // Imposta l’altezza minima a 40 (puoi abbassarla a piacere)
      ),
      onPressed: () {
        widget.function();
      },
      child: Icon(CupertinoIcons.check_mark,color: Colors.white,)
    );
  }
}