import 'package:flutter/material.dart';

import 'package:sballando/components/sb_date_format.dart';
import 'package:sballando/sb_global.dart';

class SbTicket extends StatefulWidget {
  Map ticket;

  SbTicket({
    super.key,
    required this.ticket
  });

  @override
  State<SbTicket> createState() => SbTicketState();
}

class SbTicketState extends State<SbTicket> {
  @override
  Widget build(BuildContext context) {
    
    return
    widget.ticket['event'] != null ? 
    GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/eventShow',arguments: {'eventId' : widget.ticket['event']['id']});
      },
      child: Container(
        margin: EdgeInsets.only(top: 10,right: 10,left: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColorTheme,
        ),
        child: Row(
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  "${widget.ticket['event'] != null && widget.ticket['event']['cover_img_url'] != null && widget.ticket['event']['cover_img_url'].isNotEmpty ? widget.ticket['event']['cover_img_url'] : widget.ticket['event']['cover'] != null ? BASE_URL + widget.ticket['event']['cover'] : ''}",
                  height: 67,
                  width: 67,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "$NOPHOTO",
                      width: 67,
                      height: 67,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.ticket['event'] != null ? widget.ticket['event']['title'] : ''}'.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: mainColor,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Text(
                    '${widget.ticket['event'] != null ? widget.ticket['event']['subtitle'] : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: textLowMid,
                      color: textColor,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  Wrap(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '', // prima parte
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle, // allinea l'icona con il testo
                              child: Icon(Icons.location_on, color: mainColor, size: 18),
                            ),
                            TextSpan(
                              text: '${widget.ticket['event']['location'] != null ? widget.ticket['event']['location']['name'] : ''},',
                              style: TextStyle(
                                color: textColor,
                                fontSize: textLowMid,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            TextSpan(
                              text: '${widget.ticket['event']['location'] != null ? widget.ticket['event']['location']['provincia'] : ''}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: textLowMid,
                                fontWeight: FontWeight.w300
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
      
            SbDateFormat(date: widget.ticket['event']['datetime_start']),
            
          ],
        ),
      ),
    )
    : Container();
  }
}