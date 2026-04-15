// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:sballando/components/sb_footer_chat.dart';
import 'package:sballando/components/sb_header_chat.dart';
import 'package:sballando/sb_global.dart';

class SbScheletroChat extends StatefulWidget {
  Widget content;
  Function? loadData;
  bool? home;

  SbScheletroChat({super.key, required this.content, this.loadData, this.home});

  @override
  State<SbScheletroChat> createState() => SbScheletroChatState();
}

class SbScheletroChatState extends State<SbScheletroChat> {
  final ScrollController _scrollController = ScrollController();
  final bool _showHeader = true;
  final bool _showFooter = true;
  List events = [];
  List locations = [];
  List users = [];
  bool loader = false;

  @override
  void initState() {
    super.initState();

    // Aggiungi un listener per monitorare lo scrolling
    // _scrollController.addListener(() {
    //   double offset = _scrollController.offset;
    //   // Soglia per evitare aggiornamenti troppo frequenti
    //   if (offset > _lastOffset + 5) {
    //     // Scrolling verso il basso: nascondi header e footer
    //     if (_showHeader || _showFooter) {
    //       setState(() {
    //         _showHeader = false;
    //         _showFooter = false;
    //       });
    //     }
    //   } else if (offset < _lastOffset - 5) {
    //     // Scrolling verso l'alto: mostra header e footer
    //     if (!_showHeader || !_showFooter) {
    //       setState(() {
    //         _showHeader = true;
    //         _showFooter = true;
    //       });
    //     }
    //   }
    //   _lastOffset = offset;
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Altezza dell'header; supponiamo 200
    double headerHeight = ONAIR == true ? 110 : 60;
    const double footerHeight = 100.0;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Container(
          child: Scaffold(
            backgroundColor: backgroundColorTheme,
            body: SizedBox(
              width: width(context, 100),
              height: height(context, 100),
              child: Stack(
                children: [
                  // Contenuto scrollabile
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: headerHeight,
                        bottom: footerHeight,
                      ),
                      child: widget.content,
                    ),
                  ),

                  // Header animato in alto
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top:
                        _showHeader
                            ? 0
                            : (ONAIR == true
                                ? -headerHeight + 50
                                : -headerHeight), // se _showHeader è false, sposta fuori dalla vista
                    left: 0,
                    right: 0,
                    height: headerHeight,
                    child: Column(
                      children: [
                        SbHeaderChat(
                          home: widget.home,
                          loadData: widget.loadData,
                        ),

                        //////////////////////////
                        /// SCELTA RICERCA
                        ///////////////////////
                      ],
                    ),
                  ),
                  // Footer animato in basso
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom:
                        _showFooter
                            ? 0
                            : -footerHeight, // se _showFooter è false, sposta fuori dalla vista
                    left: 0,
                    right: 0,
                    height: footerHeight,
                    child: SbFooterChat(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
