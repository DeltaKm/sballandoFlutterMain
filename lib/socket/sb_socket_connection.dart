import 'dart:convert';
import 'package:sballando/sb_global.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connect({
    required Function(dynamic) onNewMessage,
    required String type,
    dynamic receiverId,
  }) {
    if (socket != null) {
      if (socket!.connected) {
        print('🔄 Socket già connessa, la disconnetto...');
        socket!.disconnect();
      }
      socket!.dispose();
      socket = null;
    }

    socket = IO.io(
      'https://websocket.sballando.it',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    // Rimuovi i listener vecchi
    socket!.off('connect');
    socket!.off('disconnect');
    socket!.off('new-public-message');
    socket!.off('new-private-message');

    socket!.onConnect((_) {
      print('✅ Socket connessa');

      if (type == 'public') {
        connectPublishRoom(EVENTONAIR['id']);
      } else if (type == 'private') {
        connectPrivatehRoom(EVENTONAIR['id'], USER['id'], receiverId!);
      }
    });

    socket!.onDisconnect((_) => print('❌ Disconnesso'));
    socket!.onConnectError((error) => print('⚠️ Errore connessione: $error'));
    socket!.onError((error) => print('❌ Errore generico: $error'));

    // Ascolta i messaggi
    socket!.on('new-public-message', (data) {
      print('📩 Messaggio ricevuto: $data');
      onNewMessage(data);
    });

    socket!.on('new-private-message', (data) {
      print('📩 Messaggio ricevuto private: $data');
      onNewMessage(data);
    });

    // Alla fine, connetti
    socket!.connect();
  }


  void connectPublishRoom(eventId) {
    if (socket?.connected == true) {
      final payload = json.encode({
        "joinType": "publish",
        "eventId": eventId,
      });
      socket!.emit('join-to-room', payload);
    }
  }

  void connectPrivatehRoom(int eventId,int userId,int receiverId) {
    if (socket?.connected == true) {
      final payload = json.encode({
        "userId": userId,
        "otherUserId": receiverId,
        "eventId": eventId,
      });
      socket!.emit('join-private-chat', payload);
    }
  }

  void sendMessage(Map sender, int eventId, Map message) {
    if (socket != null && socket!.connected) {
      final payload = {
        "message": message,
        "sender": sender,
        "eventId": eventId,
      };
      socket!.emit('send-public-message', payload);
    }
  }


  void sendMessagePrivate(Map sender, int eventId, Map message,int receiverId,{ int? productId }) {
    if (socket != null && socket!.connected) {
      final payload = {
        "eventId": eventId,
        "message": message,
        "sender": sender,
        "productId": productId,
        "receiverId": receiverId,
      };
      socket!.emit('send-private-message', payload);
    }
  }

  void disconnect() {
  if (socket != null && socket!.connected) {
    socket!.disconnect();
    socket!.dispose(); // opzionale ma consigliato
    print('🔌 Socket disconnessa manualmente');
  }
}

}
