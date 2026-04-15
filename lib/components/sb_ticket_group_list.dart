import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbTicketGroupList extends StatefulWidget {

  List        entryTypeTableUser;
  bool        ticketSelect;
  Function    loadData;
  Map         ticketSelectMap;

  SbTicketGroupList({
    super.key,
    required this.entryTypeTableUser,
    required this.ticketSelect,
    required this.ticketSelectMap,
    required this.loadData,
  });

  @override
  State<SbTicketGroupList> createState() => SbTicketGroupListState();
}

class SbTicketGroupListState extends State<SbTicketGroupList> {



  @override
  Widget build(BuildContext context) {

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setModalState) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group,color: mainColor,),
                        SizedBox(width: 5,),
                        Text(
                          'Scegli un\'ingresso di gruppo',
                          style: TextStyle(
                            color: textColor,
                            fontSize: textMidHight,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          }, 
                          icon: Icon(CupertinoIcons.xmark)
                        )
                      ],
                    ),
                    ...List.generate(
                      widget.entryTypeTableUser.isNotEmpty ? widget.entryTypeTableUser.length : 0,
                      (index){
                        bool isExpanded = false;

                        Map owner = {};
                        widget.entryTypeTableUser[index]['partecipanti'].forEach((p){
                          if(p['id'].toString() == widget.entryTypeTableUser[index]['user_id'].toString()){
                            owner = p;
                          }
                        });
                        int femaleCount = 0;
                        int maleCount   = 0;
                        widget.entryTypeTableUser[index]['partecipanti'].forEach((p){
                          if(p['gender'] == 'F') femaleCount++; 
                          if(p['gender'] == 'M') maleCount++; 
                        });
                        return StatefulBuilder(
                          builder: (context, accordionState) {
                            return GestureDetector(
                              onTap: () async{
                                if(widget.entryTypeTableUser[index]['fairplay_min'] != null && int.parse(USER['fairplay'].toString()) >=  int.parse(widget.entryTypeTableUser[index]['fairplay_min'].toString())){
                                  Modals().showMessage(context, 'error', 'Fairplay insufficiente');
                                  return;
                                }
                                Modals().showMessageConfirme(context, 'Invio richiesta', 'Vuoi inviare una richiesta di partecipazione a ${widget.entryTypeTableUser[index]['nickname']}?', 
                                  () async{
                                    Modals().loader(context);
                                    dynamic data = await ApiEvent().requestInviteGroup(widget.entryTypeTableUser[index]['event_id'], widget.entryTypeTableUser[index]['id']);
                                    if(data != null && data.isNotEmpty && data['status'] != false){
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Modals().showMessage(context, 'success', 'Richiesta inviata all\'utente');
                                      widget.loadData();
                                      setState(() {
                            
                                      });
                                    }else{
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Modals().showMessage(context, 'error', '${data['error']}');
                                      setState(() {
                            
                                      });
                                    }        
                            
                                    setState(() {});
                                    setModalState(() {});
                                  }, 
                                  (){
                                    Navigator.pop(context);
                                  }
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                            
                                          if(widget.entryTypeTableUser[index] != null)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${widget.entryTypeTableUser[index]['label']}  ', // Usa widget.entryTypeTableUser[index] invece di tab
                                                  style: TextStyle(
                                                    color: mainColor,
                                                    fontSize: textMidHight,
                                                    fontWeight: FontWeight.w600
                                                  ),
                                                ),
                                              ),
                                              Icon(Icons.add_circle_outline,color: mainColor,size: textHight,)
                                            ],
                                          ),
                                          
                            
                                          if(widget.entryTypeTableUser[index]['description'] != null)
                                          Text(
                                            '${widget.entryTypeTableUser[index]['description']}', // Usa widget.entryTypeTableUser[index] invece di tab
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: textColorSecondary,
                                              fontSize: textLowMid,
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                            
                                          /////////////////////////////
                                          /// ACCORDION PARTECIPANTI
                                          /////////////////////////////
                                          
                                          AnimatedCrossFade(
                                            duration: const Duration(milliseconds: 300),
                                            crossFadeState: isExpanded
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                            firstChild: GestureDetector(
                                              onTap: () {
                                                accordionState(() {
                                                  isExpanded = true;
                                                });
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: width(context, 100),
                                                    height: 55,
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: mainColor.withAlpha(20),
                                                    ),
                                                  ),
                                                  ...List.generate(
                                                    widget.entryTypeTableUser[index]['partecipanti'].isNotEmpty ? widget.entryTypeTableUser[index]['partecipanti'].length : 0,
                                                    (index_){
                                                      Map partecipante = widget.entryTypeTableUser[index]['partecipanti'][index_];
                                                      int margin =  26 * index_;
                                                      return Positioned(
                                                        top: 10,
                                                        bottom: 10,
                                                        left: index_ == 0 ? 10 : double.tryParse(margin.toString()),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(500),
                                                          child: 
                                                          partecipante['picture'] != null && partecipante['picture'].isNotEmpty && partecipante['visibility'] == 1
                                                          ? Image.network(
                                                            "$BASE_URL${partecipante['picture']}${ver()}",
                                                            height: 35,
                                                            width: 35,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              // Se si verifica un errore di rete o altro, usa l'immagine di fallback
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
                                                      );
                                                    }
                                                  )
                                                ],
                                              ),
                                            ),
                                            secondChild: GestureDetector(
                                              onTap: () {
                                                accordionState(() {
                                                  isExpanded = false;
                                                });
                                              },
                                              child: Container(
                                                width: width(context, 100),
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: mainColor.withAlpha(20),
                                                    
                                                  ),
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ...List.generate(
                                                        widget.entryTypeTableUser[index]['partecipanti'].isNotEmpty ? widget.entryTypeTableUser[index]['partecipanti'].length : 0,
                                                        (index_){
                                                          Map partecipante = widget.entryTypeTableUser[index]['partecipanti'][index_];
                                                          return GestureDetector(
                                                            onTap: (){
                                                              Navigator.pushNamed(context, '/profile',arguments: { 'nickname' : partecipante['nickname']});
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(vertical: 2),
                                                              child: Row(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(500),
                                                                    child: 
                                                                    partecipante['picture'] != null && partecipante['picture'].isNotEmpty && partecipante['visibility'] == 1
                                                                    ? Image.network(
                                                                      "$BASE_URL${partecipante['picture']}${ver()}",
                                                                      height: 35,
                                                                      width: 35,
                                                                      fit: BoxFit.cover,
                                                                      errorBuilder: (context, error, stackTrace) {
                                                                        // Se si verifica un errore di rete o altro, usa l'immagine di fallback
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
                                                                  SizedBox(width: 20,),
                                                                  Text(
                                                                    '@${partecipante['nickname']}',
                                                                    style: TextStyle(
                                                                      color: textColor,
                                                                      fontSize: textMid,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      )
                                                      
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        
                            
                            
                                          if(widget.entryTypeTableUser[index]['fairplay_min'] != null)
                                          Row(
                                            children: [
                                              Text(
                                                'fair play richiesto: ', // Usa widget.entryTypeTableUser[index] invece di tab
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: textMid,
                                                  fontWeight: FontWeight.w300
                                                ),
                                              ),
                                              Text(
                                                '${widget.entryTypeTableUser[index]['fairplay_min']}', // Usa widget.entryTypeTableUser[index] invece di tab
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: textMid,
                                                  fontWeight: FontWeight.w800
                                                ),
                                              ),
                                              if(int.parse(USER['fairplay'].toString()) >=  int.parse(widget.entryTypeTableUser[index]['fairplay_min'].toString())) 
                                              Container(
                                                margin: EdgeInsets.all(3),
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: greenColor,
                                                  borderRadius: BorderRadius.circular(500),
                                                ),
                                                child: Icon(Icons.check, color: Colors.white,size: 10,),
                                              ),
                                              if(int.parse(USER['fairplay'].toString()) < int.parse(widget.entryTypeTableUser[index]['fairplay_min'].toString())) 
                                              Container(
                                                margin: EdgeInsets.all(3),
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(500),
                                                ),
                                                child: Icon(Icons.close, color: Colors.white,size: 10,),
                                              )
                                            ],
                                          ),
                                          
                                          
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if(widget.entryTypeTableUser[index]['seats'] != null && int.parse(widget.entryTypeTableUser[index]['seats'].toString()) > 1)
                                              Row(
                                                children: [
                                                  Icon(Icons.person, color: mainColor),
                                                  Text(
                                                    '${widget.entryTypeTableUser[index]['seats']}', // Usa widget.entryTypeTableUser[index] invece di tab
                                                    style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: textMid,
                                                      fontWeight: FontWeight.w800
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.male,size: 40,color: maleColor,),
                                                  Text(
                                                    '$maleCount',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: textMid
                                                    ),
                                                  ),
                            
                            
                                                  Icon(Icons.female,size: 40,color: femaleColor,),
                                                  Text(
                                                    '$femaleCount',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: textMid
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          
                                          SizedBox(height: 5,),
                                          Text(
                                            'Creato da:',
                                            style: TextStyle(
                                              color: textColorSecondary,
                                              fontSize: textLowMid
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                            
                                          Row(
                                            children: [
                                              
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(500),
                                                child: Image.network(
                                                  height: 30,
                                                  width: 30,
                                                  fit: BoxFit.cover,
                                                  '${widget.entryTypeTableUser[index]['participant_picture'] != null ? BASE_URL+widget.entryTypeTableUser[index]['participant_picture'] : ''}',
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      NOPHOTO,
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Text(
                                                ' @${widget.entryTypeTableUser[index]['participant_nickname']}', // Usa widget.entryTypeTableUser[index] invece di tab
                                                style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: textMidHight,
                                                  fontWeight: FontWeight.w600
                                                ),
                                              ),
                                              
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }
                    ),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
            
            
          ],
        );
      }
    );
  }
}