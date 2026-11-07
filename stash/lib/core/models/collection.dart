import 'package:hive/hive.dart';

part 'collection.g.dart';

@HiveType(typeId: 0)
class CollectionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String emoji;

  @HiveField(3)
  late int colorIndex;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  @HiveField(6)
  late String description;

  @HiveField(7)
  late List<String> tags;

  CollectionModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    List<String>? tags,
  }) : tags = tags ?? [];
}

List<CollectionModel> get defaultCollections => [
  CollectionModel(
    id: 'col_github',
    name: 'GitHub & Dev',
    emoji: '🐙',
    colorIndex: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: 'Repositories, docs, architecture & tools',
    tags: ['code', 'github', 'dev'],
  ),
  CollectionModel(
    id: 'col_food',
    name: 'Food & Spots',
    emoji: '🍜',
    colorIndex: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: 'Reels and spots tagged by location',
    tags: ['food', 'reels', 'places'],
  ),
  CollectionModel(
    id: 'col_design',
    name: 'UI Inspiration',
    emoji: '🎨',
    colorIndex: 2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: 'Mobbin, Shadcn UI, Magic UI, 21stdev components',
    tags: ['design', 'mobbin', 'ui'],
  ),
  CollectionModel(
    id: 'col_learning',
    name: 'Knowledge & Tutorials',
    emoji: '📚',
    colorIndex: 3,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: 'Articles, shortcuts, guides & learning clips',
    tags: ['learning', 'guides'],
  ),
];

