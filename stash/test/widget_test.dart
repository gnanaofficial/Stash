import 'package:flutter_test/flutter_test.dart';
import 'package:stash/core/models/resource.dart';
import 'package:stash/core/models/collection.dart';
import 'package:stash/core/models/place.dart';
import 'package:stash/core/services/ai_assistant_service.dart';
import 'package:stash/core/services/cloudflare_r2_service.dart';

void main() {
  group('Security & Model Hardening Tests', () {
    test('ResourceModel detects correct platforms safely', () {
      expect(ResourceModel.detectSource('https://www.youtube.com/watch?v=123'), 'youtube');
      expect(ResourceModel.detectSource('https://instagram.com/reel/abc'), 'instagram');
      expect(ResourceModel.detectSource('https://github.com/flutter/flutter'), 'github');
      expect(ResourceModel.detectSource('https://example.com/spec.pdf'), 'pdf');
      expect(ResourceModel.detectSource('https://news.ycombinator.com'), 'web');
    });

    test('ResourceModel supports many-to-many collections', () {
      final res = ResourceModel(
        id: 'res_test_1',
        collectionId: 'col_dev',
        collectionIds: ['col_dev', 'col_learning', 'col_starred'],
        url: 'https://github.com/flutter/flutter',
        createdAt: DateTime.now(),
        processingState: 'organized',
      );

      expect(res.collectionIds.length, 3);
      expect(res.collectionIds.contains('col_learning'), isTrue);
      expect(res.processingState, 'organized');
    });

    test('PlaceModel category icons & curated spots are initialized', () {
      expect(defaultCuratedPlaces.isNotEmpty, isTrue);
      final place = defaultCuratedPlaces.first;
      expect(place.name, isNotEmpty);
      expect(place.categoryIcon, isNotEmpty);
      expect(place.linkedResourceIds, isA<List<String>>());
    });

    test('Cloudflare R2 defaults to safe local simulation mode', () {
      final r2 = CloudflareR2Service.instance;
      expect(r2.isConfigured, isFalse);
    });

    test('AiToolRegistry queries only supplied resources and produces structured proposals', () {
      final sample = [
        ResourceModel(
          id: 'res_1',
          collectionId: 'col_dev',
          url: 'https://github.com/flutter/flutter',
          title: 'Flutter Engine Source Code',
          tags: ['flutter', 'code'],
          createdAt: DateTime.now(),
        ),
        ResourceModel(
          id: 'res_2',
          collectionId: 'col_food',
          url: 'https://instagram.com/reel/podi_idli',
          title: 'Bangalore Rameshwaram Cafe Podi Idli',
          tags: ['food', 'bengaluru'],
          createdAt: DateTime.now(),
        ),
      ];

      final registry = AiToolRegistry(
        getResources: () => sample,
        getCollections: () => defaultCollections,
        linkResourceToCollection: (r, c) async {},
        deleteResource: (r) async {},
      );

      // Search Flutter
      final searchResult = registry.searchResources('flutter');
      expect(searchResult.length, 1);
      expect(searchResult.first.id, 'res_1');

      // Search Food
      final foodResult = registry.searchResources('idli');
      expect(foodResult.length, 1);
      expect(foodResult.first.id, 'res_2');

      // Non-existent search returns empty, no hallucinations
      final emptyResult = registry.searchResources('nonexistent_random_query');
      expect(emptyResult, isEmpty);

      // Bulk Proposal requires explicit confirmation
      final proposal = registry.prepareBulkOrganization(
        targetCategory: 'Food',
        resourceIds: ['res_2'],
      );
      expect(proposal, isNotNull);
      expect(proposal!.isExecuted, isFalse);
    });
  });
}
