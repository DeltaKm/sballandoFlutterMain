import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_input.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';

class SbRegister extends StatefulWidget {
  const SbRegister({super.key});

  @override
  State<SbRegister> createState() => SbRegisterState();
}

class SbRegisterState extends State<SbRegister> {

  final TextEditingController       nameController                  = TextEditingController();
  final TextEditingController       surnameController               = TextEditingController();
  final TextEditingController       nicknameController              = TextEditingController();
  final TextEditingController       birthdateController             = TextEditingController();
  final TextEditingController       sexController                   = TextEditingController();
  final TextEditingController       emailController                 = TextEditingController();
  final TextEditingController       passwordController              = TextEditingController();
  final TextEditingController       confirmePasswordController      = TextEditingController();
  final                             _formKey                        = GlobalKey<FormState>();
  String?                           _selectedValue;
  bool                              _acceptedPolicy                 = true;
  DateTime?                         selectedDate;
  bool                              errorPolicy                     = false;
  String                            errorMessage                    = '';
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Center(
        child: Container(
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.all(30),
          
          child: Column(
            children: [

              /////////
              /// CONTENUTO CARD
              /////////
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ENTRA IN ',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: textHight,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  Text(
                    'SBALLANDO!',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: textHight,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Crea il tuo account',
                    style: TextStyle(
                      color: textColorSecondary,
                      fontSize: textMid,
                      fontWeight: FontWeight.w300
                    ),
                  )
                ],
              ),

              SizedBox(height: 20,),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SbInput(
                      controller: nameController,
                      obscureText: false,
                      label: 'Nome',
                      validatorFunction: (value){
                        String error = '';
                        if(error == ''){
                          error =  validatorRequired(value!);
                        }
                
                        if(error == ''){
                          error =  validatorLenght(value!,3,40);
                        }
                        
                        if(error != ''){
                          return error;
                        }
                      },
                    ),

                    SizedBox(height: 20,),

                    SbInput(
                      controller: surnameController,
                      obscureText: false,
                      label: 'Cognome*',
                      validatorFunction: (value){
                        String error = '';
                        if(error == ''){
                          error =  validatorRequired(value!);
                        }
                
                        if(error == ''){
                          error =  validatorLenght(value!,3,40);
                        }
                        
                        if(error != ''){
                          return error;
                        }
                      },
                    ),

                    SizedBox(height: 20,),
      
                    SbInput(
                      controller: nicknameController,
                      obscureText: false,
                      label: 'Nickname*',
                      validatorFunction: (value){
                       String error = '';
                        if(error == ''){
                          error =  validatorRequired(value!);
                        }
                
                        if(error == ''){
                          error =  validatorLenght(value!,3,40);
                        }
                        
                        if(error != ''){
                          return error;
                        }
                      },
                    ),

                    SizedBox(height: 20,),

                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        
                        controller: birthdateController,
                        readOnly: true, // Importantissimo: evita apertura tastiera
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: textColor
                          ),
                          fillColor: backgroundColor,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5000),
                            borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5000),
                            borderSide: BorderSide(color: backgroundColor), // bordo normale
                          ),
                          labelText: 'Data di nascita*',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5000),
                            borderSide: BorderSide.none, // opzionale per stile più moderno
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La data è obbligatoria';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime today = DateTime.now();
                          DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);
                          
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? eighteenYearsAgo,
                            firstDate: DateTime(1900),
                            lastDate: eighteenYearsAgo,
                            locale: const Locale('it', 'IT'), // Imposta la lingua italiana
                          );
                       
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              birthdateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                      ),
                    ),

                    

                    SizedBox(height: 20,),

                    SbInput(
                      controller: emailController,
                      obscureText: false,
                      label: 'Email*',
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

                    SizedBox(height: 20,),

                    SbInput(
                      controller: passwordController,
                      obscureText: true,
                      label: 'Password*',
                      typePassword: true,
                      validatorFunction: (value){
                       String error = '';
                        if(error == ''){
                          error =  validatorRequired(value!);
                        }
                
                        if(error == ''){
                          error =  validatorPassword(value!);
                        }
                        
                        if(error == ''){
                          error =  validatorLenght(value!,5,15);
                        }
                        
                        if(error != ''){
                          return error;
                        }
                      },
                      
                    ),

                    SizedBox(height: 20,),

                    SbInput(
                      controller: confirmePasswordController,
                      obscureText: true,
                      typePassword: true,
                      label: 'Conferma Password*',
                      validatorFunction: (value){
                       String error = '';
                        if(error == ''){
                          error =  validatorRequired(value!);
                        }
                
                        if(error == ''){
                          error =  validatorConfirmePassword(value!,passwordController.text);
                        }
                        
                        if(error != ''){
                          return error;
                        }
                      },
                    ),

                    SizedBox(height: 20,),

                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        style: TextStyle(color: textColor),
                        dropdownColor: backgroundColor,
                        value: _selectedValue,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: textColor
                          ),
                          fillColor: backgroundColor,
                          filled: true,
                          labelText: 'Genere*', // come l'input label
                          border: OutlineInputBorder( // 👈 bordo con radius
                            borderRadius: BorderRadius.circular(5000),
                            borderSide: BorderSide.none, // 👈 bordo invisibile (opzionale)
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleziona il genere';
                          }
                          return null;
                        },
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                        },
                        items: ['UOMO', 'DONNA','ALTRO'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    SizedBox(height: 20,),
                    Column(
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
                                width: width(context, 80),
                                child: Text(
                                  'Registrandomi dichiaro di aver letto e accettato i Termini e Condizioni e la Privacy Policy.',
                                  style: TextStyle(
                                    fontSize: textLowMid,
                                    color: textColor
                                  ),
                                ),
                              ),
                            ],
                          ),
                          value: _acceptedPolicy,
                          onChanged: (bool? newValue) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return SizedBox(
                                  height: height(context, 90),
                                  width: width(context, 100),
                                  child: Column(
                                    children: [
                                      Container(
                                        color: backgroundColor,
                                        padding: EdgeInsets.all(20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Termini e condizioni',style: TextStyle(color: textColor,fontSize: textMid),),
                                            IconButton(onPressed: (){ Navigator.pop(context); }, icon: Icon(CupertinoIcons.xmark))
                                            
                                          ],  
                                        ),
                                      ),
                                      SizedBox(
                                        height: height(context, 70),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('''
                                      
Termni e Condiioni - Sballando


1. Registrazione e Accesso all’App
L’utilizzo dell’app Sballando è gratuito. Per accedere alle funzionalità, è richiesta la registrazione con
dati personali validi.
2. Acquisto Biglietti
Gli utenti possono acquistare biglietti per eventi pubblicati da organizzatori terzi attraverso l’app.
Ogni transazione comporta una commissione di €1,50 a favore del titolare dell’app.
3. Gestione Pagamenti
I pagamenti vengono processati tramite la piattaforma Stripe. L’app non memorizza dati di pagamento
e si affida a Stripe per la sicurezza delle transazioni.
4. Responsabilità degli Eventi
Sballando non è responsabile per l’organizzazione, la qualità o l’annullamento degli eventi. Ogni
evento è sotto la responsabilità dell’organizzatore che lo ha pubblicato.
5. Dati Personali e Privacy
I dati forniti durante la registrazione e l’uso dell’app sono trattati nel rispetto del Regolamento
Europeo 679/2016 (GDPR). È disponibile una Privacy Policy dettagliata all’interno dell’app.
6. Modifiche e Aggiornamenti
I Termini e Condizioni possono essere soggetti a modifiche. Gli utenti saranno informati tramite
notifica in-app o aggiornamenti della piattaforma.
7. Accettazione dei Termini
L’utilizzo dell’app implica l’accettazione piena e incondizionata dei presenti Termini e Condizioni.


Privacy Policy - Sballando


1. Titolare del trattamento
Il titolare del trattamento dei dati è DF SERVICE SRL START UP INNOVATIVA , con sede
legale legale in Maddaloni, Via Appia 1^ trav. n.4. – 81024 (CE) , P.IVA 04695290611
2. Finalità del trattamento
I dati personali degli utenti sono raccolti e trattati per finalità connesse all'utilizzo dell’app
Sballando, inclusi registrazione, gestione eventi, acquisto biglietti e comunicazioni relative ai
servizi.
3. Tipologie di dati trattati
I dati trattati includono: nome, cognome, email, numero di telefono, dati di pagamento (gestiti da
Stripe), dati tecnici di utilizzo dell’app.
4. Base giuridica del trattamento
Il trattamento si basa sul consenso dell’utente, sull’esecuzione di obblighi contrattuali e su obblighi
legali del Titolare.
5. Modalità del trattamento
I dati sono trattati in modo lecito, corretto e trasparente. Sono protetti mediante misure di sicurezza
adeguate per evitarne la perdita o l’accesso non autorizzato.
6. Conservazione dei dati
I dati saranno conservati per il tempo necessario a perseguire le finalità per cui sono stati raccolti e
comunque non oltre 10 anni, salvo obblighi di legge differenti.
7. Comunicazione a terzi
I dati potranno essere comunicati a fornitori di servizi tecnici (es. Stripe per i pagamenti), hosting,
consulenti legali e amministrativi, ove necessario.
8. Diritti dell’interessato
L’utente può richiedere in qualsiasi momento l’accesso, la rettifica, la cancellazione, la limitazione
del trattamento, la portabilità dei dati o opporsi al trattamento, scrivendo a
dfservice22@gmail.com
9. Cookie e dati di navigazione
L’app può utilizzare cookie o tecnologie simili per raccogliere informazioni di utilizzo. Maggiori
dettagli sono disponibili nella Cookie Policy.
10. Modifiche alla presente informativa
Il Titolare si riserva il diritto di modificare la presente Privacy Policy. Le modifiche saranno
comunicate tramite aggiornamento in-app.
                                      '''),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          SbButtonMaincolor(
                                            color: Colors.white,
                                            textColor: mainColor,
                                            label: 'Rifiuta', 
                                            function: (){
                                            _acceptedPolicy =  false;
                                            Navigator.pop(context);
                                            setState(() {

                                            });
                                          }),
                                          SbButtonMaincolor(
                                            label: 'Accetta', 
                                            function: (){
                                            _acceptedPolicy = true;
                                            Navigator.pop(context);
                                            setState(() {});
                                          }),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            );

                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
    
                      ],
                    ),

                    

                    if(errorMessage != '')
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
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: textLow
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    SbButtonMaincolor(
                      fullWidth: true,
                      label: 'Registrati', 
                      function: () async{
                        if(_acceptedPolicy == false){
                          errorMessage = 'Accetta i termini e condizioni e privacy e policy';
                          setState(() { });
                          print('accetta le policy');
                          return;
                        }
                        Modals().showMessageConfirme(
                          context, 
                          'Genere', 
                          'Confermi il tuo genere? Questa informazione è importante per il corretto funzionamento dell’app e per offrirti un\'esperienza personalizzata. Non potrai modificarla successivamente.', 
                          () async{
                            Navigator.pop(context);
                            if (_formKey.currentState!.validate()) {
                              Modals().loader(context);
                              // Se tutti i campi sono validi
                              print('Form valido');
                              Map account = {
                                'email' : '${emailController.text}',
                                'name' : '${nameController.text}',
                                'surname' : '${surnameController.text}',
                                'nickname' : '${nicknameController.text}',
                                'password' : '${passwordController.text}',
                                'birthday' : '${birthdateController.text}',
                                'gender' : '${_selectedValue == 'UOMO' ? 'M' : _selectedValue == 'DONNA' ? 'F' : _selectedValue == 'ALTRO' ? 'O' : ''}',
                              };
                              dynamic data = await ApiUser().registerUser(account);
                              
                              if(data.isNotEmpty && data != null && data['status'] != false){
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/home');
                                Modals().showMessage(context, 'success', 'ACCOUNT REGISTRATO ');
                                if(data['email_verified'] == true){
                                  LOGIN           = true;
                                  USER            = data['user'];
                                  TOKEN_JWT       = data['token_jwt'];

                                  saveShared('json', USER, 'user');
                                  saveShared('string', TOKEN_JWT, 'token_jwt');
                                }else{
                                  Navigator.pushNamed(context, '/registerVerifyEmail');
                                }
                              }else{
                                Navigator.pop(context);
                                if(data['errors'] != null){
                                  String firstKey = data['errors'].keys.first;
                                  Modals().showMessage(context, 'error', '${data['errors'][firstKey][0]}');
                                }else{
                                  Modals().showMessage(context, 'error', 'Errore sconosciuto');
                                }

                              }
                            } else {
                              // Se ci sono errori
                              print('Form non valido');
                            }
                          }, 
                          (){
                            Navigator.pop(context);
                            return;
                          },
                        );

                      }
                    ),

                    SizedBox(height: 10,),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, '/register');
                        setState(() {});  
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hai già un account? ',
                            style: TextStyle(
                              color: textColor,
                              fontSize: textMid
                            ),
                          ),
                          Text(
                            'Accedi!',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: textMid
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SbButtonSecondary(label: 'HO GIÀ UN ACCOUNT', function: (){
                    //   Navigator.pushNamed(context, '/login');
                    // })
                    
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