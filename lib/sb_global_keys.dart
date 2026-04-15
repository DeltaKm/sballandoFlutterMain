
import 'package:flutter/material.dart';
import 'package:sballando/components/sb_footer.dart';
import 'package:sballando/components/sb_header.dart';
import 'package:sballando/pages/event/sb_event_show.dart';
import 'package:sballando/pages/event/sb_event_chat.dart';
import 'package:sballando/pages/event/sb_event_list_chat.dart';
import 'package:sballando/pages/event/sb_event_private_chat.dart';
import 'package:sballando/pages/location/sb_location_show.dart';
import 'package:sballando/pages/sb_checkout.dart';
import 'package:sballando/pages/sb_password_recovery.dart';
import 'package:sballando/pages/sb_qr_scanner.dart';
import 'package:sballando/pages/sb_create.dart';
import 'package:sballando/pages/sb_home.dart';
import 'package:sballando/pages/sb_info.dart';
import 'package:sballando/pages/sb_login.dart';
import 'package:sballando/pages/sb_notification.dart';
import 'package:sballando/pages/sb_register_verifield_email.dart';
import 'package:sballando/pages/user/sb_user_edit.dart';
import 'package:sballando/pages/user/sb_user_register.dart';
import 'package:sballando/pages/user/sb_user_show.dart';
import 'package:sballando/pages/sb_wallet.dart';

class SbGlobalKeys {
  final GlobalKey<NavigatorState>                                 notificationNavigatorKey           = GlobalKey<NavigatorState>();
  static final GlobalKey<SbHomeState>                             home                               = GlobalKey();
  static final GlobalKey<SbHeaderState>                           header                             = GlobalKey();
  static final GlobalKey<SbFooterState>                           footer                             = GlobalKey();
  static final GlobalKey<SbLoginState>                            login                              = GlobalKey();
  static final GlobalKey<SbProfileState>                          profile                            = GlobalKey();
  static final GlobalKey<SbEventshowState>                        eventShow                          = GlobalKey();
  static final GlobalKey<SbWalletState>                           wallet                             = GlobalKey();
  static final GlobalKey<SbCreateState>                           create                             = GlobalKey();
  static final GlobalKey<SbQrScannerState>                        qrScanner                          = GlobalKey();
  static final GlobalKey<SbInfoState>                             info                               = GlobalKey();
  static final GlobalKey<SbNotificationState>                     notification                       = GlobalKey();
  static final GlobalKey<SbCheckoutState>                         checkout                           = GlobalKey();
  static final GlobalKey<SbEventChatState>                        eventChat                          = GlobalKey();
  static final GlobalKey<SbEventPrivateChatState>                 eventPrivateChat                   = GlobalKey();
  static final GlobalKey<SbEventListChatState>                    eventListChat                      = GlobalKey();
  static final GlobalKey<SbLocationShowState>                     locationShow                       = GlobalKey();
  static final GlobalKey<SbRegisterState>                         register                           = GlobalKey();
  static final GlobalKey<SbRegisterVerifyEmailState>              registerVerifyEmail                = GlobalKey();
  static final GlobalKey<SbPasswordRecoveryState>                 passwordRecovery                   = GlobalKey();
  static final GlobalKey<SbUserEditState>                         userEdit                           = GlobalKey();


}