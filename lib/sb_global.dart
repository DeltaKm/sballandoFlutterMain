import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:sballando/pages/sb_home.dart';
import 'package:sballando/pages/sb_info.dart';
import 'package:sballando/pages/sb_qr_scanner.dart';
import 'package:sballando/pages/sb_wallet.dart';
import 'package:sballando/pages/user/sb_user_show.dart';
import 'package:sballando/socket/sb_socket_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final             socketService                 = SocketService(); // sempre questa
final             themeMode                     = ValueNotifier<ThemeMode>(ThemeMode.system);

SbWalletState?              WALLETSTATE;


List<Color> COLORS = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  const Color.fromARGB(255, 56, 193, 115),
  Colors.teal,
  Color(0xFFFC0045),
];

final MAIN_PAGES = [
  SbWallet(),
  SbQrScanner(),
  SbHome(),      
  SbProfile(),
  SbInfo(),
];

bool              SHOWOVERLAY               = false;
bool              DARKMODE                  = false;
bool              LOADING                   = false;
String            BASE_URL                  = 'https://webservice.sballando.it/storage/';
String            NOPHOTO                   = 'assets/images/sballando_no_photo.jpeg';
int               reandomnumber             = Random().nextInt(100000);
double            FOOTERHEIGHT              = 100.0;
final ValueNotifier<double> footerHeightNotifier = ValueNotifier<double>(FOOTERHEIGHT);



Color             mainColor                 = Color(0xFFFC0045);
Color             textColor                 = Color(0xFF212938);
Color             backgroundColor           = Color.fromRGBO(255, 255, 255, 1);
Color             backgroundColorTheme      = Color.fromRGBO(245, 245, 245, 1);

Color             textColorSecondary        = Color.fromRGBO(112, 112, 112, 1);
Color             grayLight                 = Color.fromRGBO(232, 232, 232, 1);
Color             maleColor                 = Color.fromRGBO(9, 134, 201, 1);
Color             femaleColor               = Color.fromRGBO(232, 76, 167, 1);
Color             greenColor                = Color.fromRGBO(0, 208, 24, 1);



double            textLow                   = 12;
double            textLowMid                = 13;
double            textMid                   = 17;
double            textMidHight              = 20;
double            textHight                 = 25;

double            rounded30                 = 30;
double            rounded50                 = 50;

double            padding30                 = 30;

String            FIREBASETOKEN             = '';
String            FOOTERSELECT              = 'home';
String            NAVIGATIONHOME            = 'events';

Map               EVENTONAIR                = {};
bool              ONAIR                     = false;
bool              LOGIN                     = false;
Map               USER                      = {};
String            TOKEN_JWT                 = '';
String            UP_KEY_IMAGE              = Uuid().v4();


bool              UNREADNOTIFICATIONS       = false;

State?            CURRENTSTATE;
State?            HEADERSTATE;

QRCodeDartScanController?           REF_CONTROLLER_QRCODE;


TextStyle         style1                    = TextStyle(
  fontWeight: FontWeight.w300,
  color: textColor,
  fontSize: textLowMid,
);

Timer? _eventTimer;

void updateFooterHeight(double newHeight) {
  FOOTERHEIGHT = newHeight;
  footerHeightNotifier.value = newHeight;
}

void startCheckingEvent() {
  _eventTimer?.cancel(); // annulla eventuali timer precedenti

  _eventTimer = Timer.periodic(Duration(seconds: 5), (timer) {
    if (!isEventStillActive()) {
      print('Evento terminato!');
      saveShared('json', {}, 'onair');
      EVENTONAIR = {};
      ONAIR = false;

      timer.cancel(); // Ferma il controllo
      // Esegui qui eventuale logica aggiuntiva (es. chiudi pagina, mostra messaggio, ecc.)
    } else {
      print('Evento ancora attivo...' '${EVENTONAIR['datetime_end']}');
    }
  });
}
String getImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return "assets/images/sballando_no_photo.jpeg"; // immagine di default
  }
  return "https://webservice.sballando.it/storage/$imagePath";
}
bool isEventStillActive() {
  if (EVENTONAIR['datetime_end'] == null) return false;

  try {
    final endDate = parseServerDateTime(EVENTONAIR['datetime_end']);
    final now = DateTime.now();
    return endDate.isAfter(now);
  } catch (e) {
    print('Errore nel parsing della data: $e');
    return false;
  }
}

TextStyle         style2                    = TextStyle(
  fontWeight: FontWeight.w700,
  color: mainColor,
  fontSize: textMidHight,
);

String removeAtPrefix(String input) {
  if (input.startsWith('@')) {
    return input.substring(1);  // Rimuove il primo carattere (la chiocciola)
  }
  return input;  // Ritorna la stringa così com'è se non inizia con '@'
}


String validatorRequired(String value){
  if(value.isEmpty || value == ''){
   return 'campo obbligatorio';
  }

  return '';
}

String invertiData(String data) {
  List<String> parts = data.split('/'); // divide in ['03', '04', '2000']
  return '${parts[2]}/${parts[1]}/${parts[0]}'; // ricompone
}

