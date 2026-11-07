import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../add/add_resource_sheet.dart';
import '../assistant/ai_assistant_screen.dart';
import '../collection/collection_screen.dart';
import '../inbox/smart_inbox_screen.dart';
import '../search/search_screen.dart';
import '../location/location_feed_screen.dart';
import '../explore/explore_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/collection_card.dart';
import 'widgets/recent_row.dart';
import 'widgets/create_collection_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  final _scrollController = ScrollController();
  late final GlassTabBarMinimizeController _minimizeController;

  @override
  void initState() {
    super.initState();
    _minimizeController = GlassTabBarMinimizeController(
      behavior: GlassBarMinimizeBehavior.onScrollDown,
    );
  }

  @override
  void dispose() {
    _minimizeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = ref.watch(resourcesProvider);
    final triageCount =
        resources.where((r) => r.tags.isEmpty && r.notes.isEmpty).length;

    final tabs = [
      const GlassTab(icon: Icon(CupertinoIcons.square_grid_2x2_fill), label: 'Vault'),
      const GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
      const GlassTab(icon: Icon(CupertinoIcons.compass_fill), label: 'Nearby'),
      const GlassTab(icon: Icon(CupertinoIcons.map_fill), label: 'Explore'),
    ];

    return GlassScaffold(
      background: _buildBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      contentAwareBrightness: false,
      appBar: GlassAppBar(
        title: _buildAppBarTitle(),
        centerTitle: false,
        actions: [
          GlassButton(
            icon: const Icon(CupertinoIcons.sparkles, color: Colors.white),
            width: 40,
            height: 40,
            iconSize: 18,
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const AiAssistantScreen()),
            ),
          ),
          GlassBadge(
            count: triageCount,
            showZero: false,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.tray_full_fill, color: Colors.white),
              width: 40,
              height: 40,
              iconSize: 18,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const SmartInboxScreen()),
              ),
            ),
          ),
          GlassButton(
            icon: const Icon(CupertinoIcons.gear_alt, color: Colors.white),
            width: 40,
            height: 40,
            iconSize: 18,
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      bottomBar: GlassTabBar.minimizable(
        tabs: tabs,
        selectedIndex: _selectedTab,
        onTabSelected: (i) {
          setState(() => _selectedTab = i);
          _minimizeController.expand();
        },
        minimizeController: _minimizeController,
        scrollController: _scrollController,
        onMinimizedTabTap: _minimizeController.expand,
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _HomeTab(scrollController: _scrollController),
          const SearchScreen(),
          const LocationFeedScreen(),
          const ExploreScreen(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: AppColors.appleLime.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.appleLime.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: const Text(
            'STASH VAULT',
            style: TextStyle(
              color: AppColors.appleLime,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 9.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Smart Hub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.bg),
        Positioned(
          top: -90,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.appleLime.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.appleIndigo.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final ScrollController scrollController;
  const _HomeTab({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final resources = ref.watch(resourcesProvider);
    final recent = ref.read(resourcesProvider.notifier).recent;

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Quick Actions Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton.custom(
                    height: 46,
                    shape: const LiquidRoundedRectangle(borderRadius: 14),
                    glowColor: AppColors.appleLime,
                    onTap: () => showCupertinoModalPopup(
                      context: context,
                      builder: (_) => const AddResourceSheet(),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.add, color: AppColors.appleLime, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Save Resource',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassButton.custom(
                    height: 46,
                    shape: const LiquidRoundedRectangle(borderRadius: 14),
                    onTap: () => showCupertinoModalPopup(
                      context: context,
                      builder: (_) => const CreateCollectionSheet(),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.folder_badge_plus,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'New Folder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Recently Saved Row
        if (recent.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Text(
                    'Recently Added',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                RecentItemsRow(resources: recent),
              ],
            ),
          ),

        // Collections Section Title
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Text(
              'Collections',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        // Collections Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final col = collections[i];
                final count =
                    resources.where((r) => r.collectionIds.contains(col.id)).length;
                return CollectionCard(
                  collection: col,
                  resourceCount: count,
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => CollectionScreen(collection: col),
                    ),
                  ),
                );
              },
              childCount: collections.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
