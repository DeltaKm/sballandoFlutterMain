import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sballando/components/sb_notification_permission.dart';
import 'package:sballando/components/sb_onboarding_page.dart';
import 'package:sballando/pages/event/sb_jukebox.dart';
import 'package:sballando/pages/user/sb_user_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_global_keys.dart';
import 'package:sballando/pages/sb_home.dart';
import 'package:sballando/pages/sb_wallet.dart';
import 'package:sballando/pages/sb_login.dart';
import 'package:sballando/pages/sb_notification.dart';
import 'package:sballando/pages/sb_checkout.dart';
import 'package:sballando/pages/sb_info.dart';
import 'package:sballando/pages/sb_qr_scanner.dart';
import 'package:sballando/pages/sb_password_recovery.dart';
import 'package:sballando/pages/sb_register_verifield_email.dart';
import 'package:sballando/pages/sb_create.dart';
import 'package:sballando/pages/test.dart';
import 'package:sballando/pages/user/sb_user_edit.dart';
import 'package:sballando/pages/user/sb_user_fairplay.dart';
import 'package:sballando/pages/user/sb_user_followers.dart';
import 'package:sballando/pages/user/sb_user_favorite.dart';
import 'package:sballando/pages/user/sb_user_register.dart';
import 'package:sballando/pages/user/sb_user_show.dart';
import 'package:sballando/pages/event/sb_event_show.dart';
import 'package:sballando/pages/event/sb_event_chat.dart';
import 'package:sballando/pages/event/sb_event_list_chat.dart';
import 'package:sballando/pages/event/sb_event_private_chat.dart';
import 'package:sballando/pages/location/sb_location_show.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
Future<void> backroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backroundMessage);

  bool granted = await NotificationPermissionService.requestNotificationPermission();
  print(granted ? "✅ Notifiche autorizzate" : "❌ Notifiche non autorizzate");

  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔐 Firebase token: $token');
    if (token != null) FIREBASETOKEN = token;

    FirebaseMessaging.onMessage.listen((RemoteMessage data) {
      if (data.data['action'] == 'chat' &&
          data.data['sender_id'] == USER['id'].toString()) {
        return;
      }

      showSimpleNotification(
        GestureDetector(
          onTap: () => navigatorKey.currentState?.pushNamed('/notification'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.notification?.title ?? 'Notifica'),
              Text(data.notification?.body ?? ''),
            ],
          ),
        ),
        leading: Icon(Icons.notifications, color: Colors.white),
        background: mainColor,
        slideDismissDirection: DismissDirection.up,
        duration: Duration(seconds: 2),
      );

      if (CURRENTSTATE != null) {
        if (data.data['action'] == 'on_air') {
          Navigator.pushNamed(CURRENTSTATE!.context, '/eventShow',
              arguments: {'eventId': data.data['event_id']});
        }
        if (CURRENTSTATE is SbNotificationState) {
          (CURRENTSTATE as SbNotificationState).takeNotifications();
        }
        if (CURRENTSTATE is SbWalletState) {
            if(data.data['action'] == 'product_consumed'){
            navigatorKey.currentState?.pop();
          }
          (CURRENTSTATE as SbWalletState).getData();
        }
        if (CURRENTSTATE is SbEventshowState && 
        (data.data['action'] == 'on_air' ||
                data.data['action'] == 'payment_request' ||
                data.data['action'] == 'event')) {
          (CURRENTSTATE as SbEventshowState).loadData();
        }
        if (CURRENTSTATE is SbEventChatState && data.data['action'] == 'chat' && data.data['receiver_id'] != null && data.data['receiver_id'] != '') {
          SbGlobalKeys.eventChat.currentState?.newMessagePrivate = true;
          (CURRENTSTATE as SbEventChatState).setState(() {});
        }
        if (CURRENTSTATE is SbEventListChatState && -data.data['action'] == 'chat' && -data.data['receiver_id'].isEmpty) {
          SbGlobalKeys.eventListChat.currentState?.newMessagePublic = true;
          (CURRENTSTATE as SbEventListChatState).setState(() {});
        }
        if (CURRENTSTATE is SbEventPrivateChatState &&
            data.data['action'] == 'chat') {
          final pc = (CURRENTSTATE as SbEventPrivateChatState);
          if (data.data['receiver_id'].isEmpty) {
            pc.newMessagePublic = true;
          } else if (data.data['sender_id'].toString() !=
              pc.user['id'].toString()) {
            pc.newMessagePrivate = true;
          }
          pc.setState(() {});
        }
      }
    });
  } catch (e) {
    print('Errore inizializzazione Firebase: $e');
  }

  runApp(OverlaySupport.global(child: MyApp(showOnboarding: hasSeenOnboarding)));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({required this.showOnboarding, super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  Uri? _pendingUri;
  bool _showBlackOverlay = false;

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();


    // Se l'app viene aperta tramite link mentre era chiusa
    _appLinks.getInitialAppLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  
    // Se l'app è aperta e arriva un link
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Gestione _pendingUri appena il Navigator è pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingUri != null) {
        final uri = _pendingUri!;
        _pendingUri = null;
        _handleUri(uri);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    super.dispose();
  }

  void _initDeepLinks() async {
    final Uri? initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) _pendingUri = initialUri;

    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleUri(uri);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final Uri? resumedUri = await _appLinks.getInitialAppLink();
      if (resumedUri != null) _handleUri(resumedUri);
    }
  }

  void _handleUri(Uri uri) {
    print('🔗 Deep link ricevuto: $uri');

    Future.delayed(Duration(milliseconds: 50), () {
      if (!mounted) return;

      // Pagamenti
      if (uri.host == 'stripe_success_checkout') {
        navigatorKey.currentState?.pushNamed('/wallet');
      }

      // Eventi
      else if (uri.host == 'webservice.sballando.it' &&
          uri.pathSegments.isNotEmpty &&
          uri.pathSegments[0] == 'event.html') {
        final eventId = uri.queryParameters['id'];
        navigatorKey.currentState
            ?.pushNamed('/eventShow', arguments: {'eventId': eventId});
      }
    });
  }

  void _toggleOverlay(bool visible) {
    setState(() => _showBlackOverlay = visible);
  }
  void _handleDeepLink(Uri uri) {
  if (uri.host == 'webservice.sballando.it' && uri.pathSegments.first == 'event.html') {
    final eventId = uri.pathSegments[0];
    navigatorKey.currentState?.pushNamed('/evento', arguments: eventId);
  }
}
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          MaterialApp(
            localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('it', 'IT'),
          ],
            locale: const Locale('it', 'IT'),
            navigatorKey: navigatorKey,
            themeMode: ThemeMode.system,
            title: 'Sballando',
            theme: ThemeData(
              fontFamily: 'Poppins',
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: NoTransitionsBuilder(),
                  TargetPlatform.iOS: NoTransitionsBuilder(),
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: widget.showOnboarding ? '/home' : '/onboarding',
            home: SbHome(),
            routes: {
              '/onboarding': (_) => OnboardingPage(),
              '/home': (context) => SbHome(key: UniqueKey()),
              '/profile': (context) => SbProfile(key: UniqueKey()),
              '/login': (context) => SbLogin(key: UniqueKey()),
              '/eventShow': (context) => SbEventshow(key: UniqueKey()),
              '/locationShow': (context) => SbLocationShow(key: UniqueKey()),
              '/wallet': (context) => SbWallet(key: UniqueKey()),
              '/create': (context) => SbCreate(key: UniqueKey()),
              '/qrScanner': (context) => SbQrScanner(key: UniqueKey()),
              '/info': (context) => SbInfo(key: UniqueKey()),
              '/notification': (context) => SbNotification(key: UniqueKey()),
              '/test': (context) => MainPageView(key: UniqueKey()),
              '/checkout': (context) => SbCheckout(key: UniqueKey()),
              '/eventChat': (context) => SbEventChat(key: UniqueKey()),
              '/eventPrivateChat': (context) => SbEventPrivateChat(key: UniqueKey()),
              '/eventListChat': (context) => SbEventListChat(key: UniqueKey()),
              '/jukebox': (context) => SbJukebox(key: UniqueKey()),
              '/register': (context) => SbRegister(key: UniqueKey()),
              '/registerVerifyEmail': (context) => SbRegisterVerifyEmail(key: UniqueKey()),
              '/passwordRecovery': (context) => SbPasswordRecovery(key: UniqueKey()),
              '/userEdit': (context) => SbUserEdit(key: UniqueKey()),
              '/userFollowers': (context) => SbUserFollowers(key: UniqueKey()),
              '/userFairplay': (context) => SbUserFairplay(key: UniqueKey()),
              '/eventFavorite': (context) => SbUserFavorite(key: UniqueKey()),
              '/gallery': (context) => SbUserGallery(key: UniqueKey()),

            },
          ),
          if (_showBlackOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _toggleOverlay(false),
                child: Container(color: Colors.black.withOpacity(0.9)),
              ),
            ),
        ],
      ),
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
