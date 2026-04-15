import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbAccordtionList extends StatefulWidget {
  String title;
  Widget items;

  SbAccordtionList({super.key, required this.title, required this.items});

  @override
  State<SbAccordtionList> createState() => SbAccordtionListState();
}

class SbAccordtionListState extends State<SbAccordtionList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context, 90),
      decoration: BoxDecoration(
        color: backgroundColor, // Colore di sfondo
        borderRadius: BorderRadius.circular(10), // Bordi arrotondati
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.all(0),
          title: Row(
            children: [
              Icon(Icons.list, color: mainColor, size: 30),
              SizedBox(width: 10),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  fontSize: textMid,
                ),
              ),
            ],
          ),
          iconColor: mainColor, // Cambia colore icona freccia
          collapsedIconColor: mainColor,
          children: [widget.items],
        ),
      ),
    );
  }
}

class SbAccordtionListProduct extends StatefulWidget {
  String title;
  Widget items;
  String image;

  SbAccordtionListProduct({
    super.key,
    required this.title,
    required this.items,
    required this.image,
  });

  @override
  State<SbAccordtionListProduct> createState() =>
      SbAccordtionListProductState();
}

class SbAccordtionListProductState extends State<SbAccordtionListProduct> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context, 90),
      decoration: BoxDecoration(
        color: backgroundColor, // Colore di sfondo
        borderRadius: BorderRadius.circular(10), // Bordi arrotondati
      ),
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(dividerColor: Colors.transparent), // Rimuove la linea sotto
        child: ExpansionTile(
          childrenPadding: EdgeInsets.all(0),
          title: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        NOPHOTO,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.title,
                  softWrap: true,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                    color: textColor,
                    fontSize: textMid,
                  ),
                ),
              ),
            ],
          ),
          iconColor: mainColor, // Cambia colore icona freccia
          collapsedIconColor: mainColor,
          children: [widget.items],
        ),
      ),
    );
  }
}
