class Folder {
  final String? id;
  final String name;
  final String event;
  final List<EventFile> files;
  final int? imageCount;
  final int? videoCount;

  Folder({
    this.id,
    required this.name,
    required this.event,
    required this.files,
    this.imageCount,
    this.videoCount,
  });

  factory Folder.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Folder(name: '', event: '', files: []);
    }

    return Folder(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      event: json['event'] as String? ?? '',
      files: (json['files'] as List<dynamic>?)
              ?.map((e) => EventFile.fromJson(e as Map<String, dynamic>?))
              .whereType<EventFile>()
              .toList() ??
          [],
      imageCount: json['imageCount'] is int ? json['imageCount'] as int : null,
      videoCount: json['videoCount'] is int ? json['videoCount'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'event': event,
      'files': files.map((e) => e.toJson()).toList(),
      'imageCount': imageCount,
      'videoCount': videoCount,
    };
  }
}

class EventFile {
  final String? id;
  final String type;
  final String url;
  final String? user;

  EventFile({
    this.id,
    required this.type,
    required this.url,
    this.user,
  });

  factory EventFile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EventFile(type: '', url: '');
    }

    return EventFile(
      id: json['_id'] as String?,
      type: json['type'] as String? ?? '',
      url: json['url'] as String? ?? '',
      user: json['user'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'url': url,
      'user': user,
    };
  }
}
