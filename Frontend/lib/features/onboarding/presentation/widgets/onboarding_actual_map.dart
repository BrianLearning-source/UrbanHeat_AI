
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OnboardingActualMap extends StatelessWidget {
  const OnboardingActualMap({
    super.key,
    this.height = 158,
    this.showLocationLabel = true,
  });

  final double height;
  final bool showLocationLabel;

  static const LatLng _lowokwaruCenter = LatLng(
    -7.9405,
    112.6145,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: _lowokwaruCenter,
                initialZoom: 14,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.urbanheat_ai',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _lowokwaruCenter,
                      width: 32,
                      height: 32,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF06132B),
                        size: 30,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),

            if (showLocationLabel)
              Positioned(
                left: 9,
                right: 9,
                bottom: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xF206132B),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF33C1EA),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lowokwaru, Malang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
