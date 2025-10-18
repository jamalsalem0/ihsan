import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  await generateAndSaveQuranFile();
}

const String outputPath = 'assets/data/quran_full.json';

Future<void> generateAndSaveQuranFile() async {
  print('🚀 بدء عملية جلب وتنسيق القرآن الكريم...');
  final stopwatch = Stopwatch()..start();

  const baseUrl = 'https://api.alquran.cloud/v1/surah';
  List<Map<String, dynamic>> quranList = [];

  for (int i = 1; i <= 114; i++) {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$i'));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes))['data'];

        final surah = {
          "id": data["number"],
          "name": data["name"],
          "transliteration": data["englishName"],
          "type": data["revelationType"].toLowerCase(),
          "total_verses": data["numberOfAyahs"],
          "verses": (data["ayahs"] as List)
              .map(
                (ayah) => {"id": ayah["numberInSurah"], "text": ayah["text"]},
              )
              .toList(),
        };

        quranList.add(surah);
        print('✔ تم جلب سورة ${data["name"]}');
      } else {
        print('❌ فشل تحميل السورة رقم $i - الحالة: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ حدث خطأ استثنائي عند جلب السورة رقم $i: $e');
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  if (quranList.length == 114) {
    print('\n💾 جاري حفظ البيانات في ملف...');
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    final formattedJson = const JsonEncoder.withIndent('  ').convert(quranList);
    await file.writeAsString(formattedJson);

    stopwatch.stop();
    print(
      '\n✅ نجاح! تم إنشاء ملف quran_full.json في ${stopwatch.elapsed.inSeconds} ثانية.',
    );
  } else {
    print('\n❌ فشل! لم يتم جلب كل السور. يرجى المحاولة مرة أخرى.');
  }
}
