
import 'package:flutter/material.dart';

import 'onboarding_actual_map.dart';

class OnboardingChallengeVisual extends StatelessWidget {
  const OnboardingChallengeVisual({super.key});

  static const Color _navy = Color(0xFF06132B);
  static const Color _blue = Color(0xFF196DDB);
  static const Color _muted = Color(0xFF566D8C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFDDEDFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'THE CHALLENGE',
            style: TextStyle(
              color: _blue,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Heat changes how a city feels.',
          style: TextStyle(
            color: _navy,
            fontSize: 27,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Urban environments can experience higher '
          'temperatures as built-up surfaces and limited '
          'greenery influence local conditions.',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 22),

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
                height: 158,
                showLocationLabel: false,
              ),
              const SizedBox(height: 10),
              const Text(
                'Explore the urban landscape of Lowokwaru',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const _FactorCard(
          icon: Icons.location_city_rounded,
          iconColor: Color(0xFFE98543),
          iconBackground: Color(0xFFFFE8D6),
          title: 'Built-up surfaces',
          description: 'Materials and dense development',
        ),

        const SizedBox(height: 12),

        const _FactorCard(
          icon: Icons.park_rounded,
          iconColor: Color(0xFF269B65),
          iconBackground: Color(0xFFD6F4E2),
          title: 'Vegetation coverage',
          description: 'Green space and canopy',
        ),
      ],
    );
  }
}

class _FactorCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;

  const _FactorCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFD6E2F4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF06132B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF566B87),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
