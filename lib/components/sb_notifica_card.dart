import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_button_notification.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbNotificaCard extends StatefulWidget {
  Map           notification;
  Function      refresh;

  SbNotificaCard({
    super.key,
    required this.notification,
    required this.refresh,
  });

  @override
  State<SbNotificaCard> createState() => SbNotificaCardState();
}

class SbNotificaCardState extends State<SbNotificaCard> {
  @override
  Widget build(BuildContext context) {
     return  GestureDetector(
         onTap: (){
           Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
         },
         child: Container(
           margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
           width: width(context, 100),
      
           child: Stack(
             clipBehavior: Clip.none, // Importante per far "uscire" il widget dai limiti
             children: [
               Column(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Stack(
                         clipBehavior: Clip.none, // 👈 questo è fondamentale
                         children: [
                           Container(
                             decoration: BoxDecoration(
                               border: Border.all(
                                 width: 1,
                                 color: mainColor,
                               ),
                               borderRadius: BorderRadius.circular(10),
                             ),
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(9),
                               child: widget.notification['sender'] != null &&
                                       widget.notification['sender']['picture'] != null &&
                                       widget.notification['sender']['picture'].toString().isNotEmpty
                                   ? Image.network(
                                       BASE_URL + widget.notification['sender']['picture'],
                                       height: 50,
                                       width: 50,
                                       fit: BoxFit.cover,
                                       errorBuilder: (context, error, stackTrace) {
                                         return Image.asset(
                                           NOPHOTO,
                                           width: 50,
                                           height: 50,
                                           fit: BoxFit.cover,
                                         );
                                       },
                                     )
                                   : Image.asset(
                                       NOPHOTO,
                                       width: 50,
                                       height: 50,
                                       fit: BoxFit.cover,
                                     ),
                             ),
                           ),
                           if(widget.notification['event'] != null && widget.notification['event']['cover'] != null && widget.notification['event']['cover'].toString().isNotEmpty)
                           Positioned(
                             bottom: -10, // 👈 ora funzionerà
                             right: -10,  // puoi usare right invece di left per metterla in basso a destra
                             child: Container(
                               decoration: BoxDecoration(
                                 border: Border.all(
                                   width: 1,
                                   color: mainColor,
                                 ),
                                 borderRadius: BorderRadius.circular(5000),
                               ),
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(9),
                                 child: widget.notification['event'] != null &&
                                         widget.notification['event']['cover'] != null &&
                                         widget.notification['event']['cover'].toString().isNotEmpty
                                     ? Image.network(
                                         BASE_URL + widget.notification['event']['cover'],
                                         height: 20,
                                         width: 20,
                                         fit: BoxFit.cover,
                                         errorBuilder: (context, error, stackTrace) {
                                           return Image.asset(
                                             NOPHOTO,
                                             width: 20,
                                             height: 20,
                                             fit: BoxFit.cover,
                                           );
                                         },
                                       )
                                     : Image.asset(
                                         NOPHOTO,
                                         width: 20,
                                         height: 20,
                                         fit: BoxFit.cover,
                                       ),
                               ),
                             ),
                           ),
                         ],
                       ),
              
                       SizedBox(width: 10,),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             RichText(
                               text: TextSpan(
                                 text: '${widget.notification['title']}',
                                 style: TextStyle(
                                   color: textColor,
                                   fontWeight: FontWeight.w700
                                 ),
                                 children: <TextSpan>[
                                   TextSpan(text: ' ', style: TextStyle(fontWeight: FontWeight.w700)),
                                   TextSpan(text: ' ${widget.notification['message']}', style: TextStyle(fontWeight: FontWeight.w400)),
                                 ],
                               ),
                             ),
                             Text(
                               'Inviato da: ${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
                               style: TextStyle(
                                 color: textColor,
                                 fontWeight: FontWeight.w700
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
              
                 ],
               ),
               Positioned(
                 top: -20,
                 right: 0,
                 child: Text(
                   '${extractTime(widget.notification['created_at'])}',
                   style: TextStyle(
                     color: textColor
                   ),
                 )
               ),
             ],
           ),
         ),
       );
  //   if(widget.notification['type'] == 'offer_product'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none, // Importante per far "uscire" il widget dai limiti
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${ widget.notification['sender']['name'] ?? '' } ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ti ha inviato', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['message']}'),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'following'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(9),
  //                     child: widget.notification['sender'] != null &&
  //                            widget.notification['sender']['picture'] != null &&
  //                            widget.notification['sender']['picture'].toString().isNotEmpty
  //                         ? Image.network(
  //                             BASE_URL + widget.notification['sender']['picture'],
  //                             height: 50,
  //                             width: 50,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               );
  //                             },
  //                           )
  //                         : Image.asset(
  //                             NOPHOTO,
  //                             width: 50,
  //                             height: 50,
  //                             fit: BoxFit.cover,
  //                           ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ha iniziato a seguirti corri a scoprire il suo profilo!', style: TextStyle(fontWeight: FontWeight.w400)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'transfer_invite'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none, // Importante per far "uscire" il widget dai limiti
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ti ha inviato degli ingressi: ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: '${widget.notification['stock']} x ${widget.notification['entry_type'] != null ? widget.notification['entry_type']['label'] : ''}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'event_notification'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none, // Importante per far "uscire" il widget dai limiti
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(9),
  //                     child: widget.notification['event'] != null &&
  //                       widget.notification['event']['cover'] != null &&
  //                       widget.notification['event']['cover'].toString().isNotEmpty
  //                     ? Image.network(
  //                         BASE_URL + widget.notification['event']['cover'],
  //                         height: 50,
  //                         width: 50,
  //                         fit: BoxFit.cover,
  //                         errorBuilder: (context, error, stackTrace) {
  //                           return Image.asset(
  //                             NOPHOTO,
  //                             width: 50,
  //                             height: 50,
  //                             fit: BoxFit.cover,
  //                           );
  //                         },
  //                       )
  //                     : Image.asset(
  //                         NOPHOTO,
  //                         width: 50,
  //                         height: 50,
  //                         fit: BoxFit.cover,
  //                       ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ${widget.notification['title']} ${widget.notification['message']} ', style: TextStyle(fontWeight: FontWeight.w700)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'transfer_product'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none, // Importante per far "uscire" il widget dai limiti
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ti ha inviato dei prodotti: ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['product'] != null && widget.notification['product']['stock'] != null ? widget.notification['product']['stock'] : 1} x ${widget.notification['product'] != null ? widget.notification['product']['label'] : ''}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'invitation_accepted'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none, // Importante per far "uscire" il widget dai limiti
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ha accettato la tua richiesta di partecipazione all\'evento: ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['event']['title']}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'invite_refused'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ha rifiutato la tua richiesta di partecipaione all\'evento: ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['event']['title']}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'payment_request'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         width: width(context, 100),
  //         padding: EdgeInsets.all(10),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             Stack(
  //               clipBehavior: Clip.none,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                           width: 1,
  //                           color: mainColor,
  //                         ),
  //                       borderRadius: BorderRadius.circular(10)
  //                       ),
  //                       child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(9),
  //                     child: widget.notification['event'] != null &&
  //                            widget.notification['event']['cover'] != null &&
  //                            widget.notification['event']['cover'].toString().isNotEmpty
  //                         ? Image.network(
  //                             BASE_URL + widget.notification['event']['cover'],
  //                             height: 50,
  //                             width: 50,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               );
  //                             },
  //                           )
  //                         : Image.asset(
  //                             NOPHOTO,
  //                             width: 50,
  //                             height: 50,
  //                             fit: BoxFit.cover,
  //                           ),
  //                   ),
  //                     ),
  //                     SizedBox(width: 10,),
  //                     Expanded(
  //                       child: RichText(
  //                         text: TextSpan(
  //                           text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                           style: TextStyle(
  //                             color: textColor,
  //                             fontWeight: FontWeight.w700
  //                           ),
  //                           children: <TextSpan>[
  //                             TextSpan(text: ' ha accettato la tua richiesta, effettua il pagamento per ottenere il biglietto per l\'evento :', style: TextStyle(fontWeight: FontWeight.w400)),
  //                             TextSpan(text: ' ${widget.notification['event']['title']}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Positioned(
  //                   bottom: -10,
  //                   left: 40,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       border: Border.all(
  //                         width: 1,
  //                         color: mainColor,
  //                       ),
  //                     borderRadius: BorderRadius.circular(10)
  //                     ),
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: -20,
  //                   right: 0,
  //                   child: Text(
  //                     '${extractTime(widget.notification['created_at'])}',
  //                     style: TextStyle(
  //                       color: textColor
  //                     ),
  //                   )
  //                 ),
  //               ],
  //             ),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: mainColor,
  //                 shadowColor: Colors.white,
  //                 elevation: 0,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(500), // Forma arrotondata
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Rimuove spazio verticale
  //                 minimumSize: Size(0, 20), // Imposta l’altezza minima a 40 (puoi abbassarla a piacere)
  //               ),
  //               child: Text(
  //                 'Paga',
  //                 style: TextStyle(
  //                   color: Colors.white
  //                 ),
  //               ),
  //               onPressed: () async{
  //                 Navigator.pushNamed(context,'/checkout',arguments: {'entry_type' : widget.notification['entry_type']});
  //               }
  //             ),

  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'entry_invite_seat'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         padding: EdgeInsets.symmetric(horizontal: 10),
  //         width: width(context, 100),
  //         child: Column(
  //           children: [
  //             Stack(
  //               clipBehavior: Clip.none,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                           width: 1,
  //                           color: mainColor,
  //                         ),
  //                       borderRadius: BorderRadius.circular(10)
  //                       ),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 10,),
  //                     Expanded(
  //                       child: RichText(
  //                         text: TextSpan(
  //                           text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                           style: TextStyle(
  //                             color: textColor,
  //                             fontWeight: FontWeight.w700
  //                           ),
  //                           children: <TextSpan>[
  //                             TextSpan(text: ' ti ha invitato a partecipare al suo ingresso :', style: TextStyle(fontWeight: FontWeight.w400)),
  //                             TextSpan(text: ' ${widget.notification['entry_type'] != null ? widget.notification['entry_type']['label'] : ''}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     SbButtoNotification(
  //                       label: 'Accetta', 
  //                       function: () async{
  //                         Modals().showMessageConfirme(
  //                           context, 
  //                           'Accetta invito', 
  //                           'Vuoi accettare l\'invito all\'ingresso?', 
  //                           () async{
  //                             Navigator.pop(context);
  //                             Modals().loader(context);
  //                             dynamic data = await ApiEvent().confirmInvite(int.parse(widget.notification['id'].toString()));
  //                             if(data['status'] != false){
  //                               await widget.refresh();
  //                               Navigator.pop(context);
  //                               Modals().showMessage(context, 'success', 'Richiesta accettata');
  //                             }else{
  //                               await widget.refresh();
  //                               Navigator.pop(context);
  //                               Modals().showMessage(context, 'error', '${data['error']}');
  //                             }
  //                             setState(() {
                              
  //                             });
  //                           }, 
  //                           (){
  //                             Navigator.pop(context);
  //                           },
  //                         );
                          
  //                       }
  //                     ),
  //                     IconButton(
  //                       onPressed: ()async {
  //                         Modals().loader(context);
  //                         dynamic data = await ApiEvent().deleteInvite(int.parse(widget.notification['id'].toString()));
  //                         if(data['status'] != false){
  //                           await widget.refresh();
  //                           Navigator.pop(context);
  //                           Modals().showMessage(context, 'success', 'Richiesta cancellata');
  //                         }else{
  //                           await widget.refresh();
  //                           Navigator.pop(context);

  //                           Modals().showMessage(context, 'error', '${data['error']}');
  //                         }
  //                         setState(() { });
  //                       }, 
  //                       icon: Icon(CupertinoIcons.xmark,color: Colors.red,)
  //                     )
  //                   ],
  //                 ),
  //                 Positioned(
  //                   bottom: -10,
  //                   left: 40,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       border: Border.all(
  //                         width: 1,
  //                         color: mainColor,
  //                       ),
  //                     borderRadius: BorderRadius.circular(10)
  //                     ),
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: -20,
  //                   right: 0,
  //                   child: Text(
  //                     '${extractTime(widget.notification['created_at'])}',
  //                     style: TextStyle(
  //                       color: textColor
  //                     ),
  //                   )
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'event_join'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(9),
  //                     child: widget.notification['event'] != null &&
  //                            widget.notification['event']['cover'] != null &&
  //                            widget.notification['event']['cover'].toString().isNotEmpty
  //                         ? Image.network(
  //                             BASE_URL + widget.notification['event']['cover'],
  //                             height: 50,
  //                             width: 50,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               );
  //                             },
  //                           )
  //                         : Image.asset(
  //                             NOPHOTO,
  //                             width: 50,
  //                             height: 50,
  //                             fit: BoxFit.cover,
  //                           ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: 'Sei stato vidimato all\'evento : ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                          TextSpan(text: '${widget.notification['event'] != null && widget.notification['event']['title'] != null ? widget.notification['event']['title'] : ''}', style: TextStyle(fontWeight: FontWeight.w700)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'entry_request'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         padding: EdgeInsets.symmetric(horizontal: 10),
  //         width: width(context, 100),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Stack(
  //               clipBehavior: Clip.none,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                           width: 1,
  //                           color: mainColor,
  //                         ),
  //                       borderRadius: BorderRadius.circular(10)
  //                       ),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 10,),
  //                     Expanded(
  //                       child: RichText(
  //                         text: TextSpan(
  //                           text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                           style: TextStyle(
  //                             color: textColor,
  //                             fontWeight: FontWeight.w700
  //                           ),
  //                           children: <TextSpan>[
  //                             TextSpan(text: ' ha richiesto un ingresso: ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                             TextSpan(text: '${widget.notification['entry_type'] != null ? widget.notification['entry_type']['label'] : ''}',style: TextStyle(fontWeight: FontWeight.w700)),
  //                             TextSpan(text: ' per l\'evento',style: TextStyle(fontWeight: FontWeight.w400)),
  //                             TextSpan(text: ' ${widget.notification['event']['title']}',style: TextStyle(fontWeight: FontWeight.w700)),
                    
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     SbButtoNotification(
  //                       label: 'Accetta', 
  //                       function: () async{
  //                         Modals().showMessageConfirme(
  //                           context, 
  //                           'Accetta invito', 
  //                           'Vuoi accettare l\'invito all\'ingresso?', 
  //                           () async{
  //                             Navigator.pop(context);
  //                             Modals().loader(context);
  //                             dynamic data = await ApiEvent().confirmInvite(int.parse(widget.notification['id'].toString()));
  //                             if(data['status'] != false){
  //                               Navigator.pop(context);
  //                               await widget.refresh();
  //                               Modals().showMessage(context, 'success', 'Richiesta accettata');
  //                             }else{
  //                               Navigator.pop(context);
  //                               await widget.refresh();
  //                               Modals().showMessage(context, 'error', '${data['error']}');
  //                             }
  //                             setState(() {
                              
  //                             });
  //                           }, 
  //                           (){
  //                             Navigator.pop(context);
  //                           },
  //                         );
                          
  //                       }
  //                     ),
  //                     IconButton(onPressed: (){
  //                       Modals().showMessageConfirme(
  //                         context, 
  //                         'Richiesta ingresso', 
  //                         'Vuoi rifiutare la richiesta di ingresso?', 
  //                         () async{
  //                           dynamic data = await ApiEvent().deleteInvite(int.parse(widget.notification['id'].toString()));
  //                           if(data['status'] != false){
  //                             Navigator.pop(context);
  //                             await widget.refresh();
  //                             Modals().showMessage(context, 'success', 'Richiesta cancellata');
  //                           }else{
  //                             Navigator.pop(context);
  //                             await widget.refresh();
  //                             Modals().showMessage(context, 'error', '${data['error']}');
  //                           }
  //                           setState(() {

  //                           });
  //                         }, 
  //                         (){
  //                           Navigator.pop(context);
  //                         }
  //                       );

  //                       }, 
  //                       icon: Icon(CupertinoIcons.xmark,color: Colors.red,)
  //                     )
  //                   ],
  //                 ),
  //                 Positioned(
  //                   bottom: -10,
  //                   left: 40,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       border: Border.all(
  //                         width: 1,
  //                         color: mainColor,
  //                       ),
  //                     borderRadius: BorderRadius.circular(10)
  //                     ),
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                         widget.notification['sender']['picture'] != null &&
  //                         widget.notification['sender']['picture'].toString().isNotEmpty
  //                       ? Image.network(
  //                           BASE_URL + widget.notification['sender']['picture'],
  //                           height: 20,
  //                           width: 20,
  //                           fit: BoxFit.cover,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             );
  //                           },
  //                         )
  //                       : Image.asset(
  //                           NOPHOTO,
  //                           width: 20,
  //                           height: 20,
  //                           fit: BoxFit.cover,
  //                         ),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: -20,
  //                   right: 0,
  //                   child: Text(
  //                     '${extractTime(widget.notification['created_at'])}',
  //                     style: TextStyle(
  //                       color: textColor
  //                     ),
  //                   )
  //                 ),
  //               ],
  //             ),
  //             // Row(
  //             //   mainAxisAlignment: MainAxisAlignment.center,
  //             //   children: [
  //             //     SizedBox(width: 30,),

  //             //     SbButtoNotification(
  //             //       label: 'Cancella',
  //             //       reverse: true,
  //             //       function: () async{
  //             //         Modals().showMessageConfirme(
  //             //           context, 
  //             //           'Richiesta ingresso', 
  //             //           'Vuoi rifiutare la richiesta di ingresso?', 
  //             //           () async{
  //             //             dynamic data = await ApiEvent().deleteInvite(int.parse(widget.notification['id'].toString()));
  //             //             if(data['status'] != false){
  //             //               Navigator.pop(context);
  //             //               await widget.refresh();
  //             //               Modals().showMessage(context, 'success', 'Richiesta cancellata');
  //             //             }else{
  //             //               Navigator.pop(context);
  //             //               await widget.refresh();
  //             //               Modals().showMessage(context, 'error', '${data['error']}');
  //             //             }
  //             //         setState(() {
                        
  //             //         });
  //             //           }, 
  //             //           (){
  //             //             Navigator.pop(context);
  //             //           }
  //             //         );
                      
  //             //       }
  //             //     )
  //             //   ],
  //             // ),
              
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'collaborator_accepted'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ti ha aggiunto come collaboratore all\'evento', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['title']}', style: TextStyle(fontWeight: FontWeight.w800)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'collaborator_removed'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' sei stato rimosso come collaboratore all\'evento', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['title']}', style: TextStyle(fontWeight: FontWeight.w800)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(9),
  //                   child: widget.notification['sender'] != null &&
  //                     widget.notification['sender']['picture'] != null &&
  //                     widget.notification['sender']['picture'].toString().isNotEmpty
  //                   ? Image.network(
  //                       BASE_URL + widget.notification['sender']['picture'],
  //                       height: 20,
  //                       width: 20,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (context, error, stackTrace) {
  //                         return Image.asset(
  //                           NOPHOTO,
  //                           width: 20,
  //                           height: 20,
  //                           fit: BoxFit.cover,
  //                         );
  //                       },
  //                     )
  //                   : Image.asset(
  //                       NOPHOTO,
  //                       width: 20,
  //                       height: 20,
  //                       fit: BoxFit.cover,
  //                     ),
  //                 ),
  //               ),
  //             ),
              
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'user_become_collaborator'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(9),
  //                     child: widget.notification['event'] != null &&
  //                       widget.notification['event']['cover'] != null &&
  //                       widget.notification['event']['cover'].toString().isNotEmpty
  //                     ? Image.network(
  //                         BASE_URL + widget.notification['event']['cover'],
  //                         height: 50,
  //                         width: 50,
  //                         fit: BoxFit.cover,
  //                         errorBuilder: (context, error, stackTrace) {
  //                           return Image.asset(
  //                             NOPHOTO,
  //                             width: 50,
  //                             height: 50,
  //                             fit: BoxFit.cover,
  //                           );
  //                         },
  //                       )
  //                     : Image.asset(
  //                         NOPHOTO,
  //                         width: 50,
  //                         height: 50,
  //                         fit: BoxFit.cover,
  //                       ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ti vuole invitare all\'evento', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['title']}', style: TextStyle(fontWeight: FontWeight.w800)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(9),
  //                       child: widget.notification['sender'] != null &&
  //                              widget.notification['sender']['picture'] != null &&
  //                              widget.notification['sender']['picture'].toString().isNotEmpty
  //                           ? Image.network(
  //                               BASE_URL + widget.notification['sender']['picture'],
  //                               height: 20,
  //                               width: 20,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) {
  //                                 return Image.asset(
  //                                   NOPHOTO,
  //                                   width: 20,
  //                                   height: 20,
  //                                   fit: BoxFit.cover,
  //                                 );
  //                               },
  //                             )
  //                           : Image.asset(
  //                               NOPHOTO,
  //                               width: 20,
  //                               height: 20,
  //                               fit: BoxFit.cover,
  //                             ),
  //                     ),
  //               ),
  //             ),
              
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else if(widget.notification['type'] == 'deleted_entry_seats'){
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/eventShow', arguments: {'eventId' : '${widget.notification['event']['id']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(9),
  //                         child: widget.notification['event'] != null &&
  //                                widget.notification['event']['cover'] != null &&
  //                                widget.notification['event']['cover'].toString().isNotEmpty
  //                             ? Image.network(
  //                                 BASE_URL + widget.notification['event']['cover'],
  //                                 height: 50,
  //                                 width: 50,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) {
  //                                   return Image.asset(
  //                                     NOPHOTO,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   );
  //                                 },
  //                               )
  //                             : Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                       ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' la cancellato il tuo ingresso di grupo. ', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['message']}', style: TextStyle(fontWeight: FontWeight.w800)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               bottom: -10,
  //               left: 40,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     width: 1,
  //                     color: mainColor,
  //                   ),
  //                 borderRadius: BorderRadius.circular(5000)
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(9),
  //                   child: widget.notification['sender'] != null &&
  //                     widget.notification['sender']['picture'] != null &&
  //                     widget.notification['sender']['picture'].toString().isNotEmpty
  //                   ? Image.network(
  //                       BASE_URL + widget.notification['sender']['picture'],
  //                       height: 20,
  //                       width: 20,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (context, error, stackTrace) {
  //                         return Image.asset(
  //                           NOPHOTO,
  //                           width: 20,
  //                           height: 20,
  //                           fit: BoxFit.cover,
  //                         );
  //                       },
  //                     )
  //                   : Image.asset(
  //                       NOPHOTO,
  //                       width: 20,
  //                       height: 20,
  //                       fit: BoxFit.cover,
  //                     ),
  //                 ),
  //               ),
  //             ),
              
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }else {
  //     return  GestureDetector(
  //       onTap: (){
  //         Navigator.pushNamed(context, '/profile', arguments: {'nickname' : '${widget.notification['sender']['nickname']}'});
  //       },
  //       child: Container(
  //         margin: EdgeInsets.all(10),
  //         width: width(context, 100),
          
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: mainColor,
  //                     ),
  //                   borderRadius: BorderRadius.circular(10)
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(9),
  //                     child: widget.notification['sender'] != null &&
  //                            widget.notification['sender']['picture'] != null &&
  //                            widget.notification['sender']['picture'].toString().isNotEmpty
  //                         ? Image.network(
  //                             BASE_URL + widget.notification['sender']['picture'],
  //                             height: 50,
  //                             width: 50,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Image.asset(
  //                                 NOPHOTO,
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               );
  //                             },
  //                           )
  //                         : Image.asset(
  //                             NOPHOTO,
  //                             width: 50,
  //                             height: 50,
  //                             fit: BoxFit.cover,
  //                           ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10,),
  //                 Expanded(
  //                   child: RichText(
  //                     text: TextSpan(
  //                       text: '${widget.notification['sender']['name'] ?? ''} ${widget.notification['sender']['surname'] ?? ''}',
  //                       style: TextStyle(
  //                         color: textColor,
  //                         fontWeight: FontWeight.w700
  //                       ),
  //                       children: <TextSpan>[
  //                         TextSpan(text: ' ${widget.notification['title']}', style: TextStyle(fontWeight: FontWeight.w400)),
  //                         TextSpan(text: ' ${widget.notification['message']}', style: TextStyle(fontWeight: FontWeight.w400)),

  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Positioned(
  //               top: -20,
  //               right: 0,
  //               child: Text(
  //                 '${extractTime(widget.notification['created_at'])}',
  //                 style: TextStyle(
  //                   color: textColor
  //                 ),
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }
  }
}