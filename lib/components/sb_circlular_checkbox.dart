import 'package:flutter/material.dart';

class CircularCheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const CircularCheckbox({super.key, required this.onChanged});

  @override
  _CircularCheckboxState createState() => _CircularCheckboxState();
}

class _CircularCheckboxState extends State<CircularCheckbox> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
       value = !value;
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: value ? Colors.blue : Colors.grey,
            width: 2,
          ),
          color: value ? Colors.blue : Colors.transparent,
        ),
        child: value
            ? Center(
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