String validatorPassword(String value){

  if(!value.contains(RegExp(r'[A-Z]'))){
   return 'Inserire almeno una maiuscola';
  }

  if(!value.contains(RegExp(r'[0-9]'))){
   return 'Inserire almeno un numero';
  }

  if(!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))){
   return 'Inserire almeno un carattere speciale';
  }

  return '';
}

String validatorConfirmePassword(String value, String confirmeValue){

  if(value != confirmeValue){
   return 'Le password non coincidono';
  }

  return '';
}

String validatorLenght(String value, int min,int max){
  if(value.length < min){
    return 'inserisci almeno $min caratteri';
  }
  if(value.length > max){
    return 'inserisci massimo $max caratteri';
  }
  return '';
}

String validatorEmail(String value){
  if (value.isEmpty) {
    return 'Inserisci l\'email';
  }
  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email non valida';
  }
  return '';
}

// void navigateToIfNotExists(BuildContext context, String routeName, {Object? arguments}) {
//   bool found = false;

//   Navigator.popUntil(context, (route) {
//     if (route.settings.name == routeName) {
//       found = true;
//       return true;
//     }
//     return false;
//   });

//   if (!found) {
//     Navigator.pushNamed(context, routeName, arguments: arguments);
//   }
// }



String getHour(String dateString) {
  DateTime date = parseServerDateTime(dateString);
  String hour = date.hour.toString().padLeft(2, '0');
  String minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int getDayFromIsoString(String isoDate) {
  DateTime date = parseServerDateTime(isoDate);
  return date.day;
}

String getShortMonth(String dateString) {
  DateTime date = parseServerDateTime(dateString);
  const months = ['GENNAIO', 'FEBRAIO', 'MARZO', 'APRILE', 'MAGGIO', 'GIUGNO', 'LUGLIO', 'AGOSTO', 'SETTEMBRE', 'OTTOBRE', 'NOVEMBRE', 'DICEMBRE'];
  return months[date.month - 1];
}

String creaStringaBase64(String parola, int numero1, int numero2, [String? extra]) {
  if (parola.trim().isEmpty) {
    throw ArgumentError('La parola non può essere vuota.');
  }
  if (numero1 < 0 || numero2 < 0) {
    throw ArgumentError('I numeri devono essere >= 0.');
  }

  // Costruzione della stringa base
  String originale = '$parola@$numero1:$numero2';

  // Aggiunta dell'extra, se presente, separato da ':'
  if (extra != null && extra.trim().isNotEmpty) {
    originale += ':$extra';
  }

  // Chiusura con @
  originale += '@';

  // Codifica base64
  String base64 = base64Encode(utf8.encode(originale));
  return base64;
}

String getCurrentTimeInIsoUtc() {
  return DateTime.now().toIso8601String();
}

String extractTime(String dateTimeString) {
  DateTime dateTime = parseServerDateTime(dateTimeString);
  return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
}

DateTime parseServerDateTime(String value) {
  final raw = value.trim();

  String normalized = raw;
  if (normalized.contains(' ') && !normalized.contains('T')) {
    normalized = normalized.replaceFirst(' ', 'T');
  }

  final hasTimezone = RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(normalized);
  final utcInput = hasTimezone ? normalized : '${normalized}Z';

  return DateTime.parse(utcInput).toLocal();
}

double width(BuildContext context, int percentage) {
  return (MediaQuery.of(context).size.width / 100) * percentage;
}

double height(BuildContext context, int percentage) {
  return (MediaQuery.of(context).size.height / 100) * percentage;
}

String ver(){
  return '?ver=$UP_KEY_IMAGE';
}

void saveShared(String type, dynamic data, String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  switch (type) {
    case 'string':
      if (data is String) {
        await prefs.setString(key, data);
      } else {
        throw ArgumentError('Il dato non è una stringa.');
      }
      break;

    case 'json':
      if (data is Map || data is List) {
        await prefs.setString(key, json.encode(data));
      } else {
        throw ArgumentError('Il dato non è un JSON valido.');
      }
      break;

    case 'int':
      if (data is int) {
        await prefs.setInt(key, data);
      } else {
        throw ArgumentError('Il dato non è un intero.');
      }
      break;

    case 'bool':
      if (data is bool) {
        await prefs.setBool(key, data);
      } else {
        throw ArgumentError('Il dato non è un booleano.');
      }
      break;

    case 'list':
      if (data is List) {
        // Converte la lista generica in una stringa JSON
        await prefs.setString(key, jsonEncode(data));
      } else {
        throw ArgumentError('Il dato non è una lista.');
      }
      break;

    default:
      throw ArgumentError('Tipo non supportato: $type');
  }
}

Future<dynamic> getShared(String type, String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  switch (type) {
    case 'string':
      return prefs.getString(key);

    case 'json':
      String? jsonString = prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString); // Converte il JSON in Map o List
      }
      return null;

    case 'int':
      return prefs.getInt(key);

    case 'bool':
      return prefs.getBool(key);

    case 'list':
      return prefs.getStringList(key);

    default:
      throw ArgumentError('Tipo non supportato: $type');
  }
}