import 'package:flutter/material.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbTest extends StatefulWidget {
  const SbTest({super.key});

  @override
  State<SbTest> createState() => SbTestState();
}

class SbTestState extends State<SbTest> {
  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Center(
        child: SizedBox(
          height: height(context, 80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: SbButtonMaincolor(
                      label: 'test',
                      function: () {
                        Modals().showMessage(context, 'success', 'hello');
                      },
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...List.generate(
                      3,
                    (index){
                      return Container(
                        child: Text('$index'),
                      );
                    }
                  ),
                  Container(
                    child: SbButtonMaincolor(
                      label: 'test',
                      function: () {
                        Modals().showMessageConfirme(
                          context,
                          'errore',
                          'sei sicuro di',
                          () {
                            print('ok');
                            Modals().loader(context);
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                           
                          },
                          () {
                            print('no');
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
