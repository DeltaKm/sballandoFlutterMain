import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_input.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/components/sb_tab_multi.dart';
import 'package:sballando/sb_global.dart';
import 'package:http/http.dart' as http;

class SbJukebox extends StatefulWidget {
  const SbJukebox({super.key});

  @override
  State<SbJukebox> createState() => SbJukeboxState();
}

class SbJukeboxState extends State<SbJukebox> {
  final ScrollController  _scrollController      = ScrollController();
  static const String spotifyApiBase = 'https://sballando-back-office.vercel.app/api/spotify';
  Timer? _searchDebounce;
  int? _eventId;
  bool _routeArgsLoaded = false;

  double headerHeight = 100;
  double footerHeight = 100;
  TextEditingController searchController = TextEditingController();
  TextEditingController dedicaController = TextEditingController();

  List searchResults = [];
  List playlistTracks = [];
  bool isLoading = false;
  bool isLoadingPlaylist = true;
  bool loader = false;
  String dedica = '';
  Map currentTrack = {};

  Timer? _playbackTimer;
  Timer? _progressTimer;
  Timer? pollingTimer;

  int currentProgressMs = 0;
  int currentDurationMs = 0;

  int? get activeEventId {
    if (_eventId != null && _eventId! > 0) return _eventId;
    final fallback = int.tryParse('${EVENTONAIR['id']}');
    if (fallback != null && fallback > 0) return fallback;
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeArgsLoaded) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['eventId'] != null) {
      final parsed = int.tryParse('${args['eventId']}');
      if (parsed != null && parsed > 0) {
        _eventId = parsed;
      }
    }
    _routeArgsLoaded = true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchCurrentTrack();
      await fetchPlaybackQueue();
      socketService.connect(onNewMessage: (data) {}, type: 'public');

      _playbackTimer = Timer.periodic(Duration(seconds: 5), (_) {
        fetchCurrentTrack();
        fetchPlaybackQueue(); // aggiorna coda per eventuali nuovi brani
      });
        // Timer per animare barra e tempo
      _progressTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
        if (currentTrack['is_playing'] == true) {
          setState(() {
            currentProgressMs += 100; // incrementa di 200ms
            if (currentProgressMs > currentTrack['duration_ms']) {
              currentProgressMs = currentTrack['duration_ms'];
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _progressTimer?.cancel();
    pollingTimer?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> fetchCurrentTrack() async {
    final url = Uri.parse('https://api.spotify.com/v1/me/player/currently-playing');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${EVENTONAIR['spotify_access_token']}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['item'] != null) {
          currentProgressMs = data['progress_ms'];
          currentTrack = {
            'title': data['item']['name'],
            'artists': (data['item']['artists'] as List)
                .map((a) => a['name'])
                .join(', '),
            'cover': data['item']['album']['images'][0]['url'],
            'progress_ms': data['progress_ms'],
            'duration_ms': data['item']['duration_ms'],
            'is_playing': data['is_playing'],
          };

          setState(() {});
        }
      } else if (response.statusCode == 204) {
        setState(() => currentTrack = {});
      }
    } catch (e) {
      print('Errore fetchCurrentTrack: $e');
    }
  }

  String formatDuration(int ms) {
    final seconds = (ms / 1000).floor();
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String formatProgress() {
    int seconds = (currentProgressMs / 1000).floor();
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> fetchPlaybackQueue() async {
    final eventId = activeEventId;
    if (eventId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$spotifyApiBase/get_playback_queue').replace(
          queryParameters: {'eventId': '$eventId'},
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          List tracks = [];

          final current = data['current_track'];
          if (current != null) {
            dedica = current['message']?['message'] ?? '';
            tracks.add({
              'title': current['name'],
              'message': current['message'],
              'subtitle': (current['artists'] as List).map((a) => a['name']).join(', '),
              'cover': current['album']['images'][0]['url'] ?? '',
            });
          }

          final queue = data['queue'] ?? [];
          for (var item in queue) {
            // evita duplicati confrontando titolo + artista
            if (!tracks.any((t) => t['title'] == item['name'] &&
                                  t['subtitle'] == (item['artists'] as List).map((a) => a['name']).join(', '))) {
              tracks.add({
                'title': item['name'],
                'message': item['message'],
                'subtitle': (item['artists'] as List).map((a) => a['name']).join(', '),
                'cover': item['album']['images'][0]['url'] ?? '',
              });
            }
          }
          setState(() => playlistTracks = tracks);
        }
      }
    } catch (e) {
      print('Errore caricamento playback queue: $e');
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      searchSongs(value);
    });
  }


  Future<void> searchSongs(String query) async {
    if (query.length < 2) {
      if (mounted) {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
      }
      return;
    }

    final eventId = activeEventId;
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento non valido per la ricerca Spotify'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$spotifyApiBase/search').replace(
          queryParameters: {
            'q': query,
            'eventId': '$eventId',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final tracksData = data['data']?['tracks'];
          searchResults = tracksData != null ? List.from(tracksData['items']) : [];
          if (mounted) setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${data['error'] ?? 'Ricerca Spotify non disponibile'}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore rete durante la ricerca Spotify'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print('Errore searchSongs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante la ricerca canzoni'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> addTrack(
    String trackUri,
    Map<String, dynamic> trackData, {
    String? message,
  }) async {
    final eventId = activeEventId;
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento non valido, impossibile aggiungere il brano'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$spotifyApiBase/add_track'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventId': eventId,
        'user_token': USER['token'],
        'trackUri': trackUri,
        'message': message ?? '',
      }),
    );

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);

      if (data['status'] == true) {
        Map newMessage = {
          'event_id': eventId,
          'sender_id': USER['id'],
          'message': message,
          'created_at': getCurrentTimeInIsoUtc(),
          'picture': USER['picture'],
          'spotify_playlist': {
            'title': trackData['name'],
            'subtitle': (trackData['artists'] as List)
                .map((a) => a['name'])
                .join(', '),
            'cover': trackData['album']['images']?[0]?['url'],
          }
        };

        socketService.sendMessage(USER, eventId, newMessage);
        setState(() {
          playlistTracks.insert(1, {
            'title': trackData['name'],
            'subtitle': (trackData['artists'] as List)
                .map((a) => a['name'])
                .join(', '),
            'cover': trackData['album']['images']?[0]?['url'],
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Canzone aggiunta!',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            backgroundColor: mainColor,
          ),
        );
      } else {
        final errorMessage = data['error'] ?? 'Impossibile aggiungere la canzone in questo momento';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$errorMessage',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      String backendMessage = 'Errore di connessione durante l\'aggiunta della canzone';

      try {
        final failData = jsonDecode(response.body);
        if (failData is Map && failData['error'] != null) {
          backendMessage = '${failData['error']}';
        }
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            backendMessage,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // --- SCROLL PRINCIPALE ---
              Positioned(
                top: 80,
                left: 0,
                right: 0,

                child: SbTabMulti(
                  firstLabel: 'Ricerca brani', 
                  secondLabel: 'Playlist', 
                  secondContent: SizedBox(
                    height: height(context, 75),
                    child: SingleChildScrollView(
                      
                      child: Column(
                        children: [
                          // --- CODA ---
                          if (currentTrack.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'In riproduzione: ${currentTrack['title']}',
                              style: TextStyle(color: mainColor, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (playlistTracks.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: playlistTracks.isNotEmpty ? playlistTracks.length : 0,
                            itemBuilder: (context, index) {
                              final track = playlistTracks[index];
                              final isPlaying = index == 0;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPlaying ? Colors.green.withOpacity(0.1) : Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: isPlaying 
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          currentTrack['cover'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              NOPHOTO,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      )
                                    : (track['cover'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.network(
                                            track['cover'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                NOPHOTO,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(Icons.music_note, color: Colors.white54)),
                                  title: Text(
                                    isPlaying ? currentTrack['title'] : track['title'],
                                    style: TextStyle(color: isPlaying ? mainColor : Colors.white, fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPlaying ? currentTrack['artists'] : track['subtitle'],
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      if (isPlaying)
                                        Column(
                                          children: [
                                            Text('$dedica'),
                                            SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: currentProgressMs / currentTrack['duration_ms'],
                                              color: mainColor,
                                              backgroundColor: Colors.grey.shade800,
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '${formatDuration(currentProgressMs)} / ${formatDuration(currentTrack['duration_ms'])}',
                                              style: TextStyle(color: Colors.white54, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  trailing: isPlaying
                                      ? currentTrack['is_playing'] == true
                                          ? Icon(Icons.play_arrow, color: mainColor)
                                          : Icon(Icons.pause, color: mainColor)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ), 
                  firstContent:  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: backgroundColorTheme,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Cerca su Spotify',
                            hintStyle: TextStyle(color: textColor),
                            prefixIcon: Icon(Icons.search, color: mainColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: onSearchChanged,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (isLoading) 
                      CircularProgressIndicator(color: mainColor),
                      if (searchResults.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final track = searchResults[index];
                          final cover = track['album']?['images'] != null && track['album']['images'].isNotEmpty  ? track['album']['images'][0]['url']  : null;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF121212),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: cover != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        cover,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.music_note, color: Colors.white54),
                              title: Text(track['name'], style: TextStyle(color: Colors.white)),
                              subtitle: Text(
                                (track['artists'] as List).map((a) => a['name']).join(', '),
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.add, color: mainColor),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: backgroundColor,
                                        child: Container(
                                          width: width(context, 90),
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Scrivi una dedica',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: textMidHight,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              SbInput(
                                                controller: dedicaController,
                                                obscureText: false,
                                                label: 'La tua dedica...',
                                                validatorFunction: (value) {},
                                              ),
                                              const SizedBox(height: 30),
                                              LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final textScale = MediaQuery.textScalerOf(context).scale(1);
                                                  final stackButtons = constraints.maxWidth < 320 || textScale > 1.1;

                                                  final cancelButton = SbButtonMaincolor(
                                                    label: 'Annulla',
                                                    function: () => Navigator.pop(context),
                                                  );

                                                  final confirmButton = SbButtonMaincolor(
                                                    label: 'Conferma',
                                                    function: () {
                                                      Modals().showMessageConfirme(
                                                        context,
                                                        'Aggiungi in Coda',
                                                        'Sei sicuro di voler aggiungere questa canzone in coda?',
                                                        () {
                                                          addTrack(track['uri'], track, message: dedicaController.text);
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                        },
                                                        () {
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                        },
                                                      );
                                                    },
                                                  );

                                                  if (stackButtons) {
                                                    return Column(
                                                      children: [
                                                        SizedBox(width: double.infinity, child: cancelButton),
                                                        const SizedBox(height: 12),
                                                        SizedBox(width: double.infinity, child: confirmButton),
                                                      ],
                                                    );
                                                  }

                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Expanded(child: cancelButton),
                                                      const SizedBox(width: 15),
                                                      Expanded(child: confirmButton),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ),


              // --- HEADER ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(color: backgroundColor),
                  height: 80,
                  width: width(context, 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.chevron_left, color: mainColor, size: 50),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width(context, 80),
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      '${EVENTONAIR['title']}',
                                      style: TextStyle(color: mainColor, fontSize: textHight, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jukebox',
                                        style: TextStyle(color: textColor, fontSize: textMidHight, fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}