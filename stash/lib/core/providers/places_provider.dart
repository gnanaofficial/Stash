import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/place.dart';

final placesProvider = NotifierProvider<PlacesNotifier, List<PlaceModel>>(
  PlacesNotifier.new,
);

class PlacesNotifier extends Notifier<List<PlaceModel>> {
  Box<PlaceModel> get _box => Hive.box<PlaceModel>('places');

  @override
  List<PlaceModel> build() {
    final box = _box;
    if (box.isEmpty) {
      for (final place in defaultCuratedPlaces) {
        box.put(place.id, place);
      }
    }
    return box.values.toList();
  }

  void _reload() => state = _box.values.toList();

  void toggleSaved(String id) {
    final place = _box.get(id);
    if (place == null) return;
    place.isSaved = !place.isSaved;
    place.save();
    _reload();
  }

  void markVisited(String id) {
    final place = _box.get(id);
    if (place == null) return;
    place.isVisited = true;
    place.save();
    _reload();
  }

  void updateNotes(String id, String notes) {
    final place = _box.get(id);
    if (place == null) return;
    place.notes = notes;
    place.save();
    _reload();
  }

  void linkResource(String placeId, String resourceId) {
    final place = _box.get(placeId);
    if (place == null) return;
    if (!place.linkedResourceIds.contains(resourceId)) {
      place.linkedResourceIds = [...place.linkedResourceIds, resourceId];
      place.save();
      _reload();
    }
  }

  void unlinkResource(String placeId, String resourceId) {
    final place = _box.get(placeId);
    if (place == null) return;
    place.linkedResourceIds =
        place.linkedResourceIds.where((id) => id != resourceId).toList();
    place.save();
    _reload();
  }

  List<PlaceModel> get saved =>
      state.where((p) => p.isSaved).toList();

  List<PlaceModel> forCity(String city) =>
      state.where((p) => p.city.toLowerCase() == city.toLowerCase()).toList();

  List<PlaceModel> forCategory(String category) =>
      state.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
}

