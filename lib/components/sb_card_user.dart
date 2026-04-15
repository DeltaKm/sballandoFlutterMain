import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbCardUser extends StatefulWidget {
  Map user;
  bool? onAir;
  final void Function()? onTap;
  SbCardUser({
    super.key,
    required this.user,
    this.onAir,
    this.onTap,
  });

  @override
  State<SbCardUser> createState() => SbCardUserState();
}

class SbCardUserState extends State<SbCardUser> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ??
      () {
        if(widget.user['visibility'] == 1)  Navigator.pushNamed(context,'/profile',arguments: {'nickname': widget.user['nickname']},);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(3),
        width: width(context, 90),
        child: Row(
          children: [
            Container(

              margin: EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none, 
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: 
                    widget.user['picture'] != null && widget.user['picture'].isNotEmpty && widget.user['visibility'] == 1
                    ? Image.network(
                      "$BASE_URL${widget.user['picture']}${ver()}",
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Se si verifica un errore di rete o altro, usa l'immagine di fallback
                        return Image.asset(
                          NOPHOTO,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Image.asset(
                      NOPHOTO,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if(widget.onAir != null && widget.onAir == true)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: EdgeInsets.only(top: 0,right: 5,left: 5,bottom: 0),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        'ON AIR',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.user['visibility'] != null &&  widget.user['visibility'] == 1 ? widget.user['name'] +' '+ widget.user['surname'] : 'Utente Privato'}',
                    style: TextStyle(
                      fontSize: textMid,
                      fontWeight: FontWeight.w800,
                      color: textColor
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '@${widget.user['visibility'] != null &&  widget.user['visibility'] == 1 ? widget.user['nickname'] : 'Utente Privato'}',
                        style: TextStyle(
                          fontSize: textMid,
                          fontWeight: FontWeight.w300,
                          color: widget.user['gender'] == 'M' ? maleColor : femaleColor
                        ),
                      ),
                      if(widget.user['gender'] == 'M')
                      Icon(Icons.male,size: 20, color: maleColor,),
                      if(widget.user['gender'] == 'F')
                      Icon(Icons.female,size: 20, color: femaleColor,),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: 
                        widget.user['followers'] != null ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.user['followers'].length}',
                              style: TextStyle(
                                fontSize: textLowMid,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'followers',
                              style: TextStyle(
                                fontSize: textLowMid,
                                fontWeight: FontWeight.w300,
                                color: textColor,
                              ),
                            ),
                          ]
                        )
                        : Row(
                          children: [],
                        )
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.user['fairplay']}',
                              style: TextStyle(
                                fontSize: textLowMid,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              'fair play',
                              style: TextStyle(
                                fontSize: textLowMid,
                                fontWeight: FontWeight.w300,
                                color: textColor,
                              ),
                            ),             
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}