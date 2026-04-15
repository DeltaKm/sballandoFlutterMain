import 'package:flutter/material.dart';

class SbFavoriteButton extends StatefulWidget {
  final bool initialIsLiked;
  final Function(bool isLiked)? onChanged;

  const SbFavoriteButton({super.key, this.initialIsLiked = false, this.onChanged});

  @override
  State<SbFavoriteButton> createState() => SbFavoriteButtonState();
}

class SbFavoriteButtonState extends State<SbFavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool isLiked;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialIsLiked;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

void _toggleLike() {
  setState(() {
    isLiked = !isLiked;
  });

  _controller.forward(from: 0.0); // Rilancia animazione
  if (widget.onChanged != null) widget.onChanged!(isLiked);
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.grey,
          size: 25,
        ),
      ),
    );
  }
}
