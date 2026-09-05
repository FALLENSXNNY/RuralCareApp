import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/ai_message.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/language_selector_modal.dart';
import '../../../core/widgets/offline_banner.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key, this.initialPrompt});

  final String? initialPrompt;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  bool _hasLoadedHistory = false;
  final List<AiMessage> _messages = [];

  List<_QuickTopic> _getQuickTopics(BuildContext context) {
    final l10n = context.l10n;
    return [
      _QuickTopic(
        icon: Icons.thermostat_outlined,
        title: l10n.aiTopicFever,
        prompt: l10n.aiTopicFeverPrompt,
      ),
      _QuickTopic(
        icon: Icons.water_drop_outlined,
        title: l10n.aiTopicOrs,
        prompt: l10n.aiTopicOrsPrompt,
      ),
      _QuickTopic(
        icon: Icons.health_and_safety_outlined,
        title: l10n.aiTopicFirstAid,
        prompt: l10n.aiTopicFirstAidPrompt,
      ),
      _QuickTopic(
        icon: Icons.local_hospital_outlined,
        title: l10n.aiTopicNearestPhc,
        prompt: l10n.aiTopicNearestPhcPrompt,
      ),
      _QuickTopic(
        icon: Icons.favorite_outline,
        title: l10n.aiTopicBp,
        prompt: l10n.aiTopicBpPrompt,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initHistory(List<AiMessage> history) {
    if (!_hasLoadedHistory) {
      _hasLoadedHistory = true;
      if (history.isNotEmpty) {
        _messages.addAll(history);
      }
    }
  }

  Future<void> _callAmbulance() async {
    final uri = Uri(scheme: 'tel', path: AppConstants.emergencyNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty || _isTyping) return;

    if (presetText == null) {
      _controller.clear();
    }

    final userMsg = AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_u',
      text: text,
      isAi: false,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final currentLang = ref.read(localeProvider).languageCode;
      final response = await aiRepo.sendMessage(
        text,
        history: _messages,
        language: currentLang,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(response);
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        final currentLang = ref.read(localeProvider).languageCode;
        String fallbackText;
        if (currentLang == 'hi') {
          fallbackText =
              'आपके प्रश्न के लिए धन्यवाद। आपके मार्गदर्शन के लिए स्वास्थ्य जानकारी निम्नलिखित है:\n\n'
              '• शांत वातावरण में विश्राम करें और पर्याप्त स्वच्छ पानी पिएं।\n'
              '• अगले 24 घंटों में अपने लक्षणों पर बारीकी से नजर रखें।\n'
              '• यदि लक्षण बने रहते हैं या बिगड़ते हैं, तो कृपया अपने नजदीकी प्राथमिक स्वास्थ्य केंद्र (PHC) जाएं।\n\n'
              '**महत्वपूर्ण सूचना:** यह सामान्य स्वास्थ्य जानकारी है, चिकित्सीय निदान नहीं। कृपया डॉक्टर से सलाह लें।';
        } else if (currentLang == 'bn') {
          fallbackText =
              'আপনার প্রশ্নের জন্য ধন্যবাদ। আপনার অবগতির জন্য স্বাস্থ্য নির্দেশিকা নিচে দেওয়া হলো:\n\n'
              '• একটি শান্ত জায়গায় বিশ্রাম নিন এবং পর্যাপ্ত বিশুদ্ধ জল পান করুন।\n'
              '• পরবর্তী ২৪ ঘণ্টায় আপনার লক্ষণগুলির ওপর সতর্ক দৃষ্টি রাখুন।\n'
              '• লক্ষণগুলি স্থায়ী হলে বা খারাপ হলে অবিলম্বে আপনার নিকটস্থ প্রাথমিক স্বাস্থ্য কেন্দ্রে (PHC) যান।\n\n'
              '**গুরুত্বপূর্ণ বিজ্ঞপ্তি:** এটি সাধারণ স্বাস্থ্য নির্দেশিকা, চিকিৎসাগত রোগ নির্ণয় নয়। অনুগ্রহ করে একজন ডাক্তারের পরামর্শ নিন।';
        } else {
          fallbackText =
              'Thank you for your question. Here is health guidance for your consideration:\n\n'
              '• Rest in a quiet space and drink plenty of clean, safe water.\n'
              '• Monitor your symptoms over the next 24 hours.\n'
              '• If symptoms worsen or persist, please visit your local Primary Health Centre (PHC Koregaon).\n\n'
              '**Important Notice:** This is general health information, not a formal medical diagnosis. Please consult a doctor or healthcare worker.';
        }

        setState(() {
          _isTyping = false;
          _messages.add(
            AiMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}_err',
              text: fallbackText,
              isAi: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _clearHistory() async {
    if (_messages.isEmpty) return;
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearChatHistory),
        content: Text(l10n.clearChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.clearChat),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final aiRepo = ref.read(aiRepositoryProvider);
      await aiRepo.clearConversationHistory();
      ref.invalidate(aiConversationHistoryProvider);
      if (mounted) {
        setState(() {
          _messages.clear();
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.animNormal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final historyAsync = ref.watch(aiConversationHistoryProvider);
    final l10n = context.l10n;

    historyAsync.whenData((history) {
      if (!_hasLoadedHistory) {
        _initHistory(history);
      }
    });

    if (!_hasLoadedHistory && !historyAsync.isLoading) {
      _initHistory(const []);
    }

    final hasMessages = _messages.isNotEmpty || _isTyping;
    final quickTopics = _getQuickTopics(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.aiHealthHelp, style: AppTextStyles.titleMedium),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.success : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? l10n.onlineAssistant : l10n.offlineKnowledge,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isOnline ? AppColors.textMuted : AppColors.warning,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.translate_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            tooltip: l10n.changeLanguage,
            onPressed: () => LanguageSelectorModal.show(context),
          ),
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textMuted),
              tooltip: l10n.clearChat,
              onPressed: _clearHistory,
            ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textMuted,
              size: 22,
            ),
            tooltip: l10n.medicalDisclaimer,
            onPressed: () => _showDisclaimerDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner when disconnected
          if (!isOnline)
            OfflineBanner(
              message: l10n.offlineAiNotice,
            ),

          // Main Chat Area or Welcome Screen
          Expanded(
            child: hasMessages
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return const _TypingIndicator();
                      }
                      final msg = _messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MessageBubble(message: msg),
                          if (msg.isEmergency)
                            _EmergencyCalloutBanner(
                              onCallAmbulance: _callAmbulance,
                              onFindCare: () => context.go(AppRoutes.facilityFinder),
                            ),
                        ],
                      );
                    },
                  )
                : _buildWelcomeState(),
          ),

          // Quick Topic Chips (Visible when chat has messages to ask follow-ups)
          if (hasMessages && !_isTyping)
            Container(
              color: AppColors.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: quickTopics.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: Icon(topic.icon, size: 16, color: AppColors.primary),
                        label: Text(topic.title),
                        labelStyle: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: AppColors.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border, width: 0.5),
                        ),
                        onPressed: () => _sendMessage(topic.prompt),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Bottom Input Bar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: l10n.aiInputPlaceholder,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _isTyping ? AppColors.textMuted : AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isTyping ? null : () => _sendMessage(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    final l10n = context.l10n;
    final quickTopics = _getQuickTopics(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aiAssistantTitle,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.homeAiSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Clinical notice box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.aiEmergencyWarning,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.commonHealthTopics,
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Grid of Quick Prompts
          ...quickTopics.map((topic) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _sendMessage(topic.prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(topic.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(topic.title, style: AppTextStyles.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                topic.prompt,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(l10n.clinicalNotice),
          ],
        ),
        content: Text(
          AppConstants.aiDisclaimerFull,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.iUnderstand),
          ),
        ],
      ),
    );
  }
}

