class Verse {
  final int id;
  final String text;

  Verse({required this.id, required this.text});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'],
      text: json['text'],
    );
  }
}

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String revelationType;
  final int numberOfAyahs;
  final List<Verse> verses;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    var versesFromJson = json['verses'] as List? ?? [];
    List<Verse> verseList = versesFromJson.map((i) => Verse.fromJson(i)).toList();

    return Surah(
      number: json['id'],
      name: json['name'],
      englishName: json['transliteration'],
      revelationType: json['type'] == 'meccan' ? 'Meccan' : 'Medinan',
      numberOfAyahs: json['total_verses'],
      verses: verseList,
    );
  }
}