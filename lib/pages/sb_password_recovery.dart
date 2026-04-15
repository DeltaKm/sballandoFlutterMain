import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_input.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbPasswordRecovery extends StatefulWidget {
  const SbPasswordRecovery({super.key});

  @override
  State<SbPasswordRecovery> createState() => SbPasswordRecoveryState();
}

class SbPasswordRecoveryState extends State<SbPasswordRecovery> {

  final                             _formKey                        = GlobalKey<FormState>();
  final TextEditingController       emailController                 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Center(
        child: Container(
          margin: EdgeInsets.only(top: 40),
          width: width(context, 90),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: backgroundColor
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recupero Password',
                style: TextStyle(
                  color: textColor,
                  fontSize: textMidHight,
                ),
              ),
              SizedBox(height: 10,),
              Text(
                'Inserisci la tua email per ricevere le istruzioni per il recupero della password',
                style: TextStyle(
                  color: textColorSecondary,
                  fontSize: textLowMid,
                ),
              ),
              SizedBox(height: 20,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SbInput(
                      controller: emailController, 
                      obscureText: false,
                      icon: Icons.email,
                      label: 'Email', 
                      validatorFunction: (value){
                       String error = '';
                        if(error == ''){
                          error =  validatorRequired(value!);
                        }
                         if(error == ''){
                          error =  validatorEmail(value!);
                        }
                        if(error != ''){
                          return error;
                        }
                      },
                    ),
                    SizedBox(height: 10,),
                    Center(
                      child: SbButtonMaincolor(
                        label: 'RINVIA EMAIL', 
                        function: () async{
                          Modals().loader(context);
                          if(_formKey.currentState!.validate()){
                            dynamic data = await ApiUser().passwordRecovery(emailController.text);
                            if(data != null && data.isNotEmpty && data['status'] != false){
                              Navigator.pop(context);
                              Modals().showMessage(context, 'success', 'Email inviata con successo!');
                            }else{
                              Navigator.pop(context);
                              Modals().showMessage(context, 'error', 'Errore durante l\'invio dell\'email!');

                            }
                          }
                        }
                      ),
                    )
                  ],
                )
              )
              
            ],
          ),
        ),
      )
    );
  }
}