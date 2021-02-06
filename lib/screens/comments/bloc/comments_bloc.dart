import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram/blocs/blocs.dart';
import 'package:flutter_instagram/models/models.dart';
import 'package:flutter_instagram/repositories/repositories.dart';
import 'package:meta/meta.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;

  StreamSubscription<List<Future<Comment>>> _commentsSubscription;

  CommentsBloc({
    @required PostRepository postRepository,
    @required AuthBloc authBloc,
  })  : _postRepository = postRepository,
        _authBloc = authBloc,
        super(CommentsState.initial());

  @override
  Future<void> close() {
    _commentsSubscription.cancel();
    return super.close();
  }

  @override
  Stream<CommentsState> mapEventToState(
    CommentsEvent event,
  ) async* {
    if (event is CommentsFetchComments) {
      yield* _mapCommentsFetchCommentsToState(event);
    } else if (event is CommentsUpdateComments) {
      yield* _mapCommentsUpdateCommentsToState(event);
    } else if (event is CommentsPostComment) {
      yield* _mapCommentsPostCommentToState(event);
    }
  }

  Stream<CommentsState> _mapCommentsFetchCommentsToState(
    CommentsFetchComments event,
  ) async* {
    yield state.copyWith(status: CommentsStatus.loading);
    try {
      _commentsSubscription?.cancel();
      _commentsSubscription = _postRepository
          .getPostComments(postId: event.post.id)
          .listen((comments) async {
        final allComments = await Future.wait(comments);
        add(CommentsUpdateComments(comments: allComments));
      });

      yield state.copyWith(post: event.post, status: CommentsStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: CommentsStatus.error,
        failure: const Failure(
          message: 'We were unable to load this post\'s comments.',
        ),
      );
    }
  }

  Stream<CommentsState> _mapCommentsUpdateCommentsToState(
    CommentsUpdateComments event,
  ) async* {
    yield state.copyWith(comments: event.comments);
  }

  Stream<CommentsState> _mapCommentsPostCommentToState(
    CommentsPostComment event,
  ) async* {
    yield state.copyWith(status: CommentsStatus.submitting);
    try {
      final author = User.empty.copyWith(id: _authBloc.state.user.uid);
      final comment = Comment(
        postId: state.post.id,
        author: author,
        content: event.content,
        date: DateTime.now(),
      );

      await _postRepository.createComment(
        post: state.post,
        comment: comment,
      );

      yield state.copyWith(status: CommentsStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: CommentsStatus.error,
        failure: const Failure(
          message: 'Comment failed to post',
        ),
      );
    }
  }
}
