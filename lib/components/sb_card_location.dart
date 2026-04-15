import 'package:flutter/material.dart';
import 'package:sballando/components/sb_map.dart';
import 'package:sballando/sb_global.dart';

class SbCardLocation extends StatefulWidget {

  Map location;
  bool? map;
  SbCardLocation({
    super.key,
    required this.location,
    this.map,
  });

  @override
  State<SbCardLocation> createState() => SbCardLocationState();
}

class SbCardLocationState extends State<SbCardLocation> {

  
 @override
  Widget build(BuildContext context) {
    double latitude  = 0;
    double longitude = 0;

    String? coordinate = widget.location['coordinates'];
    
    if (coordinate != null && coordinate.contains(',')) {
      final parts = coordinate.split(',');
    
      if (parts.length == 2) {
        try {
          final latPart = parts[0].trim();
          final lngPart = parts[1].trim();
    
          if (latPart.isNotEmpty && lngPart.isNotEmpty) {
            latitude = double.parse(latPart);
            longitude = double.parse(lngPart);
          }
        } catch (e) {
          print('Errore nel parsing delle coordinate: $e');
        }
      }
    }


    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(
          context,
          '/locationShow',
          arguments: {'locationId': widget.location['id']},
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.map != null && widget.map == true
            ? Container(
                child: Center(
                  child: MapWidget(
                    latitude: latitude, 
                    longitude: longitude,
                  ),
                ),
              )
            :  ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  width: double.infinity,
                  height: 200,
                  "$BASE_URL${widget.location['logo']}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                  width: double.infinity,
                  height: 200,
                  "assets/images/sballando_no_photo.jpeg",
                  fit: BoxFit.cover,
                  );
                  },
                ),
              ),
            SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.location['name']}',
                  style: TextStyle(
                    fontSize: textMidHight,
                    fontWeight: FontWeight.w800,
                    color: mainColor
                  ),
                ),
                        
                Text(
                  '${widget.location['description']}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                        fontSize: textLowMid,
                        fontWeight: FontWeight.w400,
                        color: textColorSecondary
                      ),
                ),
                SizedBox(height: 5,),
                Row(
                  children: [
                    Icon(Icons.location_on, color: mainColor,size: textMid,),
                    Expanded(
                      child: Text(
                        '${widget.location['comune'] + ', (' + widget.location['provincia_sigla'] + '), ' + widget.location['cap']}',
                        style: TextStyle(
                          fontSize: textMid,
                          fontWeight: FontWeight.w500,
                                          
                          color: textColor
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}