class _QuickTopic {
  const _QuickTopic({
    required this.icon,
    required this.title,
    required this.prompt,
  });

  final IconData icon;
  final String title;
  final String prompt;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final AiMessage message;

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.messageCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAi = message.isAi;
    final timeStr = DateFormat('h:mm a').format(message.time);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.health_and_safety,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAi ? AppColors.surface : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAi ? 4 : 16),
                      bottomRight: Radius.circular(isAi ? 16 : 4),
                    ),
                    border: isAi ? Border.all(color: AppColors.border, width: 0.5) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isAi
                      ? MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                            h1: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            strong: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            em: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                            listBullet: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTapLink: (text, href, title) async {
                            if (href != null && href.isNotEmpty) {
                              final uri = Uri.tryParse(href);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            }
                          },
                        )
                      : Text(
                          message.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary,
                            height: 1.5,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    if (isAi) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _copyText(context),
                        child: const Icon(
                          Icons.copy_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCalloutBanner extends StatelessWidget {
  const _EmergencyCalloutBanner({
    required this.onCallAmbulance,
    required this.onFindCare,
  });

  final VoidCallback onCallAmbulance;
  final VoidCallback onFindCare;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency, color: AppColors.emergency, size: 20),
              const SizedBox(width: 8),
              Text(
                'Potential Medical Emergency Detected',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.emergency,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCallAmbulance,
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call 108'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergency,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFindCare,
                  icon: const Icon(Icons.local_hospital_outlined, size: 16),
                  label: const Text('Find PHC'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.emergency,
                    side: const BorderSide(color: AppColors.emergency),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.health_and_safety,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(150),
                const SizedBox(width: 4),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (_, v, _) => Opacity(
        opacity: v,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
