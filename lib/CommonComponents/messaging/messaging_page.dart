import 'package:a4m/CommonComponents/messaging/contacts_list.dart';
import 'package:a4m/CommonComponents/messaging/conversation_list.dart';
import 'package:a4m/CommonComponents/messaging/conversation_screen.dart';
import 'package:a4m/CommonComponents/services/messaging_service.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MessagingView {
  conversations,
  contacts,
  chat,
}

class MessagingPage extends StatefulWidget {
  final String userId;
  final String userRole;

  const MessagingPage({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  MessagingView _currentView = MessagingView.conversations;
  String? _selectedConversationId;
  String? _selectedUserId;
  String? _selectedUserName;
  String _currentUserName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentUserName = userData['name'] ?? 'User';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToConversations() {
    setState(() {
      _currentView = MessagingView.conversations;
      _selectedConversationId = null;
      _selectedUserId = null;
      _selectedUserName = null;
    });
  }

  void _navigateToContacts() {
    setState(() {
      _currentView = MessagingView.contacts;
      _selectedConversationId = null;
      _selectedUserId = null;
      _selectedUserName = null;
    });
  }

  void _handleConversationSelected(
      String conversationId, String userId, String userName) {
    setState(() {
      _currentView = MessagingView.chat;
      _selectedConversationId = conversationId;
      _selectedUserId = userId;
      _selectedUserName = userName;
    });
  }

  void _handleContactSelected(String userId, String userName) async {
    try {
      // Create conversation if it doesn't exist
      MessagingService messagingService = MessagingService();

      // Instead of direct access to private method, use sendMessage to create conversation
      // This will automatically create the conversation if it doesn't exist
      await messagingService.sendMessage(
        receiverId: userId,
        content: "", // Empty initial message
        senderName: _currentUserName,
        senderRole: widget.userRole,
      );

      // After sending (or attempting to send) a message, query for the conversation
      final conversations = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: widget.userId)
          .get();

      String? conversationId;
      for (var doc in conversations.docs) {
        List<dynamic> participants = doc['participants'];
        if (participants.contains(userId)) {
          conversationId = doc.id;
          break;
        }
      }

      if (conversationId == null) {
        throw Exception('Failed to find or create conversation');
      }

      setState(() {
        _currentView = MessagingView.chat;
        _selectedConversationId = conversationId;
        _selectedUserId = userId;
        _selectedUserName = userName;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Container(
        color: Mycolors().offWhite,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Mycolors().darkGrey,
              child: Row(
                children: [
                  Text(
                    'Messages',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  _buildHeaderButton(
                    icon: Icons.message,
                    label: 'Conversations',
                    isActive: _currentView == MessagingView.conversations,
                    onTap: _navigateToConversations,
                  ),
                  SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: Icons.contacts,
                    label: 'Contacts',
                    isActive: _currentView == MessagingView.contacts,
                    onTap: _navigateToContacts,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .snapshots(),
                builder: (context, snapshot) {
                  // If we have an error, show error message
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Error connecting to messaging service',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check your connection and try again',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // If still loading, show loading indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // If everything is good, show the normal UI
                  return Row(
                    children: [
                      // Left panel: Conversations or Contacts list
                      _currentView == MessagingView.conversations
                          ? ConversationList(
                              onConversationSelected:
                                  _handleConversationSelected,
                              currentUserId: widget.userId,
                              userRole: widget.userRole,
                            )
                          : _currentView == MessagingView.contacts
                              ? ContactsList(
                                  userRole: widget.userRole,
                                  userId: widget.userId,
                                  onContactSelected: _handleContactSelected,
                                )
                              : SizedBox(
                                  width: 280,
                                  child: ConversationList(
                                    onConversationSelected:
                                        _handleConversationSelected,
                                    currentUserId: widget.userId,
                                    userRole: widget.userRole,
                                  ),
                                ),

                      // Right panel: Chat or empty state
                      Expanded(
                        child: _currentView == MessagingView.chat &&
                                _selectedConversationId != null &&
                                _selectedUserId != null &&
                                _selectedUserName != null
                            ? ConversationScreen(
                                conversationId: _selectedConversationId!,
                                receiverId: _selectedUserId!,
                                receiverName: _selectedUserName!,
                                currentUserId: widget.userId,
                                currentUserName: _currentUserName,
                                currentUserRole: widget.userRole,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Select a conversation to start chatting',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Mycolors().green : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
