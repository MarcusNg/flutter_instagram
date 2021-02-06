part of 'comments_bloc.dart';

enum CommentsStatus { initial, loading, loaded, submitting, error }

class CommentsState extends Equatable {
  final Post post;
  final List<Comment> comments;
  final CommentsStatus status;
  final Failure failure;

  const CommentsState({
    @required this.post,
    @required this.comments,
    @required this.status,
    @required this.failure,
  });

  factory CommentsState.initial() {
    return const CommentsState(
      post: null,
      comments: [],
      status: CommentsStatus.initial,
      failure: Failure(),
    );
  }

  @override
  List<Object> get props => [post, comments, status, failure];

  CommentsState copyWith({
    Post post,
    List<Comment> comments,
    CommentsStatus status,
    Failure failure,
  }) {
    return CommentsState(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
