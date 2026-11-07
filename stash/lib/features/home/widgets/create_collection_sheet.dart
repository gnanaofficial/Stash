import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/collection.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liquid_glass.dart';

class CreateCollectionSheet extends ConsumerStatefulWidget {
  const CreateCollectionSheet({super.key});

  @override
  ConsumerState<CreateCollectionSheet> createState() =>
      _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends ConsumerState<CreateCollectionSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _selectedIconIndex = 0;
  int _colorIndex = 0;

  static const List<IconData> _icons = [
    CupertinoIcons.folder_fill,
    CupertinoIcons.chevron_left_slash_chevron_right,
    CupertinoIcons.compass_fill,
    CupertinoIcons.sparkles,
    CupertinoIcons.doc_text_fill,
    CupertinoIcons.film_fill,
    CupertinoIcons.bookmark_fill,
    CupertinoIcons.star_fill,
    CupertinoIcons.shield_fill,
    CupertinoIcons.bolt_fill,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: LiquidGlass(
        borderRadius: 32,
        blur: 35,
        tintColor: const Color(0xCC12121A),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0x55FFFFFF),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const Text(
              'New Collection',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Vector Icon Selection (No emojis)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_icons.length, (i) {
                final icon = _icons[i];
                final isSel = i == _selectedIconIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.appleLime.withValues(alpha: 0.25)
                          : const Color(0x2EFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppColors.appleLime : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSel ? AppColors.appleLime : Colors.white70,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Color Palette Selector
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.collectionGradients.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final grad = AppColors.collectionGradients[i];
                  final isSel = i == _colorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      width: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'Collection Title (e.g. Dev Tools)',
              placeholderStyle: const TextStyle(color: AppColors.textTertiary),
              style: const TextStyle(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0x28FFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x28FFFFFF)),
              ),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: _descController,
              placeholder: 'Description (optional)',
              placeholderStyle: const TextStyle(color: AppColors.textTertiary),
              style: const TextStyle(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0x28FFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x28FFFFFF)),
              ),
            ),
            const SizedBox(height: 22),
            LiquidGlassButton(
              height: 50,
              borderRadius: 16,
              backgroundColor: AppColors.appleLime.withValues(alpha: 0.35),
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;

                final col = CollectionModel(
                  id: const Uuid().v4(),
                  name: name,
                  emoji: 'icon_$_selectedIconIndex',
                  colorIndex: _colorIndex,
                  description: _descController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                ref.read(collectionsProvider.notifier).addCollection(col);
                Navigator.pop(context);
              },
              child: const Text(
                'Create Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
