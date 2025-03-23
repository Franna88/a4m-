import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final List<String> attachments;
  final bool isImportant;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.attachments = const [],
    this.isImportant = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      attachments: List<String>.from(data['attachments'] ?? []),
      isImportant: data['isImportant'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'attachments': attachments,
      'isImportant': isImportant,
    };
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final DateTime lastMessageTimestamp;
  final String lastMessageContent;
  final String lastMessageSenderId;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessageTimestamp,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp).toDate(),
      lastMessageContent: data['lastMessageContent'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
    );
  }
}

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Send a new message
  Future<void> sendMessage({
    required String receiverId,
    required String content,
    List<String> attachments = const [],
    bool isImportant = false,
    required String senderName,
    required String senderRole,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Create or get conversation
      String conversationId = await _getOrCreateConversation(receiverId);

      // Create message
      Message message = Message(
        id: '', // Will be assigned by Firestore
        senderId: currentUserId!,
        senderName: senderName,
        senderRole: senderRole,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        attachments: attachments,
        isImportant: isImportant,
      );

      // Add message to conversation
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toFirestore());

      // Update conversation metadata
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
        'lastMessageContent': content,
        'lastMessageSenderId': currentUserId,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Get or create a conversation between current user and receiver
  Future<String> _getOrCreateConversation(String receiverId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if conversation already exists
      QuerySnapshot query = await _firestore.collection('conversations').where(
          'participants',
          arrayContainsAny: [currentUserId, receiverId]).get();

      for (var doc in query.docs) {
        List<dynamic> participants = doc['participants'];
        if (participants.contains(currentUserId) &&
            participants.contains(receiverId)) {
          return doc.id;
        }
      }

      // Create new conversation
      DocumentReference docRef =
          await _firestore.collection('conversations').add({
        'participants': [currentUserId, receiverId],
        'lastMessageTimestamp': Timestamp.now(),
        'lastMessageContent': '',
        'lastMessageSenderId': '',
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      rethrow;
    }
  }

  // Get all conversations for current user
  Stream<List<Conversation>> getConversations() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromFirestore(doc))
          .toList();
    });
  }

  // Get messages for a specific conversation
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Mark message as read
  Future<void> markMessageAsRead(
      String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      rethrow;
    }
  }

  // Mark message as important
  Future<void> toggleMessageImportance(
      String conversationId, String messageId, bool isImportant) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isImportant': isImportant});
    } catch (e) {
      debugPrint('Error toggling message importance: $e');
      rethrow;
    }
  }

  // Get all messages marked as important
  Stream<List<Message>> getImportantMessages() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collectionGroup('messages')
        .where('isImportant', isEqualTo: true)
        .where(Filter.or(
          Filter('senderId', isEqualTo: currentUserId),
          Filter('receiverId', isEqualTo: currentUserId),
        ))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Get users based on role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'profileImage': data['profileImage'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting users by role: $e');
      return [];
    }
  }

  // Get facilitator students
  Future<List<Map<String, dynamic>>> getFacilitatorStudents(
      String facilitatorId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(facilitatorId)
          .collection('facilitatorStudents')
          .get();

      List<Map<String, dynamic>> students = [];
      for (var doc in querySnapshot.docs) {
        final studentDoc =
            await _firestore.collection('Users').doc(doc.id).get();

        if (studentDoc.exists) {
          final data = studentDoc.data() as Map<String, dynamic>;
          students.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'profileImage': data['profileImage'] ?? '',
          });
        }
      }

      return students;
    } catch (e) {
      debugPrint('Error getting facilitator students: $e');
      return [];
    }
  }

  // Get lecturer students (students in their courses)
  Future<List<Map<String, dynamic>>> getLecturerStudents(
      String lecturerId) async {
    try {
      // Get lecturer's courses
      final QuerySnapshot courseSnapshot = await _firestore
          .collection('courses')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      Set<String> uniqueStudentIds = {};

      // For each course, get students
      for (var courseDoc in courseSnapshot.docs) {
        final Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;
        final List<dynamic> students = courseData['students'] ?? [];

        for (var student in students) {
          if (student is Map && student.containsKey('studentId')) {
            uniqueStudentIds.add(student['studentId'] as String);
          }
        }
      }

      // Get student details
      List<Map<String, dynamic>> studentDetails = [];
      for (var studentId in uniqueStudentIds) {
        final studentDoc =
            await _firestore.collection('Users').doc(studentId).get();

        if (studentDoc.exists) {
          final data = studentDoc.data() as Map<String, dynamic>;
          studentDetails.add({
            'id': studentId,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'profileImage': data['profileImage'] ?? '',
          });
        }
      }

      return studentDetails;
    } catch (e) {
      debugPrint('Error getting lecturer students: $e');
      return [];
    }
  }

  // Get student's facilitator and lecturer
  Future<List<Map<String, dynamic>>> getStudentContacts(
      String studentId) async {
    try {
      final studentDoc =
          await _firestore.collection('Users').doc(studentId).get();

      if (!studentDoc.exists) {
        return [];
      }

      final data = studentDoc.data() as Map<String, dynamic>;
      List<dynamic> enrolledCourses = data['enrolledCourses'] ?? [];

      Set<String> facilitatorIds = {};
      Set<String> lecturerIds = {};

      // Get facilitators and lecturers from enrolled courses
      for (var course in enrolledCourses) {
        if (course is Map) {
          if (course.containsKey('facilitatorId')) {
            facilitatorIds.add(course['facilitatorId'] as String);
          }

          // Get course document to find lecturer
          if (course.containsKey('courseId')) {
            final courseDoc = await _firestore
                .collection('courses')
                .doc(course['courseId'] as String)
                .get();

            if (courseDoc.exists) {
              final courseData = courseDoc.data() as Map<String, dynamic>;
              if (courseData.containsKey('lecturerId')) {
                lecturerIds.add(courseData['lecturerId'] as String);
              }
            }
          }
        }
      }

      // Get admin contacts
      final admins = await getUsersByRole('admin');

      // Get user details for facilitators and lecturers
      List<Map<String, dynamic>> contacts = [];

      for (var facilitatorId in facilitatorIds) {
        final userDoc =
            await _firestore.collection('Users').doc(facilitatorId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          contacts.add({
            'id': facilitatorId,
            'name': userData['name'] ?? 'Unknown',
            'email': userData['email'] ?? '',
            'profileImage': userData['profileImage'] ?? '',
            'role': 'facilitator',
          });
        }
      }

      for (var lecturerId in lecturerIds) {
        final userDoc =
            await _firestore.collection('Users').doc(lecturerId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          contacts.add({
            'id': lecturerId,
            'name': userData['name'] ?? 'Unknown',
            'email': userData['email'] ?? '',
            'profileImage': userData['profileImage'] ?? '',
            'role': 'lecturer',
          });
        }
      }

      // Add admins to contacts
      for (var admin in admins) {
        admin['role'] = 'admin';
        contacts.add(admin);
      }

      return contacts;
    } catch (e) {
      debugPrint('Error getting student contacts: $e');
      return [];
    }
  }

  // Delete a message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }
}
