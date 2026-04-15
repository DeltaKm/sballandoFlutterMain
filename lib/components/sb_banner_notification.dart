import 'package:flutter/material.dart';

class NotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final String? imageUrl;
  final VoidCallback onDismiss;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.onDismiss,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() => _visible = true);
    });

    Future.delayed(const Duration(seconds: 4), () {
      setState(() => _visible = false);
      Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 10;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: _visible ? top : -200,
      left: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (widget.imageUrl != null)
                Image.network(
                  widget.imageUrl!,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                ),
              if (widget.imageUrl != null) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.body, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
