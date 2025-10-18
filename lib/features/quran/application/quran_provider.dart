import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/surah_model.dart';

final allSurahsProvider = FutureProvider<List<Surah>>((ref) async {
  final String jsonString = await rootBundle.loadString('assets/data/quran_full.json');
  
  final List<dynamic> jsonList = json.decode(jsonString);
  
  return jsonList.map((json) => Surah.fromJson(json)).toList();
});


final surahProvider = FutureProvider.family<Surah, int>((ref, surahNumber) async {
  final allSurahs = await ref.watch(allSurahsProvider.future);
  
  
  return allSurahs.firstWhere((s) => s.number == surahNumber);
});