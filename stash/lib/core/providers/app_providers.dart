import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/collection.dart';
import '../models/resource.dart';
import '../services/supabase_service.dart';

class CollectionsNotifier extends Notifier<List<CollectionModel>> {
  Box<CollectionModel> get _box => Hive.box<CollectionModel>('collections');

  @override
  List<CollectionModel> build() {
    if (_box.isEmpty) {
      for (final col in defaultCollections) {
        _box.put(col.id, col);
        SupabaseService.instance.syncCollection(col);
      }
    }
    return _box.values.toList();
  }

  Future<void> addCollection(CollectionModel collection) async {
    await _box.put(collection.id, collection);
    await SupabaseService.instance.syncCollection(collection);
    state = _box.values.toList();
  }

  Future<void> deleteCollection(String id) async {
    await _box.delete(id);
    final resBox = Hive.box<ResourceModel>('resources');
    for (final r in resBox.values.toList()) {
      if (r.collectionIds.contains(id)) {
        r.collectionIds.remove(id);
        if (r.collectionIds.isEmpty) {
          await resBox.delete(r.id);
        } else {
          r.collectionId = r.collectionIds.first;
          await r.save();
        }
      }
    }
    state = _box.values.toList();
  }
}

final collectionsProvider =
    NotifierProvider<CollectionsNotifier, List<CollectionModel>>(
        CollectionsNotifier.new);

class ResourcesNotifier extends Notifier<List<ResourceModel>> {
  Box<ResourceModel> get _box => Hive.box<ResourceModel>('resources');

  @override
  List<ResourceModel> build() => _box.values.toList();

  Future<void> addResource(ResourceModel resource) async {
    await _box.put(resource.id, resource);
    await SupabaseService.instance.syncResource(resource);
    state = _box.values.toList();
  }

  Future<void> deleteResource(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> toggleFavorite(String id) async {
    final res = _box.get(id);
    if (res != null) {
      res.isFavorite = !res.isFavorite;
      await res.save();
      await SupabaseService.instance.syncResource(res);
      state = _box.values.toList();
    }
  }

  /// Add resource to an additional collection without duplicating
  Future<void> linkToCollection(String resourceId, String collectionId) async {
    final res = _box.get(resourceId);
    if (res != null && !res.collectionIds.contains(collectionId)) {
      res.collectionIds.add(collectionId);
      await res.save();
      await SupabaseService.instance.syncResource(res);
      state = _box.values.toList();
    }
  }

  /// Remove resource from a collection
  Future<void> unlinkFromCollection(String resourceId, String collectionId) async {
    final res = _box.get(resourceId);
    if (res != null && res.collectionIds.contains(collectionId)) {
      res.collectionIds.remove(collectionId);
      if (res.collectionIds.isEmpty) {
        await _box.delete(resourceId);
      } else {
        res.collectionId = res.collectionIds.first;
        await res.save();
        await SupabaseService.instance.syncResource(res);
      }
      state = _box.values.toList();
    }
  }

  List<ResourceModel> forCollection(String collectionId) {
    return state.where((r) => r.collectionIds.contains(collectionId)).toList();
  }

  List<ResourceModel> search(String query) {
    final q = query.toLowerCase();
    return state.where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.url.toLowerCase().contains(q) ||
          r.notes.toLowerCase().contains(q) ||
          (r.locationName != null && r.locationName!.toLowerCase().contains(q)) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  List<ResourceModel> get recent {
    final sorted = [...state]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(20).toList();
  }
}

final resourcesProvider =
    NotifierProvider<ResourcesNotifier, List<ResourceModel>>(
        ResourcesNotifier.new);
