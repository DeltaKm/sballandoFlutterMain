import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_card_user.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/components/sb_ticket_wallet.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:uuid/uuid.dart';

class SbWallet extends StatefulWidget {
  const SbWallet({super.key});

  @override
  State<SbWallet> createState() => SbWalletState();
}

class SbWalletState extends State<SbWallet> {

  final walletKey = GlobalKey<SbWalletState>();





  TextEditingController                 searchController                      = TextEditingController();
  String?                               searchError;
  int?                                  eventId;
  bool                                  loader                                = true;
  bool                                  productEmpty                          = false;
  bool                                  isFree                                = false;
  Map<String, bool>                     selectedEventsMap                     = {};
  List                                  entry_types                           = [];
  List                                  products_burned                       = [];
  List                                  products                              = [];
  List                                  productsFilter                        = [];
  List                                  locations                             = [];
  List                                  users                                 = [];
  List                                  events                                = [];
  List                                  validTickets                          = [];
  List                                  expiredTickets                        = [];
  List                                  productsStock                         = [];
  List                                  modalUsers                            = [];
  String                                upKey                                 = Uuid().v4();

  Future getData() async {
    validTickets.clear();
    expiredTickets.clear();
    products.clear();
    events.clear();
  
    dynamic respTicket = await ApiEvent().getTicket();
    if (respTicket != null && respTicket.isNotEmpty && respTicket['status'] != false) {
      entry_types = respTicket['entry_types'];
      for (var entry in entry_types) {
        if (entry['burned'] == 1 || entry['check_unused'] == 1 || !parseServerDateTime(entry['event']['datetime_end']).isAfter(DateTime.now())) {
          expiredTickets.add(entry);
          expiredTickets.sort((a, b) {
            final dateA = parseServerDateTime(a['event']['datetime_start']);
            final dateB = parseServerDateTime(b['event']['datetime_start']);
            return dateB.compareTo(dateA); // decrescente
          });
        } else {
          validTickets.add(entry);
          validTickets.sort((a, b) {
            final dateA = parseServerDateTime(a['event']['datetime_start']);
            final dateB = parseServerDateTime(b['event']['datetime_start']);
            return dateB.compareTo(dateA); // decrescente
          });
          
        }
      } 
    }

    dynamic respProduct         = await ApiEvent().getProducts();
    if(respProduct != null && respProduct.isNotEmpty){
      products                    = respProduct['products'] != null ? groupProducts(respProduct['products']) : [];
      products_burned             = respProduct['products_burned'] ?? [];
      // RIMUOVE I PRODOTTI DELL'EVENTO AL CREATORE
      productsFilter = products.where((product) {
        final userId = product['user_id']?.toString();
        final event = product['event'];

        if (event == null) return true; // se non c'è evento, tieni il prodotto

        final eventUserId = event['user_id']?.toString();
        final collaborators = event['collaborators_id'];

        final isSameUser = userId == eventUserId;
        final isCollaborator = (collaborators is List && collaborators.map((e) => e.toString()).contains(userId)) && product['entry_type_id'] != null;

        return !(isSameUser || isCollaborator);
      }).toList();

      events                      = respProduct['events'];
      if(events.isNotEmpty){
        for (var e in events) {
          List array        = [];
          e['products']     = array;
          for (var p in products) {
            if(p['event']['id'].toString() == e['id'].toString()){
              if(p['created_qnt'] == null && p['stock'] > 0){
                e['products'].add(p);
              }
            }
          }
          selectedEventsMap[e['title']] = false;
        }
      }
    }
    
  
    loader = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WALLETSTATE = this;
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      FOOTERSELECT                = 'wallet';
      CURRENTSTATE                = this;
      getData();
    });

  }

  List<Map<String, dynamic>> groupProducts(List products) {
    final Map<String, Map<String, dynamic>> grouped = {};
  
    for (var product in products) {
      // Crea una chiave unica per identificare univocamente il prodotto
      if(product['burned'] == 0 && product['check_unused'] == 0){
        final key = '${product['event_id']}-${product['label']}';
        if (grouped.containsKey(key)) {
          grouped[key]?['quantity'] += 1;
        } else {
          // Copia il prodotto originale e aggiunge quantity = 1
          grouped[key] = {...product, 'quantity': 1};
        }
      }
      
    }
  
    return grouped.values.toList();
  }


  @override
  Widget build(BuildContext context) {
    // Altezza dell'header; supponiamo 200
    // Altezza del footer (personalizza in base alle tue esigenze)
    return SbScheletro(
      content: Container(
      
        child: SbTabMulti(
          firstLabel: 'Ticket', 
          secondLabel: 'Prodotti', 
          firstContent: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                if(loader == true)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(
                      color: mainColor,
                      strokeWidth: 10, // Spessore della linea dello spinner
                    ),
                  ),
                ),
                if(loader == false &&  validTickets.isEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nessun ticket',
                        style: TextStyle(
                          color: textColor
                        ),
                        // style: ,
                      ),
                    ),
                  ],
                ),
                if(validTickets.isNotEmpty)
                Text(
                  'Ticket da utilizzare',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: mainColor,
                    fontSize: textMid,
                    fontWeight: FontWeight.w800
                  ),
                ),
                if(loader == false)
                ...List.generate(
                  validTickets.isNotEmpty? validTickets.length : 0,
                  (index) {
                    final entry = validTickets[index];
                    
                    return SbTicketWallet(ticket: entry,status: true,);
                  }
                ),

                if(expiredTickets.isNotEmpty)
                  SizedBox(
                    height: 10,
                  ),
                
                if(expiredTickets.isNotEmpty)
                Text(
                  'Ticket scaduti',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: mainColor,
                    fontSize: textMid,
                    fontWeight: FontWeight.w800
                  ),
                ),
                  
                if(expiredTickets.isNotEmpty)
                ...List.generate(
                  expiredTickets.isNotEmpty ? expiredTickets.length : 0,
                  (index) {
                 final entry = expiredTickets[index];
                  return SbTicketWallet(ticket: entry, status: false); // TICKET SCADUTO
                  }
                ),
              ],
            ),
          ),
          secondContent: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              if(loader == true)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(
                      color: mainColor,
                      strokeWidth: 10, // Spessore della linea dello spinner
                    ),
                  ),
                ),
                if(loader == false &&  productsFilter.isEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nessun prodotto',
                         style: TextStyle(
                          color: textColor
                         ),
                      ),
                    ),
                  ],
                ),
                if(productsFilter.isNotEmpty && events.length > 1)
                ExpansionTile(
                  title: Text(
                    'Filtri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  leading: Icon(Icons.filter_list, color: mainColor),
                  tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  childrenPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  initiallyExpanded: true, // se vuoi aprirlo di default
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    Text(
                      'Clicca sul nome di un evento per filtrare i prodotti relativi',
                      style: TextStyle(
                        color: mainColor
                      ),
                    ),
                    ...List.generate(
                      events.isNotEmpty ? events.length : 0,
                      (index) {
                        final title = events[index]['title'];

                        return CheckboxListTile(
                          title: Text(
                            title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: textMid
                            ),
                          ),
                          value: selectedEventsMap[title],
                          onChanged: (val) {
                            setState(() {
                              selectedEventsMap[title] = val ?? false;
                            
                              // Prendi tutti i titoli attivi
                              final selectedTitles = selectedEventsMap.entries
                                  .where((entry) => entry.value == true)
                                  .map((entry) => entry.key)
                                  .toList();
                            
                              // Se nessun filtro attivo, mostra tutti i prodotti
                              if (selectedTitles.isEmpty) {
                                productsFilter = products;
                              } else {
                                productsFilter = products.where((product) =>
                                  selectedTitles.contains(product['event']['title'])
                                ).toList();
                              }
                            });
                          },
                        );
                      }
                    ),
                    
                    // altri filtri...
                  ],
                ),
                if(productsFilter.isNotEmpty)
                Text(
                  'Prodotti da utilizzare',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: mainColor,
                    fontSize: textMid,
                    fontWeight: FontWeight.w800
                  ),
                ),
                ...List.generate(
                  productsFilter.isNotEmpty ? productsFilter.length : 0,
                  (index) {
                    Map product = productsFilter[index];
                    
                    return GestureDetector(
                      onTap: (){

                        Modals().modalQrCode(context, 'product', USER['id'], product['event']['id'], product, product['event']);
                       },
                      child: Container(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product['quantity'] > 1 ? product['quantity'] : product['stock']} x ${product['label']}',
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: mainColor,
                                        fontSize: textMid,
                                        fontWeight: FontWeight.w800
                                      ),
                                    ),
                                    Text(
                                      'Evento: ${product['event']['title']}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: textMid,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    if(product['description'] != null)
                                    Text(
                                      '${product['description']}',
                                      style: TextStyle(
                                        color: textColorSecondary,
                                        fontSize: textLowMid,
                                        fontWeight: FontWeight.w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if(product['entry_type_id'] == null || product['entry_type_id'] == '')
                              IconButton(
                                onPressed: (){
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
                                                  '${productsFilter[index]['label']}',
                                                  style: style2,
                                                ),
                                                Text(
                                                  'Trasferisci un Prodotto',
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
                                                      borderSide: BorderSide(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(500)
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: mainColor, width: 2.0),
                                                      borderRadius: BorderRadius.circular(500)
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
                                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0,),
                                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0),),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                if (loader)
                                                  Center(
                                                    child: Container(
                                                      padding: EdgeInsets.all(30),
                                                      child: CircularProgressIndicator(
                                                        color: mainColor,
                                                        strokeWidth: 10, // Spessore della linea dello spinner
                                                      ),
                                                    ),
                                                  ),
                                                if (loader == false)
                                                  Expanded(
                                                    child: modalUsers.isEmpty
                                                    ? Center(
                                                      child: Text(
                                                        "Nessun utente trovato",
                                                      ),
                                                    )
                                                    : ListView.builder(
                                                      itemCount: modalUsers.length,
                                                      itemBuilder: (
                                                        context,
                                                        index_,
                                                      ) {
                                                        return Container(
                                                          padding: EdgeInsets.symmetric(vertical: 5),
                                                          child: SbCardUser(
                                                            user: modalUsers[index_],
                                                            onTap:() {
                                                              Modals().showMessageConfirme(
                                                                context,
                                                                'Trasferisci',
                                                                'Sei sicuro di voler trasferire questo prodotto?',
                                                                () async {
                                                                  Navigator.pop(context);
                                                                  Modals().loader(context);
                                                                  try {
                                                                    print(productsFilter[index]['id']);
                                                                    final res = await ApiEvent().transferProduct(
                                                                      productsFilter[index]['id'],
                                                                      modalUsers[index_]['id'],
                                                                    );
                                                                    if (res['status'] == true) {
                                                                      Navigator.pop(context);
                                                                      Modals().showMessage(
                                                                        context,
                                                                        'success',
                                                                        'Prodotto trasferito con successo',
                                                                      );
                                                                      await getData();
                                                                      setState(() {
                                                                        
                                                                      });
                                                                    } else {
                                                                      Navigator.pop(context);
                                                                      Modals().showMessage(
                                                                        context,
                                                                        'error',
                                                                        res['error'] ?? 'Erorre sconosciuto',
                                                                      );
                                                                    }
                                                                  } catch (e) {
                                                                    Navigator.pop(context);
                                                                    Modals().showMessage(
                                                                      context,
                                                                      'error',
                                                                      'Erorre sconosciuto',
                                                                    );
                                                                  }
                                                                },
                                                                () {
                                                                  Navigator.pop(context);
                                                                }
                                                              );
                                                            }
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
                                icon: Icon(Icons.swap_horiz, size: 32,color: mainColor,)
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
                if(products_burned.isNotEmpty)
                Text(
                  'Prodotti Consumati',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: mainColor,
                    fontSize: textMid,
                    fontWeight: FontWeight.w800
                  ),
                ),
                ...List.generate(
                  products_burned.isNotEmpty ? products_burned.length : 0,
                  (index) {
                    Map product = products_burned[index];
                    
                    return GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) {
                            // Programma la chiusura automatica dopo 3 secondi


                            return AlertDialog(
                              backgroundColor: backgroundColor,
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                width: width(context, 100),
                                height: 200,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ID : ${product['id']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: mainColor,
                                        fontSize: textHight,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ]
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Opacity(
                        opacity: 0.5,
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${product['label']}',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          color: mainColor,
                                          fontSize: textMid,
                                          fontWeight: FontWeight.w800
                                        ),
                                      ),
                                    Text(
                                      'Evento: ${product['event']['title']}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: textMid,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (product['description'] != null)
                                      Text(
                                        '${product['description']}',
                                        style: TextStyle(
                                          color: textColorSecondary,
                                          fontSize: textLowMid,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    if (product['updated_at'] != null)
                                      Text(
                                        'Data: ${DateFormat("dd/MM/yyyy HH:mm").format(parseServerDateTime(product['updated_at']))}',
                                        style: TextStyle(
                                          color: textColorSecondary,
                                          fontSize: textLowMid,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    );
                  }
                ),
            ],
          )
        ),
      )
    );
  }
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
