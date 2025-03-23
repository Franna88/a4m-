import 'package:a4m/CommonComponents/services/messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactsList extends StatefulWidget {
  final String userRole;
  final String userId;
  final Function(String userId, String userName) onContactSelected;

  const ContactsList({
    Key? key,
    required this.userRole,
    required this.userId,
    required this.onContactSelected,
  }) : super(key: key);

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> contacts = [];

      // Load contacts based on user role
      switch (widget.userRole) {
        case 'admin':
          // Admins can message everyone
          final students = await _messagingService.getUsersByRole('student');
          final lecturers = await _messagingService.getUsersByRole('lecturer');
          final facilitators =
              await _messagingService.getUsersByRole('facilitator');
          final contentDevs =
              await _messagingService.getUsersByRole('contentDev');
          final admins = await _messagingService.getUsersByRole('admin').then(
              (list) =>
                  list.where((admin) => admin['id'] != widget.userId).toList());

          contacts = [
            ...students,
            ...lecturers,
            ...facilitators,
            ...contentDevs,
            ...admins,
          ];
          break;

        case 'facilitator':
          // Facilitators can message their students, admin, and lecturers of their courses
          final students =
              await _messagingService.getFacilitatorStudents(widget.userId);
          final admins = await _messagingService.getUsersByRole('admin');

          contacts = [
            ...students,
            ...admins,
          ];

          // TODO: Add lecturers for the facilitator's courses
          break;

        case 'lecturer':
          // Lecturers can message students in their courses and admin
          final students =
              await _messagingService.getLecturerStudents(widget.userId);
          final admins = await _messagingService.getUsersByRole('admin');

          contacts = [
            ...students,
            ...admins,
          ];
          break;

        case 'student':
          // Students can message their facilitator, lecturers, and admin
          contacts = await _messagingService.getStudentContacts(widget.userId);
          break;

        case 'contentDev':
          // Content developers can message admin
          contacts = await _messagingService.getUsersByRole('admin');
          break;

        default:
          // Default: just admin contacts
          contacts = await _messagingService.getUsersByRole('admin');
      }

      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredContacts {
    if (_searchQuery.isEmpty) {
      return _contacts;
    }

    return _contacts.where((contact) {
      final name = contact['name']?.toString().toLowerCase() ?? '';
      final email = contact['email']?.toString().toLowerCase() ?? '';
      final role = contact['role']?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          role.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredContacts.isEmpty
                    ? Center(child: Text('No contacts found'))
                    : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          return ContactItem(
                            name: contact['name'] ?? 'Unknown',
                            email: contact['email'] ?? '',
                            role: contact['role'] ?? '',
                            profileImage: contact['profileImage'] ?? '',
                            onTap: () => widget.onContactSelected(
                              contact['id'],
                              contact['name'] ?? 'Unknown',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String profileImage;
  final VoidCallback onTap;

  const ContactItem({
    Key? key,
    required this.name,
    required this.email,
    required this.role,
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
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(
        name,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (email.isNotEmpty)
            Text(
              email,
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            _formatRoleName(role),
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: _getRoleColor(role),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'facilitator':
        return 'Facilitator';
      case 'lecturer':
        return 'Lecturer';
      case 'student':
        return 'Student';
      case 'contentdev':
        return 'Content Developer';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'facilitator':
        return Colors.orange;
      case 'lecturer':
        return Colors.green;
      case 'student':
        return Colors.blue;
      case 'contentdev':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
