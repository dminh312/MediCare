import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/logic/models/chat_message.dart';

class LiveChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of messages for the current user
  Stream<List<ChatMessage>> getMessagesStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('support_chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  // Send a message to the support chat
  Future<void> sendMessage(String text) async {
    final userId = currentUserId;
    if (userId == null || text.trim().isEmpty) return;

    final messageRef = _firestore
        .collection('support_chats')
        .doc(userId)
        .collection('messages')
        .doc();

    final chatMessage = ChatMessage(
      id: messageRef.id,
      senderId: userId,
      text: text.trim(),
      timestamp: DateTime.now(),
      isSupport: false,
    );

    // Write message
    await messageRef.set(chatMessage.toFirestore());

    // Update the parent document with last message info for admin view
    await _firestore.collection('support_chats').doc(userId).set({
      'lastMessage': chatMessage.text,
      'lastUpdated': chatMessage.timestamp,
      'userId': userId,
      'userEmail': _auth.currentUser?.email,
      'userName': _auth.currentUser?.displayName,
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }
}
