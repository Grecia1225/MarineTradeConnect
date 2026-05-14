import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/language_provider.dart';
import 'package:mtc/utils/voice_provider/voice_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherName;
  final String otherId;
  final String listingTitle;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherName,
    required this.otherId,
    required this.listingTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _uid        = FirebaseAuth.instance.currentUser!.uid;
  bool  _sending    = false;
  // Track last spoken message to avoid re-reading same message
  String _lastSpokenId = '';

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    // Stop voice when leaving chat
    try {
      Provider.of<VoiceProvider>(context, listen: false).stop();
    } catch (_) {}
    super.dispose();
  }

  // Read an incoming message aloud
  void _speakMessage(BuildContext context, String text, String docId) {
    if (_lastSpokenId == docId) return; // don't re-read same message
    _lastSpokenId = docId;
    final voice = Provider.of<VoiceProvider>(context, listen: false);
    final lang  = Provider.of<LanguageProvider>(context, listen: false);
    final langCode = lang.currentCode == 'hi' ? 'hi-IN'
        : lang.currentCode == 'ta' ? 'ta-IN'
        : lang.currentCode == 'te' ? 'te-IN'
        : lang.currentCode == 'ar' ? 'ar-SA'
        : lang.currentCode == 'fr' ? 'fr-FR'
        : 'en-US';
    voice.speak('${widget.otherName} says: $text', langCode);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      final batch  = FirebaseFirestore.instance.batch();
      final msgRef = FirebaseFirestore.instance
          .collection('chats').doc(widget.chatId)
          .collection('messages').doc();
      batch.set(msgRef, {
        'senderId':  _uid,
        'text':      text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      batch.update(chatRef, {
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t     = Provider.of<ThemeProvider>(context).current;
    final voice = Provider.of<VoiceProvider>(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: t.primary.withOpacity(0.35)),
            ),
            child: Center(child: Text(
              widget.otherName.isNotEmpty ? widget.otherName[0].toUpperCase() : 'T',
              style: TextStyle(color: t.primary, fontWeight: FontWeight.w800, fontSize: 13),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherName,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              if (widget.listingTitle.isNotEmpty)
                Text('Re: ${widget.listingTitle}',
                    style: TextStyle(color: t.primary.withOpacity(0.7), fontSize: 11),
                    overflow: TextOverflow.ellipsis),
            ],
          )),
        ]),
        // Voice toggle button in chat app bar
        actions: [
          GestureDetector(
            onTap: () {
              if (voice.isSpeaking) {
                Provider.of<VoiceProvider>(context, listen: false).stop();
              }
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: voice.isSpeaking
                    ? t.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: voice.isSpeaking
                        ? t.primary.withOpacity(0.5)
                        : Colors.transparent),
              ),
              child: Icon(
                voice.isSpeaking ? Icons.volume_up_rounded : Icons.volume_off_outlined,
                color: voice.isSpeaking ? t.primary : Colors.white.withOpacity(0.3),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats').doc(widget.chatId)
                .collection('messages')
                .orderBy('timestamp')
                .snapshots(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: t.primary, strokeWidth: 2));
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(child: Text('Start the conversation',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)));
              }

              // Auto-read the latest incoming message
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollCtrl.hasClients) {
                  _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
                }
                // Speak only if the last message is from the other person
                final lastDoc = docs.last;
                final lastData = lastDoc.data() as Map<String, dynamic>;
                if (lastData['senderId'] != _uid) {
                  _speakMessage(context, lastData['text'] ?? '', lastDoc.id);
                }
              });

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d    = docs[i].data() as Map<String, dynamic>;
                  final isMe = d['senderId'] == _uid;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      // Long press any message to read it aloud
                      onLongPress: () => _speakMessage(context, d['text'] ?? '', docs[i].id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 7),
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        decoration: BoxDecoration(
                          color: isMe ? t.primary : t.card,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isMe ? 14 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 14),
                          ),
                          border: isMe ? null : Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Text(d['text'] ?? '',
                            style: TextStyle(
                                color: isMe ? t.background : Colors.white,
                                fontSize: 14, height: 1.4)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          decoration: BoxDecoration(
            color: t.card,
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                  filled: true,
                  fillColor: t.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _sending ? t.primary.withOpacity(0.5) : t.primary,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(color: t.background, strokeWidth: 2))
                    : Icon(Icons.send_rounded, color: t.background, size: 19),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}