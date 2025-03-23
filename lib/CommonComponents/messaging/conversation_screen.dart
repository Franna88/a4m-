import 'package:a4m/CommonComponents/services/messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;
  final String currentUserId;
  final String currentUserName;
  final String currentUserRole;

  const ConversationScreen({
    Key? key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isImportantFilter = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      await _messagingService.sendMessage(
        receiverId: widget.receiverId,
        content: messageText,
        senderName: widget.currentUserName,
        senderRole: widget.currentUserRole,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _toggleImportance(String messageId, bool currentValue) async {
    try {
      await _messagingService.toggleMessageImportance(
        widget.conversationId,
        messageId,
        !currentValue,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking message: $e')),
      );
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      await _messagingService.deleteMessage(
        widget.conversationId,
        messageId,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          // Message header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(widget.receiverName.isNotEmpty
                      ? widget.receiverName[0].toUpperCase()
                      : '?'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.receiverName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isImportantFilter ? Icons.star : Icons.star_border,
                    color: _isImportantFilter ? Colors.amber : null,
                  ),
                  tooltip: 'Show important messages only',
                  onPressed: () {
                    setState(() {
                      _isImportantFilter = !_isImportantFilter;
                    });
                  },
                ),
              ],
            ),
          ),

          // Message list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _isImportantFilter
                  ? _messagingService.getImportantMessages()
                  : _messagingService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                // Filter messages if important filter is on
                List<Message> displayedMessages = _isImportantFilter
                    ? messages
                        .where((msg) =>
                            (msg.senderId == widget.currentUserId &&
                                msg.receiverId == widget.receiverId) ||
                            (msg.senderId == widget.receiverId &&
                                msg.receiverId == widget.currentUserId))
                        .toList()
                    : messages;

                if (displayedMessages.isEmpty) {
                  return Center(
                    child: Text(
                      _isImportantFilter
                          ? 'No important messages'
                          : 'Start a conversation with ${widget.receiverName}',
                    ),
                  );
                }

                // Group messages by date
                Map<String, List<Message>> groupedMessages = {};
                for (var message in displayedMessages) {
                  final dateString =
                      DateFormat('yyyy-MM-dd').format(message.timestamp);
                  groupedMessages.putIfAbsent(dateString, () => []);
                  groupedMessages[dateString]!.add(message);
                }

                List<Widget> dateGroups = [];
                groupedMessages.forEach((date, messages) {
                  dateGroups.add(
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatDateHeader(DateTime.parse(date)),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );

                  for (var message in messages) {
                    dateGroups.add(
                      MessageBubble(
                        message: message,
                        isFromCurrentUser:
                            message.senderId == widget.currentUserId,
                        onToggleImportant: () => _toggleImportance(
                          message.id,
                          message.isImportant,
                        ),
                        onDelete: () => _deleteMessage(message.id),
                      ),
                    );
                  }
                });

                return ListView(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  children: dateGroups.reversed.toList(),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    // Implement file attachment
                  },
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    // Implement image attachment
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFromCurrentUser;
  final VoidCallback onToggleImportant;
  final VoidCallback onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isFromCurrentUser,
    required this.onToggleImportant,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: isFromCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Material(
                borderRadius: BorderRadius.circular(12),
                color: isFromCurrentUser ? Colors.blue : Colors.white,
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onLongPress: () {
                    _showMessageOptions(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isFromCurrentUser)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              message.senderName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isFromCurrentUser
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        Text(
                          message.content,
                          style: TextStyle(
                            color:
                                isFromCurrentUser ? Colors.white : Colors.black,
                          ),
                        ),
                        if (message.isImportant)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.star,
                              size: 12,
                              color: isFromCurrentUser
                                  ? Colors.white70
                                  : Colors.amber,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    if (isFromCurrentUser && message.isRead)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.check_circle,
                          size: 10,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                message.isImportant ? Icons.star : Icons.star_border,
                color: message.isImportant ? Colors.amber : null,
              ),
              title: Text(
                message.isImportant
                    ? 'Remove from Important'
                    : 'Mark as Important',
              ),
              onTap: () {
                Navigator.pop(context);
                onToggleImportant();
              },
            ),
            if (isFromCurrentUser)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Message'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }
}
