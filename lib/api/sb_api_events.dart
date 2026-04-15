import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sballando/sb_global.dart';

class ApiEvent {


  Map       data            = {};
  String                      endpoint       = 'https://webservice.sballando.it/api';


  Future<Map> getEvents({String? search, int? offset,int? limit, String? regione, String? provincia }) async {

    Map<String, String> body = {
      'search'  :'$search',
      'offset' : '${offset ?? 0}',
      'limit' : '${limit ?? 10}',
      'regione': '${regione ?? ''}',
      'provincia': '${provincia ?? ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/event/index"),
        body: body
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> login(String email,String password) async {
    Map<String, String> body = {
      'email' : email, 
      'password' : password,

    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/login"),
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getEvent(int eventId,{ int? offset,int? limit }) async {

    Map<String, String> body = {
      'event_id'  :'$eventId',
      'user_token' : '${USER['token']}',
      'offset' : '${offset ?? 0}',
      'limit' : '${limit ?? 10}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/event/show"),
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getTicket() async {
    Map<String, String> body = {
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types/wallet"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> removePartecipant(int partecipantId, int entryTypeId,) async {
    Map<String, String> body = {
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
      'partecipant_id' : '$partecipantId',
      'entry_type_id' : '$entryTypeId',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types/removePartecipant"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }
  
  Future<Map> verifyProduct(codeText) async {
    Map<String, String> body = {
      'auth_token' : '${USER['token']}',
      'QRCode' : '$codeText',
    };
    TOKEN_JWT;
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/scanQRCodeProduct"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  
  Future<Map> verifyTicket(codeText) async {
    TOKEN_JWT;
    Map<String, String> body = {
      'auth_token' : '${USER['token']}',
      'QRCode' : '$codeText',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/scanQRCode"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

    Future<Map> registerEventQr(codeText) async {
    TOKEN_JWT;
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'QRCode' : '$codeText',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/registerEventQr"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getNotifications(int page,int perPage) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'page' : '$page',
      'per_page' : '$perPage'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types_notification/index"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getNotificationsRequest(int page,int perPage) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'page' : '$page',
      'per_page' : '$perPage'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types_notification/indexRequest"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }
  
  
  Future<Map> getEntryType(int entryId, {int? collaboratorId}) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'entry_id': '$entryId',
      'collaborator_id' : '$collaboratorId',
      'notification_message': '${collaboratorId != null ? 'Richiesta di ingresso' : ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types/transfer_to_client"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getProduct(int entryId, {int? collaboratorId}) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'entry_id': '$entryId',
      'collaborator_id' : '$collaboratorId',
      'notification_message': '${collaboratorId != null ? 'Richiesta di ingresso' : ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/product/transfer_to_client"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getProducts() async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/products/wallet"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> deleteNotificationEntryType(int entryId) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'entry_type_id': '$entryId',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types_notification/deleteNotificationEntryType"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }


  Future<Map> createIntentPayment({int? entry_type_id, int? product_id, int? product_qnt, List<Map<String, dynamic>>? cartItems}) async {
    Map<String, dynamic> body = {
      'user_token' : '${USER['token']}',
    };
    
    // Se è un carrello, invia l'array di items
    if(cartItems != null && cartItems.isNotEmpty) {
      body['cart_items'] = jsonEncode(cartItems);
    } else {
      // Altrimenti, invia i parametri singoli
      body['entry_type_id'] = '${entry_type_id ?? ''}';
      body['product_id'] = '${product_id ?? ''}';
      body['product_qnt'] = '${product_qnt ?? ''}';
    }
    
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/payments/createIntentPayment"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  
  Future<Map> unsubscribe(int eventId) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'event_id': '$eventId'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types/unsubscribe"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> confirmInvite(int notificationId) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'notification_id': '$notificationId'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types_notification/confirm_invite"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> deleteInvite(int notificationId) async {
    Map<String, String> body = {
      'user_token' : '${USER['token']}',
      'notification_id': '$notificationId'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types_notification/delete_invite"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getMusicGenres({String? search}) async {
    try{
      http.Response response = await http.get(
        Uri.parse("$endpoint/music_genres?search=${search ?? ''}"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> requestInviteGroup(int eventId, int entryTypeId) async {
    print(TOKEN_JWT);
    Map body = {
      'event_id' : '$eventId',
      'entry_type_id' : '$entryTypeId',
      'user_token' : '${USER['token']}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types/transfer_invite_client_to_client"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',

        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> transferEntryTypeSeat(int eventId, int entryTypeId,int receiverId) async {
     Map body = {
      'event_id' : '$eventId',
      'entry_type_id' : '$entryTypeId',
      'receiver_id': '$receiverId',
      'user_token' : '${USER['token']}'
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types/invite_client_to_client"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> transferProduct(int productId,int receiverId) async {
     Map body = {
      'product_id' : '$productId',
      'receiver_id': '$receiverId',
      'user_token' : '${USER['token']}',
      'stock' : '1',
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/products/transfer_client_to_client"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> addFavoriteEvent(int eventId) async {
     Map body = {
      'user_token' : '${USER['token']}',
      'event_id' : '$eventId',
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/favorite/addFavoriteEvent"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> removeFavoriteEvent(int eventId) async {
     Map body = {
      'user_token' : '${USER['token']}',
      'event_id' : '$eventId',
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/favorite/removeFavoriteEvent"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> getFavoriteEvent(int userId) async {
     Map body = {
      'user_id' : '${USER['id']}',
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/favorite/index"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> deleteGeneralNotification(int notifId) async {
     Map body = {
      'user_token' : '${USER['token']}',
      'notification_id' : '$notifId'
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/entry_types_notification/delete_general_notification"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future<Map> getPhotosEventGallery(int eventId) async {
     Map body = {
      'event_id' : '$eventId'
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$endpoint/event/get_photos_event_gallery"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
          data = jsonResponse;
      }
    } catch (e) {
        if(kDebugMode){
        print(e);
      }
    }
    return data;
  }

  Future googleLogin(String email, String name, String googleId) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/google/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'google_id': googleId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Errore del server'};
      }
    } catch (e) {
      return {'error': 'Errore di connessione'};
    }
  }
  
  // Metodo per iOS: usa handleGoogleCallback senza idToken
  Future handleGoogleCallback(String email, String name, String surname) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/google/handleGoogleCallback'),
        body: {
          'email': email,
          'name': name,
          'surname': surname,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Errore del server'};
      }
    } catch (e) {
      return {'error': 'Errore di connessione'};
    }
  }
  
}