import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleMessagingPage extends StatefulWidget {
  final String userId;
  final String userRole;

  const SimpleMessagingPage({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<SimpleMessagingPage> createState() => _SimpleMessagingPageState();
}

class _SimpleMessagingPageState extends State<SimpleMessagingPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Mycolors().offWhite,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    label: 'Inbox',
                    isActive: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: Icons.contacts,
                    label: 'Contacts',
                    isActive: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left panel
                  Container(
                    width: 280,
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child: _selectedTab == 0
                        ? _buildInboxPanel()
                        : _buildContactsPanel(),
                  ),

                  // Right panel
                  Expanded(
                    child: Center(
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
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors().green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text('New Message'),
                          ),
                        ],
                      ),
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

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Mycolors().green : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInboxPanel() {
    // Simulated inbox data
    List<Map<String, dynamic>> conversations = [
      {
        'name': 'Admin Support',
        'lastMessage': 'How can we help you today?',
        'time': '10:30 AM',
        'unread': true,
      },
      {
        'name': 'John Doe (Student)',
        'lastMessage': 'Thank you for your help!',
        'time': 'Yesterday',
        'unread': false,
      },
      {
        'name': 'Jane Smith (Lecturer)',
        'lastMessage': 'Please review the latest course materials',
        'time': 'Jul 25',
        'unread': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Inbox',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildConversationItem(conversation);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactsPanel() {
    // Simulated contacts data
    List<Map<String, dynamic>> contacts = [
      {'name': 'Admin Support', 'role': 'Admin'},
      {'name': 'John Doe', 'role': 'Student'},
      {'name': 'Jane Smith', 'role': 'Lecturer'},
      {'name': 'Sam Brown', 'role': 'Content Developer'},
      {'name': 'Alex Johnson', 'role': 'Facilitator'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _buildContactItem(contact);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Mycolors().green,
        child: Text(
          conversation['name'][0],
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        conversation['name'],
        style: TextStyle(
          fontWeight:
              conversation['unread'] ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation['lastMessage'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation['time'],
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (conversation['unread'])
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Mycolors().green,
              ),
            ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildContactItem(Map<String, dynamic> contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Mycolors().darkGrey,
        child: Text(
          contact['name'][0],
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(contact['name']),
      subtitle: Text(contact['role']),
      trailing: IconButton(
        icon: Icon(Icons.message, color: Mycolors().green),
        onPressed: () {},
      ),
      onTap: () {},
    );
  }
}
