import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/messaging_service.dart';
import '../../../Themes/Constants/myColors.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDevMessagesMain extends StatefulWidget {
  final String contentDevId;

  const ContentDevMessagesMain({
    super.key,
    required this.contentDevId,
  });

  @override
  State<ContentDevMessagesMain> createState() => _ContentDevMessagesMainState();
}

class _ContentDevMessagesMainState extends State<ContentDevMessagesMain> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedChatId;
  String? _selectedUserName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        height: MediaQuery.of(context).size.height - 110,
        width: double.infinity,
        child: Row(
          children: [
            // Chat list
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Mycolors().darkTeal,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "Messages",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Chat list
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          _messagingService.getUserChats(widget.contentDevId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error loading chats'));
                        }

                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final chats = snapshot.data!.docs;

                        if (chats.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                'No active chats\nMessages from admin will appear here',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat =
                                chats[index].data() as Map<String, dynamic>;
                            final chatId = chats[index].id;
                            final participants =
                                chat['participants'] as List<dynamic>;
                            final otherUserId = participants.firstWhere(
                              (id) => id != widget.contentDevId,
                              orElse: () => '',
                            );

                            return FutureBuilder<Map<String, dynamic>?>(
                              future:
                                  _messagingService.getUserDetails(otherUserId),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return SizedBox.shrink();
                                }

                                final otherUserData = userSnapshot.data!;
                                return _buildChatItem(
                                  chatId: chatId,
                                  chat: chat,
                                  userData: otherUserData,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Chat area
            Expanded(
              child: Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: _selectedChatId != null
                          ? Mycolors().darkTeal
                          : Colors.grey[100],
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedChatId == null
                              ? "Select a chat to start messaging"
                              : _selectedUserName ?? "Chat",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedChatId == null
                                ? Colors.grey[600]
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Messages area
                  Expanded(
                    child: _selectedChatId == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text(
                                  "Select a chat to start messaging",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : StreamBuilder<QuerySnapshot>(
                            stream: _messagingService
                                .getChatMessages(_selectedChatId!),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error loading messages'));
                              }

                              if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              final messages = snapshot.data!.docs;

                              return ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.all(15),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index].data()
                                      as Map<String, dynamic>;
                                  final isMe = message['senderId'] ==
                                      widget.contentDevId;

                                  return _buildMessageBubble(message, isMe);
                                },
                              );
                            },
                          ),
                  ),
                  // Input area
                  if (_selectedChatId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            color: Colors.grey[600],
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // Handle file attachment
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              maxLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            color: Mycolors().darkTeal,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required String chatId,
    required Map<String, dynamic> chat,
    required Map<String, dynamic> userData,
  }) {
    final userName = userData['name'] ?? 'Unknown User';
    final lastMessage = chat['lastMessage'] ?? '';
    final lastMessageTime = chat['lastMessageTime'] as Timestamp?;
    final unreadCount = chat['unreadCount'] ?? 0;
    final isSelected = chatId == _selectedChatId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedChatId = chatId;
          _selectedUserName = userName;
        });
        _messagingService.markChatAsRead(chatId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors().darkTeal : Colors.white,
          border: Border.all(
            color: isSelected ? Mycolors().darkTeal : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    userName,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Mycolors().darkTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: GoogleFonts.montserrat(
                        color: isSelected ? Mycolors().darkTeal : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (lastMessage.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                lastMessage,
                style: GoogleFonts.montserrat(
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (lastMessageTime != null) ...[
              SizedBox(height: 4),
              Text(
                _formatTime(lastMessageTime),
                style: GoogleFonts.montserrat(
                  color: isSelected ? Colors.white70 : Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Mycolors().darkTeal : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message['message'] as String,
              style: GoogleFonts.montserrat(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedChatId == null) {
      return;
    }

    _messagingService.sendMessage(
      chatId: _selectedChatId!,
      senderId: widget.contentDevId,
      message: _messageController.text.trim(),
    );

    _messageController.clear();
  }

  String _formatTime(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
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
