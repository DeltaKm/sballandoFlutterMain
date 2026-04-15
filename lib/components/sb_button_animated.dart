import 'package:flutter/material.dart';

class AnimatedIconsScreen extends StatefulWidget {
  const AnimatedIconsScreen({super.key});

  @override
  _AnimatedIconsScreenState createState() => _AnimatedIconsScreenState();
}

class _AnimatedIconsScreenState extends State<AnimatedIconsScreen> {
  bool _isIconsVisible = false; // Indica se le icone devono essere visibili o meno
  bool _isOverlayVisible = false; // Indica se l'overlay è visibile
  double _offset = 0; // Variabile per animare il movimento delle icone

  void _toggleIcons() {
    setState(() {
      _isIconsVisible = !_isIconsVisible;
      _isOverlayVisible = !_isOverlayVisible;
      _offset = _isIconsVisible ? 0 : 100; // Definisce l'animazione di salita
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Overlay che oscura la pagina
          if (_isOverlayVisible)
            GestureDetector(
              onTap: _toggleIcons,
              child: Container(
                color: Colors.black.withOpacity(0.5), // Colore semitrasparente
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Icona principale che avvia l'animazione
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.white, size: 30),
                onPressed: _toggleIcons, // Mostra o nasconde le altre icone
              ),
            ),
          ),

          // Icicle altre che salgono in verticale
          if (_isIconsVisible)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: _offset + 80, // La prima icona si sposta sopra l'icona principale
              right: 20,
              child: IconButton(
                icon: Icon(Icons.home, color: Colors.blue, size: 30),
                onPressed: () {},
              ),
            ),
          if (_isIconsVisible)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: _offset + 140, // La seconda icona si sposta sopra la prima
              right: 20,
              child: IconButton(
                icon: Icon(Icons.search, color: Colors.blue, size: 30),
                onPressed: () {},
              ),
            ),
          if (_isIconsVisible)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: _offset + 200, // La terza icona si sposta sopra la seconda
              right: 20,
              child: IconButton(
                icon: Icon(Icons.notifications, color: Colors.blue, size: 30),
                onPressed: () {},
              ),
            ),
          if (_isIconsVisible)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: _offset + 260, // La quarta icona
              right: 20,
              child: IconButton(
                icon: Icon(Icons.account_circle, color: Colors.blue, size: 30),
                onPressed: () {},
              ),
            ),
          if (_isIconsVisible)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: _offset + 320, // La quinta icona
              right: 20,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.blue, size: 30),
                onPressed: () {},
              ),
            ),
        ],
      ),
    );
  }
}
