import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram/config/paths.dart';
import 'package:meta/meta.dart';

import 'package:flutter_instagram/enums/enums.dart';
import 'package:flutter_instagram/models/models.dart';

class Notif extends Equatable {
  final String id;
  final NotifType type;
  final User fromUser;
  final Post post;
  final DateTime date;

  const Notif({
    this.id,
    @required this.type,
    @required this.fromUser,
    this.post,
    @required this.date,
  });

  @override
  List<Object> get props => [id, type, fromUser, post, date];

  Notif copyWith({
    String id,
    NotifType type,
    User fromUser,
    Post post,
    DateTime date,
  }) {
    return Notif(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUser: fromUser ?? this.fromUser,
      post: post ?? this.post,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toDocument() {
    final notifType = EnumToString.convertToString(type);
    return {
      'type': notifType,
      'fromUser':
          FirebaseFirestore.instance.collection(Paths.users).doc(fromUser.id),
      'post': post != null
          ? FirebaseFirestore.instance.collection(Paths.posts).doc(post.id)
          : null,
      'date': Timestamp.fromDate(date),
    };
  }

  static Future<Notif> fromDocument(DocumentSnapshot doc) async {
    if (doc == null) return null;
    final data = doc.data();
    final notifType = EnumToString.fromString(NotifType.values, data['type']);

    // From User
    final fromUserRef = data['fromUser'] as DocumentReference;
    if (fromUserRef != null) {
      final fromUserDoc = await fromUserRef.get();

      // Post
      final postRef = data['post'] as DocumentReference;
      if (postRef != null) {
        final postDoc = await postRef.get();

        if (postDoc.exists) {
          return Notif(
            id: doc.id,
            type: notifType,
            fromUser: User.fromDocument(fromUserDoc),
            post: await Post.fromDocument(postDoc),
            date: (data['date'] as Timestamp)?.toDate(),
          );
        }
      } else {
        return Notif(
          id: doc.id,
          type: notifType,
          fromUser: User.fromDocument(fromUserDoc),
          post: null,
          date: (data['date'] as Timestamp)?.toDate(),
        );
      }
    }
    return null;
  }
}
