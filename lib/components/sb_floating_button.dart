import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbFloatingButton extends StatefulWidget {
  bool         showFooter;
  double         footerHeight;
  bool        activeButtonAnimated;

  SbFloatingButton({
    super.key,
    required this.showFooter,
    required this.footerHeight,
    required this.activeButtonAnimated,
  });

  @override
  State<SbFloatingButton> createState() => SbFloatingButtonState();
}

class SbFloatingButtonState extends State<SbFloatingButton> {
  @override
  Widget build(BuildContext context) {
    return 
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: widget.showFooter ? widget.footerHeight + 0 : 20,
          right: 20,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                onPressed: () async {
                  setState(() {
                    widget.activeButtonAnimated = widget.activeButtonAnimated;
                  });
                },
                icon: Icon(
                  Icons.settings,
                  color: backgroundColor,
                  size: 30,
                ),
              ),
            ),
          ),
        );

        // Le icone che compaiono una dopo l'altra con animazione


        // Quando si chiude, facciamo scendere le icone
        // if (widget!.activeButtonAnimated)
        //   ...List.generate(5, (index) {
        //     // Calcoliamo l'offset in base alla visibilità del footer
        //     double offset = 70.0 * (index + 1);

        //     return AnimatedPositioned(
        //       duration: Duration(milliseconds: 300), // Durata fissa per tutte
        //       bottom: widget.showFooter
        //           ? widget.footerHeight - offset // Se il footer è visibile, le icone vanno più in basso
        //           : 0 - offset, // Se il footer non è visibile, le icone scendono fuori dalla vista
        //       right: 20,
        //       child: SizedBox(
        //         width: 50,
        //         height: 50,
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: mainColor,
        //             borderRadius: BorderRadius.circular(50),
        //           ),
        //           child: IconButton(
        //             onPressed: () async {
        //               setState(() {

        //               });
        //             },
        //             icon: Icon(
        //               Icons.settings,
        //               color: backgroundColor,
        //               size: 30,
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   }),
        // if (widget.activeButtonAnimated)
        //   ...List.generate(5, (index) {
        //     // Calcoliamo l'offset in base alla visibilità del footer
        //     double offset = 70.0 * (index + 1);

        //     return AnimatedPositioned(
        //       duration: Duration(milliseconds: 300), // Durata fissa per tutte
        //       bottom: widget.showFooter
        //           ? widget.footerHeight + offset // Se il footer è visibile, aggiungiamo lo spazio del footer
        //           : 20 + offset, // Altrimenti partiamo da una posizione fissa
        //       right: 20,
        //       child: SizedBox(
        //         width: 50,
        //         height: 50,
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: mainColor,
        //             borderRadius: BorderRadius.circular(50),
        //           ),
        //           child: IconButton(
        //             onPressed: () async {
        //               setState(() {

        //               });
        //             },
        //             icon: Icon(
        //               Icons.settings,
        //               color: backgroundColor,
        //               size: 30,
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   }),
    
  }
}