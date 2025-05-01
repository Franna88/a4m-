import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import '../../../../../services/messaging_service.dart';
import '../../../../myutility.dart';
import '../../../../Themes/Constants/myColors.dart';

class AdminInbox extends StatefulWidget {
  final String currentUserId;
  final MessagingService messagingService;
  final String? selectedUserName;
  final String? selectedUserId;
  final String? selectedUserType;

  const AdminInbox({
    super.key,
    required this.currentUserId,
    required this.messagingService,
    this.selectedUserName,
    this.selectedUserId,
    this.selectedUserType,
  });

  @override
  State<AdminInbox> createState() => _AdminInboxState();
}

class _AdminInboxState extends State<AdminInbox> {
  String? _currentChatId;
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedUserId != null && widget.selectedUserType != null) {
      _initializeChat();
    }
  }

  @override
  void didUpdateWidget(AdminInbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUserId != oldWidget.selectedUserId &&
        widget.selectedUserId != null &&
        widget.selectedUserType != null) {
      _initializeChat();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (widget.selectedUserId == null || widget.selectedUserId!.isEmpty) {
        throw ArgumentError('Please select a user to chat with first');
      }

      if (widget.selectedUserType == null || widget.selectedUserType!.isEmpty) {
        throw ArgumentError('Selected user type is not specified');
      }

      print('Initializing chat with:');
      print('Selected User ID: ${widget.selectedUserId}');
      print('Selected User Type: ${widget.selectedUserType}');
      print('Current User Role: admin');

      // Sort IDs to ensure consistent chat ID creation
      final sortedIds = [widget.currentUserId, widget.selectedUserId!]..sort();
      final chatId = '${sortedIds[0]}_${sortedIds[1]}';

      await widget.messagingService.createChat(
        senderId: widget.currentUserId,
        receiverId: widget.selectedUserId!,
        senderType: 'admin',
        receiverType: widget.selectedUserType!,
      );

      setState(() {
        _currentChatId = chatId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error initializing chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentChatId == null) {
      return;
    }

    try {
      await widget.messagingService.sendMessage(
        chatId: _currentChatId!,
        senderId: widget.currentUserId,
        message: _messageController.text.trim(),
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for fixed calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Fixed width for the chat list
    const double chatListWidth = 280;

    // Calculate the height for the container
    final containerHeight = screenHeight - 110;

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
        height: containerHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE: Chat list with fixed width
            Container(
              width: chatListWidth,
              height: containerHeight,
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
                  // Compact header
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
                      "Active Chats",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Optimized chat list
                  Expanded(
                    child: _buildChatList(),
                  ),
                ],
              ),
            ),
            // RIGHT SIDE: Messages area with remaining width
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Compact header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: _currentChatId == null
                          ? Colors.grey[100]
                          : Mycolors().darkTeal,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      _currentChatId == null
                          ? "Select a chat to start messaging"
                          : widget.selectedUserName ?? "Chat",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _currentChatId == null
                            ? Colors.grey[600]
                            : Colors.white,
                      ),
                    ),
                  ),

                  // Messages area
                  Expanded(
                    child: Container(
                      color: Colors.grey[50],
                      child: _currentChatId == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No chat selected",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _buildMessagesArea(),
                    ),
                  ),

                  // Input area
                  if (_currentChatId != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
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

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.messagingService.getUserChats(widget.currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error loading chats"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data?.docs ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 32, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    "No active chats",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index].data() as Map<String, dynamic>;
            final chatId = chats[index].id;
            final participants = chat['participants'] as List<dynamic>;
            final lastMessageTime = chat['lastMessageTime'] as Timestamp?;
            final unreadCount = chat['unreadCount'] ?? 0;
            final lastMessage = chat['lastMessage'];

            // Skip if there's no last message (empty chat)
            if (lastMessage == null || lastMessage.isEmpty) {
              return const SizedBox.shrink();
            }

            final otherUserId = participants.firstWhere(
              (id) => id != widget.currentUserId,
              orElse: () => '',
            );

            // Skip if the other user ID is the current user
            if (otherUserId == widget.currentUserId || otherUserId.isEmpty) {
              return const SizedBox.shrink();
            }

            return FutureBuilder<Map<String, dynamic>?>(
              future: widget.messagingService.getUserDetails(otherUserId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final userData = userSnapshot.data!;
                final userName = userData['name'] ?? 'Unknown User';
                final userType = userData['userType'] ?? 'student';
                final userStatus = userData['status'] ?? 'offline';
                final profileImage = userData['profileImageUrl'];

                return _buildChatItem(
                  chatId: chatId,
                  userName: userName,
                  userRole: userType,
                  lastMessage: lastMessage,
                  lastMessageTime: lastMessageTime,
                  unreadCount: unreadCount,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatItem({
    required String chatId,
    required String userName,
    required String userRole,
    required String lastMessage,
    required Timestamp? lastMessageTime,
    required int unreadCount,
  }) {
    final isSelected = _currentChatId == chatId;
    final formattedTime = lastMessageTime != null
        ? DateFormat('HH:mm').format(lastMessageTime.toDate())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentChatId = chatId;
              widget.messagingService.markChatAsRead(chatId);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Mycolors().darkTeal : Colors.white,
              border: Border.all(
                color: isSelected ? Mycolors().darkTeal : Colors.grey[300]!,
                width: 1,
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
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              userName,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "[${userRole.toUpperCase()}]",
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.white : Mycolors().darkTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color:
                                isSelected ? Mycolors().darkTeal : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: isSelected ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesArea() {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.messagingService.getChatMessages(_currentChatId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error in message stream: ${snapshot.error}");
          return Center(
              child: Text("Error loading messages: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isNotEmpty) {
          widget.messagingService.markChatAsRead(_currentChatId!);
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No messages yet",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Start the conversation",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index].data() as Map<String, dynamic>;
              final isMe = message['senderId'] == widget.currentUserId;
              final messageText = message['message'] ?? '';
              final timestamp = message['timestamp'] as Timestamp?;

              return SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: (MediaQuery.of(context).size.width - 500)
                              .clamp(300.0, 500.0),
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Mycolors().darkTeal : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          messageText,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (timestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 12),
                        child: Text(
                          _formatMessageTime(timestamp),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatMessageTime(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();

    if (now.day == date.day &&
        now.month == date.month &&
        now.year == date.year) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
