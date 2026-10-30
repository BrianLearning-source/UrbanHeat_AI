
import 'package:flutter/material.dart';

import 'onboarding_actual_map.dart';

class OnboardingDataVisual extends StatelessWidget {
  const OnboardingDataVisual({super.key});

  static const Color _navy = Color(0xFF06132B);
  static const Color _blue = Color(0xFF196DDB);
  static const Color _muted = Color(0xFF566D8C);
  static const Color _lightBlue = Color(0xFFDDEDFF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'EXPLORE THE DATA',
            style: TextStyle(
              color: _blue,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Headline
        const Text(
          'From a heat map to a prediction.',
          style: TextStyle(
            color: _navy,
            fontSize: 27,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // Description
        const Text(
          'Explore spatial patterns and review model-based '
          'heat intensity estimates for a selected location '
          'and period.',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 22),

        // Map preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE2EFFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDDE8F4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingActualMap(
                height: 185,
                showLocationLabel: false,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: _blue,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      'Lowokwaru District, Malang',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MAP VIEW',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Prediction information card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD6E2F4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF163B68).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F0FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: _blue,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predict Heat Intensity',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Explore model-based estimates to understand '
                      'potential heat intensity across locations.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: _blue,
                          size: 13,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'MODEL-BASED ESTIMATE',
                          style: TextStyle(
                            color: _blue,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
