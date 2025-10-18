import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_flip/page_flip.dart';
import '../application/quran_provider.dart';
import '../data/models/surah_model.dart';

final fontSizeProvider = StateProvider<double>((ref) => 25.0);
final isNightModeProvider = StateProvider<bool>((ref) => false);

class SurahReaderScreen extends ConsumerWidget {
  final int surahNumber;
  const SurahReaderScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahProvider(surahNumber));
    final isNightMode = ref.watch(isNightModeProvider);

    return Scaffold(
      backgroundColor: isNightMode
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFFDFCEC),
      body: SafeArea(
        child: surahAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('خطأ: $error')),
          data: (surah) {
            const versesPerPage = 10;
            final pageCount = (surah.verses.length / versesPerPage).ceil();

            return Container(
              decoration: BoxDecoration(
                gradient: isNightMode
                    ? LinearGradient(
                        colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                      )
                    : LinearGradient(
                        colors: [Color(0xFFFDFCEC), Color(0xFFF0E5D1)],
                      ),
              ),
              child: Column(
                children: [
                  _SurahHeader(surah: surah),
                  Expanded(
                    child: PageFlipWidget(
                      lastPage: Container(
                        color: isNightMode
                            ? Color(0xFF1E1E1E)
                            : Color(0xFFFDFCEC),
                        child: Center(
                          child: Text(
                            'صدق الله العظيم',
                            style: GoogleFonts.amiri(
                              fontSize: 24,
                              color: isNightMode
                                  ? Colors.white70
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      children: List.generate(pageCount, (pageIndex) {
                        final startVerse = pageIndex * versesPerPage;
                        final endVerse =
                            (startVerse + versesPerPage > surah.verses.length)
                            ? surah.verses.length
                            : startVerse + versesPerPage;
                        final versesForPage = surah.verses.sublist(
                          startVerse,
                          endVerse,
                        );

                        return _SurahPage(
                          verses: versesForPage,
                          isFirstPage: pageIndex == 0,
                          surahNumber: surah.number,
                          pageNumber: pageIndex + 1,
                          totalSurahPages: pageCount,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SurahHeader extends ConsumerWidget {
  const _SurahHeader({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFontSize = ref.watch(fontSizeProvider);
    final isNightMode = ref.watch(isNightModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNightMode
              ? [Color(0xFF3A3A3A), Color(0xFF2C2C2C)]
              : [Color(0xFFFDFCEC), Color(0xFFF5F0E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: isNightMode
                ? Colors.grey[800]
                : const Color(0xffB59441).withOpacity(0.1),
            radius: 18,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isNightMode ? Colors.white70 : const Color(0xffB59441),
                size: 18,
              ),

              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/quran');
                }
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                surah.name,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: isNightMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.brightness_6,
                  color: isNightMode ? Colors.white70 : const Color(0xffB59441),
                ),
                onPressed: () =>
                    ref.read(isNightModeProvider.notifier).state = !isNightMode,
              ),
              Container(
                decoration: BoxDecoration(
                  color: isNightMode
                      ? Colors.grey[800]
                      : const Color(0xffB59441).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _FontSizeButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (currentFontSize > 18)
                          ref.read(fontSizeProvider.notifier).state -= 2;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        currentFontSize.toInt().toString(),
                        style: GoogleFonts.amiri(
                          color: isNightMode
                              ? Colors.white
                              : const Color(0xffB59441),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _FontSizeButton(
                      icon: Icons.add,
                      onPressed: () {
                        if (currentFontSize < 40)
                          ref.read(fontSizeProvider.notifier).state += 2;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class _SurahPage extends ConsumerWidget {
  const _SurahPage({
    required this.verses,
    required this.isFirstPage,
    required this.surahNumber,
    required this.pageNumber,
    required this.totalSurahPages,
  });
  final List<Verse> verses;
  final bool isFirstPage;
  final int surahNumber;
  final int pageNumber;
  final int totalSurahPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final isNightMode = ref.watch(isNightModeProvider);

    return GestureDetector(
      onTapUp: (details) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('آية ${details.localPosition} تم اختيارها')),
        );
      },
      child: Container(
        color: isNightMode ? Color(0xFF1E1E1E) : const Color(0xFFFDFCEC),
        child: CustomPaint(
          painter: _FramePainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35, 35, 35, 20),
            child: Column(
              children: [
                if (isFirstPage && surahNumber != 1 && surahNumber != 9)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                      style: GoogleFonts.amiri(
                        fontSize: fontSize + 2,
                        color: isNightMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text.rich(
                        TextSpan(
                          style: GoogleFonts.amiri(
                            fontSize: fontSize,
                            color: isNightMode
                                ? Colors.white70
                                : Colors.black87,
                            height: 2.0,
                          ),
                          children: verses.asMap().entries.map((entry) {
                            final index = entry.key;
                            final verse = entry.value;
                            return TextSpan(
                              children: [
                                TextSpan(text: '${verse.text} '),
                                TextSpan(
                                  text: '\uFD3F${verse.id}\uFD3E',
                                  style: TextStyle(
                                    color: isNightMode
                                        ? Colors.amber[200]
                                        : const Color(0xffB59441),
                                    fontSize: fontSize * 0.85,
                                  ),
                                ),
                                if (index < verses.length - 1)
                                  TextSpan(text: '  '),
                              ],
                            );
                          }).toList(),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ),
                _PageNumberFooter(
                  pageNumber: pageNumber,
                  totalSurahPages: totalSurahPages,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintOuter = Paint()
      ..color = const Color(0xffD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rectOuter = Rect.fromLTWH(25, 25, size.width - 50, size.height - 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectOuter, Radius.circular(10)),
      paintOuter,
    );

    final paintInner = Paint()
      ..color = const Color(0xffD4AF37).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final innerRect = Rect.fromLTWH(30, 30, size.width - 60, size.height - 60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(8)),
      paintInner,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PageNumberFooter extends StatelessWidget {
  const _PageNumberFooter({
    required this.pageNumber,
    required this.totalSurahPages,
  });
  final int pageNumber;
  final int totalSurahPages;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xffD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$pageNumber / $totalSurahPages',
        style: GoogleFonts.amiri(color: const Color(0xffD4AF37), fontSize: 16),
      ),
    );
  }
}
