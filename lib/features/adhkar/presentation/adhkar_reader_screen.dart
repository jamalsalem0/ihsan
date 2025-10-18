import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';

import '../application/adhkar_provider.dart';
import '../data/models/adhkar_model.dart';

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

class AnimatedAdhkarReaderBackground extends StatelessWidget {
  const AnimatedAdhkarReaderBackground({super.key});
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
      particles.add(Particle(color: Colors.white.withOpacity(random.nextDouble() * 0.5)));
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
          if (particle.x > MediaQuery.of(context).size.width || particle.x < 0) particle.vx = -particle.vx;
          if (particle.y > MediaQuery.of(context).size.height || particle.y < 0) particle.vy = -particle.vy;
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


class AdhkarReaderScreen extends ConsumerStatefulWidget {
  final int categoryId;
  const AdhkarReaderScreen({super.key, required this.categoryId});

  @override
  ConsumerState<AdhkarReaderScreen> createState() => _AdhkarReaderScreenState();
}

class _AdhkarReaderScreenState extends ConsumerState<AdhkarReaderScreen> {
  int _currentDhikrIndex = 0;
  int _currentCount = -1;

  void _onCounterTap(AdhkarCategory category) {
    HapticFeedback.lightImpact();
    if (_currentCount > 1) {
      setState(() => _currentCount--);
    } else {
      if (_currentDhikrIndex < category.dhikrList.length - 1) {
        setState(() {
          _currentDhikrIndex++;
          _currentCount = category.dhikrList[_currentDhikrIndex].count;
        });
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(adhkarByIdProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedAdhkarReaderBackground(),
          SafeArea(
            child: categoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (err, stack) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.white))),
              data: (category) {
                if (_currentCount == -1 && category.dhikrList.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _currentCount = category.dhikrList[0].count;
                      });
                    }
                  });
                }
                if (_currentDhikrIndex >= category.dhikrList.length) {
                  return const Center(child: Text('لا توجد أذكار', style: TextStyle(color: Colors.white)));
                }

                final dhikr = category.dhikrList[_currentDhikrIndex];

                return Column(
                  children: [
                    _Header(
                      title: category.category,
                      currentIndex: _currentDhikrIndex,
                      total: category.dhikrList.length,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: 450.ms,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: animation, child: child),
                          );
                        },
                        child: _DhikrCard(
                          key: ValueKey<int>(dhikr.id),
                          text: dhikr.text,
                        ),
                      ),
                    ),
                    _CounterButton(
                      count: _currentCount,
                      onTap: () => _onCounterTap(category),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.currentIndex, required this.total});
  final String title;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                onPressed: () => context.pop(),
              ),
              Text(title, style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
              const SizedBox(width: 40), 
            ],
          ),
          const SizedBox(height: 16),
          _ModernProgressBar(
            currentIndex: currentIndex,
            total: total,
          ),
        ],
      ),
    );
  }
}

class _ModernProgressBar extends StatelessWidget {
  const _ModernProgressBar({required this.currentIndex, required this.total});
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? (currentIndex + 1) / total : 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        return Container(
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: 300.ms,
                      width: barWidth * progress,
                      decoration: BoxDecoration(
                        color: const Color(0xff8a79b8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Center(
                      child: Text(
                        total > 0 ? '${currentIndex + 1} من $total' : '0',
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xff8a79b8).withOpacity(0.1),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        color: Colors.white,
                        height: 2.3,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  const _CounterButton({required this.count, required this.onTap});

  @override
  State<_CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<_CounterButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: 100.ms,
      reverseDuration: 200.ms,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
      child: GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.9).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
          ),
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xff8a79b8), Color(0xff4c3a7a)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff8a79b8).withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: 250.ms,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: widget.count > 1
                    ? Text(
                        '${widget.count}',
                        key: ValueKey<int>(widget.count),
                        style: GoogleFonts.amiri(fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : Row(
                        key: const ValueKey<String>('next'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'التالي',
                            style: GoogleFonts.amiri(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(period: 2.seconds)).shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.2)),
      ),
    );
  }
}