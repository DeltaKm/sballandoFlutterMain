import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

class GoogleAuthService {
  // ✅ Web Client ID configurato in Firebase e nel backend Laravel
  // Necessario SOLO per Android per ottenere l'idToken
  static const String _webClientId = '8699556000-lr57rud6l7vojt2uduvpbmjm5lvpci3s.apps.googleusercontent.com';
  
  // Istanza singleton per mantenere lo stato
  GoogleSignIn? _googleSignInInstance;
  
  // GoogleSignIn configurato in base alla piattaforma
  GoogleSignIn get _googleSignIn {
    if (_googleSignInInstance != null) {
      return _googleSignInInstance!;
    }
    
    if (Platform.isAndroid) {
      // Android: richiede serverClientId per ottenere idToken
      _googleSignInInstance = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: _webClientId,
      );
    } else {
      // iOS: funziona senza serverClientId
      _googleSignInInstance = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
    
    return _googleSignInInstance!;
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      print('🔍 Piattaforma: ${Platform.isAndroid ? "Android" : "iOS"}');
      print('🔑 serverClientId: ${Platform.isAndroid ? "ATTIVO" : "NON USATO"}');
      
      // ⚠️ IMPORTANTE: Disconnetti prima per permettere di scegliere l'account
      try {
        await _googleSignIn.signOut();
        print('✅ SignOut completato');
      } catch (e) {
        print('⚠️ SignOut fallito (probabilmente nessun utente loggato): $e');
      }
      
      // Piccolo delay per assicurarsi che signOut sia completato
      await Future.delayed(Duration(milliseconds: 300));
      
      print('📱 Apertura dialog di selezione account Google...');
      final account = await _googleSignIn.signIn();
      print('📱 Dialog chiuso. Account selezionato: ${account?.email ?? "null"}');
      
      if (account != null) {
        print('✅ Login Google riuscito per: ${account.email}');
        
        // Ottieni l'authentication
        final auth = await account.authentication;
        
        // Debug completo
        print('=== TOKEN DEBUG ===');
        print('idToken: ${auth.idToken != null ? "✅ PRESENTE (${auth.idToken!.length} char)" : "❌ NULL"}');
        print('accessToken: ${auth.accessToken != null ? "✅ PRESENTE (${auth.accessToken!.length} char)" : "❌ NULL"}');
        
        if (auth.idToken != null) {
          final segments = auth.idToken!.split('.');
          print('JWT segments: ${segments.length} (dovrebbe essere 3)');
        } else {
          print('⚠️ idToken è NULL! Verifica che il Web Client ID sia corretto.');
        }
        
        print('User ID: ${account.id}');
        print('Display Name: ${account.displayName}');
        print('==================');
      }
      
      return account;
    } catch (error) {
      print('❌ Errore Google Sign-In: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
