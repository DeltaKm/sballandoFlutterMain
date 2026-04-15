import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbUserFairplay extends StatefulWidget {
  const SbUserFairplay({super.key});

  @override
  State<SbUserFairplay> createState() => SbUserFairplayState();
}

class SbUserFairplayState extends State<SbUserFairplay> {

  List      fairplays                           = [];
  List      fairplaysCollaborator               = [];
  String    userId                              = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      dynamic args        = ModalRoute.of(context)!.settings.arguments;
      if (args != null) {
        userId            = args['id'].toString();
      }
      
      Map data        = await ApiUser().getFairplaylist(userId);
      Map dataColl    = await ApiUser().getFairplayCollaboratorlist(userId);

      
      if(data.isNotEmpty && data['status'] == true){
        fairplays = data['data'];
        fairplays.sort((a, b) {
          final dateA = parseServerDateTime(a['created_at']);
          final dateB = parseServerDateTime(b['created_at']);
          return dateB.compareTo(dateA); // decrescente
        });
      }

      if (dataColl.isNotEmpty && dataColl['status'] == true) {
  final List<dynamic> fairplays = dataColl['data'];

  // Ordina per created_at decrescente
  fairplays.sort((a, b) {
    final dateA = parseServerDateTime(a['created_at']);
    final dateB = parseServerDateTime(b['created_at']);
    return dateB.compareTo(dateA);
  });

  // Raggruppa per event_id e somma i punti
  final Map<String, Map<String, dynamic>> grouped = {};

  for (var item in fairplays) {
    final eventId = item['event_id'].toString();
    final points = (item['points'] is num)
        ? item['points'] as num
        : num.tryParse(item['points'].toString()) ?? 0;

    if (!grouped.containsKey(eventId)) {
      grouped[eventId] = {
        'event_id': eventId,
        'event': item['event'], // Prendi da uno qualsiasi, tanto è uguale
        'points': 0,
      };
    }

    grouped[eventId]!['points'] += points;
  }

  // Converti la mappa in una lista
  fairplaysCollaborator = grouped.values.toList();
}



      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SbScheletro(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SbTabMulti(
                firstLabel: 'FAIRPLAY', 
                secondLabel: 'F.P. COLLAB', 
                firstContent: SizedBox(
                  height: height(context, 60), // ⬅️ Questa riga risolve il problema
                  child: ListView.builder(
                    itemCount: fairplays.isNotEmpty ? fairplays.length : 0,
                    itemBuilder: (context, index) {
                      Map fairplay = fairplays[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/eventShow',arguments: {'eventId' : fairplay['event']['id']});
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: backgroundColor
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                                child: Image.network(
                                  "${fairplay['event'] != null ? BASE_URL + fairplay['event']['cover'] : ''}",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/sballando_no_photo.jpeg",
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${fairplay['event']?['title'] ?? ''}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            Text(
                                              '${fairplay['event']?['subtitle'] ?? ''}',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: textLowMid,
                                                fontWeight: FontWeight.w300
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${int.parse(fairplay['points'].toString()) > 0 ? '+ ${fairplay['points']}' : fairplay['points'].toString() }',
                                        style: TextStyle(
                                          color: int.parse(fairplay['points'].toString()) > 0 ? Colors.green : int.parse(fairplay['points'].toString()) < 0 ? Colors.red : textColor,
                                          fontSize: textHight,
                                          fontWeight: FontWeight.w800
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                secondContent: SizedBox(
                  height: height(context, 60), // ⬅️ Questa riga risolve il problema
                  child: ListView.builder(
                    itemCount: fairplaysCollaborator.isNotEmpty ? fairplaysCollaborator.length : 0,
                    itemBuilder: (context, index) {
                      Map fairplay = fairplaysCollaborator[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/eventShow',arguments: {'eventId' : fairplay['event']['id']});
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: backgroundColor
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                                child: Image.network(
                                  "${fairplay['event'] != null && fairplay['event']['cover'] != null ? BASE_URL + fairplay['event']['cover'] : ''}",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/sballando_no_photo.jpeg",
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${fairplay['event'] != null ? fairplay['event']['title'] : ''}',
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            Text(
                                              '${fairplay['event'] != null ? fairplay['event']['subtitle'] : ''}',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: textLowMid,
                                                fontWeight: FontWeight.w300
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${int.parse(fairplay['points'].toString()) > 0 ? '+ ${fairplay['points']}' : fairplay['points'].toString() }',
                                        style: TextStyle(
                                          color: int.parse(fairplay['points'].toString()) > 0 ? Colors.green : int.parse(fairplay['points'].toString()) < 0 ? Colors.red : textColor,
                                          fontSize: textHight,
                                          fontWeight: FontWeight.w800
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ]
          ), 
        ),
      ],
    );
  }
}