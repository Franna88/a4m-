import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      'admin': ['student', 'lecturer', 'content_dev', 'facilitator'],
      'facilitator': ['lecturer', 'facilitator', 'admin'],
    };

    final normalized1 = normalizeUserRole(role1);
    final normalized2 = normalizeUserRole(role2);

    final allowed = allowedCommunication[normalized1] ?? [];
    return allowed.contains(normalized2);
  }

  // Create a new chat with validation
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
        throw ArgumentError('Cannot create chat with self');
      }

      // Normalize roles and validate them
      String normalizedSenderType;
      String normalizedReceiverType;
      try {
        normalizedSenderType = normalizeUserRole(senderType);
        normalizedReceiverType = normalizeUserRole(receiverType);
      } catch (e) {
        throw ArgumentError('Role normalization failed: $e');
      }

      // Verify users exist in Firestore
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

      // Check if communication is allowed
      if (!canCommunicate(normalizedSenderType, normalizedReceiverType)) {
        throw ArgumentError(
            'Communication not allowed between $normalizedSenderType and $normalizedReceiverType');
      }

      // Create chat ID
      final List<String> sortedIds = [senderId, receiverId]..sort();
      final chatId = sortedIds.join('_');

      // Create participant types map with validation
      final participantTypes = {
        senderId: normalizedSenderType,
        receiverId: normalizedReceiverType,
      };

      // Validate participant types map
      if (participantTypes.isEmpty ||
          participantTypes.values.any((type) => type.isEmpty)) {
        throw ArgumentError('Invalid participant types: $participantTypes');
      }

      // Prepare chat data
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

      // Create the chat document
      await _firestore.collection('chats').doc(chatId).set(chatData);

      if (kDebugMode) {
        print('Chat created successfully with ID: $chatId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat: $e');
      }
      rethrow; // Rethrow to handle in UI
    }
  }

  // Get available users for chat
  Stream<QuerySnapshot> getAvailableUsers(
      String currentUserId, String userRole) {
    try {
      if (currentUserId.trim().isEmpty) {
        throw ArgumentError('Current user ID cannot be empty');
      }

      final normalizedRole = normalizeUserRole(userRole);
      return _firestore
          .collection('Users')
          .where('userType', isEqualTo: normalizedRole)
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .snapshots();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available users: $e');
      }
      rethrow;
    }
  }

  // Check if chat exists
  Future<bool> chatExists(String user1Id, String user2Id) async {
    try {
      if (user1Id.trim().isEmpty || user2Id.trim().isEmpty) {
        return false;
      }

      final List<String> sortedIds = [user1Id, user2Id]..sort();
      final chatId = sortedIds.join('_');
      final doc = await _firestore.collection('chats').doc(chatId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking chat existence: $e');
      }
      return false;
    }
  }
}
