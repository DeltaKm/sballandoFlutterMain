import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_input.dart';
import 'package:sballando/components/sb_qr_generator.dart';
import 'package:sballando/sb_global.dart';
import 'package:url_launcher/url_launcher.dart';

class Modals {
  void loader(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero, // Rimuove il padding interno
          content: Container(
            color: Colors.transparent,
            width: 300,
            height: 300,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50, // Larghezza dello spinner
                  height: 50, // Altezza dello spinner
                  child: CircularProgressIndicator(
                    color: mainColor,
                    strokeWidth: 10, // Spessore della linea dello spinner
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  

  void modalUpdateVersion(BuildContext context, String title, String body,{String? webRoute}){
    showDialog(
      barrierDismissible:false,
      context: context, 
      builder: (context){
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 250)
            ],
          ),
          content: SizedBox(
            width: 700,
            height: 100,
            child: Center(
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: textMid,color: textColor,fontWeight: FontWeight.w600),
                  ),
                  Text(
                    body,
                    style: TextStyle(fontSize: textMid,color: textColor,fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if(webRoute != null)
            Center(
              child: SbButtonMaincolor(
                label: 'Aggiorna',
                function: () async{
                  final Uri url = Uri.parse('$webRoute'); // Sostituisci con l'URL desiderato
                  try {
                    // Usa launchUrl per aprire l'URL nel browser
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    throw 'Non è possibile aprire l\'URL: $url';
                  }
                },
              ),
            ),
          ]
        );
      }
    );
  }

