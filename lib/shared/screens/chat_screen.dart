import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';

/// Chat Screen with Firebase Realtime Database
/// Enables real-time messaging between client and admin
class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final bool isAdmin;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.isAdmin,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref('messages');

  String _currentUserId = '';
  List<ChatMessage> _messages = [];
  bool _isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Get actual user ID - try multiple possible keys
      _currentUserId = prefs.getString('userId') ??
          prefs.getString('user_id') ??
          prefs.getInt('userId')?.toString() ??
          '';

      // Debug print to check
      print('🔍 Current User ID: $_currentUserId');
      print('🔍 Other User ID: ${widget.otherUserId}');

      if (_currentUserId.isEmpty) {
        print('⚠️ Warning: User ID is empty! Chat will not work properly.');
      }

      // Check if Firebase is actually initialized and available
      try {
        // Try to access Firebase - this will throw if not initialized
        await FirebaseDatabase.instance.ref().once();
        _isFirebaseInitialized = true;

        // Listen to messages only if Firebase is working
        _listenToMessages();
      } catch (firebaseError) {
        // Firebase not initialized or configured
        _isFirebaseInitialized = false;
        print('Firebase not available: $firebaseError');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _isFirebaseInitialized = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _listenToMessages() {
    final chatId = _getChatId();
    _messagesRef.child(chatId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final messages = <ChatMessage>[];

        data.forEach((key, value) {
          messages.add(ChatMessage.fromMap(Map<String, dynamic>.from(value)));
        });

        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (mounted) {
          setState(() {
            _messages = messages;
          });
          _scrollToBottom();
        }
      }
    });
  }

  String _getChatId() {
    // Create consistent chat ID for both users
    final ids = [_currentUserId, widget.otherUserId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (!_isFirebaseInitialized) {
      _showFirebaseNotConfigured();
      return;
    }

    final message = ChatMessage(
      senderId: _currentUserId,
      receiverId: widget.otherUserId,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    try {
      final chatId = _getChatId();
      await _messagesRef.child(chatId).push().set(message.toMap());
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(
                widget.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.isAdmin ? 'Admin' : 'Client',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: !_isFirebaseInitialized
          ? _buildNotConfiguredView()
          : Column(
              children: [
                // Messages List
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderId == _currentUserId;
                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                ),

                // Input Field
                _buildInputField(),
              ],
            ),
    );
  }

  Widget _buildNotConfiguredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Firebase Chat',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Fitur chat real-time memerlukan konfigurasi Firebase.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Silakan konfigurasi Firebase di main.dart dan tambahkan file google-services.json (Android) atau GoogleService-Info.plist (iOS).',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Setup Firebase:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Buat project di Firebase Console\n'
                    '2. Download file konfigurasi\n'
                    '3. Initialize Firebase di main.dart\n'
                    '4. Enable Realtime Database',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Belum ada pesan',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Mulai percakapan dengan ${widget.otherUserName}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radiusM),
                  topRight: const Radius.circular(AppTheme.radiusM),
                  bottomLeft: Radius.circular(isMe ? AppTheme.radiusM : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppTheme.radiusM),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppColors.primary,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showFirebaseNotConfigured() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Belum Dikonfigurasi'),
        content: const Text(
          'Fitur chat memerlukan Firebase. Silakan ikuti petunjuk setup Firebase terlebih dahulu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}
