import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/adhkar_model.dart';

final allAdhkarProvider = FutureProvider<List<AdhkarCategory>>((ref) async {
  final String jsonString = await rootBundle.loadString(
    'assets/data/adhkar.json',
  );
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => AdhkarCategory.fromJson(json)).toList();
});

final adhkarByIdProvider = FutureProvider.family<AdhkarCategory, int>((
  ref,
  categoryId,
) async {
  final allCategories = await ref.watch(allAdhkarProvider.future);

  return allCategories.firstWhere((c) => c.id == categoryId);
});
