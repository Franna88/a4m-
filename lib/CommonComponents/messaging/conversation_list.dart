import 'package:a4m/CommonComponents/services/messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ConversationList extends StatefulWidget {
  final Function(String conversationId, String userId, String userName)
      onConversationSelected;
  final String currentUserId;
  final String userRole;

  const ConversationList({
    Key? key,
    required this.onConversationSelected,
    required this.currentUserId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Conversation>>(
              stream: _messagingService.getConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final conversations = snapshot.data ?? [];
                if (conversations.isEmpty) {
                  return Center(child: Text('No conversations yet'));
                }

                return FutureBuilder<List<Widget>>(
                  future: _buildConversationItems(conversations),
                  builder: (context, itemsSnapshot) {
                    if (itemsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (itemsSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${itemsSnapshot.error}'));
                    }

                    final items = itemsSnapshot.data ?? [];
                    if (items.isEmpty) {
                      return Center(child: Text('No matching conversations'));
                    }

                    return ListView(
                      children: items,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _buildConversationItems(
      List<Conversation> conversations) async {
    List<Widget> items = [];

    for (var conversation in conversations) {
      // Get the other participant's ID
      final otherUserId = conversation.participants
          .firstWhere((id) => id != widget.currentUserId, orElse: () => '');

      if (otherUserId.isEmpty) continue;

      // Get user details from Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(otherUserId)
            .get();

        if (!userDoc.exists) continue;

        final userData = userDoc.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? 'Unknown';
        final userRole = userData['role'] ?? '';
        final profileImage = userData['profileImage'] ?? '';

        // Skip if it doesn't match search query
        if (_searchQuery.isNotEmpty &&
            !userName.toLowerCase().contains(_searchQuery) &&
            !conversation.lastMessageContent
                .toLowerCase()
                .contains(_searchQuery)) {
          continue;
        }

        items.add(
          ConversationItem(
            userName: userName,
            userRole: userRole,
            lastMessage: conversation.lastMessageContent,
            timestamp: conversation.lastMessageTimestamp,
            isUnread: conversation.lastMessageSenderId != widget.currentUserId,
            profileImage: profileImage,
            onTap: () {
              widget.onConversationSelected(
                  conversation.id, otherUserId, userName);
            },
          ),
        );
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }

    return items;
  }
}

class ConversationItem extends StatelessWidget {
  final String userName;
  final String userRole;
  final String lastMessage;
  final DateTime timestamp;
  final bool isUnread;
  final String profileImage;
  final VoidCallback onTap;

  const ConversationItem({
    Key? key,
    required this.userName,
    required this.userRole,
    required this.lastMessage,
    required this.timestamp,
    required this.isUnread,
    required this.profileImage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage:
            profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
        child: profileImage.isEmpty
            ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(
        userName,
        style: GoogleFonts.montserrat(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage.isEmpty ? 'Start a conversation' : lastMessage,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          color: isUnread ? Colors.black87 : Colors.grey,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: isUnread ? Colors.black87 : Colors.grey,
            ),
          ),
          if (isUnread)
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE').format(timestamp); // Day of week
    } else {
      return DateFormat('MMM d').format(timestamp); // Month and day
    }
  }
}
