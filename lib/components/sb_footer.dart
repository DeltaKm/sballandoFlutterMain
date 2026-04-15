import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbFooter extends StatefulWidget {
  const SbFooter({
    super.key,
  });

  @override
  State<SbFooter> createState() => SbFooterState();
}

class SbFooterState extends State<SbFooter> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor
      ),
      height: FOOTERHEIGHT,
      width: width(context, 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            elevation: FOOTERSELECT == 'wallet' ? 2.0 : 0,
            borderRadius: BorderRadius.circular(5000),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: FOOTERSELECT == 'wallet' ? mainColor : backgroundColor,
                borderRadius: BorderRadius.circular(5000)
              ),
              child: IconButton(
                onPressed: () async{
                  if(REF_CONTROLLER_QRCODE != null){
                    await REF_CONTROLLER_QRCODE!.stopScan();
                    await REF_CONTROLLER_QRCODE!.dispose();
                  }
                  if(USER.isNotEmpty && LOGIN == true){
                    FOOTERSELECT = 'wallet';
                    Navigator.pushNamed(
                      context,
                      '/wallet',
                      arguments: {'page' : 'ticket'},
                    );
                  }else{
                    Modals().showMessage(context, 'error', 'Effettua il login per poter usare questa funzionalità!');
                  }
                  
                  setState(() {});
                }, 
                icon: Icon(Icons.wallet,size: FOOTERSELECT == 'wallet' ? 28 : 24, color: DARKMODE == true ? FOOTERSELECT == 'wallet' ? Colors.black : Colors.white :  FOOTERSELECT == 'wallet' ? Colors.white : Colors.black,)
              ),
            ),
          ),
          Material(
            elevation: FOOTERSELECT == 'qrCode' ? 2.0 : 0,
            borderRadius: BorderRadius.circular(5000),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: FOOTERSELECT == 'qrCode' ? mainColor : backgroundColor,
                borderRadius: BorderRadius.circular(5000)
              ),
              child: IconButton(
                onPressed: ()async {
                  if(USER.isNotEmpty && LOGIN == true){
                    FOOTERSELECT = 'qrCode';
                    await Navigator.pushNamed(
                      context, '/qrScanner',
                    );
                    if(REF_CONTROLLER_QRCODE != null){
                      await REF_CONTROLLER_QRCODE!.stopScan();
                      await REF_CONTROLLER_QRCODE!.dispose();
                    }
                  }else{
                    Modals().showMessage(context, 'error', 'Effettua il login per poter usare questa funzionalità!');
                  }
                  setState(() {});
                }, 
                icon: Icon(Icons.qr_code,size: FOOTERSELECT == 'qrCode' ? 28 : 24, color: DARKMODE == true ? FOOTERSELECT == 'qrCode' ? Colors.black : Colors.white :  FOOTERSELECT == 'qrCode' ? Colors.white : Colors.black,)
              ),
            ),
          ),
          Material(
            elevation: FOOTERSELECT == 'home' ? 2.0 : 0,
            borderRadius: BorderRadius.circular(5000),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: FOOTERSELECT == 'home' ? mainColor : backgroundColor,
                borderRadius: BorderRadius.circular(5000)
              ),
              child: IconButton(
                onPressed: () async {
                  if(REF_CONTROLLER_QRCODE != null){
                    await REF_CONTROLLER_QRCODE!.stopScan();
                    await REF_CONTROLLER_QRCODE!.dispose();
                  }
                  FOOTERSELECT = 'home';
                  Navigator.pushNamed(context,'/home');
                  setState(() {});
                }, 
                icon: Icon(CupertinoIcons.home,size: FOOTERSELECT == 'home' ? 28 : 24, color: DARKMODE == true ? FOOTERSELECT == 'home' ? Colors.black : Colors.white :  FOOTERSELECT == 'home' ? Colors.white : Colors.black,)
              ),
            ),
          ),
          if(EVENTONAIR.isNotEmpty)
          Material(
            elevation: FOOTERSELECT == 'eventListChat' ? 2.0 : 0,
            borderRadius: BorderRadius.circular(5000),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: FOOTERSELECT == 'eventListChat' ? mainColor : backgroundColor,
                borderRadius: BorderRadius.circular(5000)
              ),
              child: IconButton(
                onPressed: () async{
                      // Navigator.pushNamed(context, '/eventListChat');

                  if(REF_CONTROLLER_QRCODE != null){
                    await REF_CONTROLLER_QRCODE!.stopScan();
                    await REF_CONTROLLER_QRCODE!.dispose();
                  }
                  FOOTERSELECT = 'eventListChat';
                  if(USER.isNotEmpty &&  EVENTONAIR.isNotEmpty){
                    if(USER['visibility'] == 0){
                      Modals().showMessage(context, 'error', 'Attivare la visibilità dell\'account per accedere alla chat!');
                    }else{
                      Navigator.pushNamed(context, '/eventListChat');
                    }

                  }else{
                    Modals().showMessage(context, 'error', 'Solo i partecipanti vidimati possono accedere alla chat dell’evento.');
                  }
                  
                  setState(() {});
                }, 
                icon: Icon(Icons.message_outlined,size: FOOTERSELECT == 'eventListChat' ? 28 : 24, color: DARKMODE == true ? FOOTERSELECT == 'eventListChat' ? Colors.black : Colors.white :  FOOTERSELECT == 'eventListChat' ? Colors.white : Colors.black,)
              ),
            ),
          ),
          Material(
            elevation: FOOTERSELECT == 'info' ? 2.0 : 0,
            borderRadius: BorderRadius.circular(5000),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: FOOTERSELECT == 'info' ? mainColor : backgroundColor,
                borderRadius: BorderRadius.circular(5000)
              ),
              child: IconButton(
                onPressed: () async{
                  if(REF_CONTROLLER_QRCODE != null){
                    await REF_CONTROLLER_QRCODE!.stopScan();
                    await REF_CONTROLLER_QRCODE!.dispose();
                  }
                  FOOTERSELECT = 'info';
                  Navigator.pushNamed(
                    context, '/info',
                  );
                  setState(() {});
                }, 
                icon: Icon(Icons.help_outline,size: FOOTERSELECT == 'info' ? 28 : 24, color: DARKMODE == true ? FOOTERSELECT == 'info' ? Colors.black : Colors.white :  FOOTERSELECT == 'info' ? Colors.white : Colors.black,)
              ),
            ),
          ),
        ],
      ),
    );
  }
}