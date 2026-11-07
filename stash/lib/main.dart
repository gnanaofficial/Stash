import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'core/models/collection.dart';
import 'core/models/resource.dart';
import 'core/models/place.dart';
import 'core/services/supabase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  // iOS-style translucent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Hive local cache
  await Hive.initFlutter();
  Hive.registerAdapter(CollectionModelAdapter());
  Hive.registerAdapter(ResourceTypeAdapter());
  Hive.registerAdapter(ResourceModelAdapter());
  Hive.registerAdapter(PlaceModelAdapter());

  await Hive.openBox<CollectionModel>('collections');
  await Hive.openBox<ResourceModel>('resources');
  await Hive.openBox<PlaceModel>('places');

  // Supabase cloud initialization (offline-safe)
  await SupabaseService.instance.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      adaptiveQuality: true,
      theme: const GlassThemeData.ios27(),
      child: const ProviderScope(child: StashApp()),
    ),
  );
}
