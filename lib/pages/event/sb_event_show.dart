import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_card_location.dart';
import 'package:sballando/components/sb_card_user.dart';
import 'package:sballando/components/sb_favorite_button.dart';
import 'package:sballando/components/sb_image_full_screen.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/components/sb_tab_custom_multi.dart';
import 'package:sballando/components/sb_ticket_group_list.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class SbEventshow extends StatefulWidget {
  const SbEventshow({super.key});

  @override
  State<SbEventshow> createState() => SbEventshowState();
}

class SbEventshowState extends State<SbEventshow> {

  final TextEditingController       spotifyController         = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double    fabBottom                 = 170; // posizione iniziale
  bool      onAir                     = false;
  bool      isProductAssigned         = false;
  bool      isEntryAssigned           = false;
  bool      pendingNotification       = false;
  bool      eventEnded                = false;
  bool      areCollaborator           = false;
  bool      areOwner                  = false;
  bool      register                  = false;
  bool      ticketSelect              = false;
  bool      loader                    = true;
  bool      isExpanded                = false;
  bool      buyEvent                  = false;
  int?      eventId;
  int       partecipantVisibles       = 0;

  List      users                     = [];
  List      participants              = [];
  List      collaborators             = [];
  List      entry_types               = [];
  List      products                  = [];
  List      entryTypeTableUser        = [];
  List      categories                = [];
  List      productsCategories        = [];
  List      specialGuest              = [];

  Map       notificationRequest       = {};
  Map       event                     = {};
  Map       location                  = {};
  Map       organizzatore             = {};
  Map       categoryMap               = {};
  Map       entryTypeOwned            = {};
  Map       userOwner                 = {};
  Map       ticketSelectMap           = {};
  Map       favorite                  = {};

  String    upKey                     = Uuid().v4();

