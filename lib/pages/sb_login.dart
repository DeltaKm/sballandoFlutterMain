import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_input.dart';
import 'package:sballando/components/sb_login_google.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SbLogin extends StatefulWidget {
  const SbLogin({super.key});

  @override
  State<SbLogin> createState() => SbLoginState();
}

class SbLoginState extends State<SbLogin> {
  final GoogleAuthService _authService = GoogleAuthService();
  final keyForm = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  Map? _tempUserData;

  bool acceptedPolicy = true;
  bool showError = false;
  String errorMessage = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      CURRENTSTATE = this;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      Modals().loader(context);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      Navigator.pop(context);

      dynamic respo = await ApiEvent().googleLogin(
        googleUser.email,
        googleUser.displayName ?? '',
        googleUser.id,
      );

      if (respo != null && respo['error'] == null) {
        saveShared('json', respo['user'], 'user');
        saveShared('string', respo['token_jwt'], 'token_jwt');

        LOGIN = true;
        USER = respo['user'];
        TOKEN_JWT = respo['token_jwt'];

        Navigator.pushNamed(
          context,
          '/profile',
          arguments: {'nickname': USER['nickname']},
        );
      } else {
        setState(() {
          errorMessage = respo['error'] ?? 'Errore durante il login con Google';
        });
      }
    } catch (error) {
      Navigator.pop(context);
      print('Errore Google Sign In: $error');
      setState(() {
        errorMessage = 'Errore durante il login con Google: $error';
      });
    }
  }

  void _showCompleteRegistrationModal(Map userData) {
    _tempUserData = userData;
    
    // Debug: stampa i dati ricevuti
    print('📦 userData ricevuto: ${userData.keys}');
    print('👤 user: ${userData['user']}');
    
    // Verifica se il nickname è già presente e valido
    String? existingNickname = userData['user']?['nickname'];
    String? userToken = userData['user']?['token'];
    
    print('🏷️ Nickname esistente: $existingNickname');
    print('🔑 Token utente: ${userToken != null ? "Presente" : "NULL"}');
    
    if (existingNickname != null && 
        existingNickname.isNotEmpty && 
        existingNickname.trim().isNotEmpty) {
      // Se il nickname è già presente e valido, vai direttamente alla data di nascita
      _nicknameController.text = existingNickname;
      print('Nickname già presente: $existingNickname - Saltando alla data di nascita');
      _showDateOfBirthModal();
    } else {
      // Se il nickname non c'è o è vuoto, mostra la modale per inserirlo
      print('Nickname mancante o vuoto - Mostrando modale nickname');
      
      // Se il token è null, usa un token temporaneo o salta la verifica
      String tokenToUse = userToken ?? '';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              
              backgroundColor: backgroundColor,
              title: Text(
                'Scegli un Nickname',
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: width(context, 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '',
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: 20),
                    _buildNicknameStep(tokenToUse),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildNicknameStep(String token) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          children: [
            SbInput(
              obscureText: false,
              controller: _nicknameController,
              icon: Icons.person,
              label: 'Nickname',
              validatorFunction: (value) {
                if (value == null || value.isEmpty) {
                  return 'Il nickname è obbligatorio';
                }
                if (value.length < 3) {
                  return 'Il nickname deve avere almeno 3 caratteri';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            SbButtonMaincolor(
              fullWidth: true,
              label: 'Verifica Nickname',
              function: () async {
                if (_nicknameController.text.length >= 3) {

                  await _verifyNickname(setModalState, token);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyNickname(StateSetter setModalState, String token) async {
    try {
      // Se il token è vuoto, significa che è un nuovo account
      // Usa il token da _tempUserData se disponibile
      String actualToken = token.isEmpty && _tempUserData != null 
          ? (_tempUserData!['user']?['token'] ?? '')
          : token;
      
      print('🔍 Verifica nickname: ${_nicknameController.text}');
      print('🔑 Token usato: ${actualToken.isEmpty ? "VUOTO" : "Presente"}');
      
      if (actualToken.isEmpty) {
        print('⚠️ Token vuoto - Salto verifica nickname e procedo direttamente');
        Navigator.pop(context);
        _showDateOfBirthModal();
        return;
      }
      
      Modals().loader(context);

      dynamic response = await ApiUser().checkNickname(_nicknameController.text, actualToken);

      Navigator.pop(context);

      if (response != null && response['status'] == true) {
        Navigator.pop(context);
        _showDateOfBirthModal();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Nickname non disponibile'),
            content: Text('Il nickname "${_nicknameController.text}" è già in uso. Scegline un altro.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Errore'),
          content: Text('Errore durante la verifica del nickname: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showDateOfBirthModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(
              'Quando sei Nato?',
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: width(context, 100),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 10),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Seleziona data di nascita',
                              style: TextStyle(
                                color: _selectedDate != null ? textColor : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SbButtonMaincolor(
                      fullWidth: true,
                      label: 'Continua',
                      function: () {
                        if (_selectedDate != null) {
                          Navigator.pop(context);
                          _showGenderModal();
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showGenderModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(
              'Seleziona il tuo Genere',
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  width: width(context, 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      SizedBox(height: 20),
                      ListTile(
                        title: Text('Maschio',style: TextStyle(color: textColor),),
                        
                        leading: Radio<String>(
                          value: 'M',
                          groupValue: _selectedGender,
                          onChanged: (String? value) {
                            setModalState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Femmina',style: TextStyle(color: textColor),),
                        leading: Radio<String>(
                          value: 'F',
                          groupValue: _selectedGender,
                          onChanged: (String? value) {
                            setModalState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      SbButtonMaincolor(
                        fullWidth: true,
                        label: 'Completa Registrazione',
                        function: _selectedGender != null
                            ? () async {
                                await _completeRegistration(); 
                              }
                            : () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _completeRegistration() async {
    try {
      print('🔄 Completamento registrazione...');
      print('📦 _tempUserData: ${_tempUserData?.keys}');
      print('🏷️ Nickname: ${_nicknameController.text}');
      print('📅 Data nascita: $_selectedDate');
      print('⚧️ Genere: $_selectedGender');
      
      String? userToken = _tempUserData?['user']?['token'];
      print('🔑 Token: ${userToken ?? "NULL"}');
      
      if (userToken == null || userToken.isEmpty) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Errore'),
            content: Text('Token utente non disponibile. Riprova ad effettuare il login.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      Modals().loader(context);

      dynamic response = await ApiUser().completeGoogleRegistration(
        userToken,
        _selectedDate!,
        _selectedGender!,
      );

      Navigator.pop(context);
      Navigator.pop(context);

      if (response != null && response['error'] == null) {
        saveShared('json', response['user'], 'user');
        saveShared('string', response['token_jwt'], 'token_jwt');

        LOGIN = true;
        USER = response['user'];
        TOKEN_JWT = response['token_jwt'];

        Navigator.pushNamed(
          context,
          '/profile',
          arguments: {'nickname': USER['nickname']},
        );

        
        Modals().showMessage(context, 'success', 'Registrazione completata con successo!');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Errore'),
            content: Text('Errore durante la registrazione: ${response['error']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Errore'),
          content: Text('Errore durante la registrazione: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Container(
        height: height(context, 100),
        padding: EdgeInsets.all(padding30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              children: [
                Text(
                  'ENTRA IN ',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: textHight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'SBALLANDO!',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: textHight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              'Sei già registrato?',
              style: TextStyle(
                fontSize: textMid,
                color: textColorSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: keyForm,
              child: Column(
                children: [
                  SbInput(
                    controller: _emailController,
                    obscureText: false,
                    icon: Icons.email,
                    label: 'Email',
                    validatorFunction: (value) {
                      String error = '';
                      if (error == '') {
                        error = validatorRequired(value!);
                      }

                      if (error == '') {
                        error = validatorEmail(value!);
                      }

                      if (error != '') {
                        return error;
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  SbInput(
                    controller: _passwordController,
                    typePassword: true,
                    obscureText: true,
                    icon: Icons.lock,
                    label: 'Password',
                    validatorFunction: (value) {
                      String error = '';
                      if (error == '') {
                        error = validatorRequired(value!);
                      }
                      if (error != '') {
                        return error;
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.pushNamed(context, '/passwordRecovery');
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(color: textColor, fontSize: textLowMid),
                            ),
                            Text(
                              'dimenticata? ',
                              style: TextStyle(color: textColor, fontSize: textLowMid),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  if (errorMessage != '')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: textMidHight,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  SbButtonMaincolor(
                    fullWidth: true,
                    label: 'Accedi',
                    function: () async {
                      if (acceptedPolicy == false) {
                        showError = true;
                        setState(() {});
                        return;
                      }
                      if (keyForm.currentState!.validate()) {
                        Modals().loader(context);
                        dynamic respo = await ApiEvent().login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        Navigator.pop(context);

                        if (respo != null && respo['error'] != null) {
                          if (respo['error'] == 'user_not_found') {
                            errorMessage = 'Utente non trovato';
                          } else if (respo['error'] == 'Credenziali non corrette') {
                            errorMessage = 'Credenziali non corrette';
                          }
                        } else {
                          saveShared('json', respo['user'], 'user');
                          saveShared('string', respo['token_jwt'], 'token_jwt');

                          LOGIN = true;
                          USER = respo['user'];
                          TOKEN_JWT = respo['token_jwt'];

                          Navigator.pushNamed(
                            context,
                            '/profile',
                            arguments: {'nickname': USER['nickname']},
                          );
                        }

                        setState(() {});
                      } else {}
                    },
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'oppure',
                          style: TextStyle(
                            color: textColorSecondary,
                            fontSize: textMid,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 15),
                  SocialLoginButton(
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                    label: 'Accedi con Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    onPressed: () async {
                      try {
                        print('🔵 Inizio login Google');
                        final GoogleSignInAccount? user = await _authService.signIn();
                        
                        if (user == null) {
                          print('❌ Login annullato dall\'utente');
                          return;
                        }
                        
                        Modals().loader(context);
                        
                        final GoogleSignInAuthentication googleAuth = await user.authentication;
                        dynamic data;
                        data = await ApiUser().loginWithGoogle(googleAuth.idToken);
                        
                        Navigator.pop(context);
                        
                        print('📥 Risposta backend ricevuta');
                        print('data == null: ${data == null}');
                        if (data != null) {
                          print('data["user"] == null: ${data["user"] == null}');
                          print('data["error"]: ${data["error"]}');
                        }
                        
                        if (data != null && data['user'] != null && data['error'] == null) {
                          if (data['newAccount'] == true) {
                            print('✅ Nuovo account creato per ${data['user']['email']}');
                  
                            _showCompleteRegistrationModal(data);
                          } else {
                            print('✅ Login esistente per ${data['user']['email']}');
                            saveShared('json', data['user'], 'user');
                            saveShared('string', data['token_jwt'], 'token_jwt');
                  
                            LOGIN = true;
                            USER = data['user'];
                            TOKEN_JWT = data['token_jwt'];
                  
                            Navigator.pushNamed(
                              context,
                              '/profile',
                              arguments: {'nickname': USER['nickname']},
                            );
                            setState(() {});
                          }
                        } else {
                          String errorMsg = data?['error'] ?? 'Risposta non valida dal server';
                          print('❌ Errore nel login: $errorMsg');
                          setState(() {
                            errorMessage = errorMsg;
                          });
                        }
                      } catch (error) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        print('❌ Errore completo: $error');
                        setState(() {
                          errorMessage = 'Errore: $error';
                        });
                      }
                    },
                  ),

                  
                ],
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 0,
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Non hai un Account? ',
                        style: TextStyle(color: textColor, fontSize: textMid),
                      ),
                      Text(
                        'Registrati!',
                        style: TextStyle(color: mainColor, fontSize: textMid),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/registerVerifyEmail');
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: mainColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Reinvia conferma E-mail',
                        style: TextStyle(color: textColor, fontSize: textMid),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () async {
                final Uri uri = Uri.parse('https://sballando.it');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: textMid,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Cos\'è ',
                    style: TextStyle(
                      color: textColorSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: textMid,
                    ),
                  ),
                  Text(
                    'SBALLANDO',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w400,
                      fontSize: textMid,
                    ),
                  ),
                  Text(
                    ' ?',
                    style: TextStyle(
                      color: textColorSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: textMid,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(label, style: TextStyle(color: textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      onPressed: onPressed,
    );
  }
}
