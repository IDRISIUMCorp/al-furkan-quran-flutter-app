import "dart:convert";

class MutashabihatBookModel {
  String language;
  String name;
  String description;
  int totalEntries;
  double score;
  String fullPath;

  MutashabihatBookModel({
    required this.language,
    required this.name,
    required this.description,
    required this.totalEntries,
    required this.score,
    required this.fullPath,
  });

  MutashabihatBookModel copyWith({
    String? language,
    String? name,
    String? description,
    int? totalEntries,
    double? score,
    String? fullPath,
  }) =>
      MutashabihatBookModel(
        language: language ?? this.language,
        name: name ?? this.name,
        description: description ?? this.description,
        totalEntries: totalEntries ?? this.totalEntries,
        score: score ?? this.score,
        fullPath: fullPath ?? this.fullPath,
      );

  factory MutashabihatBookModel.fromJson(String str) =>
      MutashabihatBookModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MutashabihatBookModel.fromMap(Map<String, dynamic> json) =>
      MutashabihatBookModel(
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
      other is MutashabihatBookModel &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          name == other.name &&
          fullPath == other.fullPath;

  @override
  int get hashCode => language.hashCode ^ name.hashCode ^ fullPath.hashCode;
}
