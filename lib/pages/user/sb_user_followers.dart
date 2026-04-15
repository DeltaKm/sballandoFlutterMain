import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_card_user.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbUserFollowers extends StatefulWidget {
  const SbUserFollowers({super.key});

  @override
  State<SbUserFollowers> createState() => SbUserFollowersState();
}

class SbUserFollowersState extends State<SbUserFollowers> {

  List      seguiti         = [];
  List      follower        = [];
  String    userId          = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      dynamic args        = ModalRoute.of(context)!.settings.arguments;
      if (args != null) {
        userId            = args['id'].toString();
      }
      
      Map dataSeguiti = await ApiUser().getSeguiti(userId);
      Map dataFollower = await ApiUser().getFollower(userId);
      
      if(dataSeguiti.isNotEmpty && dataSeguiti['status'] == true){
        seguiti = dataSeguiti['followers'];
      }
      if(dataFollower.isNotEmpty && dataFollower['status'] == true){
        follower = dataFollower['followers'];
      }
      setState(() {
        
      });
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
                firstLabel: 'FOLLOWER', 
                secondLabel: 'SEGUITI', 
                firstContent: SizedBox(
                  height: height(context, 60), // ⬅️ Questa riga risolve il problema
                  child: ListView.builder(
                    itemCount: follower.length,
                    itemBuilder: (context, index) {
                      return Container(
                        
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: SbCardUser(user: follower[index])
                      );
                    },
                  ),
                ),
                secondContent: SizedBox(
                  height: height(context, 60), // ⬅️ Questa riga risolve il problema
                  child: ListView.builder(
                    itemCount: seguiti.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: SbCardUser(user: seguiti[index])
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