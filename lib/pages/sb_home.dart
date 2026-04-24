// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/api/sb_api_location.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_card_event.dart';
import 'package:sballando/components/sb_card_location.dart';
import 'package:sballando/components/sb_card_user.dart';
import 'package:sballando/components/sb_footer.dart';
import 'package:sballando/components/sb_header.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:uuid/uuid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class SbHome extends StatefulWidget {
  const SbHome({super.key});

  @override
  State<SbHome> createState() => SbHomeState();
}

class SbHomeState extends State<SbHome> {
  final ScrollController _scrollController = ScrollController();

  bool                            _showFooter                   = true;
  bool                            _showHeader                   = true;
  bool                            filterActive                  = false;
  bool                            isLoadingMore                 = false;
  bool                            loader                        = false;
  bool                            searchActive                  = false;
  bool                            showDropdown                  = false;

  List                            events                        = [];
  List                            locations                     = [];
  List                            users                         = [];
  List<String>                    provinceList                  = [];
  List<String>                    regioniList                   = [];

  String?                         regioneValue;
  String?                         provinciaValue;
  String                          upKey                         = Uuid().v4();
  String                          searchFilter                  = '';
  String                          messageMoreResults            = 'Carica altri risultati';

  double                          _lastOffset                   = 0;
  int                             offset                        = 0; 
  TextEditingController           searchController              = TextEditingController();

  void loadData() async{
    loader = true;


    if(mounted){
      setState(() {
        
      });
    }
    
    
    if(NAVIGATIONHOME == 'users'){
      dynamic data = await ApiUser().getUsers(search: searchFilter, regione: regioneValue,provincia: provinciaValue);
      loader = false;
      if(data != null && data['users'] != null){
        users = data['users'];
      }else{
        users = [];
      } 
    }else if(NAVIGATIONHOME == 'events'){
      dynamic data = await ApiEvent().getEvents(search: searchFilter,limit: 10, regione: regioneValue,provincia: provinciaValue);
      loader = false;
      if(data != null && data['events'] != null){
        events = data['events'];
      }else{
        events = [];
      } 
    }else if(NAVIGATIONHOME == 'locations'){
      dynamic data = await ApiLocation().getLocations(search: searchFilter, regione: regioneValue,provincia: provinciaValue);
      loader = false;
      if(data != null && data['locations'] != null){
        locations = data['locations'];
      }else{
        locations = [];
      }
    }
    if(mounted){
      setState(() {
        
      });
    }
  }

