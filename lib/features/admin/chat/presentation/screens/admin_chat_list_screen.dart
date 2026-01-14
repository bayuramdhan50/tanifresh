import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/shared/screens/chat_screen.dart';

/// Admin Chat List Screen
/// Shows all clients who have chatted with admin
class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref('messages');
  List<ChatContact> _contacts = [];
  bool _isLoading = true;
  bool _isFirebaseAvailable = false;
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adminId = prefs.getString('userId') ?? 'admin-001';

      // Check Firebase availability
      try {
        await FirebaseDatabase.instance.ref().once();
        _isFirebaseAvailable = true;
        _listenToChats();
      } catch (e) {
        _isFirebaseAvailable = false;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _listenToChats() {
    _messagesRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final Map<String, ChatContact> contactsMap = {};

        // Process all chat IDs to find unique clients
        data.forEach((chatId, messages) {
          if (messages == null) return;

          final messagesList = Map<String, dynamic>.from(messages as Map);
          if (messagesList.isEmpty) return;

          // Get last message
          final lastMessageData = messagesList.values.last;
          final lastMessage = Map<String, dynamic>.from(lastMessageData as Map);

          final senderId = lastMessage['senderId'] as String? ?? '';
          final receiverId = lastMessage['receiverId'] as String? ?? '';

          // Determine client ID - whoever is NOT admin
          String clientId = '';
          String clientName = 'Unknown Client';

          if (senderId.isNotEmpty &&
              senderId != _adminId &&
              senderId != 'admin-001') {
            clientId = senderId;
            clientName =
                'Client ${clientId.substring(0, clientId.length > 8 ? 8 : clientId.length)}';
          } else if (receiverId.isNotEmpty &&
              receiverId != _adminId &&
              receiverId != 'admin-001') {
            clientId = receiverId;
            clientName =
                'Client ${clientId.substring(0, clientId.length > 8 ? 8 : clientId.length)}';
          } else {
            // Try to extract from chat ID
            final parts = chatId.split('_');
            for (var part in parts) {
              if (part != _adminId && part != 'admin-001' && part.isNotEmpty) {
                clientId = part;
                clientName =
                    'Client ${part.substring(0, part.length > 8 ? 8 : part.length)}';
                break;
              }
            }
          }

          if (clientId.isNotEmpty) {
            contactsMap[clientId] = ChatContact(
              userId: clientId,
              userName: clientName,
              lastMessage: lastMessage['message'] as String? ?? '',
              lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
                lastMessage['timestamp'] as int? ?? 0,
              ),
              unreadCount: 0,
            );
          }
        });

        final contacts = contactsMap.values.toList()
          ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

        if (mounted) {
          setState(() {
            _contacts = contacts;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _contacts = [];
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: !_isFirebaseAvailable
          ? _buildFirebaseNotAvailable()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _contacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return _buildContactCard(contact);
                      },
                    ),
    );
  }

  Widget _buildFirebaseNotAvailable() {
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
              'Firebase Chat Belum Dikonfigurasi',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Lihat FIREBASE_SETUP.md untuk petunjuk konfigurasi.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
            'Belum ada percakapan',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Client belum memulai chat',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ChatContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          contact.userName,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              contact.lastMessage,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(contact.lastMessageTime),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: contact.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${contact.unreadCount}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUserId: contact.userId,
                otherUserName: contact.userName,
                isAdmin: true,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ChatContact {
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatContact({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}
