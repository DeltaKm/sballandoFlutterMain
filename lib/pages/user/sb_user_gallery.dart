import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class SbUserGallery extends StatefulWidget {
  final String? eventId;
  
  const SbUserGallery({super.key, this.eventId});

  @override
  State<SbUserGallery> createState() => SbUserGalleryState();
}

class SbUserGalleryState extends State<SbUserGallery> {
  List<dynamic> photos = [];
  bool isLoading = true;
  dynamic eventId;
  Set<String> downloadingImages = {}; // Track which images are being downloaded

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get eventId from route parameters if not provided directly
    if (widget.eventId != null) {
      eventId = widget.eventId;
    } else {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      eventId = args?['eventId'];
    }
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    try {
      dynamic data = await ApiEvent().getPhotosEventGallery(eventId);
      if (data != null && data['status'] == true) {
        setState(() {
          photos = List.from(data['photos'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading photos: $e');
      setState(() => isLoading = false);
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Full screen photo
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareImage(String imageUrl) async {
    try {
      // Scarica l'immagine
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // Salva temporaneamente
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(bytes);

      // Condividi come file
      await Share.shareXFiles([XFile(file.path)], text: 'Guarda questa foto!');
    } catch (e) {
      print("Errore nella condivisione: $e");
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    // Se l'immagine è già in download, non fare nulla
    if (downloadingImages.contains(imageUrl)) {
      return;
    }

    try {
      // Aggiungi l'immagine al set di download in corso
      setState(() {
        downloadingImages.add(imageUrl);
      });

      // Scarica l'immagine
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // Ottieni la directory Downloads
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        // Crea un nome file unico con timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'sballando_photo_$timestamp.jpg';
        final filePath = '${downloadsDir.path}/$fileName';
        
        // Salva il file
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Mostra messaggio di successo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Immagine salvata in ${Platform.isAndroid ? 'Download' : 'Documenti'}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print("Errore nel download: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nel salvare l\'immagine'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // Rimuovi l'immagine dal set di download in corso
      if (mounted) {
        setState(() {
          downloadingImages.remove(imageUrl);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Column(
        children: [
          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: mainColor),
                )
              : photos.isEmpty
                  ? Center(
                      child: Text(
                        'Nessuna foto disponibile',
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : Column(
                    children: photos.map((photo) {
                      final imageUrl =
                          'https://webservice.sballando.it/$photo';
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(context, imageUrl),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  height: 300,
                                  width: double.infinity,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      height: 300,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.grey[500],
                                          size: 48,
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return SizedBox(
                                      height: 300,
                                      child: Center(
                                        child:
                                            CircularProgressIndicator(
                                          color: mainColor,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Bottone share
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.share,
                                        color: Colors.white),
                                    onPressed: () => _shareImage(imageUrl),
                                  ),
                                ),
                              ),
                              // Bottone download
                              Positioned(
                                top: 60,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: downloadingImages.contains(imageUrl)
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.download,
                                            color: Colors.white),
                                        onPressed: () => _downloadImage(imageUrl),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
        ],
      ),
    );
  }
}