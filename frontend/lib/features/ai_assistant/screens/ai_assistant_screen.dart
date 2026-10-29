import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Active Session tracking (null = new fresh chat session)
  String? _currentSessionId;
  String? _currentSessionTitle;

  // Active Patient Profile
  String _activeUserName = 'Tayasshuk Imam';
  String _activeUserId = 'tayasshuk';

  @override
  void initState() {
    super.initState();
    // Always start on a fresh new page every time
    _startNewChat();
  }

  void _startNewChat() {
    setState(() {
      _currentSessionId = null;
      _currentSessionTitle = null;
      _messages.clear();
      _loadInitialGreeting();
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

  Future<void> _loadSession(String sessionId, String title) async {
    setState(() {
      _isLoadingHistory = true;
      _currentSessionId = sessionId;
      _currentSessionTitle = title;
    });

    final history = await AIChatService.fetchUserHistory(
      userId: _activeUserId,
      sessionId: sessionId,
    );

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
      sessionId: _currentSessionId,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(ChatMessage.thinking(sessionId: _currentSessionId));
      _isBusy = true;
    });
    _scrollToBottom();

    try {
      final botResponse = await AIChatService.sendMessage(
        query: text,
        attachment: attachment,
        userId: _activeUserId,
        sessionId: _currentSessionId,
        conversationHistory: _messages,
      );

      setState(() {
        _messages.removeWhere((m) => m.isThinking);
        _messages.add(botResponse);
        _isBusy = false;
        // If this was a new session, lock onto the returned sessionId
        if (_currentSessionId == null && botResponse.sessionId != null) {
          _currentSessionId = botResponse.sessionId;
          _currentSessionTitle = text.length > 35
              ? '${text.substring(0, 35)}...'
              : (text.isNotEmpty ? text : 'Prescription Consultation');
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.isThinking);
        _messages.add(
          ChatMessage.assistant(
            text:
                "Sorry, I encountered an issue processing your request. Please try again.",
            sessionId: _currentSessionId,
          ),
        );
        _isBusy = false;
      });
    }

    _scrollToBottom();
  }


  void _showChatHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChatHistoryModal(
        userId: _activeUserId,
        userName: _activeUserName,
        currentSessionId: _currentSessionId,
        onSelectSession: (sessionId, title) {
          Navigator.pop(ctx);
          _loadSession(sessionId, title);
        },
        onStartNewChat: () {
          Navigator.pop(ctx);
          _startNewChat();
        },
      ),
    );
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
            _startNewChat();
          });
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
                            'Engine: Google Gemini 3.1 Flash',
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
                      ? 'Connected to Django PostgreSQL database'
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            'AI Assistant',
                            style: TextStyle(
                              fontSize: 14,
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
                              'Online • Gemini 3.1 Flash',
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

                // CHAT HISTORY BUTTON
                InkWell(
                  onTap: _showChatHistoryBottomSheet,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // NEW CHAT BUTTON
                IconButton(
                  icon: const Icon(Icons.add_comment_outlined, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Start New Chat',
                  visualDensity: VisualDensity.compact,
                  onPressed: _startNewChat,
                ),

                // Profile Switcher
                IconButton(
                  icon: const Icon(Icons.people_outline_rounded, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Switch Patient Profile',
                  visualDensity: VisualDensity.compact,
                  onPressed: _showUserSwitcher,
                ),

                // Settings
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 19),
                  color: AppColors.textSecondary,
                  tooltip: 'AI Configuration',
                  visualDensity: VisualDensity.compact,
                  onPressed: _showBackendSettings,
                ),
              ],
            ),
          ),

          // Continuing Consultation Indicator Banner (if a previous chat was selected)
          if (_currentSessionTitle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.6),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.forum_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Continuing: $_currentSessionTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _startNewChat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                          SizedBox(width: 2),
                          Text(
                            'New Chat',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Quick suggestions chips (available on new chat or anytime)
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

/// Interactive Bottom Sheet displaying past consultations for the user
class _ChatHistoryModal extends StatefulWidget {
  final String userId;
  final String userName;
  final String? currentSessionId;
  final Function(String sessionId, String title) onSelectSession;
  final VoidCallback onStartNewChat;

  const _ChatHistoryModal({
    required this.userId,
    required this.userName,
    required this.currentSessionId,
    required this.onSelectSession,
    required this.onStartNewChat,
  });

  @override
  State<_ChatHistoryModal> createState() => _ChatHistoryModalState();
}

class _ChatHistoryModalState extends State<_ChatHistoryModal> {
  late Future<List<ChatSessionSummary>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = AIChatService.fetchUserSessions(userId: widget.userId);
  }

  Future<void> _handleDeleteSession(ChatSessionSummary session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Consultation?'),
        content: Text('Delete "${session.title}" from ${widget.userName}\'s history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AIChatService.deleteSession(sessionId: session.id, userId: widget.userId);
      setState(() {
        _loadSessions();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chat History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Past consultations for ${widget.userName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Top Action: "+ Start New Chat" button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: InkWell(
              onTap: widget.onStartNewChat,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Start a New Consultation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 16),

          // Past Sessions List
          Expanded(
            child: FutureBuilder<List<ChatSessionSummary>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                final sessions = snapshot.data ?? [];
                if (sessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Past Consultations',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Every consultation you have with the AI assistant will be saved here for ${widget.userName}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final isActive = session.id == widget.currentSessionId;

                    return _buildSessionCard(session, isActive);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ChatSessionSummary session, bool isActive) {
    IconData leadingIcon = Icons.chat_bubble_outline_rounded;
    Color iconBg = AppColors.primaryLight;
    Color iconColor = AppColors.primary;

    if (session.hasPrescription) {
      leadingIcon = Icons.medication_rounded;
      iconBg = const Color(0xFFE6FFFA);
      iconColor = const Color(0xFF0D9488);
    } else if (session.doctorRecommendation != null &&
        session.doctorRecommendation!.isNotEmpty) {
      leadingIcon = Icons.medical_services_rounded;
      iconBg = AppColors.tagBlueBg;
      iconColor = AppColors.tagBlueText;
    }

    final formattedDate =
        DateFormat('MMM d, yyyy • h:mm a').format(session.updatedAt);

    return InkWell(
      onTap: () => widget.onSelectSession(session.id, session.title),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryLight.withValues(alpha: 0.4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title + Active tag + Delete button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(leadingIcon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.online.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.online,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppColors.textMuted,
                  tooltip: 'Delete Consultation',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _handleDeleteSession(session),
                ),
              ],
            ),

            if (session.lastMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Footer chips: message count + Continue action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.userPillBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${session.messageCount} messages',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    if (session.hasPrescription) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FFFA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Prescription',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
