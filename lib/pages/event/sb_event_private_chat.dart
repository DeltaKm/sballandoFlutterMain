import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_chat.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:uuid/uuid.dart';

class SbEventPrivateChat extends StatefulWidget {
  const SbEventPrivateChat({super.key});

  @override
  State<SbEventPrivateChat> createState() => SbEventPrivateChatState();
}

class SbEventPrivateChatState extends State<SbEventPrivateChat> {

  final ScrollController            _scrollController         = ScrollController();
  final TextEditingController       messageController          = TextEditingController();

  final bool      _showHeader               = true;
  final bool      _showFooter               = true;
  bool      loader                    = true;
  bool      newMessagePublic          = false;
  bool      newMessagePrivate         = false;

  List      events                    = [];
  List      locations                 = [];
  List      messages                  = [];
  List      users                     = [];
  List      products                  = [];

  Map       user                      = {};
  int       usersLive                 = 0;
  String    newMessage                = '';
  String    upKey                     = Uuid().v4();

  @override


  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      CURRENTSTATE = this;
      try{
        final args                          = ModalRoute.of(context)!.settings.arguments as Map;
        user                                = args['user'] ?? {};
        dynamic data                        = await ApiChat().getMessages(EVENTONAIR['id'],receiver_id: user['id']);    // OTTENGO I MESSAGGI
        dynamic dataProducts                = await ApiChat().getProductsEvent(EVENTONAIR['id']);                       // OTTENGO I PRODOTTI
        products                            = dataProducts['products'];
        if(data['status'] != false){
          messages = data['message'];

          Future.delayed(Duration(milliseconds: 100)).then((timestamp){
            // <-- SCROLL DOPO IL CARICAMENTO
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }
        socketService.connect(
          onNewMessage: (data) {
            // Aggiorna la lista e rifresca la UI
            if(data != null && data['sender']['id'] == user['id'] && data['receiverId'] == USER['id'] && data['eventId'] == EVENTONAIR['id']){
              messages.add(Map<String, dynamic>.from(data['message']));
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
            setState(() {});
          },
          type: 'private',
          receiverId: user['id']
        );
        loader = false;
        setState(() {});
      }catch(e){
        print(e);
      }
    });
    // Aggiungi un listener per monitorare lo scrolling
    // _scrollController.addListener(() {
    //   double offset = _scrollController.offset;
    //   // Soglia per evitare aggiornamenti troppo frequenti
    //   if (offset > _lastOffset + 5) {
    //     // Scrolling verso il basso: nascondi header e footer
    //     if (_showHeader || _showFooter) {
    //       setState(() {
    //         _showHeader = false;
    //         _showFooter = false;
    //       });
    //     }
    //   } else if (offset < _lastOffset - 5) {
    //     // Scrolling verso l'alto: mostra header e footer
    //     if (!_showHeader || !_showFooter) {
    //       setState(() {
    //         _showHeader = true;
    //         _showFooter = true;
    //       });
    //     }
    //   }
    //   _lastOffset = offset;
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          if(loader == false && messages.isEmpty)
                          Center(
                            child: Text('Scrivi il primo messaggio...'),
                          ),
                          if(loader == false)
                          ...List.generate(
                            messages.isNotEmpty ? messages.length : 0 ,
                            (index) {
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
                                            if(messages[index]['product'] != null)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    if(messages[index]['product'] != null)
                                                    Text(
                                                      maxLines: 20,
                                                      overflow: TextOverflow.ellipsis,
                                                      '${messages[index]['product']['label']} ',
                                                      style: TextStyle(
                                                        color: mainColor,
                                                        fontSize: textMid,
                                                        fontWeight: FontWeight.w700
                                                      ),
                                                    ),
                                                    if(messages[index]['product_id'] != null)
                                                    Icon(Icons.card_giftcard,color: mainColor,size: 50,),
                                                  ],
                                                )
                                              ],
                                            ),
                                            if(messages[index]['message'] != null && messages[index]['message'] != '')
                                            Text(
                                              maxLines: 20,
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
                              }else{
                                return GestureDetector(
                                  onTap:(){
                                    if(messages[index]['product_id'] != null){
                                      Modals().modalQrCode(context, 'product', USER['id'], EVENTONAIR['id'], messages[index]['product'], EVENTONAIR);
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                  
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.pushNamed(context,'/profile',arguments: {'nickname' :'${user['nickname']}'});
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
                                                    "$NOPHOTO",
                                                    width: 25,
                                                    height: 25,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                                ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          padding: EdgeInsets.all(10),
                                          constraints: BoxConstraints(
                                            maxWidth: width(context, 70), // larghezza massima
                                          ),
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
                                              if(messages[index]['product'] != null)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      if(messages[index]['product'] != null)
                                                      Text(
                                                        maxLines: 20,
                                                        overflow: TextOverflow.ellipsis,
                                                        '${messages[index]['product']['label']} ',
                                                        style: TextStyle(
                                                          color: mainColor,
                                                          fontSize: textMid,
                                                          fontWeight: FontWeight.w700
                                                        ),
                                                      ),
                                                      if(messages[index]['product_id'] != null)
                                                      Icon(Icons.card_giftcard,color: mainColor,size: 50,),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              
                                              if(messages[index]['message'] != null && messages[index]['message'] != '')
                                              Text(
                                                maxLines: 20,
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
                                      ],
                                    ),
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
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _showHeader ? 0 : (ONAIR == true ? - headerHeight + 50 :  -headerHeight), // se _showHeader è false, sposta fuori dalla vista
                    left: 0,
                    right: 0,
                    // height: headerHeight,
                    child: Column(
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
                                        // width: width(context, 40),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${EVENTONAIR['title']}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: textHight,
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              user.isNotEmpty && user.isNotEmpty ? '${user['name']} ${user['surname']}' : '',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: textMidHight,
                                                fontWeight: FontWeight.w500
                                        
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.pushNamed(
                                            context, '/eventChat',
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: mainColor,
                                            borderRadius: BorderRadius.circular(500)
                                          ),
                                          child: Icon(Icons.chat_outlined, size: 15,color: Colors.white),
                                        ),
                                      ),
                                      if(newMessagePublic)
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
                                  
                                  SizedBox(width: 15,),
                                  Stack(
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
                                  SizedBox(width: 20,)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                  // Footer animato in basso
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: _showFooter ? 0 : -footerHeight, // se _showFooter è false, sposta fuori dalla vista
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
                            width: width(context, 65), // oppure una larghezza specifica
                            height: 50, // altezza definita
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                              decoration: InputDecoration(
                                fillColor: backgroundColorTheme,
                                filled: true,
                                hintText: 'Scrivi un messaggio...',
                                border: InputBorder.none,
                              ),

                              onSubmitted: (value) async{
                                if(value.trim().isNotEmpty) {
                                  try{
                                    String cloneMessage = json.decode(json.encode(messageController.text));
                                    Map newMessage = {
                                      'sender_id' : USER['id'],
                                      'message' : cloneMessage,
                                      'created_at' : getCurrentTimeInIsoUtc(),
                                      'picture' : USER['picture']
                                    };
                                    messages.add(newMessage);
                                    messageController.text = '';
                                    setState(() { });
                                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                    socketService.sendMessagePrivate(USER,EVENTONAIR['id'],newMessage,user['id']);
                                    setState(() { });
                                    dynamic data = await ApiChat().sendMessage(EVENTONAIR['id'], cloneMessage,receiver_id: user['id']);
                                    if(data['status'] == false){
                                      Modals().showMessage(context, 'error', 'errore durante l\'invio del prodotto');
                                    }
                                  }catch(e){
                                    print(e);
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
                                if(messageController.text.isNotEmpty && messageController.text != ''){
                                  try{
                                    String cloneMessage = json.decode(json.encode(messageController.text));
                                    Map newMessage = {
                                      'sender_id' : USER['id'],
                                      'message' : cloneMessage,
                                      'created_at' : getCurrentTimeInIsoUtc(),
                                      'picture' : USER['picture']
                                    };
                                    messages.add(newMessage);
                                    messageController.text = '';
                                    setState(() { });
                                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                    socketService.sendMessagePrivate(USER,EVENTONAIR['id'],newMessage,user['id']);
                                    setState(() { });
                                    dynamic data = await ApiChat().sendMessage(EVENTONAIR['id'], cloneMessage,receiver_id: user['id']);
                                    if(data['status'] == false){
                                      Modals().showMessage(context, 'error', 'errore durante l\'invio del prodotto');
                                    }
                                  }catch(e){
                                    print(e);
                                  }
                                }
                                
                              }, 
                              icon: Icon(Icons.send,color: Colors.white, size: 25,)
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(400),
                              color: mainColor
                            ),
                            child: IconButton(
                              onPressed: () async{

                                final Map grouped = {};
                                for (var product in products) {
                                  final label = product['label'];
                                  if (grouped.containsKey(label)) {
                                    grouped[label]!['stock'] += product['stock'];
                                  } else {
                                    grouped[label] = Map.from(product);
                                  }
                                }
                                final List mergedProducts = grouped.values.toList();

                                Modals().modalGiftProducts(
                                  context, 
                                  mergedProducts, 
                                  user,
                                  (productSelect) async {
                                    String cloneMessage = json.decode(json.encode(messageController.text));
                                    Map newMessage = {
                                      'sender_id' : USER['id'],
                                      'message' : cloneMessage,
                                      'product_id': productSelect['id'],
                                      'created_at' : getCurrentTimeInIsoUtc(),
                                      'picture' : USER['picture'],
                                      'product' : productSelect,
                                    };
                                    messages.add(newMessage);
                                    messageController.text = '';
                                    setState(() { });
                                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                    socketService.sendMessagePrivate(USER,EVENTONAIR['id'],newMessage,user['id'],productId: productSelect['id']);
                                    setState(() { });
                                    dynamic data = await ApiChat().sendMessage(EVENTONAIR['id'], cloneMessage,receiver_id: user['id'],productId: productSelect['id']);
                                    if(data['status'] == false){
                                      Modals().showMessage(context, 'error', 'errore durante l\'invio del prodotto');
                                    }else{
                                      dynamic dataProducts                = await ApiChat().getProductsEvent(EVENTONAIR['id']);                       // OTTENGO I PRODOTTI
                                      products                            = dataProducts['products'];
                                      setState(() { });
                                    }
                        
                                  }
                                );
                              }, 
                              icon: Icon(Icons.card_giftcard_rounded,color: Colors.white, size: 25)
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