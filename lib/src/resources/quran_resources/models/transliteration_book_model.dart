import "dart:convert";

class TransliterationBookModel {
  String language;
  String name;
  String description;
  int totalEntries;
  double score;
  String fullPath;

  TransliterationBookModel({
    required this.language,
    required this.name,
    required this.description,
    required this.totalEntries,
    required this.score,
    required this.fullPath,
  });

  TransliterationBookModel copyWith({
    String? language,
    String? name,
    String? description,
    int? totalEntries,
    double? score,
    String? fullPath,
  }) =>
      TransliterationBookModel(
        language: language ?? this.language,
        name: name ?? this.name,
        description: description ?? this.description,
        totalEntries: totalEntries ?? this.totalEntries,
        score: score ?? this.score,
        fullPath: fullPath ?? this.fullPath,
      );

  factory TransliterationBookModel.fromJson(String str) =>
      TransliterationBookModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TransliterationBookModel.fromMap(Map<String, dynamic> json) =>
      TransliterationBookModel(
        language: json["language"],
        name: json["name"],
        description: json["description"] ?? "",
        totalEntries: json["totalEntries"] ?? 0,
        score: (json["score"] ?? 100).toDouble(),
        fullPath: json["full_path"],
      );

  Map<String, dynamic> toMap() => {
        "language": language,
        "name": name,
        "description": description,
        "totalEntries": totalEntries,
        "score": score,
        "full_path": fullPath,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransliterationBookModel &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          name == other.name &&
          fullPath == other.fullPath;

  @override
  int get hashCode => language.hashCode ^ name.hashCode ^ fullPath.hashCode;
}