  Future loadData() async{
    loader = true;

    if(mounted){
      setState(() {
        
      });
    }
    if(eventId != null){
      dynamic resp                      = await ApiEvent().getEvent(eventId!);
      if(resp != null && resp['status'] != false){
        
        event                           = resp['event'];
        location                        = resp['location'];
        participants                    = resp['partecipanti'] ?? [];
        entry_types                     = resp['entry_types'] ?? [];
        products                        = resp['products'] ?? [];
        products = products.where(
          (product) => product['price'] != 0 && product['price'] != '0' && product['price'] != '' && product['price'] != null
        ).toList();
        productsCategories              = resp['products_categories'] ?? [];
        favorite                        = resp['favorite'] ?? {};
        isProductAssigned               = resp['isProductAssigned'];
        isEntryAssigned                 = resp['isEntryAssigned'];
        pendingNotification             = resp['pending_notification'];
        eventEnded                      = resp['eventEnded'];
        entryTypeOwned                  = resp['entryTypeOwned'] ?? {};
        userOwner                       = resp['userOwner'];
        areOwner                        = resp['auth'];
        register                        = resp['register'];
        collaborators                   = resp['collaborators'];
        categories                      = resp['categories'];
        entryTypeTableUser              = resp['entryTypeTableUser']; // lista di ingressi con piu posti presi dagli utenti
        notificationRequest             = resp['notificationRequest'] ?? {};
        if((resp['youAreOnAir'] == true && parseServerDateTime(resp['event']['datetime_end']).isAfter(DateTime.now())) || onAir || areCollaborator || areOwner){

          EVENTONAIR                    = resp['event'];
          ONAIR                         = true;
          onAir                         = resp['youAreOnAir'];
          saveShared('json', EVENTONAIR, 'onair');
        }
        for (var p in participants) {
          if(p['visibility'] == 0){
            partecipantVisibles += 1;
          }
        }

        specialGuest = [];
        Set<String> specialGuestIds = {};
        if(resp['collaborators_group'].isNotEmpty){
          resp['collaborators_group'].forEach((g){
            if(g['pivot']['guest_enabled'] == 1){
              specialGuest.add(g);
              specialGuestIds.add(g['id'].toString());
            }
          });
        }

        if(collaborators.isNotEmpty && collaborators.isNotEmpty){
          //  collaborators = collaborators.where((col) => !specialGuestIds.contains(col['id'].toString())).toList();
          for (var col in collaborators) {
            if(col['id'].toString() == USER['id'].toString()){
              areCollaborator = true;
              if(!parseServerDateTime(event['datetime_start']).isAfter(DateTime.now())){
                EVENTONAIR = resp['event'];
              }
            }
          }
        }
      }
    }
    loader = false;
     if(mounted){
      setState(() {
        
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      footerHeightNotifier.value = FOOTERHEIGHT;

      SHOWOVERLAY = false;
      // resto del codice initState...
      FOOTERHEIGHT = 100.0;
      _scrollController.addListener(() {
        if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
          // verso il basso → abbassa il pulsante
          if (fabBottom != 50) {
            setState(() {
              fabBottom = 50;
            });
          }
        } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
          // verso l’alto → rialza il pulsante
          if (fabBottom != 170) {
            setState(() {
              fabBottom = 170;
            });
          }
        }
      });

      CURRENTSTATE = this;
      final route = ModalRoute.of(context);
      if (route == null) {
        // Gestisci l'assenza della route
        print('Route non trovata!');
      } else {
        dynamic args = route.settings.arguments;
        // Usa args
        eventId           = args != null ? int.parse(args!['eventId'].toString()) : 1;
        buyEvent          = args != null && args!['buyProducts'] != null ? args!['buyProducts'] : false;

      }
      if(eventId != null){
        dynamic resp                      = await ApiEvent().getEvent(int.parse(eventId!.toString()));

        if(resp != null && resp.isNotEmpty && resp['status'] != false){
          
          event                           = resp['event'];
          location                        = resp['location'];
          participants                    = resp['partecipanti'];
          entry_types                     = resp['entry_types'];
          products                        = resp['products'];
          productsCategories              = resp['products_categories'];
          isProductAssigned               = resp['isProductAssigned'];
          isEntryAssigned                 = resp['isEntryAssigned'];
          favorite                        = resp['favorite'] ?? {};
          pendingNotification             = resp['pending_notification'];
          eventEnded                      = resp['eventEnded'];
          entryTypeOwned                  = resp['entryTypeOwned'] ?? {};
          userOwner                       = resp['userOwner'];
          areOwner                        = resp['auth'];
          register                        = resp['register'];
          collaborators                   = resp['collaborators'];
          categories                      = resp['categories'];
          entryTypeTableUser              = resp['entryTypeTableUser']; // lista di ingressi con piu posti presi dagli utenti
          notificationRequest             = resp['notificationRequest'] ?? {};
          if((resp['youAreOnAir'] == true && parseServerDateTime(resp['event']['datetime_end']).isAfter(DateTime.now())) || onAir || areCollaborator || areOwner){
            EVENTONAIR                    = resp['event'];
            ONAIR                         = true;
            onAir                           = resp['youAreOnAir'];
            saveShared('json', EVENTONAIR, 'onair');
          }
          specialGuest                    = [];
          Set<String> specialGuestIds     = {};

          for (var p in participants) {
            if(p['user'] == null || p['user']['visibility'] == 0){
              partecipantVisibles += 1;
            }
          }

          if(resp['collaborators_group'].isNotEmpty){
            resp['collaborators_group'].forEach((g){
              if(g['pivot']['guest_enabled'] == 1){
                specialGuest.add(g);
                specialGuestIds.add(g['id'].toString());
              }
            });
          }

          if(collaborators.isNotEmpty && collaborators.isNotEmpty){
            //  collaborators = collaborators.where((col) => !specialGuestIds.contains(col['id'].toString())).toList();
            for (var col in collaborators) {
              if(col['id'].toString() == USER['id'].toString()){
                areCollaborator = true;
                if(!parseServerDateTime(event['datetime_start']).isAfter(DateTime.now())){
                  EVENTONAIR = resp['event'];
                }
              }
            }
          }

          entry_types.forEach((entry) async{
            String category = entry['category'];
            if (!categoryMap.containsKey(category)) {
              categoryMap[category] = [];
            }
            categoryMap[category]!.add(entry);
          });

          dynamic data = await ApiUser().getUser(userOwner['nickname'].toString());
          
          if(data != null && data.isNotEmpty && data['status'] != false){
            organizzatore = data['user'];
          }

          loader = false;
        }
        if(mounted){
          setState(() {});

        }


        if(buyEvent == true){
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                child: Container(
                  color: backgroundColor,
                  width: width(context, 100),
                  child: SizedBox(
                width: width(context, 100),
                child: SbTabCustomMulti(
                  collaborators: collaborators,
                  elements: products,
                  tabs: productsCategories,
                  loadData: loadData,
                  typeElement: 'products',
                ),
              ),
                )
              );
            },
          );
        }
        
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SbScheletro(
          buttons: [
            ValueListenableBuilder<double>(
              valueListenable: footerHeightNotifier,
              builder: (context, FOOTERHEIGHT, child) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 1000),
                  bottom: !SHOWOVERLAY ? FOOTERHEIGHT : FOOTERHEIGHT + 65,
                  child: GestureDetector(
                    onTap: () {
                      if(event['spotify_access_token'] == null) return; // Non fare nulla se non c'è token Spotify
                      SHOWOVERLAY = false;
                      Navigator.pushNamed(context, '/jukebox',arguments: {'eventId': eventId});
                    },
                    child: Container(
                      height: 60,
                      width: width(context, 100),
                      decoration: BoxDecoration(
                        color: event['spotify_access_token'] == null ? Colors.grey : mainColor,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jukebox',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: event['spotify_access_token'] == null ? Colors.grey[400] : Colors.white,
                                fontSize: textMidHight
                              ),
                            ),
                            Icon(
                              CupertinoIcons.music_note,
                              color: event['spotify_access_token'] == null ? Colors.grey[400] : Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            ValueListenableBuilder<double>(
              valueListenable: footerHeightNotifier,
              builder: (context, FOOTERHEIGHT, child) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 1000),
                  bottom: FOOTERHEIGHT + 130,
                  child: GestureDetector(
                    onTap: () {
                      SHOWOVERLAY = false;
                      Navigator.pushNamed(context, '/eventListChat',arguments: {'eventId': eventId, 'event': event});
                    },
                    child: Container(
                      height: 60,
                      width: width(context, 100),
                      decoration: BoxDecoration(
                        color: mainColor,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: textMidHight
                              ),
                            ),
                            Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: footerHeightNotifier,
              builder: (context, FOOTERHEIGHT, child) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  bottom: FOOTERHEIGHT + 195, 
                  child: GestureDetector(
                    onTap: () {
                      if(products.isEmpty) return; // Non fare nulla se non ci sono prodotti
                      SHOWOVERLAY = false;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.9, // 👈 70% dell'altezza dello schermo
                            child: Container(
                              color: backgroundColor,
                              width: width(context, 100),
                              child: SizedBox(
                            width: width(context, 100),
                            child: SbTabCustomMulti(
                              collaborators: collaborators,
                              elements: products,
                              tabs: productsCategories,
                              loadData: loadData,
                              typeElement: 'products',
                            ),
                                                      ),
                            )
                          );
                        },
                      );
                    },

                    child: Container(
                      height: 60,
                      width: width(context, 100),
                      decoration: BoxDecoration(
                        color: products.isEmpty ? Colors.grey : mainColor,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aquista',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: products.isEmpty ? Colors.grey[400] : Colors.white,
                                fontSize: textMidHight
                              ),
                            ),
                            Icon(
                              FontAwesomeIcons.martiniGlass,
                              color: products.isEmpty ? Colors.grey[400] : Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: footerHeightNotifier,
              builder: (context, FOOTERHEIGHT, child) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  bottom: FOOTERHEIGHT + 260, 
                  child: GestureDetector(
                    onTap: () {
                      SHOWOVERLAY = false;
                      Navigator.pushNamed(context, '/gallery',arguments: {'eventId': eventId,});
                    },
                    child: Container(
                      height: 60,
                      width: width(context, 100),
                      decoration: BoxDecoration(
                        color: mainColor,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gallery',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: textMidHight
                              ),
                            ),
                            Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          content: Center(
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
                if(loader == false)
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 250,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImageFullscreen(imageUrl: "${event['cover_image_url']}"),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: "${event['cover_image_url']}",
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    width: width(context, 90),
                                    "${event['cover_image_url']}",
                                    height: 250,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/sballando_no_photo.jpeg",
                                        height: 250,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final eventUrl = 'https://webservice.sballando.it/event.html?id=$eventId';
                                final message = 'Ciao! Guarda questo evento su Sballando: $eventUrl';
                                final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
                                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                              },


                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5000),
                                  color: Colors.white,
                                ),   
                                margin: EdgeInsets.all(10),
                                child: Center(child: Padding(
                                  padding: EdgeInsets.only(right: 3),
                                  child: Icon(Icons.share,size: 25,color: mainColor,),
                                )),
                              ),
                            ) 
                          ),
                          Positioned(
                            top: 0,
                            right: 50,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5000),
                                color: Colors.white,
                              ),   
                              margin: EdgeInsets.all(10),
                              child: SbFavoriteButton(
                                initialIsLiked: favorite.isNotEmpty ? true : false,
                                onChanged: (a) async{
                                  if(a){
                                    dynamic data = await ApiEvent().addFavoriteEvent(event['id']);
                                    if(data['status'] != false){
                                    
                                    }
                                  }else{
                                    dynamic data = await ApiEvent().removeFavoriteEvent(event['id']);
                                    if(data['status'] != false){
                                      
                                    }
                                  }
                                  return true;
                                },
                              ),
                            ) 
                          ),
                          if(participants.length > 10)
                          Positioned(
                            right: 0,
                            left: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return Container(
                                      color: backgroundColorTheme,
                                      child: FractionallySizedBox(
                                        heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.list),
                                                  Text(
                                                    'Partecipanti all\'evento',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: textMidHight,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  IconButton(
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    }, 
                                                    icon: Icon(CupertinoIcons.xmark)
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: height(context, 80),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    if(partecipantVisibles > 0)
                                                    Text(
                                                      '${partecipantVisibles.toString()} : Partecipanti invisibili',
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontSize: textMid
                                                      ),
                                                    ),
                                                    ...List.generate(
                                                      participants.isNotEmpty ? participants.length : 1,
                                                      (index) {
                                                      
                                                        if(participants.isEmpty || participants.isEmpty){
                                                          return Container(
                                                            padding: EdgeInsets.all(10),
                                                            child: Text('Ancora nessun partecipante')
                                                          );
                                                        }else{
                                                          return 
                                                            participants[index]['user']!= null && participants[index]['user']['visibility'] == 1
                                                            ? Container(
                                                                padding: EdgeInsets.symmetric(vertical: 5),
                                                                child: SbCardUser(user: participants[index]['user'], onAir: participants[index]['burned'].toString() == '1' ? true : false)
                                                              )
                                                            : Container();
                                                        }
                                                      }
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            
                                          ],
                                        )
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                                  color: mainColor.withAlpha(170),
                                ),   
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people, color: Colors.white,),
                                  SizedBox(width: 8,),
                                  Text('${participants.length}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,fontSize: textMidHight),),
                                  SizedBox(width: 8,),
                                  Text('Partecipanti',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,fontSize: textMidHight),),
                                  
                                ],
                              ),
                              ),
                            ) 
                          )
                        ],
                      ),


                      SizedBox(height: 20,),
                      //////////////////////////////////
                      /// GENERI MUSICALI
                      //////////////////////////////////
                      
                      if(event['datetime_end'] != null && event['datetime_end'] != '' && parseServerDateTime(event['datetime_end']).isBefore(DateTime.now()))
                      SbButtonMaincolor(label: 'Galleria', function: (){Navigator.pushNamed(context, '/gallery',arguments: {'eventId': eventId, 'event': event});}, fullWidth: true, color: mainColor,),
                      SizedBox(height: 20,),

                      if(event['qr_enter'] != null && onAir == false)
                      Container(
                        width: width(context, 100),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: mainColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: mainColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: mainColor,
                              size: 30,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'Per accedere all\'evento è necessario scannerizzare il QR code all\'ingresso',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: textMid,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(event['qr_enter'] != null)
                      SizedBox(height: 20,),
                      
                      SizedBox(
                        width: width(context, 100),
                        child: Wrap(
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          
                          children: [
                          
                            ...List.generate(
                              event['music_genres'] != null ? event['music_genres'].length : 0 ,
                              (index) {
                                return Container(
                                  margin: EdgeInsets.only(right: 5),
                                  padding: EdgeInsets.only(top: 2,bottom: 2,right: 10,left: 10),
                                  decoration: BoxDecoration(
                                    color: mainColor,
                                    borderRadius: BorderRadius.circular(rounded30)
                                  ),
                                  child: Text(
                                    '♫ ${event['music_genres'][index]['label']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: textMid,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10,bottom: 10),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.calendar_month, size: textMidHight, color: textColor,),
                                          SizedBox(width: 5,),
                                          Text(
                                            '${getDayFromIsoString(event['datetime_start'])}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMidHight,
                                              fontWeight: FontWeight.w400
                                            ),
                
                                          ),
                                          SizedBox(width: 5,),
                                          Text(
                                            '${getShortMonth(event['datetime_start'])}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMidHight,
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Text(
                                            '${getHour(event['datetime_start'])}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMidHight,
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${event['title']}'.toUpperCase(),
                                        style: TextStyle(
                                          
                                          color: mainColor,
                                          fontSize: textHight,
                                          fontWeight: FontWeight.w700
                                        ),
                                        textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${event['subtitle']}',
                                        textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                    ],
                                  )
                                ),
                                
                              ],
                            ),
                            SizedBox(height: 20,),  
                            Column(
                              children: [
                                Row(
                                  children: [
                                    if(event['dress_code'] != null && event['dress_code'] != '')
                                    Container(
                                      width: 120,
                                      height: 120,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1, color: textColor.withAlpha(20)),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '👔',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textHight,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          Text(
                                            '${event['dress_code']}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMid,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          Text(
                                            'Dress Code',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textLow,
                                              fontWeight: FontWeight.w300
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    if(event['age_recommended'] != null && event['age_recommended'] != '')
                                    Container(
                                      width: 120,
                                      height: 120,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1, color: textColor.withAlpha(20)),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '🎂',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textHight,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          Text(
                                            '${event['age_recommended']}',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMid,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          Text(
                                            'Età consigliata',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textLow,
                                              fontWeight: FontWeight.w300
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                              ],
                            ),
                            SizedBox(height: 20,),  

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                
                                    SizedBox(
                                      width: width(context, 85),
                                      child: Text(
                                        '${event['description_extended']}',
                                        maxLines: 20,
                                        style: TextStyle(
                                          fontSize: textMid,
                                          fontWeight: FontWeight.w500,
                                          color: textColor
                                        ),
                                        textAlign: TextAlign.start, // 👈 centra il testo
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20,),
                            if(notificationRequest.isNotEmpty)
                
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10,),
                                Divider(height: 1,color: backgroundColorTheme,),
                                SizedBox(height: 10,),
                                Container(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    'La tua richiesta di ingresso: ${notificationRequest['title']} è in attesa di risposta',
                                    style: TextStyle(
                                      color: mainColor,
                                      fontSize: textMid,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                SbButtonMaincolor(
                                  label: 'ANNULLA',
                                  fullWidth: true,
                                  color: mainColor.withAlpha(200),
                                  function: () async{
                                    Modals().showMessageConfirme(
                                      context,
                                      'Annulla',
                                      'Vuoi annullare la richiesta?',
                                      () async{
                                        Navigator.pop(context);
                                        setState(() {
                                          
                                        });
                                        Modals().loader(context);
                                        dynamic data = await ApiEvent().deleteNotificationEntryType(notificationRequest['entry_type_id']);
                                        if(data['status'] != false){
                                          loadData();
                                          Navigator.pop(context);
                                          Modals().showMessage(context, 'success', 'HAI ANNULLATO LA RICHIESTA ');
                                          await loadData();
                                          setState(() {
                                          
                                          });
                                          Navigator.pop(context);
                
                                        }else{
                                          Modals().showMessage(context, 'error', '${data['error']}');
                                        }
                                      },
                                      (){
                                        Navigator.pop(context);
                                      }
                                    );
                                   
                                  },
                                ),
                              ],
                            ),
                            
                            if(entryTypeOwned['paid'] == 'pending')
                
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10,),
                                Divider(height: 1,color: backgroundColorTheme,),
                                SizedBox(height: 10,),
                                Container(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    'Hai un ingresso in attesa di essere pagato',
                                    style: TextStyle(
                                      color: mainColor,
                                      fontSize: textMid,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                SbButtonMaincolor(
                                  fullWidth: true,
                                  label: 'PAGA',
                                  function: () async{
                                    Navigator.pushNamed(context, '/checkout', arguments: {'entry_type' : entryTypeOwned});
                                  },
                                ),
                              ],
                            ),
                                  
                            if(entryTypeOwned.isNotEmpty && areCollaborator == false && areOwner == false && parseServerDateTime(event['datetime_end']).isAfter(DateTime.now())
                            //  && (entryTypeOwned['price'] != null ? entryTypeOwned['paid'] == 'paid' : true) 
                            && !onAir)
                            Column(
                              children: [
                                SbButtonMaincolor(
                                  fullWidth: true,
                                  label: 'ANNULLA ISCRIZIONE',
                                  color: mainColor.withAlpha(200),
                                  function: () async{
                                    Modals().showMessageConfirme(
                                      context, 
                                      'Annulla', 
                                      'Vuoi annullare la partecipaione all\'evento', 
                                      () async{
                                        Modals().loader(context);
                                        dynamic data = await ApiEvent().unsubscribe(event['id']);
                                        if(data != null && data['status'] != null && data['status'] == true){
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Modals().showMessage(context, 'success', 'HAI ANNULLATO L\'ISCRIZIONE ALL\'EVENTO');
                                          await loadData();
                                          setState(() {
                                          
                                          });
                                        }else{
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                
                                          Modals().showMessage(context, 'error', '${data['error']}'.toUpperCase());
                                          await loadData();
                                          setState(() {
                                          
                                          });
                                        }
                                      }, 
                                      (){
                                        Navigator.pop(context);
                                      }
                                    );
                                  },
                                ),
                                // Text('Ticket evento',style: TextStyle(color: textColorSecondary,fontWeight: FontWeight.w300),),
                              ],
                            ),

                            SizedBox(height: 20,),
                           
                            if(onAir && products.isNotEmpty)
                            SbButtonMaincolor(
                              fullWidth: true,
                              label: 'Acquista Prodotti', 
                              function: (){
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                                      child: Container(
                                        color: backgroundColor,
                                        width: width(context, 100),
                                        child: SizedBox(
                                      width: width(context, 100),
                                      child: SbTabCustomMulti(
                                        collaborators: collaborators,
                                        elements: products,
                                        tabs: productsCategories,
                                        loadData: loadData,
                                        typeElement: 'products',
                                      ),
                                    ),
                                      )
                                    );
                                  },
                                );
                              
                              }
                            ),
                          ],
                        ),
                      ),

                      Divider(),
                      SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Dove si tiene l\'evento',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: textMid,
                              fontWeight: FontWeight.w300
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      SbCardLocation(location: location,map: true,),
                      SizedBox(height: 20,),

                      if( organizzatore.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 5,),
                              Text(
                                'Chi ha organizzato l\'evento',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: textMid,
                                  fontWeight: FontWeight.w300
                                ),
                              ),
                            ],
                          ),
                          
                        ],
                      ),

                      
                      SizedBox(height: 5,),
                      if( organizzatore.isNotEmpty)
                      SbCardUser(user: organizzatore),
                      SizedBox(height: 10,),



                      if(specialGuest.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(CupertinoIcons.star, size: 20,color: mainColor,),
                          SizedBox(width: 5,),
                          Text(
                            'Ospiti',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: textMid,
                              fontWeight: FontWeight.w300
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      if(specialGuest.isNotEmpty)
                      Column(
                        children: [
                          ...List.generate(
                            specialGuest.length,
                            (index){
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: SbCardUser(user: specialGuest[index])
                              );
                            }
                          )
                        ],
                      ),


                      if(collaborators.isNotEmpty && collaborators.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 5,),
                              Text(
                                'I collaboratori',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: textMid,
                                  fontWeight: FontWeight.w300
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = true;
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: width(context, 100),
                                    height: 55,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: backgroundColor,
                                    ),
                                  ),
                                  ...List.generate(
                                    collaborators.isNotEmpty ? collaborators.length : 0,
                                    (index_){
                                      Map partecipante = collaborators[index_];
                                      int margin =  26 * index_;
                                      return Positioned(
                                        top: 10,
                                        bottom: 10,
                                        left: index_ == 0 ? 10 : double.tryParse(margin.toString()),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(500),
                                          child: 
                                          partecipante['picture'] != null && partecipante['picture'].isNotEmpty && partecipante['visibility'] == 1
                                          ? Image.network(
                                            "$BASE_URL${partecipante['picture']}${ver()}",
                                            height: 35,
                                            width: 35,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              // Se si verifica un errore di rete o altro, usa l'immagine di fallback
                                              return Image.asset(
                                                NOPHOTO,
                                                width: 35,
                                                height: 35,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                          : Image.asset(
                                            NOPHOTO,
                                            width: 35,
                                            height: 35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }
                                  )
                                ],
                              ),
                            ),
                            secondChild: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = false;
                                });
                              },
                              child: Container(
                                width: width(context, 100),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: backgroundColor,

                                  ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...List.generate(
                                        collaborators.isNotEmpty ? collaborators.length : 0,
                                        (index_){
                                          Map partecipante = collaborators[index_];
                                          return GestureDetector(
                                            onTap: (){
                                              Navigator.pushNamed(context, '/profile',arguments: { 'nickname' : partecipante['nickname']});
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 2),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(500),
                                                    child: 
                                                    partecipante['picture'] != null && partecipante['picture'].isNotEmpty && partecipante['visibility'] == 1
                                                    ? Image.network(
                                                      "$BASE_URL${partecipante['picture']}${ver()}",
                                                      height: 35,
                                                      width: 35,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        // Se si verifica un errore di rete o altro, usa l'immagine di fallback
                                                        return Image.asset(
                                                          NOPHOTO,
                                                          width: 35,
                                                          height: 35,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      NOPHOTO,
                                                      width: 35,
                                                      height: 35,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: 20,),
                                                  Text(
                                                    '@${partecipante['nickname']}',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: textMid,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      )

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                        ],
                      ),
        
                      SizedBox(height: 100,),
                
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        

        if(onAir || areCollaborator || areOwner || SHOWOVERLAY == true)
        ValueListenableBuilder<double>(
          valueListenable: footerHeightNotifier,
          builder: (context, FOOTERHEIGHT, child) {
            return AnimatedPositioned(
              duration: Duration(milliseconds: 300),
               bottom: FOOTERHEIGHT + MediaQuery.of(context).padding.bottom,
              child: GestureDetector(
                onTap: () {
                  SHOWOVERLAY = !SHOWOVERLAY;
                  setState(() {
                    
                  });
                },
                child: Container(
                  width: width(context, 100),
                  height: 60,
                  decoration: BoxDecoration(
                    color: mainColor,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lobby',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: textMidHight
                          ),
                        ),
                        Icon(
                          SHOWOVERLAY == true ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_up,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            );
          }
        ),
        if(loader == false && entryTypeOwned.isEmpty && areCollaborator == false && areOwner == false && pendingNotification == false && entry_types.length > 0)
        ValueListenableBuilder<double>(
          valueListenable: footerHeightNotifier,
          builder: (context, FOOTERHEIGHT, child) {
            return AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: FOOTERHEIGHT + 30,
              child: GestureDetector(
                onTap: () {
                  if(entryTypeTableUser.isNotEmpty &&  entryTypeOwned.isEmpty && areCollaborator == false && areOwner == false && pendingNotification == false){
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                          color: backgroundColor,
                        ),
                        width: width(context, 100),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SbButtonMaincolor(
                              label: 'Ottieni un ingresso', 
                              function: (){
                                if (USER.isNotEmpty && LOGIN == true) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                                        child: SbTabCustomMulti(
                                          collaborators: collaborators,
                                          elements: entry_types,
                                          tabs: categories,
                                          loadData: loadData,
                                          typeElement: 'entry_types',
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  Modals().showMessage(
                                    context,
                                    'error',
                                    'Effettua il login per poter usare questa funzionalità!',
                                  );
                                }  
                              },
                              fullWidth: true,
                            ),
                            if(entryTypeTableUser.isNotEmpty &&  entryTypeOwned.isEmpty && areCollaborator == false && areOwner == false && pendingNotification == false)
                            SbButtonMaincolor(
                              label: 'Unisciti a un gruppo', 
                              function: (){
                                if (USER.isNotEmpty && LOGIN == true) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                                        child: Container(
                                          color: backgroundColorTheme,
                                          child: SbTicketGroupList(
                                            entryTypeTableUser: entryTypeTableUser,
                                            ticketSelect:ticketSelect,
                                            ticketSelectMap: ticketSelectMap,
                                            loadData: loadData,
                                          ),
                                        )
                                      );
                                    },
                                  );

                                } else {
                                  Modals().showMessage(
                                    context,
                                    'error',
                                    'Effettua il login per poter usare questa funzionalità!',
                                  );
                                }
                              },
                              fullWidth: true,
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                );
              }else{
                if (USER.isNotEmpty && LOGIN == true) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                        child: SbTabCustomMulti(
                          collaborators: collaborators,
                          elements: entry_types,
                          tabs: categories,
                          loadData: loadData,
                          typeElement: 'entry_types',
                        ),
                      );
                    },
                  );
                } else {
                  Modals().showMessage(
                    context,
                    'error',
                    'Effettua il login per poter usare questa funzionalità!',
                  );
                }  
              }
            },
                child: Container(
                  width: width(context, 100),
                  height: 60,
                  decoration: BoxDecoration(
                    color: mainColor,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Partecipa  ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: textMidHight
                          ),
                        ),
                        Icon(
                          CupertinoIcons.ticket,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                )
              ),
          );
        }
      ),

      

        // if((onAir || areCollaborator || areOwner) && !parseServerDateTime(event['datetime_start']).isAfter(DateTime.now()) && parseServerDateTime(event['datetime_end']).isAfter(DateTime.now()))
        // Positioned(
        //   bottom: 170,right: 20,
        //   child:  Container(
        //     padding: EdgeInsets.all(15),
        //     decoration: BoxDecoration(
        //       color: mainColor,
        //       borderRadius: BorderRadius.circular(200)
        //     ),
        //     child: GestureDetector(
        //       onTap: () {
        //         if(USER['visibility'] == 0){
        //           Modals().showMessage(context, 'error', 'Attivare la visibilità dell\'account per accedere alla chat!');
        //         }else{
        //           Navigator.pushNamed(context, '/eventListChat');
        //         }
        //         EVENTONAIR = event;
        //         setState(() {
                  
        //         });
        //       },
        //       child: Icon(
        //         Icons.message,
        //         color: Colors.white,
        //         size: 30,
        //       )
        //     ),
        //   ),
        // ),
        
        
        // if(kDebugMode)
        // AnimatedPositioned(
        //   duration: Duration(microseconds: 300),
        //   bottom: 170,left: 20,
        //   child:  GestureDetector(
        //     onTap: () {
        //       EVENTONAIR = event;
        //       Navigator.pushNamed(context, '/eventListChat', arguments: { eventId: event['id']});
        //     },
        //     child: Container(
        //       padding: EdgeInsets.all(15),
        //       decoration: BoxDecoration(
        //         color: mainColor,
        //         borderRadius: BorderRadius.circular(200)
        //       ),
        //       child: Icon(
        //         Icons.chat, 
        //         color: Colors.white,
        //         size: 30,
        //       )
        //     ),
        //   ),
        // ),



        if(entryTypeOwned.isNotEmpty && areCollaborator == false && areOwner == false 
        // && (entryTypeOwned['price'] != null ? entryTypeOwned['paid'] == 'paid' : true) 
        && !onAir && parseServerDateTime(event['datetime_end']).isAfter(DateTime.now()))
        Positioned(
          bottom: 170,right: 20,
          child:  GestureDetector(
            onTap: () {
              Modals().modalQrCode(context, 'ticket', USER['id'],entryTypeOwned['event_id'], entryTypeOwned, event);
            },
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(200)
              ),
              child: Icon(
                Icons.qr_code, 
                color: Colors.white,
                size: 30,
              )
            ),
          ),
        ),


        if(entryTypeOwned['paid'] == 'pending')
        Positioned(
          bottom: 170,right: 20,
          child:  GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/checkout', arguments: {'entry_type' : entryTypeOwned});
            },
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(200)
              ),
              child: Icon(
                Icons.wallet, 
                color: Colors.white,
                size: 30,
              )
            ),
          ),
        ),
      ],
    );
  }
}