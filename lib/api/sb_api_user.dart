import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sballando/sb_global.dart';
import 'package:path/path.dart' as path;
class ApiUser {


  Map       data            = {};
  String                      endpoint       = 'https://webservice.sballando.it/api';

    Future<Map> completeGoogleRegistration(String user_token, dynamic data, dynamic gender) async {
    Map<String, String> body = {
      'user_token': user_token,
      'birthday': '${data}',
      'gender': gender
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/google/completeGoogleRegistration"),
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

  Future<Map> checkNickname(dynamic nickname, String token) async {
    Map<String, String> body = {
      'user_token': token,
      'nickname': nickname
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/google/checkNickname"),
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

  Future<Map> loginWithGoogle(dynamic idToken) async {
    print('🌐 API loginWithGoogle chiamata');
    print('📍 Endpoint: $endpoint/google/login');
    print('🔑 idToken presente: ${idToken != null}');
    print('🔑 idToken length: ${idToken?.length ?? 0}');
    
    if (idToken == null || idToken.isEmpty) {
      print('❌ idToken è null o vuoto!');
      return {'error': 'idToken non disponibile'};
    }
    
    print('📤 Invio idToken al backend...');
    print('🔑 Prime 50 char: ${idToken.substring(0, idToken.length > 50 ? 50 : idToken.length)}...');
    
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/google/login"),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id_token': idToken,
        }
      );
      
      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        print('✅ JSON parsed correttamente');
        print('📋 Chiavi presenti: ${jsonResponse.keys.toList()}');
        data = jsonResponse;
      } else {
        print('❌ Status code non 200: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        // Ritorna l'errore anche se non è 200
        try {
          data = json.decode(response.body);
        } catch (e) {
          data = {'error': response.body};
        }
      }
    }catch(e){
      print('💥 Eccezione in loginWithGoogle: $e');
      if(kDebugMode){
        print(e);
      }
      data = {'error': e.toString()};
    }

    return data;
  }

  Future<Map> getUsers({String? search, String? regione, String? provincia, int? offset, int? limit}) async {
    Map<String, String> body = {
      'search'  :'$search',
      'offset' : '${offset ?? 0}',
      'limit' : '${limit ?? 10}',
      'regione': '${regione ?? ''}',
      'provincia': '${provincia ?? ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/index"),
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

  Future<Map> deleteUser() async {
    Map<String, String> body = {

      'user_token': '${USER['token'] ?? ''}'
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/delete"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
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
  

  Future<Map> setFollower(int followedId) async {
    Map<String, String> body = {
      'followed_id'  : '$followedId',
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/set_follower"),
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
  
  Future<Map> setUnFollower(int followedId) async {
    Map<String, String> body = {
      'followed_id'  : '$followedId',
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/remove_follower"),
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
  
  
  Future<Map> getUser(String nickname) async {

    Map<String, String> body = {
      'nickname'  : '$nickname',
      'user_token' : '${USER.isNotEmpty ? USER['token'] : '' }',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/getUserProfile"),
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

  Future<Map> getUserShow(String id) async {

    Map<String, String> body = {
      'user_id'  : '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/show"),
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

  Future<Map> registerUser(Map account) async {

    Map<String, String> body = {
      'email' : '${account['email']}',
      'name' : '${account['name']}',
      'surname' : '${account['surname']}',
      'nickname' : '${account['nickname']}',
      'password' : '${account['password']}',
      'birthday' : '${invertiData(account['birthday'])}',
      'gender' : '${account['gender']}',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/register"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
          // 'Content-Type': 'application/json', // se stai mandando JSON
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return data;
  }
  
  Future<Map> verifyEmail(String email) async {
    Map<String, String> body = {
      'email' : '$email',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/resendVerificationEmail"),
        headers: {
          // 'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }


  Future<Map> passwordRecovery(String email) async {
    Map<String, String> body = {
      'email' : '$email',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/password/email"),
        headers: {
          // 'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<Map> getPhoneCodes() async {
    try{
      http.Response response = await http.get(
        Uri.parse("$endpoint/getPhoneCodes"),
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return data;
  }
  
  Future<List<String>> getProvince(String regione) async {
    List<String> listProvince = [];
    Map<String, String> body = {
      'regione' : regione
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/getProvince"),
        body: body,
      );
      
      if(response.statusCode == 200){
        List<dynamic> resp = json.decode(response.body);
        listProvince = resp.map((e) => e.toString()).toList();
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return listProvince;
  }

   Future<dynamic> getRegioni() async {
    dynamic listRegions;
    try{
      http.Response response = await http.get(
        Uri.parse("$endpoint/getRegioni"),
      );
      if(response.statusCode == 200){
        listRegions = json.decode(response.body);
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }
    return listRegions;
  }

  Future<dynamic> changePassword(oldPassword,newPassword) async {
    Map body = {
      'user_token': USER["token"],
      'old_password': oldPassword,
      'new_password': newPassword,
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/reset_password"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<dynamic> editUser(userData) async {
    dynamic data;

    try {
      var uri = Uri.parse("$endpoint/user/update");
      var request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer $TOKEN_JWT',
      });

      // Campi normali
      request.fields['token'] = USER['token'] ?? '';
      request.fields['name'] = userData['name'] ?? '';
      request.fields['surname'] = userData['surname'] ?? '';
      request.fields['nickname'] = userData['nickname'] ?? '';

      int i = 0;
      for (var genre in userData['music_genres']) {
        request.fields['music_genres[$i]'] = genre.toString();
        i++;
      }

      request.fields['bio']               = userData['bio'] ?? '';
      request.fields['prefix_phone']      = userData['prefix_phone'] ?? '';
      request.fields['phone']             = userData['phone'] ?? '';
      request.fields['gender']            = userData['gender'] ?? 'M';
      request.fields['visibility']        = userData['visibility'] == true ? '1' : '0';
      request.fields['region']            = userData['region'] ?? '';
      request.fields['city']              = userData['city'] ?? '';
      request.fields['link_instagram']    = userData['link_instagram'] ?? '';
      request.fields['link_tiktok']       = userData['link_tiktok'] ?? '';

      request.fields['birthday']          = userData['birthday'] ?? '';

      // 👉 Aggiunta immagine (come "profilo.jpg" o "profilo.png")
      if (userData['picture'] != null && userData['picture'] is File) {
        var pictureFile = userData['picture'] as File;

        String extension = path.extension(pictureFile.path).replaceFirst('.', ''); // esempio 'jpg' o 'png'

        var multipartFile = await http.MultipartFile.fromPath(
          'picture', 
          pictureFile.path,
          filename: 'profilo.$extension', // Nome file richiesto dal backend
        );

        request.files.add(multipartFile);
      }

      // Invia la richiesta
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        dynamic jsonResponse = json.decode(response.body);
        data = jsonResponse;
      } else {
        print('Errore status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore nella richiesta: $e');
      }
    }

    return data;
  }
  

  Future<dynamic> addTokenFireBase(fcmToken) async {
    Map body = {
      'user_token': USER["token"],
      'fcm_token': fcmToken,
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/set_fcm_token"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<dynamic> searchActiveEvent() async {
    Map body = {
      'user_token': USER["token"],
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/is_user_attending_event"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }
  
  Future<dynamic> getSeguiti(String id) async {
    Map body = {
      'user_id': '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/get_seguiti"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return false;
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<dynamic> getFollower(String id) async {
    Map body = {
      'user_id': '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/user/get_followers"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return {};
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }


  Future<dynamic> getFairplaylist(String id) async {
    Map body = {
      'user_id': '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/fairplay/index"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return {};
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }


  Future<dynamic> getFairplayCollaboratorlist(String id) async {
    Map body = {
      'user_id': '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/fairplayCollaborator/index"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return {};
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<dynamic> blockUser(String id) async {
    Map body = {
      'user_token': '${USER['token']}',
      'user_id': '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/blockedUser/blockUser"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return {};
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<dynamic> unblocked(String id) async {
    Map body = {
      'user_token': '${USER['token']}',
      'user_id': '$id',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/blockedUser/unblocked"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return {};
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }

  Future<dynamic> sendReport(String id, String message) async {
    Map body = {
      'user_token' : '${USER['token']}',
      'user_id' : '$id',
      'message' : '$message',
    };
    try{
      http.Response response = await http.post(
        Uri.parse("$endpoint/report/sendReport"),
        headers: {
          'Authorization': 'Bearer $TOKEN_JWT',
        },
        body: body,
      );
      if(response.statusCode == 200){
        dynamic jsonResponse  = json.decode(response.body);
        data                  = jsonResponse;
        return data;
      }else{
        return {};
      }
    }catch(e){
      if(kDebugMode){
        print(e);
      }
    }

    return data;
  }
  
}



