import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection.dart';
import '../models/resource.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  /// Enter your Supabase Project credentials here
  static const String defaultUrl = 'https://fnbjscfmuauizyrvlyac.supabase.co';
  static const String defaultAnonKey =
      'sb_publishable_YwWvPKAQEPY9eDz8B0gGew_LIKAld8-';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }

  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _isInitialized ? client!.auth.onAuthStateChange : const Stream.empty();

  Future<void> initialize(
      {String? supabaseUrl, String? supabaseAnonKey}) async {
    final url = supabaseUrl ?? defaultUrl;
    final anonKey = supabaseAnonKey ?? defaultAnonKey;

    if (url == defaultUrl || anonKey == defaultAnonKey) {
      debugPrint('[Supabase] Offline/Local cache mode active.');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
      debugPrint('[Supabase] Initialized successfully with cloud backend.');
    } catch (e) {
      debugPrint('[Supabase] Init note: $e');
    }
  }

  // --- Auth Methods ---

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    if (!_isInitialized || client == null) return null;
    return await client!.auth.signUp(
      email: email,
      password: password,
      data: {'username': username ?? email.split('@')[0]},
    );
  }

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized || client == null) return null;
    return await client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    if (!_isInitialized || client == null) return;
    await client!.auth.signOut();
  }

  // --- Sync Methods ---

  Future<void> syncResource(ResourceModel resource) async {
    if (!_isInitialized || client == null) return;
    try {
      final uid = currentUser?.id;
      final payload = {
        'id': resource.id,
        if (uid != null) 'user_id': uid,
        'collection_id': resource.collectionId,
        'collection_ids': resource.collectionIds,
        'url': resource.url,
        'title': resource.title,
        'description': resource.description,
        'thumbnail_url': resource.thumbnailUrl,
        'type': resource.type.name,
        'source': resource.source,
        'notes': resource.notes,
        'latitude': resource.latitude,
        'longitude': resource.longitude,
        'location_name': resource.locationName,
        'is_favorite': resource.isFavorite,
        'tags': resource.tags,
        'processing_state': resource.processingState,
        'created_at': resource.createdAt.toIso8601String(),
      };
      await client!.from('resources').upsert(payload);
    } catch (e) {
      debugPrint('[Supabase] Sync resource failed: $e');
    }
  }

  Future<void> syncCollection(CollectionModel collection) async {
    if (!_isInitialized || client == null) return;
    try {
      final uid = currentUser?.id;
      final payload = {
        'id': collection.id,
        if (uid != null) 'user_id': uid,
        'name': collection.name,
        'emoji': collection.emoji,
        'color_index': collection.colorIndex,
        'description': collection.description,
        'tags': collection.tags,
        'created_at': collection.createdAt.toIso8601String(),
        'updated_at': collection.updatedAt.toIso8601String(),
      };
      await client!.from('collections').upsert(payload);
    } catch (e) {
      debugPrint('[Supabase] Sync collection failed: $e');
    }
  }
}
