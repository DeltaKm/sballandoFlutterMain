import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_notifica_card.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:uuid/uuid.dart';

class SbNotification extends StatefulWidget {
  const SbNotification({super.key});

  @override
  State<SbNotification> createState() => SbNotificationState();
}

class SbNotificationState extends State<SbNotification> {
  bool      loader                          = true;
  List      notifications                   = [];
  List      getNotificationsRequest         = [];
  List      locations                       = [];
  List      users                           = [];
  int?      eventId;
  String    upKey                           = Uuid().v4();
  int? swipedNotificationId;
  Future takeNotifications() async{
    dynamic resp                            = await ApiEvent().getNotifications(1,10);
    if(resp['status'] != false){        
      notifications                         = resp['notifications'];
      loader                                = false;
    }
    setState(() {
      
    });
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      CURRENTSTATE                          = this;
      await takeNotifications();        
      UNREADNOTIFICATIONS                   = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // Altezza dell'header; supponiamo 200
    return SbScheletro(
      content: Column(
        children: [

          if(loader)
          Center(
            child: Container(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                color: mainColor,
                strokeWidth: 10, // Spessore della linea dello spinner
              ),
            ),
          ),
          if(!loader)
          ..._buildGroupedNotifications(notifications),
          if(!loader && notifications.isEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Nessuna notifica',
                  style: TextStyle(
                    color: textColor,
                    fontSize: textMid
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedNotifications(List notifications) {
  // Raggruppa le notifiche come prima
  Map<String, List> grouped = {
    'Oggi': [],
    'Ieri': [],
    'Ultimi 7 giorni': [],
    'Ultimi 30 giorni': [],
    'Meno recenti': [],
  };

  for (var notif in notifications) {
  DateTime createdAt = parseServerDateTime(notif['created_at']);
  DateTime now = DateTime.now();

  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime notifDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

  if (notifDate == today) {
    grouped['Oggi']!.add(notif);
  } else if (notifDate == yesterday) {
    grouped['Ieri']!.add(notif);
  } else {
    Duration diff = now.difference(createdAt);
    int daysAgo = diff.inDays;

    if (daysAgo <= 7) {
      grouped['Ultimi 7 giorni']!.add(notif);
    } else if (daysAgo <= 30) {
      grouped['Ultimi 30 giorni']!.add(notif);
    } else {
      grouped['Meno recenti']!.add(notif);
    }
  }
}

  final sortedKeys = ['Oggi','Ieri', 'Ultimi 7 giorni', 'Ultimi 30 giorni', 'Meno recenti'];

  List<Widget> result = [];

  for (var label in sortedKeys) {
    if (grouped[label]!.isEmpty) continue;

    result.add(Padding(
      padding: EdgeInsets.only(left: 10, top: 10,right: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      ),
    ));

    result.addAll(grouped[label]!.map((notif) {
  return Slidable(
    key: ValueKey(notif['id']),
    endActionPane: ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.25,
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(10),
          onPressed: (context) async {
            dynamic data = await ApiEvent().deleteGeneralNotification(notif['id']);
            if(data['status'] != false){
              notifications.remove(notif);
            }
            
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifica eliminata')),
            );
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Elimina',
        ),
      ],
    ),
    child: SbNotificaCard(notification: notif, refresh: takeNotifications),
  );
}).toList());
  }

  return result;
}


}


