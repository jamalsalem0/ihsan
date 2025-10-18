import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';

import '../application/quran_provider.dart';
import '../data/models/surah_model.dart';

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

class AnimatedBackgroundForQuran extends StatelessWidget {
  const AnimatedBackgroundForQuran({super.key});
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

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  String _searchQuery = '';

  String _normalizeText(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('سورة ', '')
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsyncValue = ref.watch(allSurahsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text('القرآن الكريم', style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
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
          const AnimatedBackgroundForQuran(),
          SafeArea(
            child: surahsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (error, stack) => Center(child: Text('خطأ: $error', style: const TextStyle(color: Colors.white))),
              data: (surahs) {
                final filteredSurahs = _searchQuery.isEmpty
                    ? surahs
                    : surahs.where((surah) {
                        final normalizedSurahName = _normalizeText(surah.name);
                        final normalizedQuery = _normalizeText(_searchQuery);
                        return normalizedSurahName.contains(normalizedQuery);
                      }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: _SearchField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: filteredSurahs.length,
                        itemBuilder: (context, index) {
                          final surah = filteredSurahs[index];
                          return _SurahCard(surah: surah)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: (80 * (index % 10)).ms)
                              .slideY(begin: 0.3, duration: 500.ms, delay: (80 * (index % 10)).ms, curve: Curves.easeOutCubic);
                        },
                      ),
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

class _SurahCard extends StatelessWidget {
  const _SurahCard({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/surah/${surah.number}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff8a79b8), Color(0xff4c3a7a)],
                    ),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                  ),
                  child: Center(
                    child: Text(
                      surah.number.toString(),
                      style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      Text(
                        surah.englishName,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.menu_book, color: Colors.white.withOpacity(0.7), size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.numberOfAyahs} آيات',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                    ),
                    Text(
                      surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          onChanged: onChanged,
          style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة...',
            hintStyle: GoogleFonts.amiri(color: Colors.white.withOpacity(0.6), fontSize: 18),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color(0xff8a79b8), width: 2.0),
            ),
          ),
        ),
      ),
    );
  }
}