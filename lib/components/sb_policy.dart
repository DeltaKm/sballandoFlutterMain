import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbPolicy extends StatefulWidget {
  
  bool      policyValue;
  Function  update;
  bool      showError;


  SbPolicy({
    super.key,
    required this.policyValue,
    required this.update,
    required this.showError,
  });

  @override
  State<SbPolicy> createState() => SbPolicyState();
}

class SbPolicyState extends State<SbPolicy> {
  String    errorMessage      = 'Accetta le politiche di privacy';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      widget.policyValue = await getShared('bool', 'policy') ?? false;
      print(widget.policyValue);
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CheckboxListTile(
          activeColor: mainColor,
          contentPadding: EdgeInsets.zero,

          side: BorderSide(
            color: mainColor,  // Colore del bordo
            width: 1,            // Spessore del bordo
          ),
          title: Wrap(
            children: [
              SizedBox(
                width: width(context, 40),
                child: Text(
                  'Accetto i Termini e Condizioni di Sballando!',
                  style: TextStyle(
                    fontSize: textLowMid,
                    color: textColor
                  ),
                ),
              ),
            ],
          ),
          value: widget.policyValue,
          onChanged: (bool? newValue) {
            widget.policyValue = newValue ?? false;
            saveShared('bool', newValue, 'policy');
            widget.update();
            setState(() {
              
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if(widget.showError)
         Container(
           width: double.infinity,
           height: 50,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             border: Border.all(width: 1,color: Colors.red),
             color: Colors.red.withAlpha(50),
           ),
      
           child: Center(
             child: Text(
               '$errorMessage',
               style: TextStyle(
                 color: Colors.red,
                 fontSize: textLow
               ),
             ),
           ),
         ),     
      ],
    );
  }
}