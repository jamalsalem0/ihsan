import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';

import '../application/adhkar_provider.dart';

class Particle {
  final Color color;
  Random random = Random();
  double x = 0.0, y = 0.0, vx = 0.0, vy = 0.0, size = 0.0;
  Particle({required this.color}) {
    vx = -1 + 2 * random.nextDouble();
    vy = -1 + 2 * random.nextDouble();
    size = random.nextDouble() * 2;
  }
}

class AnimatedAdhkarBackground extends StatelessWidget {
  const AnimatedAdhkarBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<int>(
      tween: ConstantTween(1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff4c3a7a), Color(0xff09142c)],
              stops: [0.0, 0.8],
            ),
          ),
          child: const Particles(25),
        );
      },
    );
  }
}

class Particles extends StatefulWidget {
  final int numberOfParticles;
  const Particles(this.numberOfParticles, {super.key});
  @override
  State<Particles> createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();
  final List<Particle> particles = [];
  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(
        Particle(color: Colors.white.withOpacity(random.nextDouble() * 0.5)),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 200.0),
      duration: const Duration(seconds: 20),
      builder: (context, value, child) {
        for (var particle in particles) {
          particle.x += particle.vx;
          particle.y += particle.vy;
          if (particle.x > MediaQuery.of(context).size.width || particle.x < 0)
            particle.vx = -particle.vx;
          if (particle.y > MediaQuery.of(context).size.height || particle.y < 0)
            particle.vy = -particle.vy;
        }
        return CustomPaint(painter: _ParticlePainter(particles));
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  _ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AdhkarHubScreen extends ConsumerWidget {
  const AdhkarHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAdhkarAsync = ref.watch(allAdhkarProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(
                'الأذكار',
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.08),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedAdhkarBackground(),
          SafeArea(
            child: allAdhkarAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'خطأ: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (categories) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                          categoryName: category.category,
                          icon: _getIconForCategory(category.category),
                          onTap: () {
                            context.push('/adhkar/${category.id}');
                          },
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (100 * index).ms)
                        .slideX(begin: -0.2);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    if (category.contains('الصباح')) return Icons.light_mode_outlined;
    if (category.contains('المساء')) return Icons.dark_mode_outlined;
    if (category.contains('النوم')) return Icons.bedtime_outlined;
    if (category.contains('الصلاة')) return Icons.mosque_outlined;
    if (category.contains('الاستيقاظ')) return Icons.alarm;
    return Icons.shield_moon_outlined; 
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xff8a79b8), Color(0xff4c3a7a)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff8a79b8).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    categoryName,
                    style: GoogleFonts.amiri(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
