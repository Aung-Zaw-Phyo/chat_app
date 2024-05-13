import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No message found.'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong.'),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(left: 13, right: 13, bottom: 18),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final message = loadedMessages[index].data();
            final nextMsg = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1]
                : null;
            final currentMsgUserId = message['userId'];
            final nextMsgUserId = nextMsg != null ? nextMsg['userId'] : null;
            final nextMsgUserIsSameWithCurrent =
                currentMsgUserId == nextMsgUserId;

            if (nextMsgUserIsSameWithCurrent) {
              return MessageBubble.next(
                message: message['text'],
                isMe: currentUser!.uid == currentMsgUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: message['userImage'],
                username: message['username'],
                message: message['text'],
                isMe: currentUser!.uid == currentMsgUserId,
              );
            }
          },
        );
      },
    );
  }
}
