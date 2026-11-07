import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/home_screen.dart';
import 'features/add/add_resource_sheet.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class StashApp extends ConsumerStatefulWidget {
  const StashApp({super.key});

  @override
  ConsumerState<StashApp> createState() => _StashAppState();
}

class _StashAppState extends ConsumerState<StashApp> {
  @override
  void initState() {
    super.initState();
    _initSharingListener();
  }

  void _initSharingListener() {
    try {
      ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> files) {
        for (final file in files) {
          _handleSharedItem(file);
        }
      });

      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
        for (final file in files) {
          _handleSharedItem(file);
        }
      });
    } catch (_) {}
  }

  void _handleSharedItem(SharedMediaFile file) {
    final raw = file.path.trim();
    if (raw.isEmpty) return;

    final isLocalFile = raw.startsWith('/') || raw.startsWith('file://') || raw.startsWith('content://');
    if (isLocalFile) {
      final localPath = raw.replaceFirst('file://', '');
      final localFile = File(localPath);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          showCupertinoModalPopup(
            context: navigatorKey.currentContext!,
            builder: (_) => AddResourceSheet(prefillFile: localFile),
          );
        }
      });
      return;
    }

    // Extract URL with RegExp if text has embedded URL
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final match = urlRegex.firstMatch(raw);

    String? extractedUrl;
    String? remainingNotes;

    if (match != null) {
      extractedUrl = match.group(0);
      remainingNotes = raw.replaceAll(extractedUrl!, '').trim();
    } else if (raw.startsWith('http://') || raw.startsWith('https://')) {
      extractedUrl = raw;
    } else {
      remainingNotes = raw;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        showCupertinoModalPopup(
          context: navigatorKey.currentContext!,
          builder: (_) => AddResourceSheet(
            prefillUrl: extractedUrl,
            prefillNotes: remainingNotes,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUser = SupabaseService.instance.isAuthenticated;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'STASH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appleDark(),
      builder: (context, child) => Material(
        type: MaterialType.transparency,
        child: child!,
      ),
      home: hasUser ? const HomeScreen() : const AuthScreen(),
    );
  }
}
