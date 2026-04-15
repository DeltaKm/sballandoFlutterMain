import 'package:flutter/material.dart';

class BlinkingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BlinkingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  });

  @override
  _BlinkingWidgetState createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<BlinkingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Duration definisce la velocità di lampeggio (1 secondo per ciclo, ad esempio)
    _controller = AnimationController(vsync: this, duration: widget.duration);
    // Intervallo di opacità, ad es. da 1.0 a 0.5 (puoi modificare questi valori)
    _animation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true); // Inizia l'animazione in loop invertendosi
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
