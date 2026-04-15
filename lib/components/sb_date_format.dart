import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';



class SbDateFormat extends StatefulWidget {

  String date;

  SbDateFormat({
    super.key,
    required this.date,
  });

  @override
  State<SbDateFormat> createState() => SbDateFormatState();
}

class SbDateFormatState extends State<SbDateFormat> {
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${getDayFromIsoString(widget.date)}',
                style: TextStyle(
                  color: mainColor,
                  fontSize: textHight,
                  fontWeight: FontWeight.w800
                ),
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              Icon(Icons.calendar_month, size: textHight, color: textColor,),

            ],
          ),

          Text(
            '${getShortMonth(widget.date)}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: textColor,
              fontSize: textMid,
              fontWeight: FontWeight.w400
            ),
          
          ),

          Text(
            '${getHour(widget.date)}',
            style: TextStyle(
              color: textColor,
              fontSize: textMid,
              fontWeight: FontWeight.w800
            ),
          ),
        ],
      ),
    );
  }
}