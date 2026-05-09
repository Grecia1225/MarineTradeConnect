import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String   id;
  final List<String> participants;
  final String   lastMessage;
  final DateTime lastUpdated;
  final String   listingId;
  final String   listingTitle;

  const ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
    this.listingId    = '',
    this.listingTitle = '',
  });

  factory ChatModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id:           doc.id,
      participants: List<String>.from(d['participants'] ?? []),
      lastMessage:  d['lastMessage']  ?? '',
      lastUpdated:  (d['lastUpdated'] as Timestamp?)?.toDate()
                        ?? DateTime.now(),
      listingId:    d['listingId']    ?? '',
      listingTitle: d['listingTitle'] ?? '',
    );
  }
}