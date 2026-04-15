import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbTabCustomMulti extends StatefulWidget {
  List        tabs;
  Function    loadData;
  List        elements;
  List        collaborators;
  String      typeElement;

  SbTabCustomMulti({
    super.key,
    required this.elements,
    required this.loadData,
    required this.tabs,
    required this.collaborators,
    required this.typeElement,
  });

  @override
  State<SbTabCustomMulti> createState() => SbTabCustomMultiState();



}

class SbTabCustomMultiState extends State<SbTabCustomMulti> {

  late String         selectedTap; // dichiarata senza inizializzazione immediata
  bool                ticketSelect            = false;
  bool                showCart                = false;
  Map                 elementSelectMap        = {};
  List<Map>           cartItems               = []; // Lista elementi nel carrello
  
  @override
  void initState() {
    super.initState();
    selectedTap = widget.tabs.isNotEmpty && widget.tabs[0] != null ? widget.tabs[0] : ''; // assegnazione nel initState
  }

  // Aggiungi elemento al carrello
  void addToCart(Map element) {
    setState(() {
      // Controlla se l'elemento è già nel carrello
      int existingIndex = cartItems.indexWhere((item) => item['id'] == element['id'] && item['item_type'] == widget.typeElement);
      if (existingIndex >= 0) {
        // Se esiste già, incrementa la quantità
        cartItems[existingIndex]['quantity'] = (cartItems[existingIndex]['quantity'] ?? 1) + 1;
      } else {
        // Altrimenti aggiungilo con quantità 1
        Map newItem = Map.from(element);
        newItem['quantity'] = 1;
        newItem['item_type'] = widget.typeElement; // Salva il tipo (entry_types o products)
        cartItems.add(newItem);
      }
    });
  }

