// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class SpotifySearchWidget extends StatefulWidget {
//   final int eventId; // ID dell'evento corrente
//   const SpotifySearchWidget({super.key, required this.eventId});

//   @override
//   State<SpotifySearchWidget> createState() => _SpotifySearchWidgetState();
// }

// class _SpotifySearchWidgetState extends State<SpotifySearchWidget> {
//   TextEditingController searchController = TextEditingController();
//   List<Map<String, dynamic>> searchResults = [];
//   bool isLoading = false;

//   Future<void> searchSongs(String query) async {
//     if (query.length < 2) return;
//     setState(() => isLoading = true);

//     final response = await http.get(
//       Uri.parse(
//           'https://webservice.sballando.it/api/spotify/search?q=$query&eventId=${widget.eventId}'),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final tracksData = data['data']?['tracks'];
//       if (tracksData != null) {
//         searchResults = List<Map<String, dynamic>>.from(tracksData['items']);
//         if (mounted) setState(() {});
//       }
//     }

//     setState(() => isLoading = false);
//   }

//   Future<void> addTrack(String trackUri, Map<String, dynamic> trackData) async {
//   final response = await http.post(
//     Uri.parse('https://webservice.sballando.it/api/spotify/add_track'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({
//       'eventId': widget.eventId,
//       'trackUri': trackUri,
//     }),
//   );

//   if (response.statusCode == 200) {
//     Map data = jsonDecode(response.body);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           data['status'] == true ? 'Canzone aggiunta!' : '${data['error']}',
//           style: TextStyle(fontWeight: FontWeight.w800),
//         ),
//         backgroundColor:
//             data['status'] == true ? Colors.greenAccent : Colors.redAccent,
//       ),
//     );

//     if (data['status'] == true) {
//       // ✅ Aggiorna la lista della coda
//       setState(() {
//         // aggiungi la traccia alla lista della coda
//         playlistTracks.add({
//           'title': trackData['name'],
//           'subtitle': (trackData['artists'] as List).map((a) => a['name']).join(', '),
//           'cover': trackData['album']['images'] != null && trackData['album']['images'].isNotEmpty
//               ? trackData['album']['images'][0]['url']
//               : null,
//         });
//       });
//     }
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Barra di ricerca stile Spotify
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Color(0xFF1E1E1E),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: TextField(
//               controller: searchController,
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Cerca canzone',
//                 hintStyle: TextStyle(color: Colors.white54),
//                 prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(vertical: 15),
//               ),
//               onChanged: (value) => searchSongs(value),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         if (isLoading) CircularProgressIndicator(color: Colors.greenAccent),
//         SizedBox(
//           height: searchResults.isNotEmpty ? 300 : 10,
//           child: ListView.builder(
//             itemCount: searchResults.length,
//             itemBuilder: (context, index) {
//               final track = searchResults[index];
//               final cover = track['album']?['images'] != null &&
//                       track['album']['images'].isNotEmpty
//                   ? track['album']['images'][0]['url']
//                   : null;

//               return Container(
//                 margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF121212),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ListTile(
//                   leading: cover != null
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: Image.network(
//                             cover,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : Icon(Icons.music_note, color: Colors.white54),
//                   title: Text(track['name'], style: TextStyle(color: Colors.white)),
//                   subtitle: Text(
//                     (track['artists'] as List).map((a) => a['name']).join(', '),
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   trailing: IconButton(
//                     icon: Icon(Icons.add, color: Colors.greenAccent),
//                     onPressed: () => addTrack(track['uri']),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
