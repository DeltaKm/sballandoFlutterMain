// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:sballando/components/sb_footer.dart';
import 'package:sballando/components/sb_header.dart';
import 'package:sballando/sb_global.dart';

class SbScheletro extends StatefulWidget {
  Widget content;
  Function? loadData;
  bool? home;
  bool? animatedButton;
  List<Widget>? buttons;
  Icon? animatedButtonIcon;
  Function? animatedButtonFunction;

  SbScheletro({
    super.key, 
    this.animatedButtonFunction,
    this.animatedButtonIcon,
    required this.content, 
    this.loadData, 
    this.home,
    this.animatedButton,
    this.buttons,
  });

  @override
  State<SbScheletro> createState() => SbScheletroState();
}

class SbScheletroState extends State<SbScheletro> {
  final ScrollController  _scrollController      = ScrollController();
  bool                    _showHeader             = true;
  bool                    _showFooter             = true;
  List                    events                  = [];
  List                    locations               = [];
  List                    users                   = [];
  bool                    loader                  = false;
  double                  _lastOffset             = 0;

  @override
  void initState() {
    super.initState();

    // Aggiungi un listener per monitorare lo scrolling
    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      // Soglia per evitare aggiornamenti troppo frequenti
      if (offset > _lastOffset + 5) {
        // Scrolling verso il basso: nascondi header e footer
        if (_showHeader || _showFooter) {
          setState(() {
            _showHeader = false;
            _showFooter = false;
            updateFooterHeight(0);

          });
        }
      } else if (offset < _lastOffset - 5) {
        // Scrolling verso l'alto: mostra header e footer
        if (!_showHeader || !_showFooter) {
          setState(() {
            _showHeader = true;
            _showFooter = true;
            updateFooterHeight(100.0);
          });
        }
      }
      _lastOffset = offset;
    });
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Altezza dell'header; supponiamo 200
    double headerHeight = ONAIR == true ? 110 : 80;
    setState(() {
      FOOTERHEIGHT = 100.0; // Nuova altezza
    });
    return WillPopScope(
      onWillPop: () async {
        // Se non ci sono altre route da poppare
        if (!Navigator.of(context).canPop()) {
          // Fai qualcosa: per esempio, mostra un messaggio o torna alla home
          // oppure ritorna false per bloccare l’uscita
          return false;
        }
        return true; // Permette il pop
      },
      child: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Container(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: backgroundColorTheme,
              body: SizedBox(
                width: width(context, 100),
                height: height(context, 100),
                child: Stack(
                  children: [
                    
                    // Contenuto scrollabile
                    RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thumbColor: mainColor,
                      radius: Radius.circular(8),
                      thickness: 6,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(), // ← Disabilita il rimbalzo
                        controller: _scrollController,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: headerHeight,
                            bottom: FOOTERHEIGHT + 40,
                          ),
                          child: widget.content,
                        ),
                      ),
                    ),
                    if (SHOWOVERLAY)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          // Toccare l'overlay lo nasconde
                          setState(() {
                            SHOWOVERLAY = false;
                          });
                        },
                        child: Container(
                          // Colore semi-trasparente per enfatizzare l'overlay
                          color: Colors.black.withOpacity(0.7),
                          
                        ),
                      ),
                    ),
                    // Bottone animato principale
                    if(widget.animatedButton != null && widget.animatedButton! == true)
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: _showFooter ? 120 : -FOOTERHEIGHT + 120, // se _showFooter è false, sposta fuori dalla vista
                      right: 20,
                      child: GestureDetector(
                        onTap: () {
                          widget.animatedButtonFunction!();
                          setState(() { });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(200),
                            boxShadow: SHOWOVERLAY 
                              ? [BoxShadow(
                                  color: mainColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )]
                              : [],
                          ),
                          child: AnimatedRotation(
                            duration: Duration(milliseconds: 300),
                            turns: SHOWOVERLAY ? 0.125 : 0, // Rotazione di 45 gradi (1/8 di giro)
                            child: widget.animatedButtonIcon,
                          ),
                        ),
                      ),
                    ),
                    // Header animato in alto
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: _showHeader ? 0 : (ONAIR == true ? -headerHeight + 60 : -headerHeight), // se _showHeader è false, sposta fuori dalla vista
                      left: 0,
                      right: 0,
                      height: headerHeight,
                      child: Column(
                        children: [
                          SbHeader(
                            home: widget.home,
                            loadData: widget.loadData,
                            search: false,
                          ),

                          //////////////////////////
                          /// SCELTA RICERCA
                          ///////////////////////
                        ],
                      ),
                    ),
                    if(SHOWOVERLAY && widget.buttons != null)
                    ...List.generate(
                      widget.buttons!.length,
                      (index){
                        Widget button = widget.buttons![index];
                        return button;
                      }
                    ),
                    // Footer animato in basso
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: _showFooter ? 0 : - FOOTERHEIGHT, // se _showFooter è false, sposta fuori dalla vista
                      left: 0,
                      right: 0,
                      child: SbFooter(),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
