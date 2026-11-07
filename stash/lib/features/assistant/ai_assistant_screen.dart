import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/resource.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/ai_assistant_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_components.dart';
import '../../core/theme/liquid_glass.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<ResourceModel> attachedResources;
  final AiActionProposal? proposal;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.attachedResources = const [],
    this.proposal,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;
  late AiToolRegistry _toolRegistry;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'Hello! I am your STASH AI Assistant. I can search across all your saved Instagram reels, YouTube videos, GitHub links, and uploaded PDFs. Try asking:\n\n• "Show me my GitHub repositories"\n• "Find food reels near me"\n• "Organize my untagged items"',
        isUser: false,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? predefinedText]) async {
    final query = predefinedText ?? _textController.text.trim();
    if (query.isEmpty) return;

    if (predefinedText == null) {
      _textController.clear();
    }

    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _isThinking = true;
    });
    _scrollToBottom();

    // Initialize Tool Registry with live Riverpod state
    _toolRegistry = AiToolRegistry(
      getResources: () => ref.read(resourcesProvider),
      getCollections: () => ref.read(collectionsProvider),
      linkResourceToCollection: (rid, cid) =>
          ref.read(resourcesProvider.notifier).linkToCollection(rid, cid),
      deleteResource: (rid) =>
          ref.read(resourcesProvider.notifier).deleteResource(rid),
    );

    await Future.delayed(const Duration(milliseconds: 400));
    final response = await _toolRegistry.processQuery(query);

    if (mounted) {
      setState(() {
        _isThinking = false;
        _messages.add(
          ChatMessage(
            text: response.message,
            isUser: false,
            attachedResources: response.matchingResources,
            proposal: response.proposal,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CupertinoNavigationBar(
        backgroundColor: const Color(0x66000000),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.appleBlue, AppColors.applePurple]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(CupertinoIcons.sparkles, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Vault Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Ambient Glow Orbs
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.applePurple.withValues(alpha: 0.22), Colors.transparent],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Chat List
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final msg = _messages[i];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              if (_isThinking)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      CupertinoActivityIndicator(radius: 8, color: AppColors.appleBlue),
                      SizedBox(width: 10),
                      Text(
                        'Searching authorized resources...',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Suggestion Pills
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _suggestionPill('Find GitHub links'),
                    const SizedBox(width: 8),
                    _suggestionPill('Find food reels'),
                    const SizedBox(width: 8),
                    _suggestionPill('Organize untagged'),
                    const SizedBox(width: 8),
                    _suggestionPill('Show PDFs'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Chat Input Bar
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _textController,
                          placeholder: 'Ask about your saved links & reels...',
                          placeholderStyle: const TextStyle(color: AppColors.textTertiary),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0x331C1C28),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x28FFFFFF)),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      LiquidGlass(
                        borderRadius: 18,
                        blur: 16,
                        padding: const EdgeInsets.all(11),
                        tintColor: AppColors.appleBlue.withValues(alpha: 0.4),
                        onTap: () => _sendMessage(),
                        child: const Icon(CupertinoIcons.arrow_up_circle_fill,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionPill(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x28FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x28FFFFFF)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.appleBlue.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(18).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(14),
              child: Text(
                msg.text,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
              ),
            ),

            // Render matching resources as interactive Apple cards
            if (msg.attachedResources.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...msg.attachedResources.map((res) => _buildResourceMiniCard(res)),
            ],

            // Render Action Proposal with Explicit Confirmation (§11 of Master Prompt)
            if (msg.proposal != null && !msg.proposal!.isExecuted) ...[
              const SizedBox(height: 10),
              _buildProposalCard(msg.proposal!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResourceMiniCard(ResourceModel res) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(10),
        onTap: () async {
          final uri = Uri.tryParse(res.url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Row(
          children: [
            ThumbnailPreview(
              imageUrl: res.thumbnailUrl,
              sourceVectorIcon: res.sourceVectorIcon,
              width: 48,
              height: 48,
              borderRadius: 10,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PlatformBadge(source: res.source),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          res.title.isNotEmpty ? res.title : res.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    res.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.arrow_up_right, size: 14, color: AppColors.appleBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalCard(AiActionProposal proposal) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.appleOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.appleOrange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.bolt_fill,
                  color: AppColors.appleOrange, size: 16),
              SizedBox(width: 6),
              Text(
                'PROPOSED ACTION',
                style: TextStyle(
                  color: AppColors.appleOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            proposal.description,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.appleGreen,
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () async {
                    await _toolRegistry.executeProposal(proposal);
                    setState(() {});
                  },
                  child: const Text('Confirm & Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(10),
                onPressed: () {
                  setState(() => proposal.isExecuted = true);
                },
                child: const Text('Dismiss', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
