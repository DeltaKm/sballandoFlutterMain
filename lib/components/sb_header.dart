

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'package:sballando/components/sb_blinking.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbHeader extends StatefulWidget {
  bool?         home              = false;
  bool          search            = false;

  Function?     loadData;
  Widget?        ricerca;
  
  SbHeader({
    super.key,
    this.home,
    this.loadData,
    this.ricerca,
    required this.search,
  });

  @override
  State<SbHeader> createState() => SbHeaderState();
}

class SbHeaderState extends State<SbHeader> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    HEADERSTATE = this;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final brightness = MediaQuery.of(context).platformBrightness;
      SystemChrome.setSystemUIOverlayStyle(
        brightness == Brightness.dark
          ? SystemUiOverlayStyle.light // Orario bianco
          : SystemUiOverlayStyle.dark  // Orario nero
      );
      DARKMODE = brightness == Brightness.dark;
      if(DARKMODE){
        backgroundColorTheme      = Color(0xFF121212);
        backgroundColor           = Color.fromARGB(255, 35, 35, 35);
        textColorSecondary        = Color.fromRGBO(255, 255, 255, 1);
        textColor                 = Color.fromRGBO(255, 255, 255, 1);
        grayLight                 = Color.fromRGBO(232, 232, 232, 1);
      }else{
        backgroundColor           = Color.fromRGBO(255, 255, 255, 1);
        backgroundColorTheme      = Color.fromRGBO(245, 245, 245, 1);
        textColorSecondary        = Color.fromRGBO(112, 112, 112, 1);
        textColor                 = Color(0xFF212938);
        grayLight                 = Color.fromRGBO(232, 232, 232, 1);
      }
      setState(() {
        
      });

      try {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          FIREBASETOKEN = token;
        }
        
        FirebaseMessaging.onMessage.listen((RemoteMessage data) {
          if (mounted) {
            UNREADNOTIFICATIONS = true;
            if(data.data['action'] == 'on_air'){
              ONAIR = true;
              EVENTONAIR = {
                'id' : data.data['event_id'],
                'title' : data.data['event_title']
              };
            }
            setState(() {
              
            });
          }
        });
      } catch (e) {
        print(e);
      }
    });
  }




  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: backgroundColor
            ),
            height: 50,
            width: width(context, 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: (){
                    if(Navigator.canPop(context)){
                      Navigator.pop(context);
                    }
                  }, 
                  icon: Icon(Icons.chevron_left, color: mainColor, size: 30,),
                ),
                
                ////////////////////////
                /// LOGO APP
                ////////////////////////                

                Expanded(
                  child: GestureDetector(
                    onTap: () async{
                      FOOTERSELECT = 'home';
                      if(REF_CONTROLLER_QRCODE != null){
                        await REF_CONTROLLER_QRCODE!.stopScan();
                        await REF_CONTROLLER_QRCODE!.dispose();
                      }
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/sballando-logo.png",
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        
                      ],
                    ),
                  ),
                ),
                      
                
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      ////////////////////////
                      /// ICONA FAVORITI
                      ////////////////////////
                      
                      IconButton(
                        onPressed: (){
                          FOOTERSELECT = 'favorite';
                          if(USER.isNotEmpty && LOGIN == true){
                            Navigator.pushNamed(context, '/eventFavorite',arguments: {'user_id' : USER['id']});
                          }else{
                            Modals().showMessage(context, 'error', 'Effettua il login per poter usare questa funzionalità!');
                          }
                          },
                        icon: Icon(
                          FOOTERSELECT == 'favorite' ? Icons.favorite : Icons.favorite_border, 
                          size: FOOTERSELECT == 'favorite' ? 25 :  25,
                          color: mainColor
                        ),
                      ),


                      ////////////////////////
                      /// ICONA NOTIFICHE
                      ////////////////////////
                      
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () async{
                              FOOTERSELECT = 'notification';
                              if(REF_CONTROLLER_QRCODE != null){
                                await REF_CONTROLLER_QRCODE!.stopScan();
                                await REF_CONTROLLER_QRCODE!.dispose();
                              }
                              if(USER.isNotEmpty && LOGIN == true){
                                Navigator.pushNamed(
                                  context, '/notification',
                                  arguments: {'page' : 'generali'}
                                );
                              }else{
                                Modals().showMessage(context, 'error', 'Effettua il login per poter usare questa funzionalità!');
                              }
                            
                            },
                            icon: Icon(
                              FOOTERSELECT == 'notification' ?  CupertinoIcons.bell_fill : CupertinoIcons.bell, 
                              size: FOOTERSELECT == 'notification' ? 25 :  25,
                              color: mainColor
                            ),
                          ),
                          if(UNREADNOTIFICATIONS == true)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(400),
                                color: Colors.green
                              ),
                            ) 
                          ),
                        ],
                      ),

                      ////////////////////////
                      /// ICONA PROFILO
                      ////////////////////////
                      
                      LOGIN != true 
                        ? IconButton(
                            onPressed: () async{
                              FOOTERSELECT = 'profile';
                              if(REF_CONTROLLER_QRCODE != null){
                                await REF_CONTROLLER_QRCODE!.stopScan();
                                await REF_CONTROLLER_QRCODE!.dispose();
                              }
                              if(LOGIN){
                                Navigator.pushNamed(
                                  context,
                                  '/profile',
                                  arguments: {'nickname': USER['nickname']},
                                );
                              }else{
                                Navigator.pushNamed(context, '/login');
                              }
                            },
            
                            icon: Icon(CupertinoIcons.profile_circled, size: 30,color: mainColor,)
            
                          )
                        : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,color: mainColor,
                            )
                          ),
                          child: GestureDetector(
                            onTap: () async{
                              FOOTERSELECT = 'profile';
                              if(REF_CONTROLLER_QRCODE != null){
                                await REF_CONTROLLER_QRCODE!.stopScan();
                                await REF_CONTROLLER_QRCODE!.dispose();
                              }
                              Navigator.pushNamed(
                                context,
                                '/profile',
                                arguments: {'nickname': USER['nickname']},
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                                child: Image.network(
                                  "$BASE_URL${USER['picture']}${ver()}",
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      NOPHOTO,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
         
          if(widget.ricerca != null)
          widget.ricerca!,
              
          ////////////////////////
          /// BANNER ONAIR 
          ////////////////////////    

          if(ONAIR == true )
          BlinkingWidget(
            duration: Duration(milliseconds: 600), // Puoi modificare la durata per un lampeggio più lento
            child: GestureDetector(
              onTap: () async {
                Navigator.pushNamed(context, '/eventShow', arguments: {'eventId': EVENTONAIR['id']});
              },
              child: Container(
                width: width(context, 100),
                height: 50,
                decoration: BoxDecoration(
                  color: mainColor,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'ON AIR',
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: Marquee(
                          text: '${EVENTONAIR['title']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: textMidHight,
                            fontWeight: FontWeight.w500,
                          ),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          blankSpace: 20.0,
                          velocity: 50.0,
                          pauseAfterRound: Duration(seconds: 1),
                          startPadding: 10.0,
                          accelerationDuration: Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration: Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

