import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sballando/api/sb_api_chat.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/sb_global.dart';
import 'package:uuid/uuid.dart';

class SbEventListChat extends StatefulWidget {
  const SbEventListChat({super.key});

  @override
  State<SbEventListChat> createState() => SbEventListChatState();
}

class SbEventListChatState extends State<SbEventListChat> {
  String                                searchQuery               = "";
  
  final     ScrollController            _scrollController         = ScrollController();
  final     TextEditingController       messageController         = TextEditingController();

  bool                                  loader                    = false;
  bool                                  newMessagePublic          = false;
  bool                                  newMessagePrivate         = false;

  int                                   maleCount                 = 0;
  int                                   femaleCount               = 0;
  int                                   usersLiveCount            = 0;

  List                                  events                    = [];
  List                                  locations                 = [];
  List                                  users                     = [];
  List                                  collaborators             = [];
  List                                  usersLive                 = [];
  List                                  messages                  = [];

  String                                newMessage                = '';
  String                                upKey                     = Uuid().v4();

  void loadData() async{
    dynamic data = await ApiChat().getUsersLive(EVENTONAIR['id']);
      if(data['status'] != false){
        usersLive = data['users'];
        loader = false;
      }
      setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      CURRENTSTATE = this;
      dynamic data = await ApiChat().getUsersLive(EVENTONAIR['id']);
      if(data['status'] != false){
        usersLive = data['users'];
        loader = false;

        if(data['users'].isNotEmpty){
          data['users'].forEach((u){
            if(u['gender'] == 'M'){
              maleCount++;
            }else if(u['gender'] == 'F'){
              femaleCount++;
            }
          });
        }
        if(data['collaborators'].isNotEmpty){
          collaborators = data['collaborators'];
          data['collaborators'].forEach((u){
            if(u['gender'] == 'M'){
              maleCount++;
            }else if(u['gender'] == 'F'){
              femaleCount++;
            }
          });
        }
      }
      setState(() {
        
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = 80;
    const double footerHeight = 100.0;
    
    final filteredCollaborators = collaborators.where((collab) {
      final fullName = "${collab['name']} ${collab['surname']}".toLowerCase();
      return fullName.contains(searchQuery.toLowerCase());
    }).toList();

    final filteredParticipants = usersLive.where((p) {
      final fullName = "${p['name']} ${p['surname']}".toLowerCase();
      return fullName.contains(searchQuery.toLowerCase());
    }).toList();

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Container(
          child: Scaffold(
            backgroundColor: backgroundColorTheme,
            body: Container(
              width: width(context, 100),
              height: height(context, 100),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    // Contenuto scrollabile
                    Padding(
                      padding: EdgeInsets.only(
                        top: headerHeight,
                        bottom: footerHeight,
                      ),
                      child: Column(
                        children: [
                          // LOADER
                          if(loader == true)
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(
                                color: mainColor,
                                strokeWidth: 10,
                              ),
                            ),
                          ),
                
                          // PULSANTI AZIONI
                          // Container(
                          //   padding: EdgeInsets.symmetric(vertical: 10),
                          //   decoration: BoxDecoration(
                          //     color: mainColor.withAlpha(20),
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     children: [
                          //       // Jukebox
                          //       SizedBox(
                          //         width: 80,
                          //         child: Column(
                          //           children: [
                          //             ElevatedButton(
                          //               style: ElevatedButton.styleFrom(
                          //                 backgroundColor: mainColor,
                          //                 shape: const CircleBorder(),
                          //                 padding: const EdgeInsets.all(8),
                          //               ),
                          //               onPressed: () {
                          //                 Navigator.pushNamed(context, '/jukebox');
                          //               },
                          //               child: const Icon(Icons.music_note, color: Colors.white, size: 30),
                          //             ),
                          //             Text('Jukebox', style: TextStyle(
                          //               color: textColor,
                          //               fontSize: textMid,
                          //               fontWeight: FontWeight.w600
                          //             )),
                          //           ],
                          //         ),
                          //       ),
                          //       // Gallery
                          //       SizedBox(
                          //         width: 80,
                          //         child: Column(
                          //           children: [
                          //             ElevatedButton(
                          //               style: ElevatedButton.styleFrom(
                          //                 backgroundColor: mainColor,
                          //                 shape: const CircleBorder(),
                          //                 padding: const EdgeInsets.all(8),
                          //               ),
                          //               onPressed: () {
                          //                 Navigator.pushNamed(context, '/gallery');
                          //               },
                          //               child: const Icon(Icons.image, color: Colors.white, size: 30),
                          //             ),
                          //             Text('Gallery', style: TextStyle(
                          //               color: textColor,
                          //               fontSize: textMid,
                          //               fontWeight: FontWeight.w600
                          //             )),
                          //           ],
                          //         ),
                          //       ),
                          //       // Chat
                          //       SizedBox(
                          //         width: 80,
                          //         child: Column(
                          //           children: [
                          //             ElevatedButton(
                          //               style: ElevatedButton.styleFrom(
                          //                 backgroundColor: mainColor,
                          //                 shape: const CircleBorder(),
                          //                 padding: const EdgeInsets.all(8),
                          //               ),
                          //               onPressed: () {
                          //                 Navigator.pushNamed(context, '/eventChat');
                          //               },
                          //               child: const Icon(Icons.message, color: Colors.white, size: 30),
                          //             ),
                          //             Text('Chat', style: TextStyle(
                          //               color: textColor,
                          //               fontSize: textMid,
                          //               fontWeight: FontWeight.w600
                          //             )),
                          //           ],
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/eventChat');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: mainColor,
                                borderRadius: BorderRadius.circular(10),
                
                              ),
                              width: width(context, 100),
                              margin: EdgeInsets.only(top: 20,left: 20,right: 20),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text('Entra in chat pubblica', style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textMidHight,
                                  fontWeight: FontWeight.w700
                                )),
                              ),
                            ),
                          ),
                
                          // TAB MULTI
                
                          SbTabMulti(
                            firstLabel: 'Partecipanti', 
                            secondLabel: 'Collaboratori', 
                            firstContent: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Cerca partecipante...",
                                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                                // Lista dei partecipanti
                                ...filteredParticipants.map((participant) {
                                  final index = filteredParticipants.indexOf(participant);
                                  return Slidable(
                                    key: Key('participant_${participant['id']}_$index'), // Chiave unica
                                    child: GestureDetector(
                                      onTap: () {
                                        if (USER['id'] != participant['id']) {
                                          Navigator.pushNamed(
                                            context,
                                            '/eventPrivateChat',
                                            arguments: {'user': participant},
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: index != 0
                                                ? BorderSide(
                                                    color: const Color.fromARGB(255, 192, 192, 192).withAlpha(50),
                                                    width: 1.0,
                                                  )
                                                : BorderSide.none,
                                            bottom: BorderSide(
                                              color: const Color.fromARGB(255, 192, 192, 192).withAlpha(50),
                                              width: filteredParticipants.length == index + 1 ? 1 : 0,
                                            ),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Row(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(500),
                                                        border: Border.all(width: 1, color: mainColor),
                                                      ),
                                                      width: 50,
                                                      height: 50,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(500),
                                                        child: Image.network(
                                                          '$BASE_URL${participant['picture']}${ver()}',
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Image.asset(
                                                              NOPHOTO,
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    if (participant['last_message_read'].toString() == '1')
                                                      Positioned(
                                                        top: 11,
                                                        right: 11,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: greenColor,
                                                            borderRadius: BorderRadius.circular(434),
                                                          ),
                                                          width: 13,
                                                          height: 13,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            USER['id'] == participant['id'] ? 'Tu' : '${participant['name']} ${participant['surname']}',
                                                            style: TextStyle(
                                                              color: textColor,
                                                              fontSize: textMid,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                          ),
                                                          if (participant['muted'] == true)
                                                            const Icon(Icons.volume_off),
                                                        ],
                                                      ),
                                                      Text(
                                                        USER['id'] == participant['id'] ? '' : '${participant['last_message'] ?? ''}',
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: textColorSecondary,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 10,
                                              child: Text(
                                                participant['last_message_date'] != null ? extractTime(participant['last_message_date']) : '',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: textMid,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                            secondContent: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Cerca collaboratore...",
                                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                      },
                                    ),
                                  ),
                                  // Lista collaboratori
                                  ...filteredCollaborators.map((collaborator) {
                                    final index = filteredCollaborators.indexOf(collaborator);
                                    return Slidable(
                                      key: Key('collaborator_${collaborator['id']}_$index'), // Chiave unica
                                      child: GestureDetector(
                                        onTap: () {
                                          if (USER['id'] != collaborator['id']) {
                                            Navigator.pushNamed(
                                              context,
                                              '/eventPrivateChat',
                                              arguments: {'user': collaborator},
                                            );
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: index != 0
                                                  ? BorderSide(
                                                      color: const Color.fromARGB(255, 192, 192, 192).withAlpha(50),
                                                      width: 1.0,
                                                    )
                                                  : BorderSide.none,
                                              bottom: BorderSide(
                                                color: const Color.fromARGB(255, 192, 192, 192).withAlpha(50),
                                                width: filteredCollaborators.length == index + 1 ? 1 : 0,
                                              ),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Row(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(500),
                                                          border: Border.all(width: 1, color: mainColor),
                                                        ),
                                                        width: 50,
                                                        height: 50,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(500),
                                                          child: Image.network(
                                                            '$BASE_URL${collaborator['picture']}${ver()}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Image.asset(
                                                                NOPHOTO,
                                                                width: 50,
                                                                height: 50,
                                                                fit: BoxFit.cover,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      if (collaborator['last_message_read'].toString() == '1')
                                                        Positioned(
                                                          top: 11,
                                                          right: 11,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: greenColor,
                                                              borderRadius: BorderRadius.circular(434),
                                                            ),
                                                            width: 13,
                                                            height: 13,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              USER['id'] == collaborator['id'] ? 'Tu' : '${collaborator['name']} ${collaborator['surname']}',
                                                              style: TextStyle(
                                                                color: textColor,
                                                                fontSize: textMid,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                            ),
                                                            if (collaborator['muted'] == true) const Icon(Icons.volume_off),
                                                          ],
                                                        ),
                                                        Text(
                                                          USER['id'] == collaborator['id'] ? '' : '${collaborator['last_message'] ?? ''}',
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            color: textColorSecondary,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 10,
                                                child: Text(
                                                  collaborator['last_message_date'] != null ? extractTime(collaborator['last_message_date']) : '',
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: textMid,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ),
                
                    // HEADER
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
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
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded( // Aggiungi Expanded qui
                                                    child: Text(
                                                      '${EVENTONAIR['title']}',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: mainColor,
                                                        fontSize: textHight,
                                                        fontWeight: FontWeight.w700
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                          
                                                children: [
                                                  Text(
                                                    '$maleCount',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: textMidHight,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Icon(Icons.male,size: 30,color: maleColor,),
                                                  Text(
                                                    '$femaleCount',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: textMidHight,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Icon(Icons.female,size: 30,color: femaleColor,),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
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
