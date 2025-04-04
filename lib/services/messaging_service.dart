import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Validate and normalize user role
  String normalizeUserRole(String role) {
    final validRoles = {
      'student': 'student',
      'lecturer': 'lecturer',
      'content_dev': 'content_dev',
      'contentDev': 'content_dev',
      'facilitator': 'facilitator',
      'admin': 'admin',
    };

    final normalized = validRoles[role.toLowerCase()];
    if (normalized == null) {
      throw ArgumentError('Invalid user role: $role');
    }
    return normalized;
  }

  // Check if communication is allowed between roles
  bool canCommunicate(String role1, String role2) {
    final allowedCommunication = {
      'student': ['lecturer', 'admin'],
      'lecturer': ['student', 'lecturer', 'admin', 'facilitator'],
      'content_dev': ['admin'],
      'admin': ['student', 'lecturer', 'content_dev', 'facilitator', 'admin'],
      'facilitator': ['lecturer', 'facilitator', 'admin'],
    };

    final normalized1 = normalizeUserRole(role1);
    final normalized2 = normalizeUserRole(role2);

    if (kDebugMode) {
      print('Checking communication between roles:');
      print('Role 1: $normalized1');
      print('Role 2: $normalized2');
      print(
          'Allowed roles for $normalized1: ${allowedCommunication[normalized1]}');
    }

    // Special case: lecturers can communicate with each other
    if (normalized1 == 'lecturer' && normalized2 == 'lecturer') {
      return true;
    }

    // Special case: admins can communicate with each other
    if (normalized1 == 'admin' && normalized2 == 'admin') {
      return true;
    }

    final allowed = allowedCommunication[normalized1] ?? [];
    return allowed.contains(normalized2);
  }

  // Create a new chat with enhanced metadata
  Future<void> createChat({
    required String senderId,
    required String receiverId,
    required String senderType,
    required String receiverType,
    String? courseId,
    String? courseTitle,
  }) async {
    try {
      // Debug print input values
      if (kDebugMode) {
        print('Creating chat with:');
        print('senderId: "$senderId"');
        print('receiverId: "$receiverId"');
        print('senderType: "$senderType"');
        print('receiverType: "$receiverType"');
      }

      // Input validation with detailed errors
      if (senderId.trim().isEmpty) {
        throw ArgumentError('Sender ID cannot be empty');
      }
      if (receiverId.trim().isEmpty) {
        throw ArgumentError('Receiver ID cannot be empty');
      }
      if (senderType.trim().isEmpty) {
        throw ArgumentError('Sender type cannot be empty');
      }
      if (receiverType.trim().isEmpty) {
        throw ArgumentError('Receiver type cannot be empty');
      }
      if (senderId == receiverId) {
        throw ArgumentError('Cannot create chat with yourself');
      }

      // Normalize roles and validate them
      String normalizedSenderType;
      String normalizedReceiverType;
      try {
        normalizedSenderType = normalizeUserRole(senderType);
        normalizedReceiverType = normalizeUserRole(receiverType);

        if (kDebugMode) {
          print('Normalized roles:');
          print('Sender: $senderType -> $normalizedSenderType');
          print('Receiver: $receiverType -> $normalizedReceiverType');
        }
      } catch (e) {
        throw ArgumentError('Role normalization failed: $e');
      }

      // Check if chat already exists
      final List<String> sortedIds = [senderId, receiverId]..sort();
      final chatId = sortedIds.join('_');
      final existingChat =
          await _firestore.collection('chats').doc(chatId).get();

      if (existingChat.exists) {
        if (kDebugMode) {
          print('Chat already exists with ID: $chatId');
        }
        return;
      }

      // Verify users exist in Firestore and are different users
      final senderDoc =
          await _firestore.collection('Users').doc(senderId).get();
      final receiverDoc =
          await _firestore.collection('Users').doc(receiverId).get();

      if (!senderDoc.exists) {
        throw ArgumentError('Sender user does not exist: $senderId');
      }
      if (!receiverDoc.exists) {
        throw ArgumentError('Receiver user does not exist: $receiverId');
      }
      if (senderDoc.id == receiverDoc.id) {
        throw ArgumentError('Cannot create chat with yourself');
      }

      // Debug print user data
      if (kDebugMode) {
        print('Sender data: ${senderDoc.data()}');
        print('Receiver data: ${receiverDoc.data()}');
      }

      // Check if communication is allowed
      if (!canCommunicate(normalizedSenderType, normalizedReceiverType)) {
        throw ArgumentError(
            'Communication not allowed between $normalizedSenderType and $normalizedReceiverType');
      }

      // Create participant types map with validation
      final participantTypes = {
        senderId: normalizedSenderType,
        receiverId: normalizedReceiverType,
      };

      // Validate participant types map
      if (participantTypes.isEmpty ||
          participantTypes.values.any((type) => type.isEmpty)) {
        if (kDebugMode) {
          print('Invalid participant types:');
          print(participantTypes);
        }
        throw ArgumentError('Invalid participant types: $participantTypes');
      }

      final chatData = {
        'participants': sortedIds,
        'participantTypes': participantTypes,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'courseContext': courseId != null
            ? {
                'courseId': courseId,
                'courseTitle': courseTitle ?? '',
              }
            : null,
      };

      // Debug logging
      if (kDebugMode) {
        print('Creating chat document with data:');
        print(chatData);
      }

      await _firestore.collection('chats').doc(chatId).set(chatData);

      if (kDebugMode) {
        print('Chat created successfully with ID: $chatId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat: $e');
      }
      rethrow;
    }
  }

  // Enhanced chat existence check
  Future<bool> chatExists(String senderId, String receiverId) async {
    final List<String> sortedIds = [senderId, receiverId]..sort();
    final chatId = sortedIds.join('_');
    final doc = await _firestore.collection('chats').doc(chatId).get();
    return doc.exists;
  }

  // Enhanced message sending with metadata
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
    String? attachmentUrl,
    String? courseId,
    String? moduleId,
    Map<String, dynamic>? metadata,
  }) async {
    final messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    final messageData = {
      'senderId': senderId,
      'message': message,
      'attachmentUrl': attachmentUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      if (courseId != null) 'courseId': courseId,
      if (moduleId != null) 'moduleId': moduleId,
      if (metadata != null) 'metadata': metadata,
    };

    await messageRef.set(messageData);

    // Get the chat document to find participants
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();

    if (chatData != null) {
      // Only increment unreadCount if the message is sent to another user
      final List<dynamic> participants = chatData['participants'] ?? [];
      final otherParticipants =
          participants.where((id) => id != senderId).toList();

      // Update chat metadata
      final updateData = {
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        if (courseId != null) 'lastCourseId': courseId,
        if (moduleId != null) 'lastModuleId': moduleId,
      };

      // Only increment unread count if there are other participants
      if (otherParticipants.isNotEmpty) {
        updateData['unreadCount'] = FieldValue.increment(1);
      }

      await _firestore.collection('chats').doc(chatId).update(updateData);
    }
  }

  // Get chat messages with enhanced query options
  Stream<QuerySnapshot> getChatMessages(
    String chatId, {
    String? courseId,
    bool onlyCourseRelated = false,
  }) {
    var query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (onlyCourseRelated) {
      query = query.where('courseId', isNull: false);
    }
    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.snapshots();
  }

  // Get user's chats with enhanced filtering
  Stream<QuerySnapshot> getUserChats(
    String userId, {
    String? userType,
    bool onlyUnread = false,
    String? courseId,
  }) {
    var query = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true);

    if (onlyUnread) {
      query = query.where('unreadCount', isGreaterThan: 0);
    }
    if (courseId != null) {
      query = query.where('lastCourseId', isEqualTo: courseId);
    }

    return query.snapshots();
  }

  // Get user details with role-specific data
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    if (userId.isEmpty) {
      return null;
    }

    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (!doc.exists) {
        print('User document does not exist for ID: $userId');
        return {
          'name': 'Unknown User',
          'userType': 'unknown',
          'profileImageUrl': '',
        };
      }

      // Return the complete user data
      return doc.data();
    } catch (e) {
      print('Error fetching user details: $e');
      return {
        'name': 'Error Loading User',
        'userType': 'unknown',
        'profileImageUrl': '',
      };
    }
  }

  // Get typing status
  Stream<bool> getTypingStatus(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.data()?['isTyping'] ?? false);
  }

  // Update typing status
  Future<void> updateTypingStatus(String chatId, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isTyping': isTyping,
      'typingUserId': isTyping ? currentUserId : null,
    });
  }

  // Mark chat as read with enhanced metadata
  Future<void> markChatAsRead(String chatId) async {
    // First check if there are any unread messages
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final unreadCount = chatDoc.data()?['unreadCount'] ?? 0;

    // Only perform the update if there are unread messages
    if (unreadCount > 0) {
      final batch = _firestore.batch();

      // Reset unread count
      batch.update(_firestore.collection('chats').doc(chatId), {
        'unreadCount': 0,
        'lastReadTime': FieldValue.serverTimestamp(),
        'lastReadBy': currentUserId,
      });

      // Mark all messages as read
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId',
              isNotEqualTo: currentUserId) // Only mark others' messages as read
          .get();

      for (var doc in messages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
          'readBy': currentUserId,
        });
      }

      await batch.commit();
    }
  }

  // Get course-specific chat history
  Stream<QuerySnapshot> getCourseChats(String courseId) {
    return _firestore
        .collection('chats')
        .where('courseContext.courseId', isEqualTo: courseId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Get unread messages count for a user
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + ((doc.data())['unreadCount'] as int? ?? 0),
      );
    });
  }

  // Selected chat information
  String? _selectedChatId;
  String? _selectedOtherUserId;
  String? _selectedOtherUserName;
  String? _selectedOtherUserImage;
  String? _selectedUserType;

  // Getters for selected chat information
  String? get selectedChatId => _selectedChatId;
  String? get selectedOtherUserId => _selectedOtherUserId;
  String? get selectedOtherUserName => _selectedOtherUserName;
  String? get selectedOtherUserImage => _selectedOtherUserImage;
  String? get selectedUserType => _selectedUserType;

  // Set selected chat information
  Future<void> setSelectedChat({
    required String chatId,
    required String otherUserId,
    required String otherUserName,
    required String otherUserImage,
    required String userType,
  }) async {
    _selectedChatId = chatId;
    _selectedOtherUserId = otherUserId;
    _selectedOtherUserName = otherUserName;
    _selectedOtherUserImage = otherUserImage;
    _selectedUserType = userType;

    // Notify listeners if you implement ChangeNotifier
    // notifyListeners();
  }

  // Clear selected chat
  void clearSelectedChat() {
    _selectedChatId = null;
    _selectedOtherUserId = null;
    _selectedOtherUserName = null;
    _selectedOtherUserImage = null;
    _selectedUserType = null;

    // Notify listeners if you implement ChangeNotifier
    // notifyListeners();
  }
}
