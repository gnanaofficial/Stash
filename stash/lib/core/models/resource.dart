import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'resource.g.dart';

@HiveType(typeId: 1)
enum ResourceType {
  @HiveField(0)
  link,
  @HiveField(1)
  reel,
  @HiveField(2)
  video,
  @HiveField(3)
  note,
  @HiveField(4)
  document,
}

@HiveType(typeId: 2)
class ResourceModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String collectionId; // Kept for legacy single collection compatibility

  @HiveField(2)
  late String url;

  @HiveField(3)
  late String title;

  @HiveField(4)
  late String description;

  @HiveField(5)
  late String thumbnailUrl;

  @HiveField(6)
  late ResourceType type;

  @HiveField(7)
  late String source;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late List<String> tags;

  @HiveField(10)
  late String notes;

  @HiveField(11)
  late double? latitude;

  @HiveField(12)
  late double? longitude;

  @HiveField(13)
  late String? locationName;

  @HiveField(14)
  late bool isFavorite;

  // Milestone 2 additions:
  @HiveField(15)
  late List<String> collectionIds; // Many-to-many collections support

  @HiveField(16)
  late String processingState; // 'pending', 'processing', 'needs_review', 'organized'

  ResourceModel({
    required this.id,
    required this.collectionId,
    required this.url,
    this.title = '',
    this.description = '',
    this.thumbnailUrl = '',
    this.type = ResourceType.link,
    this.source = 'web',
    required this.createdAt,
    List<String>? tags,
    this.notes = '',
    this.latitude,
    this.longitude,
    this.locationName,
    this.isFavorite = false,
    List<String>? collectionIds,
    this.processingState = 'organized',
  })  : tags = tags ?? [],
        collectionIds = collectionIds ?? [collectionId];

  static String detectSource(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('instagram.com')) return 'instagram';
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) return 'youtube';
    if (lower.contains('github.com')) return 'github';
    if (lower.contains('twitter.com') || lower.contains('x.com')) return 'x';
    if (lower.contains('reddit.com')) return 'reddit';
    if (lower.endsWith('.pdf')) return 'pdf';
    return 'web';
  }

  static ResourceType detectType(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('instagram.com/reel') || lower.contains('instagram.com/p/')) {
      return ResourceType.reel;
    }
    if (lower.contains('youtube.com/shorts')) return ResourceType.reel;
    if (lower.contains('youtube.com/watch') || lower.contains('youtu.be/')) {
      return ResourceType.video;
    }
    if (lower.endsWith('.pdf') || lower.contains('r2.cloudflarestorage.com')) {
      return ResourceType.document;
    }
    return ResourceType.link;
  }

  IconData get sourceVectorIcon {
    switch (source.toLowerCase()) {
      case 'instagram':
        return CupertinoIcons.camera_fill;
      case 'youtube':
        return CupertinoIcons.play_arrow_solid;
      case 'github':
        return CupertinoIcons.chevron_left_slash_chevron_right;
      case 'x':
      case 'twitter':
        return CupertinoIcons.bubble_left_bubble_right_fill;
      case 'pdf':
        return CupertinoIcons.doc_fill;
      default:
        return CupertinoIcons.link;
    }
  }

  String get sourceIcon {
    switch (source) {
      case 'instagram':
        return '📸';
      case 'youtube':
        return '▶️';
      case 'github':
        return '🐙';
      case 'x':
        return '𝕏';
      case 'pdf':
        return '📄';
      default:
        return '🔗';
    }
  }
}
