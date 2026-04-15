import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(latitude, longitude);

    return SizedBox(
      height: 200,
      width: double.infinity,
    
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(20),
        child: FlutterMap(
          options: MapOptions(
            center: point,
            zoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'it.sballando.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
