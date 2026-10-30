
import 'package:flutter/material.dart';

class OnboardingInsightsVisual extends StatelessWidget {
  const OnboardingInsightsVisual({super.key});

  static const Color _navy = Color(0xFF06132B);
  static const Color _blue = Color(0xFF196DDB);
  static const Color _muted = Color(0xFF566D8C);
  static const Color _green = Color(0xFF23865B);

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
            color: const Color(0xFFDDEDFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'UNDERSTAND THE WHY',
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
          'Turn predictions into insight.',
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
          'Understand the environmental characteristics '
          'behind urban heat patterns and explore possible '
          'ways to create cooler neighborhoods.',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 22),

        // Contributing factors card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: _blue,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Contributing factors',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 19),

              const _FactorIndicator(
                icon: Icons.location_city_rounded,
                title: 'Built-up surfaces',
                description: 'Buildings and dense development',
                progress: 0.78,
                color: Color(0xFFE99552),
                background: Color(0xFFFFE9D7),
              ),

              const SizedBox(height: 18),

              const _FactorIndicator(
                icon: Icons.park_rounded,
                title: 'Vegetation coverage',
                description: 'Green spaces and tree canopy',
                progress: 0.55,
                color: Color(0xFF269B65),
                background: Color(0xFFDDF4E7),
              ),

              const SizedBox(height: 18),

              const _FactorIndicator(
                icon: Icons.add_road_rounded,
                title: 'Paved areas',
                description: 'Roads and impervious surfaces',
                progress: 0.68,
                color: Color(0xFF71849D),
                background: Color(0xFFE8EEF5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Mitigation ideas card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F5EB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCBEBD7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0EEDB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: _green,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 11),

                  const Expanded(
                    child: Text(
                      'Explore mitigation ideas',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const _MitigationItem(
                icon: Icons.park_rounded,
                title: 'Tree canopy',
              ),

              const SizedBox(height: 10),

              const _MitigationItem(
                icon: Icons.roofing_rounded,
                title: 'Cool roofs',
              ),

              const SizedBox(height: 10),

              const _MitigationItem(
                icon: Icons.nature_rounded,
                title: 'Greener corridors',
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0EEDB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'INSIGHTS & SCENARIOS',
                  style: TextStyle(
                    color: _green,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
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

class _FactorIndicator extends StatelessWidget {
  const _FactorIndicator({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF06132B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF71839B),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFFEDF1F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MitigationItem extends StatelessWidget {
  const _MitigationItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF23865B),
          size: 17,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF294B3A),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
