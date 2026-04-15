import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbFooterChat extends StatefulWidget {
  const SbFooterChat({
    super.key,
  });

  @override
  State<SbFooterChat> createState() => SbFooterChatState();
}

class SbFooterChatState extends State<SbFooterChat> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor
      ),
      height: 90,
      width: width(context, 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width(context, 80), // oppure una larghezza specifica
            height: 50, // altezza definita
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: TextStyle(
                color: textColor, // Cambia qui il colore del testo
                fontSize: 16,      // Puoi anche personalizzare il font
              ),
              decoration: const InputDecoration(
                hintText: 'Scrivi un messaggio...',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: mainColor
            ),
            child: Icon(Icons.send,color: Colors.white,),
          )
        ],
        
      ),
    );
  }
}