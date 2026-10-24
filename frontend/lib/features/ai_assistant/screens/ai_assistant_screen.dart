import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../models/chat_message.dart';
import '../../../services/ai_chat_service.dart';
import '../../../widgets/carelink_app_bar.dart';
import '../../../widgets/carelink_bottom_nav.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/quick_suggestion_chips.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isBusy = false;
  bool _isLoadingHistory = false;

  // Active Patient Profile
  String _activeUserName = 'Tayasshuk Imam';
  String _activeUserId = 'tayasshuk';

  @override
  void initState() {
    super.initState();
    _loadUserHistory();
  }

  Future<void> _loadUserHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    final history = await AIChatService.fetchUserHistory(userId: _activeUserId);

    setState(() {
      _messages.clear();
      if (history.isNotEmpty) {
        _messages.addAll(history);
      } else {
        _loadInitialGreeting();
      }
      _isLoadingHistory = false;
    });

    _scrollToBottom();
  }

  void _loadInitialGreeting() {
    _messages.add(
      ChatMessage.assistant(
        text:
            "Hello $_activeUserName! I'm your CareLink AI Health Assistant 🩺\n\nYou can chat with me for symptom guidance, specialist doctor recommendations, or upload a photo of your prescription to get a clear breakdown of medicines and dosages.",
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String text, File? attachment) async {
    if (text.trim().isEmpty && attachment == null) return;

    final userMsg = ChatMessage.user(
      text: text,
      attachmentPath: attachment?.path,
      isImage: attachment != null,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(ChatMessage.thinking());
      _isBusy = true;
    });
    _scrollToBottom();

    try {
      final botResponse = await AIChatService.sendMessage(
        query: text,
        attachment: attachment,
        userId: _activeUserId,
        conversationHistory: _messages,
      );

      setState(() {
        _messages.removeWhere((m) => m.isThinking);
        _messages.add(botResponse);
        _isBusy = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.isThinking);
        _messages.add(
          ChatMessage.assistant(
            text:
                "Sorry, I encountered an issue processing your request. Please try again.",
          ),
        );
        _isBusy = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: Text('This will delete saved AI consultations for $_activeUserName.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AIChatService.clearUserHistory(userId: _activeUserId);
      setState(() {
        _messages.clear();
        _loadInitialGreeting();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chat history cleared for $_activeUserName.')),
        );
      }
    }
  }

  void _showUserSwitcher() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Switch Patient / Family Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Text(
                  'Each user has their own private AI consultation history stored in the database.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const Divider(height: 20),
              _buildUserTile('Tayasshuk Imam', 'tayasshuk', 'Self • Patient'),
              _buildUserTile('Ayesha Rahman', 'ayesha', 'Family Member • Patient'),
              _buildUserTile('Tanvir Islam', 'tanvir', 'Family Member • Patient'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(String name, String userId, String role) {
    final isCurrent = _activeUserId == userId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrent ? AppColors.primary : AppColors.primaryLight,
        child: Icon(
          Icons.person_rounded,
          color: isCurrent ? Colors.white : AppColors.primary,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          color: isCurrent ? AppColors.primaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(role, style: const TextStyle(fontSize: 12)),
      trailing: isCurrent
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        if (_activeUserId != userId) {
          setState(() {
            _activeUserId = userId;
            _activeUserName = name;
            AIChatService.activeUserId = userId;
          });
          _loadUserHistory();
        }
      },
    );
  }

  void _showBackendSettings() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'AI Configuration',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Engine: Google Gemini 3.8 Flash',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            'Active Patient: $_activeUserName ($activeUserIdTag)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Live Backend API',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  AIChatService.useLiveApi
                      ? 'Connected to Django PostgreSQL/SQLite database'
                      : 'Offline Simulation Mode',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                value: AIChatService.useLiveApi,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  setDialogState(() {
                    AIChatService.useLiveApi = val;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Endpoint: ${AIChatService.baseUrl}/ai-chat/',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  String get activeUserIdTag => _activeUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CareLinkAppBar(
        onProfilePressed: _showUserSwitcher,
      ),
      body: Column(
        children: [
          // Subheader: AI Health Assistant Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Bot Icon badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/carelink-icon-192.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title + Active Patient Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'AI Health Assistant',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.userPillBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _activeUserName.split(' ').first,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.online,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Flexible(
                            child: Text(
                              'Online • Gemini 3.8 Flash',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.online,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions: User Switcher / Settings / Clear
                IconButton(
                  icon: const Icon(Icons.people_outline_rounded, size: 21),
                  color: AppColors.primary,
                  tooltip: 'Switch Patient Profile',
                  visualDensity: VisualDensity.compact,
                  onPressed: _showUserSwitcher,
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Backend Settings',
                  visualDensity: VisualDensity.compact,
                  onPressed: _showBackendSettings,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Clear Chat',
                  visualDensity: VisualDensity.compact,
                  onPressed: _clearChat,
                ),
              ],
            ),
          ),

          // Quick suggestions chips
          QuickSuggestionChips(
            onSelectSuggestion: (query) => _handleSendMessage(query, null),
          ),

          // Message list / Loading indicator
          Expanded(
            child: _isLoadingHistory
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),

          // Medical disclaimer note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: Colors.transparent,
            child: const Text(
              '⚠️ AI guidance is for informational purposes. For emergencies, please visit the nearest hospital.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ),

          // Chat Input Bar
          ChatInputBar(
            onSendMessage: _handleSendMessage,
            isBusy: _isBusy,
          ),
        ],
      ),
      bottomNavigationBar: const CareLinkBottomNav(currentIndex: 4),
    );
  }
}
