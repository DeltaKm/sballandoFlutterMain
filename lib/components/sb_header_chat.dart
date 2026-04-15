

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sballando/sb_global.dart';

class SbHeaderChat extends StatefulWidget {
  bool?         home      = false;
  Function?     loadData;

  SbHeaderChat({
    super.key,
    this.home,
    this.loadData,
  });

  @override
  State<SbHeaderChat> createState() => SbHeaderChatState();
}

class SbHeaderChatState extends State<SbHeaderChat> {
  int usersLive = 3;


  @override
  Widget build(BuildContext context) {
    return Column(
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
                    Navigator.pushNamed(context, '/home');
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${EVENTONAIR['title']}',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: textHight,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          Text(
                            '$usersLive utenti live',
                            style: TextStyle(
                              color: textColor,
                              fontSize: textMid,
                              fontWeight: FontWeight.w600

                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: (){
                      Navigator.pushNamed(
                        context, '/notification',
                        arguments: {'page' : 'generali'}
                      );
                    },
                    icon: Icon(CupertinoIcons.list_bullet, size: 30,color: mainColor),
                  ),
                  SizedBox(width: 20,)
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}