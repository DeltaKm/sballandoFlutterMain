import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_footer.dart';
import 'package:sballando/components/sb_header.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';

class SbQrScanner extends StatefulWidget {
  const SbQrScanner({super.key});

  @override
  State<SbQrScanner> createState() => SbQrScannerState();
}

class SbQrScannerState extends State<SbQrScanner> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;
  bool _showFooter = true;
  String scannedText = '';
  bool _isCameraPaused = false;
  bool _isDisposed = false;
  bool _isProcessingQR = false; // Flag per evitare scansioni multiple
  QRCodeDartScanController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = QRCodeDartScanController();
    REF_CONTROLLER_QRCODE = _controller;
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FOOTERSELECT = 'qrCode';
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showHeader = true;
            _showFooter = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_isDisposed) {
      _controller?.stopScan();
      _controller?.dispose();
      _isDisposed = true;
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      _resumeCamera();
    }
  }

  // Pausa la fotocamera
  void _pauseCamera() {
    if (!_isCameraPaused && _controller != null && !_isDisposed) {
      setState(() {
        _isCameraPaused = true;
      });
      _controller?.stopScan();
    }
  }

  // Riprende la fotocamera
  void _resumeCamera() {
    if (_isCameraPaused && _controller != null && !_isDisposed && mounted) {
      setState(() {
        _isCameraPaused = false;
        _isProcessingQR = false;
      });
      _controller?.startScan();
    }
  }

  bool isValidBase64(String input) {
    try {
      base64Decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> handleScan(Result result) async {
    final code = result.text;

    // Evita scansioni multiple e controlla validità
    if (_isCameraPaused || _isProcessingQR || !mounted || code.isEmpty) return;

    // Blocca immediatamente la fotocamera e il processing
    setState(() {
      _isCameraPaused = true;
      _isProcessingQR = true;
      scannedText = code;
    });
    
    _controller?.stopScan();

    try {
      if (code.contains('qr_enter@')) {
        await _handleEventQR(code);
      } else if (isValidBase64(code)) {
        String stringDecode = String.fromCharCodes(base64.decode(code));
        
        if (stringDecode.contains('ticket')) {
          await _handleTicketQR(code);
        } else if (stringDecode.contains('product')) {
          await _handleProductQR(code);
        } else if (stringDecode.contains('snap_game')) {
          // Gestisci snap_game se necessario
          _resumeCamera();
        } else {
          await _showModalAndResume('QR non valido', isError: true);
        }
      } else {
        await _showModalAndResume('QR non valido', isError: true);
      }
    } catch (e) {
      print('Errore handleScan: $e');
      await _showModalAndResume('Errore durante la scansione', isError: true);
    }
  }

  Future<void> _handleEventQR(String code) async {
    dynamic data = await ApiEvent().registerEventQr(code);
    
    if (data != null && data['status'] == true) {
      // Naviga alla pagina evento (non riprende camera)
      if (mounted) {
        await closeScanner();
        Navigator.pushNamed(context, '/eventShow', arguments: {'eventId': data['event_id']});
      }
    } else if (data != null && data['error'] != null) {
      await _showModalAndResume(data['error'], isError: true);
    } else {
      await _showModalAndResume('Errore sconosciuto', isError: true);
    }
  }

  Future<void> _handleTicketQR(String code) async {
    try {
      dynamic data = await ApiEvent().verifyTicket(code);
      
      if (data != null && data['status'] == true) {
        await _showModalAndResume('Ticket validato con successo', isError: false);
      } else if (data != null && data['error'] != null) {
        await _showModalAndResume(data['error'], isError: true);
      } else {
        await _showModalAndResume('Errore sconosciuto', isError: true);
      }
    } catch (e) {
      print('Errore decode base64: $e');
      await _showModalAndResume('Errore sconosciuto', isError: true);
    }
  }

  Future<void> _handleProductQR(String code) async {
    dynamic data = await ApiEvent().verifyProduct(code);
    
    if (data != null && data['status'] == true) {
      await _showModalProductAndResume(data['product']);
    } else if (data != null && data['error'] != null) {
      await _showModalAndResume(data['error'], isError: true);
    } else {
      await _showModalAndResume('Errore sconosciuto', isError: true);
    }
  }

  // Mostra modale e poi riprende la camera quando si chiude
  Future<void> _showModalAndResume(String message, {required bool isError}) async {
    if (!mounted) return;
    
    Modals().showMessage(
      context,
      isError ? 'error' : 'success',
      message,
    );
    
    // Aspetta che la modale si chiuda (2 secondi tipicamente per i messaggi)
    await Future.delayed(Duration(seconds: 2));
    
    // Riprende la camera dopo che la modale si chiude
    _resumeCamera();
  }

  // Mostra modale prodotto e poi riprende la camera
  Future<void> _showModalProductAndResume(dynamic product) async {
    if (!mounted) return;
    
    Modals().showMessageScan(
      context,
      'success',
      'Prodotto validato con successo.',
      product,
    );
    
    // Aspetta che l'utente chiuda la modale (tempo maggiore per prodotti)
    await Future.delayed(Duration(seconds: 3));
    
    // Riprende la camera dopo che la modale si chiude
    _resumeCamera();
  }

  // Chiude lo scanner e ferma la fotocamera
  Future<void> closeScanner() async {
    if (_controller != null && !_isDisposed) {
      await _controller!.stopScan();
      _isDisposed = true;
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = ONAIR == true ? 150 : 100.0;
    const double footerHeight = 100.0;

    return WillPopScope(
      onWillPop: () async {
        // Ferma la scansione prima di tornare indietro
        if (_controller != null && !_isDisposed) {
          await _controller!.stopScan();
          _isDisposed = true;
        }
        return true; // Permetti la navigazione
      },
      child: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            body: SizedBox(
              width: width(context, 100),
              height: height(context, 100),
              child: Stack(
                children: [
                  QRCodeDartScanView(
                    controller: _controller,
                    scanInvertedQRCode: true,
                    typeScan: TypeScan.live,
                    onCapture: handleScan,
                    resolutionPreset: QRCodeDartScanResolutionPreset.high,
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: 100,
                  //   right: 50,
                  //   child: InkWell(
                  //     onTap: () async {
                  //       await closeScanner();
                  //     },
                  //     child: Container(
                  //       width: 50,
                  //       height: 50,
                  //       alignment: Alignment.center,
                  //       decoration: BoxDecoration(
                  //         color: Colors.red,
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       child: Text(
                  //         'Chiudi',
                  //         style: TextStyle(color: Colors.white),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  if (scannedText.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 120),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Scansionato: $scannedText',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _showHeader ? 0 : -headerHeight,
                    left: 0,
                    right: 0,
                    height: headerHeight,
                    child: Column(
                      children: [
                        SbHeader(search: false,),
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: _showFooter ? 0 : -footerHeight,
                    left: 0,
                    right: 0,
                    height: footerHeight,
                    child: SbFooter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