  // Rimuovi elemento dal carrello
  void removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  // Diminuisci quantità
  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  // Aumenta quantità
  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
  }

  // Calcola totale carrello
  double getCartTotal() {
    double total = 0;
    for (var item in cartItems) {
      double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      int quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  // Svuota carrello
  void clearCart() {
    setState(() {
      cartItems.clear();
    });
  }

  // Verifica se l'ingresso è disponibile in base alle date
  bool isEntryAvailable(Map entry) {
    // Se non è un entry_type, è sempre disponibile
    if (widget.typeElement != 'entry_types') {
      return true;
    }

    DateTime now = DateTime.now();
    
    // Verifica start_date
    if (entry['start_date'] != null && entry['start_date'].toString().isNotEmpty) {
      try {
        DateTime startDate = parseServerDateTime(entry['start_date'].toString());
        // Se la data attuale è prima della start_date, non è ancora disponibile
        if (now.isBefore(startDate)) {
          return false;
        }
      } catch (e) {
        // Se c'è un errore nel parsing, considera la data valida
        print('Errore parsing start_date: $e');
      }
    }

    // Verifica expired_date
    if (entry['expired_date'] != null && entry['expired_date'].toString().isNotEmpty) {
      try {
        DateTime expiredDate = parseServerDateTime(entry['expired_date'].toString());
        // Se la data attuale è dopo la expired_date, è scaduto
        if (now.isAfter(expiredDate)) {
          return false;
        }
      } catch (e) {
        // Se c'è un errore nel parsing, considera la data valida
        print('Errore parsing expired_date: $e');
      }
    }

    // Se non ci sono date o le date sono valide, è disponibile
    return true;
  }

  // Ottiene la quantità di un item nel carrello
  int getItemQuantityInCart(Map entry) {
    int index = cartItems.indexWhere((item) => item['id'] == entry['id'] && item['item_type'] == widget.typeElement);
    if (index >= 0) {
      return cartItems[index]['quantity'] ?? 0;
    }
    return 0;
  }

  // Ottiene il messaggio di stato della disponibilità
  String getAvailabilityMessage(Map entry) {
    if (widget.typeElement != 'entry_types') {
      return '';
    }

    DateTime now = DateTime.now();
    
    // Verifica start_date
    if (entry['start_date'] != null && entry['start_date'].toString().isNotEmpty) {
      try {
        DateTime startDate = parseServerDateTime(entry['start_date'].toString());
        if (now.isBefore(startDate)) {
          return 'Si attiva il ${DateFormat('dd/MM/yyyy HH:mm').format(startDate)}';
        }
      } catch (e) {
        print('Errore parsing start_date: $e');
      }
    }

    // Verifica expired_date
    if (entry['expired_date'] != null && entry['expired_date'].toString().isNotEmpty) {
      try {
        DateTime expiredDate = parseServerDateTime(entry['expired_date'].toString());
        if (now.isAfter(expiredDate)) {
          return 'Scaduto il ${DateFormat('dd/MM/yyyy HH:mm').format(expiredDate)}';
        }
      } catch (e) {
        print('Errore parsing expired_date: $e');
      }
    }

    return '';
  }

  // Build modal carrello
  Widget buildCartModal() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // Handle per chiudere
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header carrello
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, color: mainColor, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'Carrello (${cartItems.length})',
                        style: TextStyle(
                          color: mainColor,
                          fontSize: textMidHight,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      clearCart();
                      Navigator.pop(context);
                      setState(() {}); // Aggiorna la pagina principale
                    },
                    child: Text(
                      'Svuota',
                      style: TextStyle(color: Colors.red, fontSize: textMid),
                    ),
                  ),
                ],
              ),
              
              Divider(),
              SizedBox(height: 10),
              
              // Lista prodotti nel carrello
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                    int quantity = item['quantity'] ?? 1;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColorTheme,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mainColor.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['label']}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: textMid,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${price.toStringAsFixed(2)}€ x $quantity',
                                  style: TextStyle(
                                    color: textColorSecondary,
                                    fontSize: textMid,
                                  ),
                                ),
                                Text(
                                  'Totale: ${(price * quantity).toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    color: mainColor,
                                    fontSize: textMid,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    decreaseQuantity(index);
                                    setModalState(() {}); // Aggiorna il modal
                                    setState(() {}); // Aggiorna la pagina principale
                                  },
                                  icon: Icon(Icons.remove_circle_outline, color: mainColor),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  iconSize: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '$quantity',
                                  style: TextStyle(
                                    fontSize: textMid,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(width: 12),
                                IconButton(
                                  onPressed: () {
                                    increaseQuantity(index);
                                    setModalState(() {}); // Aggiorna il modal
                                    setState(() {}); // Aggiorna la pagina principale
                                  },
                                  icon: Icon(Icons.add_circle_outline, color: mainColor),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  iconSize: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              Divider(),
              SizedBox(height: 10),
              
              // Totale
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Totale Carrello:',
                      style: TextStyle(
                        color: textColor,
                        fontSize: textMidHight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${getCartTotal().toStringAsFixed(2)}€',
                      style: TextStyle(
                        color: mainColor,
                        fontSize: textMidHight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 15),
              
              // Pulsante Checkout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Chiudi il modal
                    Navigator.pushNamed(
                      context,
                      '/checkout',
                      arguments: {
                        'cartItems': cartItems,
                        'total': getCartTotal(),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Procedi al Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: textMid,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    
    
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.ticket, size: 40,color: mainColor,),
                Expanded(
                  child: Text(
                    '${widget.typeElement ==  'entry_types' ? 'Scegli tipologia ingresso' : 'Scegli tipologia prodotto'}' ,
                    style: TextStyle(
                      color: textColor,
                      fontSize: textMidHight,
                      fontWeight: FontWeight.w800
                    ),
                  ),
                ),
                // Badge carrello
                Stack(
                  children: [
                    IconButton(
                      onPressed: (){
                        if(cartItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Il carrello è vuoto'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        // Apri il carrello come modal
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => buildCartModal(),
                        );
                      },
                      icon: Icon(
                        Icons.shopping_cart,
                        size: 30,
                        color: mainColor,
                      ),
                    ),
                    if(cartItems.isNotEmpty)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${cartItems.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(CupertinoIcons.xmark),
                )
              ],
            ),
          ),
          Container(
            color: backgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  //////////////////////////////
                  /// LISTA CATEGORIE
                  //////////////////////////////
                  

                  ...List.generate(
                    widget.tabs.isNotEmpty ? widget.tabs.length : 0,
                    (index) {
                      return GestureDetector(
                        onTap: (){
                          selectedTap = '${widget.tabs[index]}';
                          setState(() {});
                        },
                        child: Container(
                          width: widget.tabs.length == 1 ? width(context, 100) : widget.tabs.length == 2 ? width(context, 50) : width(context, 35),
                          padding: EdgeInsets.only(top: 20,right: 20,bottom: 10,left: 20),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border(bottom: BorderSide(width: 1.5,color: selectedTap == '${widget.tabs[index]}' ?  mainColor : grayLight))
                          ),
                          child: Center(
                            child: Text(
                              '${widget.tabs[index]}',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: textMid,
                                fontWeight: FontWeight.w600,
                                color: selectedTap == '${widget.tabs[index]}' ?  mainColor : textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: Container(
              color: backgroundColorTheme,
              child: Column(
                children: [


                  //////////////////////////////
                  /// LISTA ELEMENTI DELLA CATEGORIA
                  //////////////////////////////


                  ...List.generate(
                    widget.tabs.length,
                    (index) {
                      String tab = widget.tabs[index];         
              
                      if (selectedTap == '$tab') {
                        return Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                //////////////////////////////
                                /// LISTA ELEMENTI DELLA CATEGORIA
                                //////////////////////////////
                                  
                                  
                                ...List.generate(
                                  widget.elements.isNotEmpty ? widget.elements.length : 0,
                                  (index_) {
                                    var entry = widget.elements[index_]; // Prendi l'elemento corretto          
                                    bool isAvailable = isEntryAvailable(entry);
                                    String availabilityMsg = getAvailabilityMessage(entry);
                                    
                                    // Mostra sempre l'ingresso, ma oscurato se non disponibile
                                    if(entry['category'] == tab){
                                      return GestureDetector(
                                        onTap: isAvailable ? (){
                                          ticketSelect           = !ticketSelect;
                                          if(entry == elementSelectMap){
                                            elementSelectMap     = {};
                                          }else{
                                            elementSelectMap     = entry;
                                          }
                                          if(elementSelectMap.isNotEmpty && elementSelectMap['price'] != null && elementSelectMap['price'] != '' && (elementSelectMap['type'] == null || elementSelectMap['type'] == 'free')){
                                            
                                            if(widget.typeElement == 'entry_types'){
                                              Modals().showMessageConfirme(
                                                context,
                                                'Ingresso',
                                                'Vuoi procedere al checkout?',
                                                () async{
                                                  Navigator.pushNamed(
                                                    context, 
                                                    '/checkout',
                                                    arguments: {'entry_type' : elementSelectMap }
                                                  );
                                                },
                                                (){
                                                  Navigator.pop(context);
                                                }
                                              );
                                            }else if(widget.typeElement == 'products'){
                                              Modals().showMessageConfirme(
                                                context,
                                                'Prodotto', 
                                                'Vuoi procedere al checkout?', 
                                                () async{
                                                  Navigator.pushNamed(
                                                    context, 
                                                    '/checkout',
                                                    arguments: {'product' : elementSelectMap }
                                                  );
                                                },
                                                (){
                                                  Navigator.pop(context);
                                                }
                                              );
                                            }
                                          }else if(elementSelectMap.isNotEmpty && (elementSelectMap['price'] == null || elementSelectMap['price'] == '' || elementSelectMap['type'] == 'invite')){
                                            if(elementSelectMap['type'] == null || elementSelectMap['type'] == 'free'){
                                              Modals().showMessageConfirme(
                                                context, 
                                                '${widget.typeElement ==  'entry_types' ? 'Ingresso' : 'Prodotto'}', 
                                                '${widget.typeElement ==  'entry_types' ? 'Vuoi ottenere un biglietto?' : 'Vuoi ottenere un prodotto?'}', 
                                                () async{
                                                  dynamic data;
              
                                                  if(widget.typeElement == 'entry_types'){
                                                    data = await ApiEvent().getEntryType(elementSelectMap['id']);
                                                  }else{
                                                    data = await ApiEvent().getProduct(elementSelectMap['id']);
                                                  }
                                                  if(data.isNotEmpty && data['status']){
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Modals().showMessage(context,'success','INGRESSO OTTENUTO');
                                                    await widget.loadData();
                                                    if (mounted) {
                                                      setState(() {
                                                      
                                                      });
                                                    }
                                                  }else{
                                                    Navigator.pop(context);
                                                    Modals().showMessage(context,'error','${data['error']}');
                                                    await widget.loadData();
                                                    setState(() {
                                                    
                                                    });
                                                  }
                                                }, 
                                                (){
                                                  Navigator.pop(context);
                                                }
                                              );
                                            }else if(elementSelectMap['type'] != null && elementSelectMap['type'] == 'invite'){
                                              List collaboratorsWithEntry = [];
                                              if (widget.collaborators.isNotEmpty) {
                                                for (var collaborator in widget.collaborators) {
                                                  if (collaborator['entry_types_owned'] != null &&
                                                      collaborator['entry_types_owned'].isNotEmpty) {
                                                    for (var entry in collaborator['entry_types_owned']) {
                                                      if (entry['label'] == elementSelectMap['label'] &&
                                                          entry['stock'] > 0) {
                                                        // Controlla se già presente per id
                                                        bool alreadyAdded = collaboratorsWithEntry.any(
                                                          (c) => c['id'] == collaborator['id'],
                                                        );

                                                        if (!alreadyAdded) {
                                                          collaboratorsWithEntry.add(collaborator);
                                                        }

                                                        break; // esci dal ciclo degli entry se già trovato valido
                                                      }
                                                    }
                                                  }
                                                }
                                              }

                                              Modals().tickets(context, 
                                                Container(
                                                  padding: EdgeInsets.all(20),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Icon(CupertinoIcons.ticket, size: 40,color: mainColor,),
                                                            Text(
                                                              ' Riepilogo',
                                                              style: TextStyle(
                                                                color: textColor,
                                                                fontSize: textMidHight,
                                                                fontWeight: FontWeight.w800
                                                              ),
                                                            ),
              
                                                          ],
                                                        ),
                                                        Text(
                                                          'Prima di confermare, controlla se la tua scelta è corretta, e individua il PR a cui vuoi richiedere l’accesso',
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: textMid,
                                                            fontWeight: FontWeight.w500
                                                          ),
                                                        ),
                                                        Divider(),

                                                        Container(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              if(elementSelectMap.isNotEmpty)
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      maxLines: 3,
                                                                      '${elementSelectMap['label']}', // Usa elementSelectMap invece di tab
                                                                      style: TextStyle(
                                                                        overflow: TextOverflow.ellipsis,
                                                                        color: mainColor,
                                                                        fontSize: textMidHight,
                                                                        fontWeight: FontWeight.w500
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if(elementSelectMap['price'] != null)
                                                                  Container(
                                                                    child: Text(
                                                                      '${elementSelectMap['price']}€', // Usa entry invece di tab
                                                                      style: TextStyle(
                                                                        color: mainColor,
                                                                        fontSize: textMidHight,
                                                                        fontWeight: FontWeight.w500
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              if(elementSelectMap['fairplay_min'] != null)
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'fair play richiesto: ', // Usa elementSelectMap invece di tab
                                                                    style: TextStyle(
                                                                      color: textColor,
                                                                      fontSize: textMid,
                                                                      fontWeight: FontWeight.w300
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${elementSelectMap['fairplay_min']}', // Usa elementSelectMap invece di tab
                                                                    style: TextStyle(
                                                                      color: textColor,
                                                                      fontSize: textMid,
                                                                      fontWeight: FontWeight.w800
                                                                    ),
                                                                  ),
                                                                  if(int.parse(USER['fairplay'].toString()) >=  int.parse(elementSelectMap['fairplay_min'].toString())) 
                                                                  Container(
                                                                    margin: EdgeInsets.all(3),
                                                                    padding: EdgeInsets.all(2),
                                                                    decoration: BoxDecoration(
                                                                      color: greenColor,
                                                                      borderRadius: BorderRadius.circular(500),
                                                                    ),
                                                                    child: Icon(Icons.check, color: Colors.white,size: 10,),
                                                                  ),
                                                                  if(int.parse(USER['fairplay'].toString()) < int.parse(elementSelectMap['fairplay_min'].toString())) 
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
                                                              if(int.parse(elementSelectMap['seats'].toString()) > 1)
                                                              Row(
                                                                children: [
                                                                  Icon(Icons.person, color: mainColor),
                                                                  Text(
                                                                    '${elementSelectMap['seats']}', // Usa elementSelectMap invece di tab
                                                                    style: TextStyle(
                                                                      color: mainColor,
                                                                      fontSize: textMid,
                                                                      fontWeight: FontWeight.w800
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // if(elementSelectMap['description'] != null)
                                                              // Text(
                                                              //   '${elementSelectMap['description']}', // Usa elementSelectMap invece di tab
                                                              //   maxLines: 3,
                                                              //   overflow: TextOverflow.ellipsis,
                                                              //   style: TextStyle(
                                                              //     color: textColorSecondary,
                                                              //     fontSize: textLow,
                                                              //     fontWeight: FontWeight.w400
                                                              //   ),
                                                              // ),
              
                                                              ...List.generate(
                                                                elementSelectMap['products'] != null && elementSelectMap['products'].isNotEmpty ? elementSelectMap['products'].length : 0,
                                                                (index){
                                                                  return Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                          ),
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Icon(Icons.local_bar,color: textColor,),
                                                                                  Text(
                                                                                    '${elementSelectMap['products'][index]['label']}',
                                                                                    style: TextStyle(
                                                                                      fontSize: textMid,
                                                                                      color: textColor,
                                                                                      fontWeight: FontWeight.w800
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              // Text(
                                                                              //   '${elementSelectMap['products'][index]['description']}'
                                                                              // ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  );
                                                                }
                                                              )
                                                            ],
                                                          ),
                                                        ),

                                                        Divider(),

                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Invia invito a ',
                                                              style: TextStyle(
                                                                color: mainColor,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: textMid
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            'Selezionando il PR la tua richiesta verrà immediatamente notificata',
                                                            maxLines: 4,
                                                            style: TextStyle(
                                                              color: textColor,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: textMid
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        ...List.generate( collaboratorsWithEntry.isNotEmpty ? collaboratorsWithEntry.length : 0,
                                                        (index_) {
                                                          return Container(
                                                            margin: EdgeInsets.only(top: 10),
                                                            child: ElevatedButton(
                                                              onPressed: () async{
                                                                if(elementSelectMap['fairplay_min'] != null && int.parse(USER['fairplay'].toString()) < int.parse(elementSelectMap['fairplay_min'].toString())){
                                                                  Modals().showMessage(context, 'error', 'Fairplay insufficiente');
                                                                  return; // fairplay insufficiente
                                                                }
                                                                Modals().loader(context);
                                                                setState(() {
                                                                  
                                                                });
                                                                dynamic data = await ApiEvent().getEntryType(elementSelectMap['id'], collaboratorId: int.parse(collaboratorsWithEntry[index_]['id'].toString()));
                                                                if(data['status'] != false){
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  Modals().showMessage(context,'success','RICHIESTA INVIATA AL COLLABORATORE');
                                                                  widget.loadData();
                                                                }else{
                                                                  Navigator.pop(context);
                                                                  Modals().showMessage(context,'error','${data['error']}');
                                                                }
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: backgroundColorTheme, // Colore di sfondo
                                                                foregroundColor: backgroundColorTheme, // Colore del testo/icona
                                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10), // Bordo arrotondato
                                                                ),
                                                                elevation: 0, // Ombra
                                                              ),
                                                              child: Container(
                                                                color: const Color.fromARGB(0, 0, 0, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                          width: 2,
                                                                          color: mainColor,
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(8),
                                                                        child: Image.network(
                                                                          "${collaboratorsWithEntry[index_]['picture_image_url'] ?? BASE_URL+collaboratorsWithEntry[index_]['picture']}${ver()}",
                                                                          height: 50,
                                                                          width: 50,
                                                                          fit: BoxFit.cover,
                                                                          errorBuilder: (context, error, stackTrace) {
                                                                            return Container(
                                                                              width: 50,
                                                                              height: 50,
                                                                              color: Colors.grey,
                                                                              child: Icon(Icons.person),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 10,),
                                                                    Expanded(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            '${collaboratorsWithEntry[index_]['name']}${collaboratorsWithEntry[index_]['surname']}',
                                                                            style: TextStyle(
                                                                              fontSize: textMid,
                                                                              fontWeight: FontWeight.w800,
                                                                              color: textColor
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                '@${collaboratorsWithEntry[index_]['nickname']}',
                                                                                style: TextStyle(
                                                                                  fontSize: textMid,
                                                                                  fontWeight: FontWeight.w300,
                                                                                  color: collaboratorsWithEntry[index_]['gender'] == 'M' ? maleColor : femaleColor
                                                                                ),
                                                                              ),
                                                                              if(collaboratorsWithEntry[index_]['gender'] == 'M')
                                                                              Icon(Icons.male,size: 20, color: maleColor,),
                                                                              if(collaboratorsWithEntry[index_]['gender'] == 'F')
                                                                              Icon(Icons.female,size: 20, color: femaleColor,),
                                                                            ],
                                                                          ),
                                                                          
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              );
                                            }
                                          setState(() {
                                            
                                          });
                                        
                                          }
                                        } : null,
                                        child: Opacity(
                                          opacity: isAvailable ? 1.0 : 0.4,
                                          child: Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: IntrinsicHeight(
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                        child: Center(
                                                          child: RotatedBox(
                                                            quarterTurns: 4, // 1 = 90°, 2 = 180°, 3 = 270°
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                if(widget.typeElement == 'entry_type')
                                                                Text(
                                                                  softWrap: false,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  '${widget.typeElement == 'entry_type' ? entry['category'] : ''}',
                                                                  style: TextStyle(
                                                                    fontSize: textMidHight,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                                if(widget.typeElement == 'products')
                                                                Icon(Icons.shopping_basket, color: backgroundColor,size: textHight, )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: backgroundColor,
                                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),topRight: Radius.circular(20))
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                        if(entry != null)
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                maxLines: 3,
                                                                '${entry['label']}', // Usa entry invece di tab
                                                                style: TextStyle(
                                                                  overflow: TextOverflow.ellipsis,
                                                                  color: mainColor,
                                                                  
                                                                  fontSize: textMid,
                                                                  fontWeight: FontWeight.w500
                                                                ),
                                                              ),
                                                            ),
                                                            if(entry['price'] != null)
                                                            Text(
                                                              '${entry['price']}€', // Usa entry invece di tab
                                                              style: TextStyle(
                                                                color: mainColor,
                                                                fontSize: textMid,
                                                                fontWeight: FontWeight.w500
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if(entry['fairplay_min'] != null)
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'fair play richiesto: ', // Usa entry invece di tab
                                                              style: TextStyle(
                                                                color: textColor,
                                                                fontSize: textMid,
                                                                fontWeight: FontWeight.w300
                                                              ),
                                                            ),
                                                            Text(
                                                              '${entry['fairplay_min']}', // Usa entry invece di tab
                                                              style: TextStyle(
                                                                color: textColor,
                                                                fontSize: textMid,
                                                                fontWeight: FontWeight.w800
                                                              ),
                                                            ),
                                                            if(int.parse(USER['fairplay'].toString()) >=  int.parse(entry['fairplay_min'].toString())) 
                                                            Container(
                                                              margin: EdgeInsets.all(3),
                                                              padding: EdgeInsets.all(2),
                                                              decoration: BoxDecoration(
                                                                color: greenColor,
                                                                borderRadius: BorderRadius.circular(500),
                                                              ),
                                                              child: Icon(Icons.check, color: Colors.white,size: 10,),
                                                            ),
                                                            if(int.parse(USER['fairplay'].toString()) < int.parse(entry['fairplay_min'].toString())) 
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
                                                        
                                                        if(entry['description'] != null)
                                                        Text(
                                                          '${entry['description']}', // Usa entry invece di tab
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: textColorSecondary,
                                                            fontSize: textLowMid,
                                                            fontWeight: FontWeight.w400
                                                          ),
                                                        ),
                                                        
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            if(entry['seats'] != null && int.parse(entry['seats'].toString()) > 1)
                                                            Row(
                                                              children: [
                                                                Icon(Icons.group, color: textColor),
                                                                Text(
                                                                  '${entry['seats']}', // Usa entry invece di tab
                                                                  style: TextStyle(
                                                                    color: textColor,
                                                                    fontSize: textMid,
                                                                    fontWeight: FontWeight.w800
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(''),
                                                          ],
                                                        ),
                                                    
                                                        ...List.generate(
                                                          entry['products'] != null && entry['products'].isNotEmpty ? entry['products'].length : 0,
                                                          (index){
                                                            return Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                    ),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Icon(Icons.local_bar, color: textColor,),
                                                                            Text(
                                                                              '${entry['products'][index]['label']}',
                                                                              style: TextStyle(
                                                                                fontSize: textMid,
                                                                                color: textColor,
                                                                                fontWeight: FontWeight.w500
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                          
                                                                        if(entry['products'][index]['description'] != null)
                                                                        Text(
                                                                          '${entry['products'][index]['description']}',
                                                                          style: TextStyle(
                                                                            color: textColorSecondary
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            );
                                                          }
                                                        ),
                                                        
                                                        // Pulsante Aggiungi al Carrello o messaggio disponibilità
                                                        if(entry['price'] != null && entry['price'] != '')
                                                        Container(
                                                          margin: EdgeInsets.only(top: 10),
                                                          width: double.infinity,
                                                          child: isAvailable 
                                                            ? ElevatedButton.icon(
                                                                onPressed: () {
                                                                  addToCart(entry);
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text('${entry['label']} aggiunto al carrello'),
                                                                      duration: Duration(seconds: 1),
                                                                      backgroundColor: greenColor,
                                                                    ),
                                                                  );
                                                                },
                                                                icon: Icon(Icons.add_shopping_cart, size: 18),
                                                                label: Text(
                                                                  getItemQuantityInCart(entry) > 0 
                                                                    ? 'Nel carrello (${getItemQuantityInCart(entry)})' 
                                                                    : 'Aggiungi al Carrello'
                                                                ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: getItemQuantityInCart(entry) > 0 ? greenColor : mainColor.withAlpha(200),
                                                                  foregroundColor: Colors.white,
                                                                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                  ),
                                                                  elevation: 3,
                                                                ),
                                                              )
                                                            : Container(
                                                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.red.withAlpha(50),
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  border: Border.all(color: Colors.red.withAlpha(100), width: 1),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Icon(Icons.schedule, color: Colors.red, size: 18),
                                                                    SizedBox(width: 8),
                                                                    Flexible(
                                                                      child: Text(
                                                                        getAvailabilityMessage(entry),
                                                                        style: TextStyle(
                                                                          color: Colors.red,
                                                                          fontSize: textMid,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                      );
                                    }else{
                                      return Container();
                                    }
                                    
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
              ),    
                ],
              ),
            ),
          )
          
        ],
      ),
    );
  }
}