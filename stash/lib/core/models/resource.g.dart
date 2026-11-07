part of 'resource.dart';

class ResourceTypeAdapter extends TypeAdapter<ResourceType> {
  @override
  final int typeId = 1;

  @override
  ResourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ResourceType.link;
      case 1:
        return ResourceType.reel;
      case 2:
        return ResourceType.video;
      case 3:
        return ResourceType.note;
      case 4:
        return ResourceType.document;
      default:
        return ResourceType.link;
    }
  }

  @override
  void write(BinaryWriter writer, ResourceType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResourceModelAdapter extends TypeAdapter<ResourceModel> {
  @override
  final int typeId = 2;

  @override
  ResourceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResourceModel(
      id: fields[0] as String,
      collectionId: fields[1] as String,
      url: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String,
      thumbnailUrl: fields[5] as String,
      type: fields[6] as ResourceType,
      source: fields[7] as String,
      createdAt: fields[8] as DateTime,
      tags: (fields[9] as List).cast<String>(),
      notes: fields[10] as String,
      latitude: fields[11] as double?,
      longitude: fields[12] as double?,
      locationName: fields[13] as String?,
      isFavorite: fields[14] as bool,
      collectionIds: fields.containsKey(15)
          ? (fields[15] as List).cast<String>()
          : [(fields[1] as String)],
      processingState: fields.containsKey(16)
          ? fields[16] as String
          : 'organized',
    );
  }

  @override
  void write(BinaryWriter writer, ResourceModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.collectionId)
      ..writeByte(2)..write(obj.url)
      ..writeByte(3)..write(obj.title)
      ..writeByte(4)..write(obj.description)
      ..writeByte(5)..write(obj.thumbnailUrl)
      ..writeByte(6)..write(obj.type)
      ..writeByte(7)..write(obj.source)
      ..writeByte(8)..write(obj.createdAt)
      ..writeByte(9)..write(obj.tags)
      ..writeByte(10)..write(obj.notes)
      ..writeByte(11)..write(obj.latitude)
      ..writeByte(12)..write(obj.longitude)
      ..writeByte(13)..write(obj.locationName)
      ..writeByte(14)..write(obj.isFavorite)
      ..writeByte(15)..write(obj.collectionIds)
      ..writeByte(16)..write(obj.processingState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
