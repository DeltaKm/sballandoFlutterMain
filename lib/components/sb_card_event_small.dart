import 'package:flutter/material.dart';
import 'package:sballando/components/sb_date_format.dart';
import 'package:sballando/sb_global.dart';

class SbCardEventSmall extends StatefulWidget {
  Map event;

  SbCardEventSmall({
    super.key,
    required this.event,
  });

  @override
  State<SbCardEventSmall> createState() => SbCardEventSmallState();
}

class SbCardEventSmallState extends State<SbCardEventSmall> {
  final double      tagPadding        = 10;
  final double      spacing           = 5;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
    });

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        int eventId = widget.event['id'];
        Navigator.pushNamed(
          context,
          '/eventShow',
          arguments: {
            'eventId': eventId
          },
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Colore ombra con opacità molto bassa
                  blurRadius: 10,  // Sfocatura dell'ombra
                  spreadRadius: 2, // Estensione dell'ombra
                  offset: Offset(0, 4), // Spostamento verticale dell'ombra
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              color: backgroundColor
            ),
            width: width(context, 90),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.event['title']}'.toUpperCase(),
                                  style: TextStyle(
                                    color: mainColor,
                                    fontSize: textMidHight,
                                    fontWeight: FontWeight.w700
                                  ),
                                  textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${widget.event['subtitle']}',
                                  textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Wrap(
                                  
                                  children: [
                                    Icon(Icons.location_on, color: mainColor, size: 18,),
                                    Text(
                                      '${widget.event['location']['name']}, ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    Text(
                                      '${widget.event['location']['provincia']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300
                                      ),
                                    ),
                                  ],
                                )
                                
                              ],
                            )
                          ),
                          SizedBox(width: 10,),
                          SbDateFormat(date: widget.event['datetime_start'],),
                          ////////////////
                          /// DATA
                          ///////////////
                        ],
                      ),
                      
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}