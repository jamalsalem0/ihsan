import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:adhan/adhan.dart';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';

import '../prayer_times/application/prayer_provider.dart';

final selectedPrayerProvider = StateProvider<Prayer?>((ref) => null);

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

class AnimatedBackgroundForHome extends StatelessWidget {
  const AnimatedBackgroundForHome({super.key});
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


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerInfoAsync = ref.watch(prayerInfoProvider);
    initializeDateFormatting('ar', null);

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        fit: StackFit.expand, 
        children: [
          const AnimatedBackgroundForHome(),
          SafeArea(
            child: prayerInfoAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (error, stack) => Center(child: Text('خطأ: $error', style: GoogleFonts.amiri(color: Colors.white))),
              data: (prayerInfo) {
                return Column(
                  children: [
                    _DomeHeroSection(prayerInfo: prayerInfo),
                    _PrayerTimesGrid(prayerInfo: prayerInfo),
                    const Spacer(),
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


class _DomeHeroSection extends StatelessWidget {
  const _DomeHeroSection({required this.prayerInfo});
  final PrayerInfo prayerInfo;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now());
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(today, style: GoogleFonts.amiri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal)),
          const SizedBox(height: 24),
          Text(
            _getPrayerNameInArabic(prayerInfo.nextPrayer),
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 70, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              'متبقي: ${_formatDuration(prayerInfo.timeRemaining)}',
              style: GoogleFonts.amiri(color: Colors.white, fontSize: 26, letterSpacing: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _PrayerTimesGrid extends ConsumerWidget {
  const _PrayerTimesGrid({required this.prayerInfo});
  final PrayerInfo prayerInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPrayer = ref.watch(selectedPrayerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: Prayer.values.map((prayer) {
          if (prayer == Prayer.none || prayer == Prayer.sunrise) return const SizedBox.shrink();

          bool isActive = selectedPrayer == prayer || (selectedPrayer == null && prayer == prayerInfo.nextPrayer);
          
          return _PrayerCard(
            prayer: prayer,
            time: prayerInfo.prayerTimes.timeForPrayer(prayer)!,
            isActive: isActive,
            onTap: () {
              ref.read(selectedPrayerProvider.notifier).state = prayer;
            },
          );
        }).where((widget) => widget is! SizedBox).toList(),
      )
      .animate(delay: 400.ms)
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.5, curve: Curves.easeOutCubic),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.prayer,
    required this.time,
    required this.isActive,
    required this.onTap,
  });
  final Prayer prayer;
  final DateTime time;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: AnimatedContainer(
            duration: 400.ms,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xff8a79b8).withOpacity(0.25) : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isActive ? const Color(0xff8a79b8) : Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: const Color(0xff8a79b8).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 3,
                  )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _getPrayerNameInArabic(prayer),
                  style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                _getPrayerIcon(prayer, 32, Colors.white.withOpacity(0.9)),
                Text(
                  DateFormat.jm('ar').format(time),
                  style: GoogleFonts.amiri(color: Colors.white.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getPrayerNameInArabic(Prayer prayer) {
  switch (prayer) {
    case Prayer.fajr: return 'الفجر';
    case Prayer.dhuhr: return 'الظهر';
    case Prayer.asr: return 'العصر';
    case Prayer.maghrib: return 'المغرب';
    case Prayer.isha: return 'العشاء';
    case Prayer.sunrise: return 'الشروق';
    default: return 'غير معروف';
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  String formattedHours = hours.toString().padLeft(2, '0');
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');
  return '$formattedHours:$formattedMinutes:$formattedSeconds';
}

Icon _getPrayerIcon(Prayer prayer, double size, Color color) {
  switch (prayer) {
    case Prayer.fajr: return Icon(Icons.nightlight_round, size: size, color: color);
    case Prayer.dhuhr: return Icon(Icons.wb_sunny, size: size, color: color);
    case Prayer.asr: return Icon(Icons.wb_sunny_outlined, size: size, color: color);
    case Prayer.maghrib: return Icon(Icons.dark_mode, size: size, color: color);
    case Prayer.isha: return Icon(Icons.dark_mode_outlined, size: size, color: color);
    default: return Icon(Icons.error, size: size, color: color);
  }
}