  Future modalMusicGenres(
    BuildContext context,
    Function action,
    List genres,
  ) async {
    final TextEditingController searchController = TextEditingController();
    List musicGenres = [];
    dynamic data = await ApiEvent().getMusicGenres();
    bool loading = false;
    
    if (data != null && data['status'] != false) {
      musicGenres = data['music_genres'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // serve per poter controllare altezza
      backgroundColor: Colors.transparent, // togli sfondo bianco default
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              widthFactor: 1,
              child: Container(
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generi musicali',
                      style: TextStyle(
                        color: mainColor,
                        fontSize: textMid,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 20),
                    SbInput(
                      controller: searchController,
                      function: () async {
                        setStateModal(() {
                          loading = true;
                        });
                        dynamic searchData = await ApiEvent().getMusicGenres(
                          search: searchController.text,
                        );
                        if (searchData != null &&
                            searchData['status'] != false) {
                          setStateModal(() {
                            loading = false;
                            musicGenres = searchData['music_genres'];
                          });
                        }
                      },
                      obscureText: false,
                      label: 'Cerca generi',
                      icon: Icons.search,
                      validatorFunction: (value) {},
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'I più richiesti',
                              style: TextStyle(
                                color: textColorSecondary,
                                fontSize: textLowMid,
                              ),
                            ),
                            if (loading == true)
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  padding: EdgeInsets.all(30),
                                  child: CircularProgressIndicator(
                                    color: mainColor,
                                    strokeWidth:
                                        10, // Spessore della linea dello spinner
                                  ),
                                ),
                              ),
                            if (loading == false)
                              ...List.generate(
                                musicGenres.isNotEmpty && musicGenres.isNotEmpty
                                    ? musicGenres.length
                                    : 0,
                                (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (genres.any(
                                        (g) =>
                                            g['id'] == musicGenres[index]['id'],
                                      )) {
                                        Modals().showMessage(
                                          context,
                                          'error',
                                          'Genere Musicale già presente',
                                        );
                                      } else {
                                        action(musicGenres[index]);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1,
                                            color: grayLight,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            musicGenres[index]['label'],
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: textMidHight,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void modalQrCode(
    BuildContext context,
    String text,
    int userId,
    int eventId,
    Map element,
    Map event,
    {Widget? widget}
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero, // Rimuove il padding interno
          content: Container(
            width: width(context, 100),
            height: widget != null  ? height(context, 80) : height(context, 50),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${event['title']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mainColor,
                    fontSize: textHight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${element['label']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: textHight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                SizedBox(height: 20),
                SizedBox(
                  width: width(context, 50),
                  child: SbQrGenerator(
                    string: creaStringaBase64(text, eventId, userId, text == 'product' ? element['id'].toString() : null),
                  ),
                ),
                if(widget != null)
                widget
              ],
            ),
          ),
        );
      },
    );
  }

  void showImage(BuildContext context,String text,) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          contentPadding: EdgeInsets.zero, // Rimuove il padding interno
          content: Container(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(20),
              child: Image.network(
                '$text',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  void modalGiftProducts(
    BuildContext context,
    List products,
    Map user,
    Function sendMessage,
  ) async {
    Map productSelect = {};
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              contentPadding: EdgeInsets.zero, // Rimuove il padding interno
              content: Container(
                height: height(context, 60),
                width: width(context, 100),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Invia un regalo!',
                      style: TextStyle(
                        color: textColor,
                        fontSize: textMidHight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(Icons.card_giftcard, color: mainColor, size: 50),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (products.isEmpty)
                              Text(
                                'Nessun prodotto per questo evento',
                                style: style1,
                              ),
                              SbButtonMaincolor(label: 'Acquista', function: (){
                                Navigator.pushNamed(context, '/eventShow', arguments: { 'eventId' : EVENTONAIR['id'],'buyProducts' : true});
                              }),
                            ...List.generate(products.length, (index) {
                              Map product = products[index];
                              
                              return GestureDetector(
                                onTap: () {
                                  if (productSelect == product) {
                                    productSelect = {};
                                  } else {
                                    productSelect = product;
                                  }

                                  setStateModal(() {});
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 70,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              product['label'],
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              '${product['stock'].toString()} rimanenti',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: textLowMid
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          5000,
                                        ),
                                        border: Border.all(
                                          width: 1,
                                          color: grayLight,
                                        ),
                                      ),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5000,
                                          ),
                                          color:
                                              product['label'] ==
                                                      productSelect['label']
                                                  ? mainColor
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: SbButtonMaincolor(
                        disable: productSelect.isNotEmpty ? false : true,
                        label: 'INVIA',
                        function: () {
                          if (productSelect.isNotEmpty) {
                            Modals().showMessageConfirme(
                              context,
                              'Trasferisci',
                              'Sei sicuro di voler trasferire questo prodotto?',
                              () async {
                                Navigator.pop(context);
                                Modals().loader(context);
                                try {
                                  dynamic res = await ApiEvent().transferProduct(productSelect['id'], user['id']);

                                  if (res['status'] == true) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    // Modals().showMessage(
                                    //   context,
                                    //   'success',
                                    //   'Prodotto trasferito con successo',
                                    // );

                                    sendMessage(productSelect);
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
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void modalChangePassword(BuildContext context) async {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmePasswordController =
        TextEditingController();
    final changePasswordKey = GlobalKey<FormState>();
    bool acceptedPolicy = await getShared('bool', 'policy') ?? false;
    String errorMessage = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // serve per poter controllare altezza
      backgroundColor: Colors.transparent, // togli sfondo bianco default
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              widthFactor: 1,
              child: Container(
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Form(
                  key: changePasswordKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Cambia password',
                          style: TextStyle(
                            color: mainColor,
                            fontSize: textMid,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 20),
                        SbInput(
                          controller: oldPasswordController,
                          obscureText: false,
                          label: 'Vecchia Password',
                          typePassword: true,
                          validatorFunction: (value) {
                            String error = '';
                            if (error == '') {
                              error = validatorRequired(value!);
                            }

                            if (error == '') {
                              error = validatorPassword(value!);
                            }

                            if (error == '') {
                              error = validatorLenght(value!, 5, 15);
                            }

                            if (error != '') {
                              return error;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        SbInput(
                          controller: passwordController,
                          obscureText: false,
                          label: 'Nuova Password',
                          typePassword: true,
                          validatorFunction: (value) {
                            String error = '';
                            if (error == '') {
                              error = validatorRequired(value!);
                            }

                            if (error == '') {
                              error = validatorPassword(value!);
                            }

                            if (error == '') {
                              error = validatorLenght(value!, 5, 15);
                            }

                            if (error != '') {
                              return error;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        SbInput(
                          controller: confirmePasswordController,
                          obscureText: false,
                          label: 'Conferma Nuova Password',
                          typePassword: true,
                          validatorFunction: (value) {
                            String error = '';
                            if (error == '') {
                              error = validatorRequired(value!);
                            }

                            if (error == '') {
                              error = validatorConfirmePassword(
                                value!,
                                passwordController.text,
                              );
                            }

                            if (error != '') {
                              return error;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "La password deve contenere almeno una lettera maiuscola,una lettera minuscola,un numero e un carattere speciale.",
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: textLowMid,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // SbPolicy(
                        //   policyValue: _acceptedPolicy,
                        //   showError: !_acceptedPolicy,
                        //   update: () async {
                        //     _acceptedPolicy = !_acceptedPolicy;
                        //     _acceptedPolicy = await getShared('bool', 'policy');
                        //   },
                        // ),
                        SizedBox(height: 20),

                        if (errorMessage != '')
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1, color: Colors.red),
                              color: Colors.red.withAlpha(50),
                            ),

                            child: Center(
                              child: Text(
                                '$errorMessage',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: textLow,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 20),

                        Center(
                          child: SbButtonMaincolor(
                            label: 'Salva',
                            fullWidth: true,
                            function: () async {
                              Modals().loader(context);
                              if (acceptedPolicy == false) {
                                setStateModal(() {});
                                Navigator.pop(context);
                                return;
                              } else {
                                setStateModal(() {});
                              }

                              if (changePasswordKey.currentState!.validate()) {
                                dynamic data = await ApiUser().changePassword(
                                  oldPasswordController.text,
                                  passwordController.text,
                                );
                                if (data != null && data['status'] == true) {
                                  errorMessage = '';
                                  print(data);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Modals().showMessage(
                                    context,
                                    'success',
                                    'Password aggiornata correttamente',
                                  );
                                } else {
                                  errorMessage = data['error'];
                                  Navigator.pop(context);
                                  setStateModal(() {});
                                }
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showMessage(BuildContext context, String type, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Programma la chiusura automatica dopo 3 secondi
        Future.delayed(Duration(seconds: 2), () {
          try {
            if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // Ignora errori se il context non è più valido
          }
        });

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
                  '$message',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: textMidHight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                if (type == 'error')
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                if (type == 'success')
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  void showMessageScan(BuildContext context, String type, String message, Map product) {
    showDialog(
      context: context,
      builder: (context) {
        // Programma la chiusura automatica dopo 3 secondi


        return AlertDialog(
          backgroundColor: backgroundColor,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: width(context, 100),
            height: 250,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$message',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: textMidHight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${product['label']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mainColor,
                    fontSize: textHight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
                if (type == 'error')
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                if (type == 'success')
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMessageConfirme(
    BuildContext context,
    String title,
    String message,
    Function onConfirme,
    Function onCancel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: mainColor,
          insetPadding: EdgeInsets.all(10), // margine esterno
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: textMidHight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: textMidHight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SbButtonMaincolor(
                        label: 'Annulla',
                        color: backgroundColor,
                        textColor: mainColor,
                        function: onCancel,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SbButtonMaincolor(
                        label: 'Conferma',
                        function: onConfirme,

                        color: Color(0xFF212938),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void reportUserModal(
    BuildContext context,
    String title,
    String userId,
  ) {
    showDialog(
      
      context: context,
      builder: (context) {
        final TextEditingController reportController = TextEditingController();
        return Dialog(
          
          backgroundColor: mainColor,
          insetPadding: EdgeInsets.all(10), // margine esterno
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: textMidHight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: reportController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Per quale motivo vuoi segnalare questo utente?',
                    border: OutlineInputBorder(),
                  ),
                ),
     
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SbButtonMaincolor(
                        label: 'Annulla',
                        color: backgroundColor,
                        textColor: mainColor,
                        function: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SbButtonMaincolor(
                        label: 'Invia',
                        function: () async{
                          dynamic data = await ApiUser().sendReport(userId,reportController.text);
                          if(data['status'] == true){
                            Navigator.pop(context);
                            Modals().showMessage(context, 'success', 'Report inviato');
                          }else{
                            Navigator.pop(context);
                            Modals().showMessage(context, 'error', '${data['error']}');
                          }
                        },
                        color: Color(0xFF212938),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void scanner(BuildContext context, String text) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Sfondo trasparente
          insetPadding: EdgeInsets.zero, // Rimuove padding intorno al dialog
          child: Container(
            color: Colors.transparent,
            width: 300,
            height: 300,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50, // Larghezza dello spinner
                  height: 50, // Altezza dello spinner
                  child: Text(''),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void tickets(BuildContext context, Widget content) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Sfondo trasparente
          insetPadding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Container(
                  height: height(context, 80),
                  width: width(context, 90),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: backgroundColorTheme,
                  ),
                  child: content,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, size: 24, color: textColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void filter(BuildContext context, Widget content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.transparent, // ✅ NIENTE OVERLAY!
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: IntrinsicHeight(
            child: Container(
              width: width(context, 90),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: backgroundColorTheme,
              ),
              child: content,
            ),
          ),
        );
      },
    );
  }
}
