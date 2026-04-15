// import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sballando/api/sb_api_chat.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:uuid/uuid.dart';

class SbEventChat extends StatefulWidget {
  const SbEventChat({super.key});

  @override
  State<SbEventChat> createState() => SbEventChatState();
}

class SbEventChatState extends State<SbEventChat> {
  
  final ScrollController            _scrollController         = ScrollController();

  final TextEditingController       messageController         = TextEditingController();

  List                              events                    = [];
  List                              locations                 = [];
  List                              users                     = [];
  List                              messages                  = [];
  List                              usersLive                 = [];
  bool                              loader                    = true;
  bool                              newMessagePrivate         = false;
  String                            newMessage                = '';
  String                            upKey                     = Uuid().v4();

  @override


  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {

      // <- IMPOSTA LO STATO CORRENTE IN MANIERA GLOBALE PER SAPERE DOVE MI TROVO
      CURRENTSTATE = this;

      // <- SI CONNETTE ALLA SOCHET DELLA CHAT PUBLICA E ASCOLTA I MESSAGGI IN ARRIVO PER ACCODARLI
      socketService.connect(
        onNewMessage: (data) {
          // Aggiorna la lista e rifresca la UI
          if(data != null && data['sender']['id'] != USER['id'] && data['eventId'] == EVENTONAIR['id']){
            Map newMessage = data['message'];
            newMessage['sender'] = data['sender'];
            messages.add(Map<String, dynamic>.from(newMessage));
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
          setState(() {});
        },
        type: 'public'
      );
      dynamic dataUsers = await ApiChat().getUsersLive(EVENTONAIR['id']);
      if(dataUsers['status'] != false){
        usersLive = dataUsers['users'];
        loader = false;
      }
      setState(() {
        
      });
      dynamic data = await ApiChat().getMessages(EVENTONAIR['id']);
      if(data['status'] != false){
        messages = data['message'];
        Future.delayed(Duration(milliseconds: 100)).then((timestamp){
          // <-- SCROLL DOPO IL CARICAMENTO
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
        
      }
      loader = false;
      setState(() {
        
      });
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Altezza dell'header; supponiamo 200
    double headerHeight = ONAIR == true ? 110 : 80;
    const double footerHeight = 100.0;

    return Container(
    color: backgroundColor,
      child: SafeArea(
        child: Container(
          child: Scaffold(
            backgroundColor: backgroundColorTheme,
            body: SizedBox(
              
              width: width(context, 100),
              height: height(context, 100),
              child: Stack(
                children: [
                  
                  // Contenuto scrollabile
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: headerHeight,
                        bottom: footerHeight,
                      ),
                      child: Column(
                        children: [


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

                          /////////////////////////////////
                          /// NON CI SONO MESSAGGI
                          /////////////////////////////////
                          
                          if(loader == false && messages.isEmpty)
                          Center(
                            child: Text('Inizia la conversazione'),
                          ),

                          /////////////////////////////////
                          /// INIZIO MESSAGGI
                          /////////////////////////////////

                          if(loader == false)
                          ...List.generate(
                            messages.isNotEmpty ? messages.length : 0 ,
                            (index) {

                              /////////////////////////////////
                              /// MESSAGGI INVIATI
                              /////////////////////////////////
                              if (messages[index]['spotify_playlist'] != null) {
                                final playlist = messages[index]['spotify_playlist'];
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // intestazione "utente ha aggiunto una canzone"
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "${messages[index]['sender']['nickname'] ?? 'Un utente'} ha messo in coda una canzone:",
                                          style: TextStyle(
                                            color: mainColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      // canzone
                                      ListTile(
                                        leading: playlist['cover'] != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: Image.network(
                                                  playlist['cover'],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(Icons.music_note, color: Colors.white54, size: 40),
                                        title: Text(
                                          playlist['title'] ?? "Titolo sconosciuto",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          playlist['subtitle'] ?? "Artista sconosciuto",
                                          style: TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ),
                                      // eventuale messaggio che l’utente ha scritto accanto alla canzone
                                      if ((messages[index]['message'] ?? "").isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                                          child: Text('Dedica: ',
                                            style: TextStyle(color: Colors.white70, fontSize: textMid),
                                          ),
                                        ),
                                        if ((messages[index]['message'] ?? "").isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                                          child: Text(
                                            messages[index]['message'],
                                            style: TextStyle(color: mainColor, fontSize: textMid),
                                          ),
                                        ),
                                      // orario
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                                        child: Text(
                                          extractTime(messages[index]['created_at']),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              if(messages[index]['sender_id'].toString() == USER['id'].toString()){
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                  
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.all(10),
                                        constraints: BoxConstraints(
                                          maxWidth: width(context, 70), // larghezza massima
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: backgroundColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(37, 0, 0, 0),
                                              blurRadius: 10,
                                              offset: Offset(0.1, 0.1)
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              maxLines: 15,
                                              overflow: TextOverflow.ellipsis,
                                              'Tu',
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),

                                            Text(
                                              maxLines: 15,
                                              overflow: TextOverflow.ellipsis,
                                              '${messages[index]['message']}',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: textMid
                                              ),
                                            ),

                                            Text(
                                              '${extractTime(messages[index]['created_at'])}',
                                              style: TextStyle(
                                                color: textColorSecondary,
                                                fontSize: textLowMid
                                              ),
                                            ),

                                          ],
                                        )
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1,color: mainColor),
                                          borderRadius: BorderRadius.circular(5),

                                        ),
                                        width: 25,
                                        height: 25,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.network(
                                            '$BASE_URL${messages[index]['picture']}${ver()}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                "$NOPHOTO",
                                                width: 25,
                                                height: 25,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                                
                              }

                              /////////////////////////////////
                              /// MESSAGGI RICEVUTI
                              /////////////////////////////////
                              
                              else{
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(

                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap:() {
                                          Navigator.pushNamed(context,'/eventPrivateChat',arguments: {'user' : messages[index]['sender']});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1,color: mainColor),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          width: 25,
                                          height: 25,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(
                                              '$BASE_URL${messages[index]['picture']}${ver()}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  "assets/images/sballando_no_photo.jpeg",
                                                  width: 25,
                                                  height: 25,
                                                  fit: BoxFit.cover,
                                                );
                                              }
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: width(context, 70), // larghezza massima
                                        ),
                                        margin: EdgeInsets.only(left: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(37, 0, 0, 0),
                                              blurRadius: 10,
                                              offset: Offset(0.1, 0.1)
                                            )
                                          ],
                                          borderRadius: BorderRadius.circular(5),
                                          color: backgroundColor,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              maxLines: 15,
                                              overflow: TextOverflow.ellipsis,
                                              '${messages[index]['sender'] != null && messages[index]['sender']['name'] != null && messages[index]['sender']['surname'] != null ? messages[index]['sender']['name'] + ' ' + messages[index]['sender']['surname'] : ''}',
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(
                                              maxLines: 15,
                                              overflow: TextOverflow.ellipsis,
                                              '${messages[index]['message']}',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: textMid
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${extractTime(messages[index]['created_at'])}',
                                                  style: TextStyle(
                                                    color: textColorSecondary,
                                                    fontSize: textLowMid
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        )
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          ),
                          SizedBox(height: 100,)
                        ],
                      )
                    ),
                  ),
      
                  // Header animato in alto
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: backgroundColor
                        ),
                        height: 80,
                        width: width(context, 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  if(USER['visibility'] == 0){
                                    Modals().showMessage(context, 'error', 'Attivare la visibilità dell\'account per accedere alla chat!');
                                  }else{
                                    // Navigator.pushNamed(context, '/eventListChat');
                                    Navigator.pop(context);
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.chevron_left,
                                      color: mainColor,
                                      size: 50,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${EVENTONAIR['title']}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: mainColor,
                                              fontSize: textHight,
                                              fontWeight: FontWeight.w700
                                            ),
                                          ),
                                          Text(
                                            '${usersLive.length} utenti live',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMid,
                                              fontWeight: FontWeight.w600
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Stack(
                                // mainAxisAlignment: MainAxisAlignment.end,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      if(USER['visibility'] == 0){
                                        Modals().showMessage(context, 'error', 'Attivare la visibilità dell\'account per accedere alla chat!');
                                      }else{
                                        Navigator.pushNamed(context, '/eventListChat');
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(500)
                                      ),
                                      child: Icon(CupertinoIcons.list_bullet, size: 15,color: Colors.white),
                                    ),
                                  ),
                                  if(newMessagePrivate)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(500)
                                      ),
                                      width: 10,
                                      height: 10,
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Footer animato in basso
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: footerHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor
                      ),
                      height: 90,
                      width: width(context, 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: width(context, 80), // oppure una larghezza specifica
                            height: 50, // altezza definita
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: backgroundColorTheme,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              style: TextStyle(
                                color: textColor, // Cambia qui il colore del testo
                                fontSize: 16,      // Puoi anche personalizzare il font
                              ),
                              controller: messageController,
                              decoration:  InputDecoration(
                                fillColor: backgroundColorTheme,
                                filled: true,
                                hintText: 'Scrivi un messaggio...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) async{
                              if (value.trim().isNotEmpty) {
                                if(messageController.text != ''){
                                  String cloneMessage = json.decode(json.encode(messageController.text));
                                  Map newMessage = {
                                    'event_id' : EVENTONAIR['id'],
                                    'sender_id' : USER['id'],
                                    'message' : cloneMessage,
                                    'created_at' : getCurrentTimeInIsoUtc(),
                                    'picture' : USER['picture']
                                  };
                                  messages.add(newMessage);
                                  messageController.text = '';
                                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                  setState(() {});
                                  dynamic data = await ApiChat().sendMessage(EVENTONAIR['id'], cloneMessage);
                                  if(data['status'] != false){
                                    socketService.sendMessage(USER,EVENTONAIR['id'],newMessage);
                                    setState(() {  });
                                  }
                                }
                              }
                            },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(400),
                              color: mainColor
                            ),
                            child: IconButton(
                              onPressed: () async{
                                if(messageController.text != ''){
                                  String cloneMessage = json.decode(json.encode(messageController.text));

                                  Map newMessage = {
                                    'event_id' : EVENTONAIR['id'],
                                    'sender_id' : USER['id'],
                                    'message' : cloneMessage,
                                    'created_at' : getCurrentTimeInIsoUtc(),
                                    'picture' : USER['picture']
                                  };
                                  messages.add(newMessage);
                                  messageController.text = '';
                                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

                                  setState(() {

                                  });
                                    
                                  dynamic data = await ApiChat().sendMessage(EVENTONAIR['id'], cloneMessage);
                                  if(data['status'] != false){
                                    socketService.sendMessage(USER,EVENTONAIR['id'],newMessage);
                                    setState(() {  });
                                  }
                                }
                                
                              }, 
                              icon: Icon(Icons.send,color: Colors.white,size: 25,)
                            ),
                          )
                        ],
                        
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
