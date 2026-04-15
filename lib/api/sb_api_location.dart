import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sballando/sb_global.dart';

class ApiLocation {


  Map       data            = {};
  String                      endpoint       = 'https://webservice.sballando.it/api';


  Future<Map> getLocations({String? search, int? offset, int? limit, String? regione, String? provincia}) async {
    Map<String, String> body = {
      'search'  :'$search',
      'offset' : '${offset ?? 0}',
      'limit' : '${limit ?? 10}',
      'regione': '${regione ?? ''}',
      'provincia': '${provincia ?? ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/location/index"),
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

  Future<Map> getLocation(int id) async {
    Map body = {
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
      'location_id' : '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/location/show"),
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


  Future<Map> fetchUpcomingPastEvent(int id) async {
    Map body = {
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
      'location_id' : '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/location/get_upcoming_and_past_events"),
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
  
}