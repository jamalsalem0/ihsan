import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ihsan/features/prayer_times/application/prayer_provider.dart';
import 'package:ihsan/features/settings/presentation/notification_service.dart';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AnimatedSettingsBackground extends StatelessWidget {
  const AnimatedSettingsBackground({super.key});
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xff8a79b8);

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
                'الإعدادات',
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
          const AnimatedSettingsBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _SettingsSectionCard(
                  title: 'إعدادات الصلاة',
                  children: [
                    _SettingsListTile(
                      icon: Icons.location_on_outlined,
                      title: 'طريقة الحساب',
                      subtitle: 'الهيئة المصرية العامة للمساحة',
                      onTap: () {},
                    ),
                    _SettingsListTile(
                      icon: Icons.mosque_outlined,
                      title: 'مذهب العصر',
                      subtitle: 'شافعي',
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),

                _SettingsSectionCard(
                      title: 'الإشعارات',
                      children: const [
                        _SettingsSwitchTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'إشعارات الأذان',
                          activeColor: primaryPurple,
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideX(begin: -0.2),

                _SettingsSectionCard(
                      title: 'عام',
                      children: [
                        _SettingsListTile(
                          icon: Icons.info_outline,
                          title: 'عن التطبيق',
                          onTap: () {},
                        ),
                        _SettingsListTile(
                          icon: Icons.notification_important_outlined,
                          title: 'اختبار الإشعار الآن',
                          subtitle: 'اضغط هنا لسماع صوت الأذان',
                          onTap: () async {
                            final notificationService = NotificationService();
                            await notificationService.showTestNotification();
                          },
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideX(begin: -0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  title,
                  style: GoogleFonts.amiri(
                    color: const Color(0xff8a79b8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsListTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xff8a79b8), Color(0xff4c3a7a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends ConsumerStatefulWidget {
  final IconData icon;
  final String title;
  final Color activeColor;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.activeColor,
  });

  @override
  ConsumerState<_SettingsSwitchTile> createState() =>
      _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends ConsumerState<_SettingsSwitchTile> {
  bool _currentValue = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSwitchState();
  }

  Future<void> _loadSwitchState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentValue = prefs.getBool('notifications_enabled') ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _onChanged(bool newValue) async {
    setState(() {
      _currentValue = newValue;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', newValue);

    final notificationService = NotificationService();
    final prayerInfoAsyncValue = ref.read(prayerInfoProvider);

    if (newValue == true && prayerInfoAsyncValue.hasValue) {
      final prayerInfo = prayerInfoAsyncValue.value!;
      await notificationService.schedulePrayerNotifications(
        prayerInfo.prayerTimes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تفعيل إشعارات الأذان.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      await notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء إشعارات الأذان.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xff8a79b8), Color(0xff4c3a7a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 22),
      ),
      title: Text(
        widget.title,
        style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
      ),
      value: _currentValue,
      onChanged: _isLoading ? null : _onChanged,
      activeColor: widget.activeColor,
      activeTrackColor: widget.activeColor.withOpacity(0.5),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.withOpacity(0.4),
    );
  }
}
