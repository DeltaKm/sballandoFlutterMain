import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sballando/sb_global.dart';

class SbInput extends StatefulWidget {

  TextEditingController                         controller;
  bool                                          obscureText;
  String                                        label;
  FormFieldValidator<String>                    validatorFunction;
  IconData?                                     icon;
  bool?                                         typePassword;
  bool?                                         enabled;
  Function?                                     function;
  Color?                                        background;

  SbInput({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.label,
    required this.validatorFunction,
    this.typePassword,
    this.function,
    this.enabled,
    this.background,
    this.icon,
  });

  @override
  State<SbInput> createState() => SbInputState();
}

class SbInputState extends State<SbInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.label == 'Email' ? TextInputType.emailAddress : null,
      textInputAction: TextInputAction.done,
      autofillHints: [AutofillHints.email],
      inputFormatters: widget.label == 'Email'
          ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
          : null,
      controller: widget.controller,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      validator: widget.validatorFunction,
      style: TextStyle(
        fontSize: 15,
        color: textColor
      ),
      textAlignVertical: TextAlignVertical.center,
      
      onFieldSubmitted: (value) {
        widget.function!();
        print('sto cliccando');
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.enabled == false
            ? const Color.fromARGB(166, 214, 214, 214)
            : widget.background ?? backgroundColor,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20), // 👈 aumentato
        labelText: widget.label,
        labelStyle: TextStyle(
          color: textColor
        ),
        // ✅ Bordi arrotondati ovunque
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none, // opzionale per stile più moderno
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: mainColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: backgroundColorTheme),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey),
        ),

        prefixIcon: widget.icon != null
            ? Icon(widget.icon, size: 16)
            : null,

        suffixIcon: widget.typePassword == true
            ? IconButton(
                icon: Icon(
                  widget.obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    widget.obscureText = !widget.obscureText;
                  });
                },
              )
            : null,
      ),
    );


  }
}


class SbInputUnderline extends StatefulWidget {

  TextEditingController                         controller;
  bool                                          obscureText;
  String                                        label;
  FormFieldValidator<String>                    validatorFunction;
  IconData?                                     icon;
  bool?                                         typePassword;
  String                                        positionText;
  String?                                       prefixText;
  TextStyle?                                    style;

  SbInputUnderline({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.label,
    required this.validatorFunction,
    required this.positionText,
    this.prefixText,
    this.style,
    this.typePassword,
    this.icon,
  });

  @override
  State<SbInputUnderline> createState() => SbInputUnderlineState();
}

class SbInputUnderlineState extends State<SbInputUnderline> {
  @override
  void initState() {
    super.initState();
    if (widget.prefixText != null && widget.prefixText!.isNotEmpty) {
      if (!widget.controller.text.startsWith(widget.prefixText!)) {
        widget.controller.text = '${widget.prefixText}${widget.controller.text}';
      }

      widget.controller.addListener(() {
        if (!widget.controller.text.startsWith(widget.prefixText!)) {
          final newText = widget.controller.text.replaceAll(widget.prefixText!, '');
          widget.controller.text = '${widget.prefixText}$newText';
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: widget.style,
      validator: widget.validatorFunction,
      controller: widget.controller,
      obscureText: widget.obscureText,
      textAlign: widget.positionText == 'center' ? TextAlign.center : widget.positionText == 'left' ? TextAlign.start : widget.positionText == 'right' ? TextAlign.end : TextAlign.start,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5000)
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        isDense: true,
        suffixIcon: widget.typePassword == true
          ? IconButton(
              icon: Icon(
                widget.obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  widget.obscureText = !widget.obscureText;
                });
              },
            )
          : null,
        labelText: widget.controller.text.isEmpty ? widget.label : null,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mainColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: backgroundColorTheme),
        ),
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                size: 20,
              )
            : null,
      ),
    );
  }
}
