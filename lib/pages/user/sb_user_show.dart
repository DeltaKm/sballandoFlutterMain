import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_image_full_screen.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/components/sb_switch.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/components/sb_ticket.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SbProfile extends StatefulWidget {
  const SbProfile({super.key});

  @override
  State<SbProfile> createState() => SbProfileState();
}

class SbProfileState extends State<SbProfile> {
  String?   userNickname;
  Map       user                          = {};
  List      entry_types                   = [];
  List      entry_collaborator            = [];
  bool      auth                          = false;
  bool      activeButtonAnimated          = false;
  bool      loader                        = true;
  bool      seguito                       = false;
  bool      blocked                       = false;

  void showColorPickerModal(BuildContext context, void Function(Color) onColorSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: backgroundColor,
      builder: (context) {
   

        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Scegli un colore',
                      style: TextStyle(
                        color: textColor,
                        fontSize: textMid,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SbSwitch(label: 'thema', value: true)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 30,
                  runSpacing: 30,
                  children: COLORS.map((color) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // chiude la modale
                        onColorSelected(color); // callback
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      loadData();
    });
  }

  loadData() async{
    dynamic args        = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      userNickname            = args['nickname'];
      dynamic data            = await ApiUser().getUser(userNickname!); // Recupero l'utente
      if(data != null && data['user'] != null){
        loader        = false;
        user          = data['user'];
        blocked       = data['blocked'] ?? false;
        seguito       = data['user']['is_followed'];
        auth          = data['auth'];
        // se sono nel mio profilo
        if(auth == true){
          USER = data['user'];
          saveShared('json', data['user'], 'user');
          
          dynamic dataEventOnAir = await ApiUser().searchActiveEvent(); // controllo se sono onair ad un evento
          if(dataEventOnAir['status'] != false){
            ONAIR = true;
            EVENTONAIR = dataEventOnAir['active_event'];
            saveShared('json', EVENTONAIR, 'onair');
          }
        }
        entry_collaborator = data['event_collaborator'] ?? [];
        entry_types = data['entry_types'];
        entry_types.sort((a, b) {
          final eventA = a['event'];
          final eventB = b['event'];
          if (eventA != null && eventB != null) {
            final startA = eventA['datetime_start'];
            final startB = eventB['datetime_start'];
            if (startA != null && startB != null) {
              final dateA = parseServerDateTime(startA);
              final dateB = parseServerDateTime(startB);
              return dateB.compareTo(dateA); // decrescente
            }
          }
          // fallback: quelli con eventi null o date null vanno in fondo
          if (eventA == null && eventB == null) return 0;
          if (eventA == null) return 1;
          if (eventB == null) return -1;
          return 0;
        });
      }else{
      
      }
      if(mounted){
        setState(() {});
      }
    }else{
      userNickname            = USER['nickname'];
      dynamic data            = await ApiUser().getUser(userNickname!);
      if(data != null && data['user'] != null){
        loader = false;
        user = data['user'];
        seguito = data['user']['is_followed'];
        auth = data['auth'];
        // se sono nel mio profilo
        if(auth == true){
          USER = data['user'];
          saveShared('json', USER, 'user');
          dynamic dataEventOnAir = await ApiUser().searchActiveEvent(); // controllo se sono onair ad un evento
          if(dataEventOnAir['status'] != false){
            ONAIR = true;
            EVENTONAIR = dataEventOnAir['active_event'];
            saveShared('json', EVENTONAIR, 'onair');
          }
        }
        entry_types = data['entry_types'];
      }else{
        LOGIN         = false;
        ONAIR         = false;
        USER          = {};
        EVENTONAIR    = {};
        TOKEN_JWT     = '';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('user');
        await prefs.remove('token_jwt');
        await prefs.remove('onair');
        SHOWOVERLAY = false;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (Route<dynamic> route) => false, // Rimuove tutte le route precedenti
        );
        setState(() {
                  
        });
      }
      if(mounted){
        setState(() {});
      }
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Set<String> addedIds = {};

    return Stack(
      children: [
        SbScheletro(
          buttons: [
            Positioned(
              bottom: 245,right: 20,
              child:  Row(
                children: [
                  Text('Logout',style: TextStyle(color: Colors.white, fontSize: textMid,fontWeight: FontWeight.w500),),
                  SizedBox(width: 10,),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(200)
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Modals().showMessageConfirme(
                          context, 
                          'Logout', 
                          'Vuoi eseguire il logout?', 
                          () async{
                            LOGIN         = false;
                            ONAIR         = false;
                            USER          = {};
                            EVENTONAIR    = {};
                            TOKEN_JWT     = '';
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.remove('user');
                            await prefs.remove('token_jwt');
                            await prefs.remove('onair');
                            SHOWOVERLAY = false;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (Route<dynamic> route) => false, // Rimuove tutte le route precedenti
                            );
                            setState(() {
                  
                            });
                          }, 
                          (){
                            Navigator.pop(context);
                          }
                        );
                      },
                      child: Icon(
                        Icons.logout, 
                        color: Colors.white,
                        size: 35,
                      )
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 305,right: 20,
              child:  Row(
                children: [
                  Text('Colori',style: TextStyle(color: Colors.white, fontSize: textMid,fontWeight: FontWeight.w500),),
                  SizedBox(width: 10,),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(200)
                    ),
                    child: GestureDetector(
                      onTap: () {
                        SHOWOVERLAY = false;
                        showColorPickerModal(context, (selectedColor) {
                          mainColor = selectedColor;
                          saveShared('int', selectedColor.value, 'mainColor');
                          setState(() {
                  
                          });
                        });
                      },
                      child: Icon(
                        Icons.color_lens, 
                        color: Colors.white,
                        size: 35,
                      )
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 365,right: 20,
              child:  Row(
                children: [
                  Text('Crea Evento',style: TextStyle(color: Colors.white, fontSize: textMid,fontWeight: FontWeight.w500),),
                  SizedBox(width: 10,),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(200)
                    ),
                    child: GestureDetector(
                        onTap: () async{
                        SHOWOVERLAY = false;
                        final Uri uri = Uri.parse('https://backend.sballando.it');
                        await launchUrl(uri, mode: LaunchMode.externalApplication); 
                      },
                      child: Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                        size: 35,
                      )
                    ),
                  ),
                ],
              ),
            ),
          ],
          animatedButton:  true,
          animatedButtonFunction: (){
            SHOWOVERLAY = !SHOWOVERLAY;
          },
          animatedButtonIcon: Icon(Icons.settings,color: Colors.white,size: 35,),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Column(
                children: [
                  
                  SizedBox(height: 80,),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none, // permette all'immagine di uscire dal Container
                      alignment: Alignment.topCenter, // centra orizzontalmente
                      children: [
                        Container(
                          width: width(context, 90),
                          padding: EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 30), // spazio per lasciare la foto sopra
                              Text(
                                '${user['name'] ?? ''} ${user['surname'] ?? ''}',
                                style: TextStyle(
                                  fontSize: textHight,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 10), // spazio per lasciare la foto sopra
                              if(user['bio'] != null && user['bio'].isNotEmpty)
                              Text(
                                'Biografia',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: textMidHight,
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if(user['bio'] != null && user['bio'].isNotEmpty)
                              Text(
                                '${user['bio']}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: textMid
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10), // spazio per lasciare la foto sopra

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  if(user['gender'] == 'M')
                                  Icon(Icons.male,size: textHight,color: mainColor,),
                                  if(user['gender'] == 'F')
                                  Icon(Icons.female,size: textHight,color: mainColor,),
                                  
                                  Text(
                                    '@${user['nickname']}',
                                    style: TextStyle(
                                      fontSize: textHight,
                                      fontWeight: FontWeight.w400,
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),

                              if((user['region'] != null && user['region'].isNotEmpty )&& (user['city'] != null && user['city'].isNotEmpty))
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on,color: mainColor,size: textMid,),
                                  Wrap(
                                    children: [
                                      Text(
                                        '${user['region'] ?? ''} , ${user['city'] ?? ''}',
                                        style: TextStyle(
                                          color: textColorSecondary,
                                          fontSize: textMid
                                        ),
                                      ),
                                    ],
                                  )
                              
                                ],
                              ),
                              
                              SizedBox(height: 10,),
                              Divider(height: 1,color: backgroundColorTheme,),
                              SizedBox(height: 10,),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context,'/userFairplay',arguments: { 'id' : user['id']});
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          '${user['fairplay_collaborator']}',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Text(
                                          'fair play col',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w300,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 50,),
                                  
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/userFairplay',arguments: {'id' : user['id']});
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${user['fairplay']}',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Text(
                                          'fair play',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w300,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(width: 50,),
                                    
                                        
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pushNamed(context,'/userFollowers',arguments: { 'id' : user['id']});
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          '${user['following_count']}',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Text(
                                          'following',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w300,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 50,),
                                  
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pushNamed(context,'/userFollowers',arguments: { 'id' : user['id']});
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          '${user['followers_count']}',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Text(
                                          'followers',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w300,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if(auth == false)
                              SizedBox(height: 20,),

                              if(auth == false && seguito == false)
                              SbButtonMaincolor(label: 'SEGUI', function: () async{
                                if(LOGIN == false){
                                  Modals().showMessage(context, 'error', 'Devi effettuare prima il Login'); 
                                  return;
                                } 
                                loader =  true;
                                setState(() {
                                  
                                });
                                dynamic data = await ApiUser().setFollower(user['id']);
                                if(data['status'] != false){
                                  dynamic data            = await ApiUser().getUser(userNickname!);
                                  if(data != null && data['user'] != null){
                                    loader          = false;
                                    user            = data['user'];
                                    auth            = data['auth'];
                                    seguito         = data['user']['is_followed'];
                                    entry_types     = data['entry_types'];
                                  }
                                  loader = false;

                                  setState(() {
                                    
                                  });
                                }else{
                                  loader = false;
                                  Modals().showMessage(context, 'error', '${data['error']}');
                                }
                              }),

                              if(auth == false && seguito == true)
                              SbButtonMaincolor(label: 'NON SEGUIRE PIU', function: () async{
                                loader =  true;
                                setState(() {
                                  
                                });
                                dynamic data = await ApiUser().setUnFollower(user['id']);
                                if(data['status'] != false){
                                  dynamic data            = await ApiUser().getUser(userNickname!);
                                  if(data != null && data['user'] != null){
                                    loader          = false;
                                    user            = data['user'];
                                    seguito         = data['user']['is_followed'];
                                    auth            = data['auth'];
                                    entry_types     = data['entry_types'];
                                  }
                                  loader = false;
                                  setState(() {
                                    
                                  });
                                }
                              }),

                              SizedBox(height: 30,),
                              Text('♫ generi musicali',style: TextStyle(color: textColorSecondary, fontWeight: FontWeight.w400),),
                              SizedBox(height: 10,),
                  
                              Wrap(
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ...List.generate(
                                    user['music_genres'] != null ? user['music_genres'].length : 0 ,
                                    (index) {
                                      return Container(
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.only(top: 2,bottom: 2,right: 10,left: 10),
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius: BorderRadius.circular(rounded30)
                                        ),
                                        child: Text(
                                          '♫ ${user['music_genres'][index]['label']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: textMid,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                ],
                              ),

                              SizedBox(height: 20,),
                              if((user['link_instagram'] != null && user['link_instagram'].isNotEmpty) || (user['link_tiktok'] != null && user['link_tiktok'].isNotEmpty) || (user['phone'] != null && user['phone'].isNotEmpty))
                              Text('Contatti',style: TextStyle(color: textColorSecondary, fontWeight: FontWeight.w400),),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(user['link_instagram'] != null && user['link_instagram'].isNotEmpty)
                                  IconButton(onPressed: () async{ final Uri uri = Uri.parse('${user['link_instagram']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.instagram, size: 30,color: mainColor,)),
                                  if(user['link_tiktok'] != null && user['link_tiktok'].isNotEmpty)
                                  IconButton(onPressed: () async{ final Uri uri = Uri.parse('${user['link_tiktok']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.tiktok, size: 30,color: mainColor,)),
                                  if(user['phone'] != null && user['phone'].isNotEmpty)
                                  IconButton(onPressed: () async{ final Uri uri = Uri.parse('https://wa.me/${user['phone']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.whatsapp, size: 30,color: mainColor,)),
                                ],
                              )
                            ],
                          ),
                        ),
                  
                        // Foto sopra
                        Positioned(
                          top: -70,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageFullscreen(
                                    imageUrl: "$BASE_URL${user['picture']}${ver()}",
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: "$BASE_URL${user['picture']}${ver()}",
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: mainColor,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: Image.network(
                                    "$BASE_URL${user['picture']}${ver()}",
                                    height: 140,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "$NOPHOTO",
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if(auth == true)
                        Positioned(
                          top: 20,right: 20,
                          child:  Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  SHOWOVERLAY = false;
                                  Navigator.pushNamed(context, '/userEdit', arguments: {'nickname': userNickname});
                                },
                                child: Icon(
                                  Icons.edit, 
                                  color: mainColor,
                                  size: 35,
                                )
                              ),
                            ],
                          ),
                        ),
                        if(USER.isNotEmpty && USER['id'] != user['id'])
                        Positioned(
                          top: 10,
                          right: 10,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: mainColor, size: textHight),
                            onSelected: (String value) {

                              if (value == 'Segnala') {
                                Modals().reportUserModal(
                                  context, 
                                  'Segnala Utente',
                                  user['id'].toString()
                                );
                                // Puoi mostrare un dialog, snackbar o chiamare una funzione
                              } else if (value == 'Blocca') {
                                Modals().showMessageConfirme(
                                  context, 
                                  'Blocca Utente', 
                                  'Vuoi bloccare questo utente?', 
                                  ()async{
                                    dynamic data = await ApiUser().blockUser(user['id'].toString());
                                    Navigator.pop(context);
                                    if(data['status'] == true){
                                      Modals().showMessage(
                                        context, 
                                        'success', 
                                        'L\'utente è stato bloccato ora non potrai piu inviargli e ricevere messaggi', 
                                      );
                                    }else{
                                      Modals().showMessage(
                                        context, 
                                        'error', 
                                        '${data['error']}', 
                                      );
                                    }
                                    loadData();
                                  }, 
                                  (){
                                    Navigator.pop(context);
                                  }
                                );
                              } else if (value == 'Sblocca') {
                                Modals().showMessageConfirme(
                                  context, 
                                  'Sblocca Utente', 
                                  'Vuoi sbloccare questo utente?', 
                                  ()async{
                                    dynamic data = await ApiUser().unblocked(user['id'].toString());
                                    Navigator.pop(context);
                                    if(data['status'] == true){
                                      
                                      Modals().showMessage(
                                        context, 
                                        'success', 
                                        'L\'utente è stato sbloccato ora potrai inviargli e ricevere messaggi', 
                                      );
                                    }else{
                                      Modals().showMessage(
                                        context, 
                                        'error', 
                                        '${data['error']}', 
                                      );
                                    }
                                    loadData();
                                  }, 
                                  (){
                                    Navigator.pop(context);
                                  }
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'Segnala',
                                child: Text('Segnala'),
                              ),
                              if(blocked == false)
                              PopupMenuItem<String>(
                                value: 'Blocca',
                                child: Text('Blocca utente'),
                              ),
                              if(blocked == true)
                              PopupMenuItem<String>(
                                value: 'Sblocca',
                                child: Text('Sblocca utente'),
                              ),
                            ],
                          ),
                        )

                        
                      ],
                    ),
                  ),
              
                  
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Eventi',
                      style: TextStyle(
                        color: textColor,
                        fontSize: textHight,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  Container(
                    width: width(context, 90),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SbTabMulti(
                      firstLabel: 'Partecipa a...',
                      secondLabel: 'Collabora a...',
                      firstContent: Column(
                        children: [
                          ...List.generate(
                            entry_types.isNotEmpty ? entry_types.length : 0,
                            (index) {
                              final entry = entry_types[index];
                              return SbTicket(ticket: entry);
                            },
                          ),
                          if(entry_types.isNotEmpty)
                          SizedBox(height: 10),                          
                          if(entry_types.isEmpty)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Row(
                              children: [
                                Text('Ancora nessun evento...',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: textMid
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      secondContent: Column(
                        children: [
                          ...List.generate(
                            entry_collaborator.isNotEmpty ? entry_collaborator.length : 0,
                            (index) {
                              return SbTicket(ticket: entry_collaborator[index]);
                            }
                          ),
                          if(entry_collaborator.isNotEmpty)
                          SizedBox(height: 10),                          
                          if(entry_collaborator.isEmpty)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Row(
                              children: [
                                Text('Ancora nessun evento...',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: textMid
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                ],
              ),
              
        
            ],
          ), 
        ),
        
        // if(auth)
        

        
      ],
    );
  }
}


List<Widget> buildTickets(List entryTypes, Map user) {
  Set<String> addedIds = {};

  // Filtra gli eventi validi dell'utente
  final validEntries = entryTypes.where((entry) {
    final event = entry['event'];

    // Protezione: se event è null, skippa
    if (event == null) return false;

    // Protezione: assicura che collaborators_id sia una lista
    final collaborators = event['collaborators_id'];
    final collaboratorsList =
        (collaborators is List) ? collaborators : <dynamic>[];

    final userId = user['id'].toString();

    // Controlla se l'utente è collaboratore o proprietario
    final isCollaborator = collaboratorsList.contains(userId);
    final isOwner = event['user_id']?.toString() == userId;

    return isCollaborator || isOwner;
  }).where((entry) {
    final event = entry['event'];
    if (event == null) return false;

    // Protezione: evita duplicati
    final eventId = event['id']?.toString();
    if (eventId == null || addedIds.contains(eventId)) return false;

    addedIds.add(eventId);
    return true;
  }).toList();

  // Se non ci sono eventi validi
  if (validEntries.isEmpty) {
    return [
      Container(
        padding: EdgeInsets.all(40),
        child: Row(
          children: [
            Text(
              'Ancora nessun evento...',
              style: TextStyle(color: textColor, fontSize: textMid),
            ),
          ],
        ),
      )
    ];
  }

  // Genera i widget SbTicket in modo sicuro
  return [
    ...validEntries.map((entry) {
      // Eventuale protezione extra: se l'evento è nullo, salta
      final event = entry['event'];
      if (event == null) return const SizedBox.shrink();

      // Se serve, puoi anche filtrare per campi obbligatori come cover_img_url
      // if (event['cover_img_url'] == null) return const SizedBox.shrink();

      return SbTicket(ticket: entry);
    }),
    const SizedBox(height: 10),
  ];
}
