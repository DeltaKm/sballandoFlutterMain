import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_card_event.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbUserFavorite extends StatefulWidget {
  const SbUserFavorite({super.key});

  @override
  State<SbUserFavorite> createState() => _SbUserFavoriteState();
}

class _SbUserFavoriteState extends State<SbUserFavorite> {
  int         userId        = 0;
  List        events        = [];
  bool        loader        = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      dynamic args        = ModalRoute.of(context)!.settings.arguments;
      if(args != null && args['user_id'] != null){
        userId  = args['user_id'];
        if(userId != 0){
          loader = true;
          setState(() {
            
          });
          dynamic data            = await ApiEvent().getFavoriteEvent(userId); // Recupero l'utente
          if(data['status'] != false){
            events = data['data'];
          }
          loader = false;
          setState(() {
            
          });
        }
      }

      setState(() {
      
    });
    });

  }
  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'EVENTI PREFERITI',
                style: TextStyle(
                  color: mainColor,
                  fontSize: textHight,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            if(loader == true)
              Center(
                child: Container(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    color: mainColor,
                    strokeWidth: 10, // Spessore della linea dello spinner
                  ),
                ),
              ),

            if(loader == false && events.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Nessun evento aggiunto ai preferiti',
                style: TextStyle(
                  color: textColor,
                  fontSize: textLowMid,
                  fontWeight: FontWeight.w400
                ),
              ),
            ),
            if(loader == false)

            ...List.generate(
              events.isNotEmpty ? events.length : 0,
              (index){
                Map event = events[index]['event'];
                return SbCardEvent(event: event);
              }
            )
          ],
        ),
      )
    );
  }
}