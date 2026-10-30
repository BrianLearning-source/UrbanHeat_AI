
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_actual_map.dart';

class OnboardingFinalVisual extends StatelessWidget {
  const OnboardingFinalVisual({super.key});

  static const Color _navy = Color(0xFF06132B);
  static const Color _cyan = Color(0xFF33C1EA);
  static const Color _muted = Color(0xFFA8C1E2);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),

        // Section label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF193A5E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'YOUR CITY, MORE UNDERSTANDABLE',
            style: TextStyle(
              color: _cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Ready to explore UrbanHeat AI?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            height: 1.18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),

        const SizedBox(height: 13),

        const Text(
          'Start exploring urban heat patterns, discover '
          'environmental insights, and understand how '
          'AI-powered predictions can help us see cities differently.',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.65,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFF142B4F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF284F77),
            ),
          ),
          child: Column(
            children: [
              const OnboardingActualMap(
                height: 175,
                showLocationLabel: false,
              ),

              const SizedBox(height: 11),

              const Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: _cyan,
                    size: 15,
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Lowokwaru District, Malang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'EXPLORE YOUR CITY',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 51,
          child: ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: _navy,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Create an account',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 11),

        SizedBox(
          width: double.infinity,
          height: 49,
          child: OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFF456181),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Log in',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 17),

        const Center(
          child: Text(
            'Model-based insights · Not live sensor readings',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 9,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }
}
