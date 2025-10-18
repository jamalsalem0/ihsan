class Dhikr {
  final int id;
  final String text;
  final int count;

  Dhikr({required this.id, required this.text, required this.count});

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(id: json['id'], text: json['text'], count: json['count']);
  }
}

class AdhkarCategory {
  final int id;
  final String category;
  final List<Dhikr> dhikrList;

  AdhkarCategory({
    required this.id,
    required this.category,
    required this.dhikrList,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    var list = json['array'] as List;
    List<Dhikr> dhikrs = list.map((i) => Dhikr.fromJson(i)).toList();

    return AdhkarCategory(
      id: json['id'],
      category: json['category'],
      dhikrList: dhikrs,
    );
  }
}
