import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_card_event_small.dart';
import 'package:sballando/components/sb_card_user.dart';
import 'package:sballando/components/sb_dashed_line.dart';
import 'package:sballando/components/sb_date_format.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbTicketWallet extends StatefulWidget {
  Map ticket;
  bool status;
  SbTicketWallet({super.key, required this.ticket, required this.status});

  @override
  State<SbTicketWallet> createState() => SbTicketWalletState();
}

class SbTicketWalletState extends State<SbTicketWallet> {
  TextEditingController searchController = TextEditingController();
  String? searchError;
  List modalUsers         = [];
  bool loader             = false;

  @override
  Widget build(BuildContext context) {
    int seats = widget.ticket['seats'] != null ? int.parse(widget.ticket['seats'].toString()) : 1;


      return GestureDetector(
        onTap: () {
          if(widget.status != false && (widget.ticket['table_owner_id'] != null || widget.ticket['stock'] == 1)){
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.9, // 👈 70% dell’altezza dello schermo
                  child: Container(
                    color: backgroundColorTheme,
                    width: width(context, 100),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            color: backgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(CupertinoIcons.ticket, size: 40,color: mainColor,),
                                Flexible(
                                  child: Text(
                                    '${widget.ticket['label']}',
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: textHight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(CupertinoIcons.xmark))
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Modals().modalQrCode(context, 'ticket',USER['id'],widget.ticket['event']['id'],widget.ticket,widget.ticket['event']);
                                  },
                                  child: Container(
                                    height: 120,
                                    margin: EdgeInsets.only(top: 20,right: 5,left: 10,bottom: 20),
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.qr_code, color: Colors.white,),
                                            SizedBox(width: 5,),
                                            Text(
                                              'QR Code',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.bold
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          'Apri il QR del tuo biglietto per vidimarti all\'ingresso',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: textLow,
                                            fontWeight: FontWeight.w600
                                  
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if(widget.ticket['table_owner_id'] != null && widget.ticket['table_owner_id'] == USER['id'] && widget.ticket['seats'] > 1)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Modals().tickets(
                                      context,
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        height: height(context, 60),
                                        padding: EdgeInsets.all(20),
                                        child: StatefulBuilder(
                                          builder: (
                                            BuildContext context,
                                            void Function(void Function()) modalSetState,
                                          ) {
                                            return Column(
                                              children: [
                                                Text(
                                                  '${widget.ticket['event']['title']}',
                                                  style: style2,
                                                ),
                                                Text(
                                                  'Trasferisci un Posto',
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: textMid,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                TextField(
                                                  style: TextStyle(
                                                    color: textColor, // Cambia qui il colore del testo
                                                    fontSize: 16,      // Puoi anche personalizzare il font
                                                  ),
                                                  controller: searchController,
                                                  onSubmitted: (_) async {
                                                    loader = true;
                                                    modalSetState(() {});
                                                    await handleSearch(modalSetState);
                                                    loader = false;
                                                    modalSetState(() {});
                                                    setState(() {});
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: "Cerca utente",
                                                    errorText: searchError,
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(500),
                                                      borderSide: BorderSide(color: Colors.grey)
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(500),
                                                      borderSide: BorderSide(color: mainColor, width: 2.0)
                                                    ),              
                                                    suffixIcon: IconButton(
                                                      icon: Icon(Icons.search),
                                                      onPressed: () async {
                                                        loader = true;
                                                        modalSetState(() {});
                                                        await handleSearch(modalSetState);
                                                        loader = false;
                                                        modalSetState(() {});
                                                        setState(() {});
                                                      },
                                                    ),
      
                                                    contentPadding: EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 15.0,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(
                                                        25.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                if (loader)
                                                  Center(
                                                    child: Container(
                                                      padding: EdgeInsets.all(30),
                                                      child: CircularProgressIndicator(
                                                        color: mainColor,
                                                        strokeWidth:
                                                            10, // Spessore della linea dello spinner
                                                      ),
                                                    ),
                                                  ),
                                                if (loader == false)
                                                Flexible(
                                                  child: modalUsers.isEmpty
                                                  ? Center(
                                                    child: Text(
                                                      "Nessun utente trovato",
                                                    ),
                                                  )
                                                  : ListView.builder(
                                                    itemCount:  modalUsers.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: 10),
                                                        child: SbCardUser(
                                                          user: modalUsers[index],
                                                          onTap:  () => Modals().showMessageConfirme(
                                                            context,
                                                            'Trasferisci',
                                                            'Sei sicuro di voler trasferire questo invito?',
                                                            () async {
                                                              Navigator.pop(context);
                                                              Modals().loader(context);
                                                              try {
                                                                final res = await ApiEvent().transferEntryTypeSeat(
                                                                  widget.ticket['event']['id'],
                                                                  widget.ticket['id'],
                                                                  modalUsers[index]['id'],
                                                                );
                                                                if (res['status'] == true) {
                                                                  if(WALLETSTATE != null){
                                                                    await WALLETSTATE!.getData();
                                                                  }
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context,);
                                                                  Navigator.pop(context);
                                                                  Modals().showMessage(context,'success','Invito trasferito con successo');
                                                                } else {
                                                                  Navigator.pop(context);
                                                                  Modals().showMessage(  context,  'error',  res['error'] ?? 'Errore sconosciuto');
                                                                }
                                                              } catch (e) {
                                                                Navigator.pop(context);
                                                                Modals().showMessage(
                                                                  context,
                                                                  'error',
                                                                  'Errore sconosciuto',
                                                                );
                                                              }
                                                              if (WALLETSTATE != null) {
                                                                await WALLETSTATE!.getData();
                                                              }
                                                              setState((){});
      
                                                            },
                                                            () =>  Navigator.pop(context,),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 120,
                                    margin: EdgeInsets.only(top: 20,right: 10,left: 5,bottom: 20),
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.group_add, color: Colors.white,),
                                            SizedBox(width: 5,),
                                            Text(
                                              'Invita Utenti',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.bold
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          'Invita persone in questo tavolo fino a riempimento',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: textLow,
                                            fontWeight: FontWeight.w600
                                  
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if(widget.ticket['partecipanti'] != null && widget.ticket['partecipanti'].length > 0 && widget.ticket['table_owner_id'] != null && widget.ticket['table_owner_id'] == USER['id'] && widget.ticket['seats'] > 1)
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.group_outlined,
                                  size: textHight,
                                  color: textColor,
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  'Partecipanti',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: textMidHight,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                if((widget.ticket['seats'] - (widget.ticket['stock'] - 1) != 1) && (seats != 1))
                                Text(
                                  ' ${widget.ticket['seats'] - (widget.ticket['stock'] - 1)}/$seats',
                                  style: TextStyle(
                                    fontSize: textMidHight,
                                    color: textColor,
                                    fontWeight: FontWeight.w800
                                  ),
                                  
                                ),
                              ],
                            ),
                          ),
      
      
                          ////////////////////////
                          /// PARTECIPANTI
                          ////////////////////////
      
                          if(widget.ticket['partecipanti'] != null && widget.ticket['partecipanti'].length > 0 && widget.ticket['table_owner_id'] != null && widget.ticket['table_owner_id'] == USER['id'] && widget.ticket['seats'] > 1)
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: mainColor.withAlpha(10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 300,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ...List.generate(
                                      widget.ticket['partecipanti'].length,
                                      (index) {
                                        Map user = widget.ticket['partecipanti'][index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context, '/profile',arguments: {'nickname' : user['nickname']});
                                            },
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(500),
                                                  child: user['picture'] != null &&
                                                      user['picture'].isNotEmpty &&
                                                      user['visibility'] == 1
                                                  ? Image.network(
                                                      "$BASE_URL${user['picture']}${ver()}",
                                                      height: 35,
                                                      width: 35,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Image.asset(
                                                          NOPHOTO,
                                                          width: 35,
                                                          height: 35,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      NOPHOTO,
                                                      width: 35,
                                                      height: 35,
                                                      fit: BoxFit.cover,
                                                    ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              '@${user['nickname']}',
                                                              style: TextStyle(
                                                                color: textColor,
                                                                fontSize: textMid,
                                                              ),
                                                            ),
                                                            if(user['notification_status'] != null && user['notification_status'] == 'pending')
                                                            Text(
                                                              'in attesa di risposta',
                                                              style: TextStyle(
                                                                color: Colors.orange,
                                                                fontSize: textMid,
                                                              ),
                                                            ),
                                                            if(user['notification_status'] == null)
                                                            Text(
                                                              'confermato',
                                                              style: TextStyle(
                                                                color: Colors.green,
                                                                fontSize: textMid,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if(user['id'] != USER['id'])
                                                      Container(
                                                        child: IconButton(
                                                          onPressed: ()async{
                                                            Modals().showMessageConfirme(
                                                              context, 
                                                              'Rimuovi Partecipante', 
                                                              'Sei sicuro di volere rimuove un partecipante?', 
                                                              ()async{
                                                                Modals().loader(context);
                                                                dynamic data = await ApiEvent().removePartecipant(user['id'],widget.ticket['id']);
                                                                if(data != null && data.isNotEmpty && data['status'] == true){
                                                                  
                                                                  if (WALLETSTATE != null) {
                                                                    await WALLETSTATE!.getData();
                                                                  }
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Modals().showMessage(context, 'success', '${data['message']}');
                                                                  setState(() {});

                                                                }else{
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Modals().showMessage(context, 'error', '${data != null && data.isNotEmpty && data['error']}');
                                                                  setState(() {});
                                                                  
                                                                }
                                                                
                                                              },
                                                              () async{
                                                                Navigator.pop(context);
                                                              }
                                                            );
                                                          }, 
                                                          icon: Icon(Icons.delete,color: mainColor,)
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
      
                          ////////////////////////
                          /// EVENTO E LOCALE
                          ////////////////////////
                          SizedBox(height: 10),
                          
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.event,
                                  size: textHight,
                                  color: textColor,
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  'Evento',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: textMidHight,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                               
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: SbCardEventSmall(
                              event: widget.ticket['event']
                            ),
                          ),
                          SizedBox(height: 50,),
                        ],
                      ),
                    ),
                  )
                );
              },
            );
      
          }
        },
        
        child: Opacity(
          opacity: widget.status == false && widget.ticket['event']['id'] != EVENTONAIR['id'] ? 0.6 : 1,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: widget.status == false && widget.ticket['event']['id'] == EVENTONAIR['id'] ? Border.all(width: 2, color: mainColor) : null,
                  color: mainColor,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: 3, // 1 = 90°, 2 = 180°, 3 = 270°
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              width: 120,
                              child: Text(
                                '${widget.ticket['category']}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: textMidHight,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: backgroundColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.ticket['label']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: textMid,
                                  color: mainColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Evento: ${widget.ticket['event']['title']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: textMid,
                                  color: textColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              
                              
                                
                              if (seats != 0 && seats > 1 && widget.ticket['table_owner_id'] != null && widget.status == true)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 85,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.group_outlined,
                                          size: textHight,
                                          color: textColor,
                                        ),
                                        Text(
                                          ' ${widget.ticket['seats'] - (widget.ticket['stock'] - 1)}/$seats',
                                          style: TextStyle(
                                            fontSize: textMid,
                                            color: textColor,
                                            fontWeight: FontWeight.w500
                                          ),
                                          
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  
                                ],
                              ),
                              if(widget.ticket['table_owner_id'] != null && 
                                 widget.ticket['owner'] != null && 
                                 widget.ticket['owner']['nickname'] != null &&
                                 widget.ticket['owner']['nickname'] != (USER['nickname'] ?? ''))
                              Text(
                                'Proprietario: @${widget.ticket['owner']['nickname']}',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: textMid
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: backgroundColor,
                        child: VerticalDashedLine(height: 20,color: backgroundColorTheme)
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                        ),
                        child: Center(
                          child: SbDateFormat(date: widget.ticket['event']['datetime_start'])
                        )
                      ),
                    ],
                  ),
                ),
              ),
              if( widget.status == true && widget.ticket['table_owner_id'] == null)
              Positioned(
                top: 0,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    ' x ${widget.ticket['stock']}',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w800,
                      fontSize: textMid
                    ),
                  ),
                )
              ),
              
              // if (widget.status == false && widget.ticket['event']['id'] == EVENTONAIR['id'])
              // Positioned(
              //   top: 0,
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: GestureDetector(
              //     onTap: () {
              //       // Navigator.pushNamed(context, '/eventShow', arguments: { 'eventId' : widget.ticket['event']['id']});
              //     },
              //     child: Container(
              //       margin: EdgeInsets.only(top: 10, right: 10, left: 10),
              //       padding: EdgeInsets.all(5),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(19),
              //         border: Border.all(width: 2,color: mainColor)
              //         // color: const Color.fromARGB(97, 139, 139, 139),
              //       ),
              //     ),
              //   )
              // ),
              if (widget.status == false && widget.ticket['event']['id'] == EVENTONAIR['id'])
              Positioned(
                top: 2,
                left: 20,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1,color: Colors.white),
                    borderRadius: BorderRadius.circular(19),
                    color: mainColor,
                  ),
                  child: Text('ON AIR', style: TextStyle(color: Colors.white,fontSize: 10)),
                )
              ),
            ],
          ),
        ),
      );
  
  }

  // Funzioni
  Future handleSearch(void Function(void Function()) modalSetState) async {
    final value = searchController.text.trim();
    if (value.length < 3) {
      modalSetState(() {
        searchError = 'Inserisci almeno 3 caratteri';
      });
      return;
    }

    Map res = await ApiUser().getUsers(search: value);
    if (res['status'] == true) {
      modalSetState(() {
        modalUsers = res['users'] ?? [];
        searchError = null; // pulisco errore se esiste
      });
    }
  }
}
