class LearningCornerModel {
  final String id;
  final String name;
  final String event;
  final String description;
  final String designation;
  final String speakerImage;
  final String speaker;
  final bool learningCorner;
  final List<String> files;
  final String? thumbnail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  LearningCornerModel({
    required this.id,
    required this.name,
    required this.event,
    required this.description,
    required this.designation,
    required this.speaker,
    required this.speakerImage,
    required this.learningCorner,
    required this.files,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.thumbnail,
  });

  factory LearningCornerModel.fromJson(Map<String, dynamic> json) {
    return LearningCornerModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      event: json['event'] as String,
      description: json['description'] as String,
      designation: json['designation'] as String,
      speakerImage: json['speakerImage'] as String,
      speaker: json['speaker'] as String,
      learningCorner: json['learningCorner'] as bool,
      files: (json['files'] as List<dynamic>?)?.map((e) => e['url'] as String).toList() ?? [],
      thumbnail: json['thumbnail'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'event': event,
      'description': description,
      'speakerImage': speakerImage,
      'designation': designation,
      'speaker': speaker,
      'learningCorner': learningCorner,
      'files': files,
      'thumbnail': thumbnail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
} 