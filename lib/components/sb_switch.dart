import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbSwitch extends StatefulWidget {

  Function?        function;
  String           label;
  bool             value;
  SbSwitch({
    super.key,
    required this.label,
    required this.value,
    this.function,
  });

  @override
  State<SbSwitch> createState() => SbSwitchState();
}

class SbSwitchState extends State<SbSwitch> {


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          CupertinoSwitch(
            value: widget.value,
            onChanged: (bool value) {
              widget.value = value;
              widget.function!();
              print(widget.value);
              setState(() {
                
              });
            },
            activeTrackColor: mainColor, // colore quando è ON
            inactiveTrackColor: CupertinoColors.systemGrey,   // colore della traccia quando è OFF
          ),
          SizedBox(width: 20,),
          Text(
            '${widget.label}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: textMid
            ),
          ),
        ],
      ),
    );
  }
}