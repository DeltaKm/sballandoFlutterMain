import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sballando/components/sb_date_format.dart';
import 'package:sballando/sb_global.dart';

class SbCardEvent extends StatefulWidget {
  Map event;

  SbCardEvent({
    super.key,
    required this.event,
  });

  @override
  State<SbCardEvent> createState() => SbCardEventState();
}

class SbCardEventState extends State<SbCardEvent> {
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
            margin: EdgeInsets.only(top: 20,bottom: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Colore ombra con opacità molto bassa
                  blurRadius: 10,  // Sfocatura dell'ombra
                  spreadRadius: 2, // Estensione dell'ombra
                  offset: Offset(0, 4), // Spostamento verticale dell'ombra
                ),
              ],
              border: !parseServerDateTime(widget.event['datetime_start']).isAfter(DateTime.now()) ? Border.all(width: 2,color: mainColor) : null,
              borderRadius: BorderRadius.circular(rounded30),
              color: backgroundColor
            ),
            width: width(context, 90),
            // height: 500,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(28),topRight: Radius.circular(28)),
                  child: Image.network(
                    "${widget.event['cover_image_url'] ?? BASE_URL + widget.event['cover']}",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.file(
                        File(''),
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                      );
                    },
                  ),
                ),
                Container(
                  // height: 150,
                  padding: EdgeInsets.only(top: 10,left: 20,right: 20,bottom: 30),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on, color: mainColor, size: 18),
                                    SizedBox(width: 4), // un po' di spazio tra icona e testo
                                    Expanded(
                                      child: Text(
                                        '${widget.event['location']['name']}, ${widget.event['location']['provincia']}',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                      SizedBox(height: 10,),
                      if(widget.event['music_genres'] != null && widget.event['music_genres'].isNotEmpty)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double availableWidth = constraints.maxWidth;
                          double usedWidth = 0;
                          List<Widget> visibleTags = [];
                          int hiddenCount = 0;
          
                          for (var genre in widget.event['music_genres']) {
                            final text = '♫ ${genre['label']}';
                            final textPainter = TextPainter(
                              text: TextSpan(
                                text: text,
                                style: TextStyle(fontSize: textLowMid, fontWeight: FontWeight.w600),
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout();
          
                            double tagWidth = textPainter.width + tagPadding * 2 + spacing;
          
                            if (usedWidth + tagWidth <= availableWidth - 60) {
                              // -50 spazio per '& altri'
                              usedWidth += tagWidth;
                              visibleTags.add(
                                Container(
                                  margin: EdgeInsets.only(right: spacing),
                                  padding: EdgeInsets.symmetric(horizontal: tagPadding, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: mainColor, // mainColor
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: textLowMid,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              hiddenCount++;
                            }
                          }
          
                          return Row(
                            children: [
                              ...visibleTags,
                              if (hiddenCount > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: Text(
                                    '& altri',
                                    style: TextStyle(
                                      color: Colors.blue, // mainColor
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                            ],
                          );
                          
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          if(!parseServerDateTime(widget.event['datetime_start']).isAfter(DateTime.now()) && parseServerDateTime(widget.event['datetime_end']).isAfter(DateTime.now()))
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(500)
              ),
              child: Text(
                'ON AIR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textMid,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          if(parseServerDateTime(widget.event['datetime_start']).isAfter(DateTime.now()) && parseServerDateTime(widget.event['datetime_start']).difference(DateTime.now()).inHours < 24) // CONTROLLA SE MANCANO ME DI 24 ORE E SE NON è GIA INIZIATO
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(500)
              ),
              child: Text(
                '${parseServerDateTime(widget.event['datetime_start']).difference(DateTime.now()).inHours.remainder(24).toString().padLeft(2, '0')}:${parseServerDateTime(widget.event['datetime_start']).difference(DateTime.now()).inMinutes.remainder(60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textMid,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

        ],
      ),
    );
  }
}