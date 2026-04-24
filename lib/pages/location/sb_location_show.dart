import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sballando/api/sb_api_location.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_image_full_screen.dart';
import 'package:sballando/components/sb_map.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/components/sb_ticket.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:url_launcher/url_launcher.dart';

class SbLocationShow extends StatefulWidget {
  const SbLocationShow({super.key});

  @override
  State<SbLocationShow> createState() => SbLocationShowState();
}

class SbLocationShowState extends State<SbLocationShow> {
  int?              locationId;
  bool              loader              = true;
  Map               location            = {};
  bool              auth                = false;
  List              pastEvents          = [];
  List              upcomingEvents      = [];
  double            latitude            = 0;
  double            longitude           = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args == null || args['locationId'] == null) {
        loader = false;
        if (mounted) {
          setState(() {});
        }
        return;
      }

      locationId = args['locationId'];
      dynamic data          = await ApiLocation().getLocation(locationId!);
      dynamic dataEvents    = await ApiLocation().fetchUpcomingPastEvent(locationId!);
      if (dataEvents != null && dataEvents['status'] != false) {
        final pastRaw = dataEvents['pastEvents'];
        final upcomingRaw = dataEvents['upcomingEvents'];

        pastEvents = pastRaw is List ? pastRaw : [];
        upcomingEvents = upcomingRaw is List ? upcomingRaw : [];
      }
      if(data != null && data['status'] != null){
        location            = data['location'];
        auth                = data['auth'];

        final coordinate = data['location']?['coordinates'];
        if (coordinate is String && coordinate.contains(',')) {
          final parts = coordinate.split(',');
          if (parts.length >= 2) {
            latitude = double.tryParse(parts[0].trim()) ?? 0;
            longitude = double.tryParse(parts[1].trim()) ?? 0;
          }
        }
      }
      loader = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SbScheletro(
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
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 30), // spazio per lasciare la foto sopra
                          Text(
                            '${location['name']} ',
                            style: TextStyle(
                              fontSize: textHight,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          // Text(
                          //   'BAR',
                          //   style: TextStyle(
                          //     fontSize: textMidHight,
                          //     fontWeight: FontWeight.w400,
                          //     color: mainColor,
                          //   ),
                          // ),
                          
                          SizedBox(height: 10,),
                          Divider(height: 1,color: grayLight,),
                          SizedBox(height: 10,),
              
                          Wrap(
                            children: [
                              Text(
                                '${location['description']}',
                                maxLines: 10,
                                textAlign: TextAlign.center, // 👈 centra il testo
                                style: TextStyle(
                                  fontSize: textLowMid,
                                  fontWeight: FontWeight.w300,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
            
                          SizedBox(height: 10,),
                          Divider(height: 1,color: grayLight,),
                          SizedBox(height: 10,),
            
                     
                          

                          if(latitude != 0 && longitude != 0)
                          Container(
                            child: MapWidget(
                              latitude: latitude, 
                              longitude: longitude,
                            ),
                          ),
                          
                          SizedBox(height: 10,),
                          SbButtonMaincolor(
                            label: 'Apri nelle mappe', 
                            function: () async{
                              try{
                                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }catch(e){
                                print(e);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossibile aprire la mappa')));
                              }
                                
                            }
                          ),

                          SizedBox(height: 10,),
                          Divider(height: 1,color: grayLight,),
                          SizedBox(height: 10,),


                          Row( 
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Contatti',
                                maxLines: 3,
                                style: TextStyle(
                                  color: mainColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: textMidHight,
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: 10,),
                          
                          Row( 
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.home, color: mainColor,size: textHight),
                              SizedBox(width: 5,),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      '${location['address']}, ${location['comune']} (${location['provincia_sigla']})',
                                      maxLines: 3,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: textMid,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.email, color: mainColor,size: textHight),
                              SizedBox(width: 5,),
                              Text(
                                '${location['email']}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: textMid,
                                ),
                              )
                            ],
                          ),

                          GestureDetector(
                            onTap: () async{
                              final Uri url = Uri(scheme: 'tel', path: location['phone']);
                              try{
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }catch(e){
                                print(e);
                              }
                              
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.phone, color: mainColor,size: textHight),
                                SizedBox(width: 5,),
                                Text(
                                  '${location['phone']}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: textMid,
                                  ),
                                )
                              ],
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(location['link_instagram'] != null && location['link_instagram'].isNotEmpty)
                              IconButton(onPressed: () async{ final Uri uri = Uri.parse('${location['link_instagram']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.instagram, size: 30)),
                              if(location['link_tiktok'] != null && location['link_tiktok'].isNotEmpty)
                              IconButton(onPressed: () async{ final Uri uri = Uri.parse('${location['link_tiktok']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.tiktok, size: 30)),
                              if(location['phone'] != null && location['phone'].isNotEmpty)
                              IconButton(onPressed: () async{ final Uri uri = Uri.parse('https://wa.me/${location['phone']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.whatsapp, size: 30)),
                              if(location['link_facebook'] != null && location['link_facebook'].isNotEmpty)
                              IconButton(onPressed: () async{ final Uri uri = Uri.parse('${location['link_facebook']}');  await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: FaIcon(FontAwesomeIcons.facebook, size: 30)),
                            ],
                          ),

                          SizedBox(height: 10,),
                          Divider(height: 1,color: grayLight,),
                          SizedBox(height: 10,),

                          if(location['gallery'].isNotEmpty)
                          SizedBox(
                            width: width(context, 90),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...List.generate(
                                    location['gallery'].length, 
                                    (index){
                                      final imageUrl = location['gallery'][index];
                                      return GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ImageFullscreen(
                                                imageUrl: imageUrl,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag: imageUrl,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: 10),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                imageUrl,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    "assets/images/sballando_no_photo.jpeg",
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  )
                                ],
                              ),
                            ),
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
                                imageUrl: "${location['logo']}",
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: "${location['logo']}",
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
                                "${location['logo']}",
                                height: 140,
                                width: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/sballando_no_photo.jpeg",
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
                    
                  ],
                ),
              ),
          
              SizedBox(height: 50,),
              
             
              Container(
                width: width(context, 90),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: SbTabMulti(
                  firstLabel: 'Prossimi eventi', 
                  secondLabel: 'Storico eventi',
                  secondContent: Column(
                    children: [
                      if(pastEvents.isEmpty)
                      Text(
                        'Nessun evento passato'
                      ),
                      ...List.generate(
                        pastEvents.isNotEmpty ? pastEvents.length : 0,
                        (index) {
                          pastEvents[index]['location'] = Map;
                          pastEvents[index]['location'] = location;
                          Map event = {
                            'event' : pastEvents[index]
                          };
                          return SbTicket(ticket: event);
                        }
                      ),
                      SizedBox(height: 20,),
                      if(pastEvents.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Text('Ancora nessun evento...',
                          style: TextStyle(
                            color: textColor,
                            fontSize: textMid
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                  firstContent: Column(
                    children: [
                      
                      ...List.generate(
                         upcomingEvents.isNotEmpty ? upcomingEvents.length : 0,
                        (index) {
                          upcomingEvents[index]['location'] = Map;
                          upcomingEvents[index]['location'] = location;
                          Map event = {
                            'event' : upcomingEvents[index]
                          };
                          return SbTicket(ticket: event);
                        }
                      ),
                      SizedBox(height: 20,),
                      if(upcomingEvents.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Text('Ancora nessun evento...',
                          style: TextStyle(
                            color: textColor,
                            fontSize: textMid
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]
      ),
    );
  }
}