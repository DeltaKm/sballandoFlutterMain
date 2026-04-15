
import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbCreate extends StatefulWidget {
  const SbCreate({super.key});

  @override
  State<SbCreate> createState() => SbCreateState();
}

class SbCreateState extends State<SbCreate> {
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      // final args        = ModalRoute.of(context)!.settings.arguments as Map;

    });
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

    return SbScheletro(
      content: SizedBox(
        height: height(context, 70),
        child: Center(
          child: Text(
            'Uncoming',
            style: TextStyle(
              color: textColor,
              fontSize: textHight
            ),
          ),
        ),
      ),
      );
  }
}