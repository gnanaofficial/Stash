import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/resource.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/cloudflare_r2_service.dart';
import '../../core/services/link_preview_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass.dart';

class AddResourceSheet extends ConsumerStatefulWidget {
  final String? prefillUrl;
  final String? prefillNotes;
  final File? prefillFile;
  final String? preselectedCollectionId;

  const AddResourceSheet({
    super.key,
    this.prefillUrl,
    this.prefillNotes,
    this.prefillFile,
    this.preselectedCollectionId,
  });

  @override
  ConsumerState<AddResourceSheet> createState() => _AddResourceSheetState();
}

class _AddResourceSheetState extends ConsumerState<AddResourceSheet> {
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _selectedColIds = [];
  LinkPreviewData? _preview;
  bool _loading = false;
  bool _uploadingFile = false;
  bool _fetchingLocation = false;
  String? _detectedLocation;
  double? _latitude;
  double? _longitude;
  final List<String> _tags = [];
  File? _pickedFile;
  String? _uploadedPdfUrl;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCollectionId != null) {
      _selectedColIds.add(widget.preselectedCollectionId!);
    }
    if (widget.prefillNotes != null && widget.prefillNotes!.isNotEmpty) {
      _noteController.text = widget.prefillNotes!;
    }
    if (widget.prefillFile != null) {
      _pickedFile = widget.prefillFile;
      WidgetsBinding.instance.addPostFrameCallback((_) => _uploadGivenFile(widget.prefillFile!));
    }
    if (widget.prefillUrl != null) {
      _urlController.text = widget.prefillUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMetadata());
    }
  }

  void _autoSuggestCollection(String url, String? title) {
    if (widget.preselectedCollectionId != null) return;
    final text = '$url ${title ?? ''} ${_noteController.text}'.toLowerCase();
    String? matchedCol;
    if (text.contains('github.com') || text.contains('gitlab.com') || text.contains('git') || text.contains('code')) {
      matchedCol = 'col_github';
    } else if (text.contains('food') || text.contains('recipe') || text.contains('cafe') || text.contains('restaurant') || text.contains('eat')) {
      matchedCol = 'col_food';
    } else if (text.contains('design') || text.contains('figma') || text.contains('ui') || text.contains('mobbin') || text.contains('css')) {
      matchedCol = 'col_design';
    } else if (text.contains('tutorial') || text.contains('learn') || text.contains('guide') || text.contains('course')) {
      matchedCol = 'col_learning';
    }

    if (matchedCol != null) {
      setState(() {
        if (!_selectedColIds.contains(matchedCol)) {
          _selectedColIds.add(matchedCol!);
        }
      });
    }
  }

  Future<void> _uploadGivenFile(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    setState(() {
      _pickedFile = file;
      _uploadingFile = true;
    });

    final cloudUrl = await CloudflareR2Service.instance.uploadFile(
      file: file,
      customFileName: fileName,
      folder: 'vault_documents',
    );

    if (mounted) {
      setState(() {
        _uploadingFile = false;
        _uploadedPdfUrl = cloudUrl;
        if (_urlController.text.isEmpty && cloudUrl != null) {
          _urlController.text = cloudUrl;
        }
        if (!_tags.contains('pdf') && fileName.toLowerCase().endsWith('.pdf')) {
          _tags.add('pdf');
        }
      });
      _autoSuggestCollection(fileName, fileName);
    }
  }

  Future<void> _fetchMetadata() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || !url.startsWith('http')) return;

    setState(() => _loading = true);
    final data = await LinkPreviewService().fetchPreview(url);
    if (mounted) {
      setState(() {
        _preview = data;
        _loading = false;
      });
      _autoSuggestCollection(url, data.title);
    }
  }

  Future<void> _pickAndUploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      setState(() {
        _pickedFile = file;
        _uploadingFile = true;
      });

      final cloudUrl = await CloudflareR2Service.instance.uploadFile(
        file: file,
        customFileName: fileName,
        folder: 'vault_documents',
      );

      if (mounted) {
        setState(() {
          _uploadingFile = false;
          _uploadedPdfUrl = cloudUrl;
          if (_urlController.text.isEmpty && cloudUrl != null) {
            _urlController.text = cloudUrl;
          }
          if (!_tags.contains('pdf')) {
            _tags.add('pdf');
          }
        });
      }
    }
  }

  Future<void> _attachCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.denied && perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (marks.isNotEmpty && mounted) {
          final p = marks.first;
          setState(() {
            _latitude = pos.latitude;
            _longitude = pos.longitude;
            _detectedLocation = '${p.locality ?? p.subLocality ?? p.name}, ${p.country ?? ''}';
          });
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _fetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);
    if (_selectedColIds.isEmpty && collections.isNotEmpty) {
      _selectedColIds.add(collections.first.id);
    }

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: LiquidGlass(
        borderRadius: 34,
        blur: 35,
        tintColor: const Color(0xDE14141E),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0x55FFFFFF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Link, Reel or PDF',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  // Cloudflare R2 Upload PDF Button
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    onPressed: _uploadingFile ? null : _pickAndUploadPdf,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.appleOrange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.appleOrange.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_uploadingFile)
                            const CupertinoActivityIndicator(radius: 7, color: AppColors.appleOrange)
                          else
                            const Icon(CupertinoIcons.cloud_upload_fill, size: 14, color: AppColors.appleOrange),
                          const SizedBox(width: 5),
                          Text(
                            _uploadedPdfUrl != null
                                ? 'R2 Uploaded ✓'
                                : (_pickedFile != null ? 'PDF Attached' : 'Upload File'),
                            style: const TextStyle(
                              color: AppColors.appleOrange,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _urlController,
                      placeholder: 'Paste Instagram, YouTube, doc link or R2 file...',
                      placeholderStyle: const TextStyle(color: AppColors.textTertiary),
                      style: const TextStyle(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0x2EFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x28FFFFFF)),
                      ),
                      onSubmitted: (_) => _fetchMetadata(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  LiquidGlass(
                    borderRadius: 14,
                    blur: 16,
                    padding: const EdgeInsets.all(12),
                    tintColor: AppColors.appleBlue.withValues(alpha: 0.35),
                    onTap: _fetchMetadata,
                    child: _loading
                        ? const CupertinoActivityIndicator(radius: 9, color: Colors.white)
                        : const Icon(CupertinoIcons.arrow_right, color: Colors.white, size: 18),
                  ),
                ],
              ),
              if (_preview != null) ...[
                const SizedBox(height: 12),
                LiquidGlass(
                  borderRadius: 16,
                  blur: 16,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      if (_preview!.thumbnailUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _preview!.thumbnailUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.link, size: 36),
                          ),
                        )
                      else
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(CupertinoIcons.link, color: AppColors.appleBlue),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _preview!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (_preview!.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _preview!.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Collections (Select Multiple)',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_selectedColIds.length} selected',
                    style: const TextStyle(color: AppColors.appleBlue, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: collections.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final col = collections[i];
                    final isSel = _selectedColIds.contains(col.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSel) {
                            if (_selectedColIds.length > 1) {
                              _selectedColIds.remove(col.id);
                            }
                          } else {
                            _selectedColIds.add(col.id);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.appleBlue : const Color(0x2EFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.appleBlue : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.folder_fill,
                              size: 14,
                              color: isSel ? Colors.white : AppColors.appleLime,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              col.name,
                              style: TextStyle(
                                color: isSel ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            if (isSel) ...[
                              const SizedBox(width: 4),
                              const Icon(CupertinoIcons.checkmark_alt, size: 12, color: Colors.white),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              CupertinoTextField(
                controller: _noteController,
                placeholder: 'Add quick notes, shortcuts, or key takeaways...',
                placeholderStyle: const TextStyle(color: AppColors.textTertiary),
                style: const TextStyle(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0x2EFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x28FFFFFF)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _tagController,
                      placeholder: '+ Add tag (press enter)',
                      placeholderStyle: const TextStyle(color: AppColors.textTertiary),
                      style: const TextStyle(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x2EFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x28FFFFFF)),
                      ),
                      onSubmitted: (val) {
                        final t = val.trim().toLowerCase();
                        if (t.isNotEmpty && !_tags.contains(t)) {
                          setState(() => _tags.add(t));
                        }
                        _tagController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: _fetchingLocation ? null : _attachCurrentLocation,
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid, size: 16, color: AppColors.appleGreen),
                        const SizedBox(width: 4),
                        Text(
                          _detectedLocation != null ? 'Tagged' : 'Location',
                          style: const TextStyle(color: AppColors.appleGreen, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_tags.isNotEmpty || _detectedLocation != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (_detectedLocation != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.appleGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.appleGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.location_solid, size: 12, color: AppColors.appleGreen),
                            const SizedBox(width: 4),
                            Text(_detectedLocation!, style: const TextStyle(fontSize: 11, color: AppColors.appleGreen)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _detectedLocation = null),
                              child: const Icon(CupertinoIcons.clear_circled_solid, size: 12, color: AppColors.appleGreen),
                            ),
                          ],
                        ),
                      ),
                    ..._tags.map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.appleBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.appleBlue.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('#$tag', style: const TextStyle(fontSize: 11, color: AppColors.appleBlue)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _tags.remove(tag)),
                              child: const Icon(CupertinoIcons.clear_circled_solid, size: 12, color: AppColors.appleBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              LiquidGlassButton(
                height: 52,
                borderRadius: 18,
                backgroundColor: AppColors.appleBlue.withValues(alpha: 0.5),
                onPressed: _save,
                child: const Text(
                  'Save to STASH Vault',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || _selectedColIds.isEmpty) return;

    final primaryColId = _selectedColIds.first;
    final isUntriaged = _tags.isEmpty && _noteController.text.trim().isEmpty;

    final resource = ResourceModel(
      id: const Uuid().v4(),
      collectionId: primaryColId,
      collectionIds: _selectedColIds,
      url: url,
      title: _preview?.title ?? (_pickedFile != null ? _pickedFile!.path.split(Platform.pathSeparator).last : url),
      description: _preview?.description ?? '',
      thumbnailUrl: _preview?.thumbnailUrl ?? '',
      type: _pickedFile != null ? ResourceType.document : (_preview?.type ?? ResourceModel.detectType(url)),
      source: _pickedFile != null ? 'pdf' : (_preview?.source ?? ResourceModel.detectSource(url)),
      createdAt: DateTime.now(),
      notes: _noteController.text.trim(),
      tags: _tags,
      locationName: _detectedLocation,
      latitude: _latitude,
      longitude: _longitude,
      processingState: isUntriaged ? 'needs_review' : 'organized',
    );

    await ref.read(resourcesProvider.notifier).addResource(resource);
    if (mounted) Navigator.pop(context);
  }
}