  Future<bool> checkForUpdate(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String url = "https://webservice.sballando.it/version.txt";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String latestVersion = response.body.trim();

        print("Versione attuale: $currentVersion");
        print("Versione disponibile: $latestVersion");

        if (latestVersion.compareTo(currentVersion) > 0) {
          Modals().loader(context);

          // Determine platform and set store URL
          final String storeUrl = Platform.isIOS 
              ? 'https://apps.apple.com/it/app/sballando/id6749372071' // Replace with your App Store ID
              : 'https://play.google.com/store/apps/details?id=it.sballando.app'; // Replace with your Play Store ID

          Modals().modalUpdateVersion(
            context,
            'Aggiornamento disponibile',
            Platform.isIOS 
                ? 'Aggiorna l\'app dall\'App Store'
                : 'Aggiorna l\'app dal Play Store',
            webRoute: storeUrl
          );
          return true;
        } else {
          print("✅ L'app è già aggiornata.");
        }
      } else {
        print("❌ Errore nel recupero della versione: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Errore durante il controllo della versione: $e");
    }
    return false;
  }
  
  void toggleDropdown() {
    setState(() {
      showDropdown = !showDropdown;
    });
  }
  
  @override
  void initState() {
    super.initState();
    
    _scrollController.addListener(() async{
      double offsetScroll = _scrollController.offset;
      // Soglia per evitare aggiornamenti troppo frequenti
      if (offsetScroll > _lastOffset + 5) {
        // Scrolling verso il basso: nascondi header e footer
        if (_showHeader || _showFooter) {
          setState(() {
            _showHeader = false;
            _showFooter = false;
          });
        }
      } else if (offsetScroll < _lastOffset - 5) {
        // Scrolling verso l'alto: mostra header e footer
        if (!_showHeader || !_showFooter) {
          setState(() {
            _showHeader = true;
            _showFooter = true;
          });
        }
      }
      _lastOffset = offsetScroll;

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        // Siamo quasi alla fine (100px prima)
        if (!isLoadingMore) {
          setState(() {
            isLoadingMore = true;
            offset += 10;
          });
          if(NAVIGATIONHOME == 'users'){
            dynamic data = await ApiUser().getUsers(search: searchFilter, offset: offset,limit: 10, regione: regioneValue,provincia: provinciaValue);
            if(data != null && data['users'] != null){
              List newUsers = List.from(data['users']);
              // Rimuovi quelli con ID già esistente
              newUsers.removeWhere((nUser) => 
                users.any((exist) => exist['id'] == nUser['id'])
              );
              // Aggiungi solo quelli non duplicati
              users.addAll(newUsers);
              if(data['users'].isEmpty){
                messageMoreResults = 'Non ci sono nuovi risultati';
              }
            }else{
              Modals().showMessage(context, 'Errore imprevisto','error');
            }  
          }else if(NAVIGATIONHOME == 'events'){
            dynamic data = await ApiEvent().getEvents(search: searchFilter, offset: offset,limit: 10, regione: regioneValue,provincia: provinciaValue);
            if(data != null && data['events'] != null){
              List newEvents = List.from(data['events']);
              // Rimuovi quelli con ID già esistente
              newEvents.removeWhere((nEvent) => 
                events.any((exist) => exist['id'] == nEvent['id'])
              );
              // Aggiungi solo quelli non duplicati
              events.addAll(newEvents);
              if(data['events'].isEmpty){
                messageMoreResults = 'Non ci sono nuovi risultati';
              }
            }else{
              Modals().showMessage(context, 'Errore imprevisto','error');
            }
          }else if(NAVIGATIONHOME == 'locations'){
            dynamic data = await ApiLocation().getLocations(search: searchFilter, offset: offset,limit: 10, regione: regioneValue,provincia: provinciaValue);
            if(data != null && data['locations'] != null){
              List newLocations = List.from(data['locations']);
              // Rimuovi quelli con ID già esistente
              newLocations.removeWhere((nLocation) => 
                locations.any((exist) => exist['id'] == nLocation['id'])
              );
              // Aggiungi solo quelli non duplicati
              locations.addAll(newLocations);
              if(data['locations'].isEmpty){
                messageMoreResults = 'Non ci sono nuovi risultati';
              }
            }else{
              Modals().showMessage(context, 'Errore imprevisto','error');
            }
          }
          
          setState(() {
            isLoadingMore = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      checkForUpdate(context);
      FOOTERSELECT                = 'home';

      dynamic regioniData         = await ApiUser().getRegioni();

      if(regioniData != null){
        regioniData.forEach((regione){
          regioniList.add(regione['regione']);
        });
      }
      if(LOGIN == false){
        saveShared('json', {}, 'onair');
        EVENTONAIR = {};
      }
      if(EVENTONAIR != {}){
        startCheckingEvent();
      }

      CURRENTSTATE = this;
      
      Map         user            = await getShared('json', 'user') ?? {};
      String      tokenJwt       = await getShared('string', 'token_jwt') ?? '';
      EVENTONAIR                  = await getShared('json', 'onair') ?? {};
      int? colorValue             = await getShared('int', 'mainColor');
      
      if(colorValue != null){
        mainColor = Color(colorValue);
      }
      if(EVENTONAIR.isNotEmpty){
        ONAIR = true;
      }
      loadData();
      if(user.isNotEmpty && tokenJwt.isNotEmpty){
        LOGIN                       = true;
        USER                        = user;
        TOKEN_JWT                   = tokenJwt;
        dynamic dataEventOnAir      = await ApiUser().searchActiveEvent();
        if(dataEventOnAir['status'] != false){
          ONAIR                     = true;
          EVENTONAIR                = dataEventOnAir['active_event'] ?? {};
          saveShared('json', EVENTONAIR, 'onair');
        }else{
          EVENTONAIR                = {};
          ONAIR = false;
        }
        ApiUser().addTokenFireBase(FIREBASETOKEN);
      }
      
      
      if(mounted){
        setState(() {});
      }
    
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Altezza dell'header; supponiamo 200
    double headerHeight = ONAIR == true ? 170 : 120;
    // Altezza del footer (personalizza in base alle tue esigenze)
    const double footerHeight = 100.0;
    if(searchActive){
      showDropdown = searchActive;
    }
    
  return WillPopScope(
      onWillPop: () async {
      // Se non ci sono altre route da poppare
      if (!Navigator.of(context).canPop()) {
        // Fai qualcosa: per esempio, mostra un messaggio o torna alla home
        // oppure ritorna false per bloccare l’uscita
        return false;
      }
      return true; // Permette il pop
    },
    child: Container(
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
    
                    RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thumbColor: mainColor,
                      radius: Radius.circular(8),
                      thickness: 6,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(), // ← Disabilita il rimbalzo
                        controller: _scrollController,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: headerHeight,
                            bottom: footerHeight + 40,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if(loader == true)
                                
                                Container(
                                  padding: EdgeInsets.all(30),
                                  child: CircularProgressIndicator(
                                    color: mainColor,
                                    strokeWidth: 10, // Spessore della linea dello spinner
                                  ),
                                ),
                      
                                //////////////////////////////
                                /// BARRA DI RICERCA
                                ////////////////////////////// 
                      
                                // if(filterActive == true)
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   child: TextField(
                                //     style: TextStyle(
                                //       color: textColor, // Cambia qui il colore del testo
                                //       fontSize: 16,      // Puoi anche personalizzare il font
                                //     ),
                                //     controller: searchController,
                                //     onSubmitted:(_) async {
                                //       searchFilter = searchController.text;
                                //       searchActive =  false;
                                //       FocusScope.of(context).unfocus();
                                //       loadData();
                                //     },
                                //     decoration: InputDecoration(
                                //       hintText: "Cerca",
                                //       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                //       focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: mainColor, width: 2.0)),              
                                //       suffixIcon: Container(
                                //         width: 100,
                                //         child: Row(
                                //           children: [
                                //             IconButton(
                                //               icon: Icon(Icons.search),
                                //               onPressed: () async {
                                //                 searchFilter = searchController.text;
                                //                 searchActive =  false;
                                //                 FocusScope.of(context).unfocus();
                                //                 loadData();
                                //               },
                                //             ),
                                //             IconButton(
                                //               icon: Icon(CupertinoIcons.xmark),
                                //               onPressed: () async {
                                //                 searchController.text = '';
                                //                 searchFilter = '';
                                //                 searchActive =  false;
                                //                 FocusScope.of(context).unfocus();
                                //                 loadData();
                                //               },
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //       contentPadding: EdgeInsets.symmetric(
                                //         vertical: 10.0,
                                //         horizontal: 15.0,
                                //       ),
                                //       border: OutlineInputBorder(
                                //         borderRadius: BorderRadius.circular(
                                //           25.0,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                      
                      
                                //////////////////////////////
                                /// BARRA DI NAVIGAZIONE
                                ////////////////////////////// 

                                if(NAVIGATIONHOME == 'events' && events.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Nessun evento trovato',
                                    style: TextStyle(
                                      color: textColor, // Cambia qui il colore del testo
                                      fontSize: 16,      // Puoi anche personalizzare il font
                                    ),
                                  ),
                                ),
                         
                                if(NAVIGATIONHOME == 'events')
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(), // disabilita lo scroll interno
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      // child: events[index]['title'] != 'evento test' ? SbCardEvent(event: events[index]) : Container()
                                      child:  SbCardEvent(event: events[index])

                                    );
                                  }
                                ),
                                if(NAVIGATIONHOME == 'locations' && locations.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Nessun locale trovato',
                                    style: TextStyle(
                                      color: textColor, // Cambia qui il colore del testo
                                      fontSize: 16,      // Puoi anche personalizzare il font
                                    ),
                                  ),
                                ),
                                // if(NAVIGATIONHOME == 'locations')
                                // Image(image: AssetImage('assets/images/cosa-fai-stasera-logo.png'), height: 60,),
                                if(NAVIGATIONHOME == 'locations')
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(), // disabilita lo scroll interno
                                  itemCount: locations.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.all(10),
                                      child: SbCardLocation(location: locations[index])
                                    );
                                  }
                                ),
                                if(NAVIGATIONHOME == 'users' && users.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Nessun utente trovato',
                                    style: TextStyle(
                                      color: textColor, // Cambia qui il colore del testo
                                      fontSize: 16,      // Puoi anche personalizzare il font
                                    ),
                                  ),
                                ),
                                // if(NAVIGATIONHOME == 'users')
                                // Image(image: AssetImage('assets/images/cosa-fai-stasera-logo.png'), height: 60,),
                                if(NAVIGATIONHOME == 'users')
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(), // disabilita lo scroll interno
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.all(5),
                                      child: SbCardUser(user: users[index])
                                    );
                                  }
                                ),
                      
                      
                                if(isLoadingMore == true)
                                Container(
                                  padding: EdgeInsets.all(30),
                                  child: CircularProgressIndicator(
                                    color: mainColor,
                                    strokeWidth: 10, // Spessore della linea dello spinner
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ),
                      ),
                    ),

                    //////////////////////////////
                    /// HEADERR
                    ////////////////////////////// 
                    
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: _showHeader ? 0 : - headerHeight, // se _showFooter è false, sposta fuori dalla vista
                      height: 370,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          SbHeader(
                            home: true,
                            search: searchActive,
                            ricerca: Column(
                              children: [

                                ///////////////////////////////
                                /// TASTI DI NAVIGAZIONE HOME
                                ///////////////////////////////
                                
                                Container(
                                  width: width(context, 100),
                                  height: 60,
                                  color: backgroundColor,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: NAVIGATIONHOME == 'events' ? mainColor : backgroundColorTheme,
                                          elevation: 0,
                                          padding: EdgeInsets.only(top: 12,bottom: 12,left: 20,right: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(40),
                                          )
                                        ),
                                        onPressed: () async{
                                          NAVIGATIONHOME = 'events';
                                          offset = 0;
                                          searchController.text = '';
                                          searchFilter = '';
                                          searchActive =  false;
                                          FocusScope.of(context).unfocus();
                                          loadData();
                                          setState(() {});
                                        }, 
                                        child: Text(
                                          'Eventi',
                                          style: TextStyle(
                                            fontSize: textMid, 
                                            color: NAVIGATIONHOME == 'events' ? backgroundColor : const Color.fromARGB(255, 120, 120, 120),
                                            fontWeight: FontWeight.w500
                                          ),
                                        )
                                      ),
                                      
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: NAVIGATIONHOME == 'users' ? mainColor : backgroundColorTheme,
                                          elevation: 0,
                                          padding: EdgeInsets.only(top: 12,bottom: 12,left: 20,right: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(40),
                                          )
                                        ),
                                        onPressed: () async{
                                          NAVIGATIONHOME = 'users';
                                          offset = 0;
                                          searchController.text = '';
                                          searchFilter = '';
                                          searchActive =  false;
                                          FocusScope.of(context).unfocus();
                                          loadData();
                                          setState(() {});
                                        }, 
                                        child: Text(
                                          'Utenti',
                                          style: TextStyle(
                                            fontSize: textMid, 
                                            color: NAVIGATIONHOME == 'users' ? backgroundColor :  const Color.fromARGB(255, 120, 120, 120),
                                            fontWeight: FontWeight.w500
                                          ),
                                        )
                                      ),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: NAVIGATIONHOME == 'locations' ? mainColor : backgroundColorTheme,
                                          elevation: 0,
                                          padding: EdgeInsets.only(top: 12,bottom: 12,left: 20,right: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(40),
                                          )
                                        ),
                                        onPressed: (){
                                          NAVIGATIONHOME = 'locations';
                                          offset = 0;
                                          searchController.text = '';
                                          searchFilter = '';
                                          searchActive =  false;
                                          FocusScope.of(context).unfocus();
                                          loadData();
                                          setState(() {
                                
                                          });
                                        }, 
                                        child: Text(
                                          'Locali',
                                          style: TextStyle(
                                            fontSize: textMid, 
                                            color: NAVIGATIONHOME == 'locations' ? backgroundColor :  const Color.fromARGB(255, 120, 120, 120),
                                            fontWeight: FontWeight.w500
                                          ),
                                        )
                                      ),
                                      Stack(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: searchActive == true ? mainColor : backgroundColorTheme,
                                              elevation: 0,
                                              padding: EdgeInsets.only(top: 12,bottom: 12,left: 20,right: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(40),
                                              )
                                            ),
                                            onPressed: (){
                                              searchActive = !searchActive;
                                              setState(() {
                                                
                                              });
                                            }, 
                                            child: Icon(
                                              Icons.search,
                                              size: 22,
                                              color: NAVIGATIONHOME == '' ? mainColor :  searchActive == true ?  Colors.white : mainColor
                                            )
                                          ),
                                          if(searchController.text != '')
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: mainColor,
                                                borderRadius: BorderRadius.circular(500)
                                              ),
                                              width: 13,
                                              height: 13,
                                            )
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                ///////////////////////////////
                                /// FILTRI
                                ///////////////////////////////
                                if(searchActive)
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 0),
                                  height: showDropdown ? 200 : 0,
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    color: backgroundColor,
                                    child: Column(
                                      children: [

                                        ///////////////////////////////
                                        /// SEARCHBAR
                                        ///////////////////////////////
                                       
                                       ClipRect( // ← importante per evitare overflow visivi
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            heightFactor: 1.0,
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                             
                                              child: TextField(
                                                style: TextStyle(
                                                  color: textColor, // Cambia qui il colore del testo
                                                  fontSize: 16,      // Puoi anche personalizzare il font
                                                ),
                                                controller: searchController,
                                                onSubmitted:(_) async {
                                                  searchFilter = searchController.text;
                                                  searchActive =  false;
                                                  FocusScope.of(context).unfocus();
                                                  loadData();
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(500),
                                                  ),
                                                  hintText: NAVIGATIONHOME == 'events' ? "Cerca evento" : NAVIGATIONHOME == 'locations' ? "Cerca locale" : NAVIGATIONHOME == 'users' ? "Cerca utente" : '',
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: mainColor, 
                                                      width: 2.0,
                                                    ),
                                                    borderRadius: BorderRadius.circular(500),
                                                  ),              
                                                  
                                                  suffixIcon: SizedBox(
                                                    width: 100,
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons.search),
                                                          onPressed: () async {
                                                            searchFilter = searchController.text;
                                                            searchActive =  false;
                                                            FocusScope.of(context).unfocus();
                                                            loadData();
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(CupertinoIcons.xmark),
                                                          onPressed: () async {
                                                            searchController.text       = '';
                                                            searchFilter                = '';
                                                            regioneValue                = null;
                                                            provinciaValue              = null;
                                                            searchActive                = false;
                                                            FocusScope.of(context).unfocus();
                                                            loadData();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0,),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        ///////////////////////////////
                                        /// REGIONI 
                                        ///////////////////////////////
                                        
                                        Container(
                                          height: 50,
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          child: DropdownButtonFormField<String>(
                                            style: TextStyle(color: textColor),
                                            value: regioneValue,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: backgroundColor,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                                                borderRadius: BorderRadius.circular(500),

                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: grayLight), // bordo normale
                                                borderRadius: BorderRadius.circular(500),

                                              ),
                                              labelText: 'Regione',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(500),
                                              ),
                                            ),
                                            dropdownColor: backgroundColor,
                                            validator: (value) {
                                            },
                                            onChanged: (String? newValue) async{
                                              regioneValue = newValue;
                                              provinciaValue = null;
                                              List<String> provinceData = await ApiUser().getProvince(regioneValue!);
                                    
                                              if(provinceData.isNotEmpty){
                                                provinceList = provinceData;
                                              }
                                              setState(() {
                                    
                                              });
                                            },
                                            items: regioniList.map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                    
                                        SizedBox(height: 10,),
                                        
                                        ///////////////////////////////
                                        /// PROVINCE 
                                        ///////////////////////////////
                                        
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          height: 50,
                                          child: DropdownButtonFormField<String>(
                                            value: provinciaValue,
                                            dropdownColor: backgroundColor,
                                            style: TextStyle(color: textColor),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: backgroundColor,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                                                borderRadius: BorderRadius.circular(500),

                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: grayLight), // bordo normale
                                                borderRadius: BorderRadius.circular(500),

                                              ),
                                              labelText: 'Provincia',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(500),

                                              ),
                                            ),
                                            validator: (value) {
                                            },
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                provinciaValue = newValue;
                                              });
                                            },
                                            items: provinceList
                                                .map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),

                                        ///////////////////////////////
                                        /// REGIONI 
                                        ///////////////////////////////
                                      
                                        
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    
                    //////////////////////////////
                    /// FOOTER
                    //////////////////////////////
                    
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: _showFooter ? 0 : -footerHeight, // se _showFooter è false, sposta fuori dalla vista
                      left: 0,
                      right: 0,
                      height: footerHeight,
                      child: SbFooter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
  );
  }
}
