import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sballando/sb_global.dart';

class ApiChat {


  Map                         data           = {};
  String                      endpoint       = 'https://webservice.sballando.it/api';


  

  Future<Map> getMessages(int eventId,{ int? receiver_id}) async {
    Map<String, String> body = {
      'user_id' : '${USER.isNotEmpty ? USER['id'] : '' }',
      'event_id' : '$eventId',
      'receiver_id' : '${receiver_id ?? ''}',
      'sender_id' : '${USER.isNotEmpty ? USER['id'] : '' }'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/message_index"),
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

  Future<Map> sendMessage(int eventId, String message,{int? productId , int? receiver_id,}) async {
    Map<String, String> body = {
      'sender_id' : '${USER.isNotEmpty ? USER['id'] : '' }',
      'event_id' : '$eventId',
      'message' : '$message',
      "product_id": "${productId ?? ''}",
      'sender_color' : 'red',
      'receiver_id' : '${receiver_id ?? ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/send_message"),
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

  Future<Map> getUsersLive(int eventId) async {
    Map<String, String> body = {
      'user_id' : '${USER.isNotEmpty ? USER['id'] : '' }',
      'event_id' : '$eventId'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/users_live_event"),
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
  
  Future<Map> getProductsEvent(int eventId) async {
    Map<String, String> body = {
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
      'event_id' : '$eventId'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/products/my_products_of_this_event"),
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
  
}