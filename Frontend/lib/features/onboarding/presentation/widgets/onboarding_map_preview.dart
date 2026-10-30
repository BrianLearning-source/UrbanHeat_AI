
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OnboardingMapPreview extends StatelessWidget {
  const OnboardingMapPreview({super.key});

  static const Color navy = Color(0xFF06132B);
  static const Color cyan = Color(0xFF33C1EA);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 245,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(-7.9405, 112.6145),
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.urbanheat_ai',
                ),

                // Illustrative preview only.
                // Will be replaced with actual LST data later.
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(-7.9405, 112.6145),
                      radius: 38,
                      useRadiusInMeter: false,
                      color: const Color(0xFFE83A33)
                          .withValues(alpha: 0.55),
                    ),
                    CircleMarker(
                      point: LatLng(-7.9365, 112.6200),
                      radius: 30,
                      useRadiusInMeter: false,
                      color: const Color(0xFFFC721E)
                          .withValues(alpha: 0.50),
                    ),
                    CircleMarker(
                      point: LatLng(-7.9460, 112.6090),
                      radius: 25,
                      useRadiusInMeter: false,
                      color: const Color(0xFFFFBA33)
                          .withValues(alpha: 0.50),
                    ),
                  ],
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(-7.9405, 112.6145),
                      width: 34,
                      height: 34,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF06132B),
                        size: 32,
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

            // Map information badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: navy.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cyan.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      color: cyan,
                      size: 13,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'HEAT MAP PREVIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom location label
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: navy.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: cyan,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lowokwaru District',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Malang, East Java, Indonesia',
                            style: TextStyle(
                              color: Color(0xFFADCCED),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.my_location,
                      color: cyan,
                      size: 16,
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
