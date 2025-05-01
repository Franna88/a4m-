import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintsSuggestionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Add a new complaint
  Future<void> addComplaint({
    required String title,
    required String description,
    required String type,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('Users').doc(user.uid).get();
    if (!userDoc.exists) throw Exception('User data not found');

    final userData = userDoc.data() as Map<String, dynamic>;

    await _firestore.collection('complaints').add({
      'title': title,
      'description': description,
      'type': type,
      'submitterId': user.uid,
      'submitterName': userData['name'] ?? 'Unknown',
      'submitterRole': userData['userType'] ?? 'unknown',
      'status': 'pending',
      'isImportant': false,
      'dateAdded': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Add a new suggestion
  Future<void> addSuggestion({
    required String title,
    required String description,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('Users').doc(user.uid).get();
    if (!userDoc.exists) throw Exception('User data not found');

    final userData = userDoc.data() as Map<String, dynamic>;

    await _firestore.collection('suggestions').add({
      'title': title,
      'description': description,
      'category': category,
      'submitterId': user.uid,
      'submitterName': userData['name'] ?? 'Unknown',
      'submitterRole': userData['userType'] ?? 'unknown',
      'status': 'pending',
      'isImportant': false,
      'dateAdded': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Report a chat
  Future<void> reportChat({
    required String chatId,
    required String reason,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('Users').doc(user.uid).get();
    if (!userDoc.exists) throw Exception('User data not found');

    final userData = userDoc.data() as Map<String, dynamic>;

    await _firestore.collection('chatReports').add({
      'chatId': chatId,
      'reason': reason,
      'description': description,
      'reporterId': user.uid,
      'reporterName': userData['name'] ?? 'Unknown',
      'reporterRole': userData['userType'] ?? 'unknown',
      'status': 'pending',
      'isImportant': false,
      'dateAdded': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get complaints stream
  Stream<QuerySnapshot> getComplaints({bool importantOnly = false}) {
    Query query = _firestore.collection('complaints');
    if (importantOnly) {
      query = query.where('isImportant', isEqualTo: true);
    }
    return query.orderBy('dateAdded', descending: true).snapshots();
  }

  // Get suggestions stream
  Stream<QuerySnapshot> getSuggestions({bool importantOnly = false}) {
    Query query = _firestore.collection('suggestions');
    if (importantOnly) {
      query = query.where('isImportant', isEqualTo: true);
    }
    return query.orderBy('dateAdded', descending: true).snapshots();
  }

  // Get chat reports stream
  Stream<QuerySnapshot> getChatReports({bool importantOnly = false}) {
    Query query = _firestore.collection('chatReports');
    if (importantOnly) {
      query = query.where('isImportant', isEqualTo: true);
    }
    return query.orderBy('dateAdded', descending: true).snapshots();
  }

  // Get user's complaints stream
  Stream<QuerySnapshot> getUserComplaints() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('complaints')
        .where('submitterId', isEqualTo: user.uid)
        .orderBy('dateAdded', descending: true)
        .snapshots();
  }

  // Get user's suggestions stream
  Stream<QuerySnapshot> getUserSuggestions() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('suggestions')
        .where('submitterId', isEqualTo: user.uid)
        .orderBy('dateAdded', descending: true)
        .snapshots();
  }

  // Mark complaint as important
  Future<void> markComplaintAsImportant(String complaintId) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'isImportant': true,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Mark suggestion as important
  Future<void> markSuggestionAsImportant(String suggestionId) async {
    await _firestore.collection('suggestions').doc(suggestionId).update({
      'isImportant': true,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Mark chat report as important
  Future<void> markChatReportAsImportant(String reportId) async {
    await _firestore.collection('chatReports').doc(reportId).update({
      'isImportant': true,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Add admin response to complaint
  Future<void> addAdminResponseToComplaint(
      String complaintId, String response) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'adminResponse': response,
      'status': 'resolved',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Add admin response to suggestion
  Future<void> addAdminResponseToSuggestion(
      String suggestionId, String response) async {
    await _firestore.collection('suggestions').doc(suggestionId).update({
      'adminResponse': response,
      'status': 'resolved',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Add admin response to chat report
  Future<void> addAdminResponseToChatReport(
      String reportId, String response) async {
    await _firestore.collection('chatReports').doc(reportId).update({
      'adminResponse': response,
      'status': 'resolved',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get course reviews stream
  Stream<QuerySnapshot> getCourseReviews({bool importantOnly = false}) {
    Query query = _firestore.collection('courseReviews');
    if (importantOnly) {
      query = query.where('isImportant', isEqualTo: true);
    }
    return query.orderBy('dateAdded', descending: true).snapshots();
  }

  // Mark course review as important
  Future<void> markCourseReviewAsImportant(String reviewId) async {
    await _firestore.collection('courseReviews').doc(reviewId).update({
      'isImportant': true,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Add admin response to course review
  Future<void> addAdminResponseToCourseReview(
      String reviewId, String response) async {
    await _firestore.collection('courseReviews').doc(reviewId).update({
      'adminResponse': response,
      'status': 'resolved',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get course average rating
  Future<double> getCourseAverageRating(String courseId) async {
    final reviews = await _firestore
        .collection('courseReviews')
        .where('courseId', isEqualTo: courseId)
        .where('status', isEqualTo: 'resolved')
        .get();

    if (reviews.docs.isEmpty) return 0.0;

    double totalRating = 0;
    for (var doc in reviews.docs) {
      final data = doc.data();
      totalRating += (data['courseRating'] as num).toDouble();
    }

    return totalRating / reviews.docs.length;
  }

  // Get lecturer average rating
  Future<double> getLecturerAverageRating(String lecturerId) async {
    final reviews = await _firestore
        .collection('courseReviews')
        .where('lecturerId', isEqualTo: lecturerId)
        .where('status', isEqualTo: 'resolved')
        .get();

    if (reviews.docs.isEmpty) return 0.0;

    double totalRating = 0;
    for (var doc in reviews.docs) {
      final data = doc.data();
      totalRating += (data['lecturerRating'] as num).toDouble();
    }

    return totalRating / reviews.docs.length;
  }

  // Get lecturer reviews
  Stream<QuerySnapshot> getLecturerReviews() {
    return _firestore
        .collection('lecturerReviews')
        .orderBy('dateAdded', descending: true)
        .snapshots();
  }

  // Add admin response to lecturer review
  Future<void> addAdminResponseToReview(
      String reviewId, String response) async {
    await _firestore.collection('lecturerReviews').doc(reviewId).update({
      'adminResponse': response,
      'status': 'resolved',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get lecturer average ratings
  Future<Map<String, double>> getLecturerRatings(String lecturerId) async {
    final reviews = await _firestore
        .collection('lecturerReviews')
        .where('lecturerId', isEqualTo: lecturerId)
        .where('status', isEqualTo: 'resolved')
        .get();

    if (reviews.docs.isEmpty) {
      return {
        'overall': 0.0,
        'teaching': 0.0,
        'communication': 0.0,
        'support': 0.0,
      };
    }

    double overallTotal = 0;
    double teachingTotal = 0;
    double communicationTotal = 0;
    double supportTotal = 0;
    int count = reviews.docs.length;

    for (var doc in reviews.docs) {
      final data = doc.data();
      overallTotal += (data['rating'] as num).toDouble();
      teachingTotal += (data['teachingRating'] as num).toDouble();
      communicationTotal += (data['communicationRating'] as num).toDouble();
      supportTotal += (data['supportRating'] as num).toDouble();
    }

    return {
      'overall': overallTotal / count,
      'teaching': teachingTotal / count,
      'communication': communicationTotal / count,
      'support': supportTotal / count,
    };
  }

  Future<void> markEvaluationAsResolved(String evaluationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('course_evaluations')
          .doc(evaluationId)
          .update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking evaluation as resolved: $e');
      rethrow;
    }
  }
}
