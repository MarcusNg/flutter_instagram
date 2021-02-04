import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram/blocs/blocs.dart';
import 'package:flutter_instagram/cubits/cubits.dart';
import 'package:flutter_instagram/models/models.dart';
import 'package:flutter_instagram/repositories/repositories.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final LikedPostsCubit _likedPostsCubit;

  StreamSubscription<List<Future<Post>>> _postsSubscription;

  ProfileBloc({
    @required UserRepository userRepository,
    @required PostRepository postRepository,
    @required AuthBloc authBloc,
    @required LikedPostsCubit likedPostsCubit,
  })  : _userRepository = userRepository,
        _postRepository = postRepository,
        _authBloc = authBloc,
        _likedPostsCubit = likedPostsCubit,
        super(ProfileState.initial());

  @override
  Future<void> close() {
    _postsSubscription.cancel();
    return super.close();
  }

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is ProfileLoadUser) {
      yield* _mapProfileLoadUserToState(event);
    } else if (event is ProfileToggleGridView) {
      yield* _mapProfileToggleGridViewToState(event);
    } else if (event is ProfileUpdatePosts) {
      yield* _mapProfileUpdatePostsToState(event);
    } else if (event is ProfileFollowUser) {
      yield* _mapProfileFollowUserToState();
    } else if (event is ProfileUnfollowUser) {
      yield* _mapProfileUnfollowUserToState();
    }
  }

  Stream<ProfileState> _mapProfileLoadUserToState(
    ProfileLoadUser event,
  ) async* {
    yield state.copyWith(status: ProfileStatus.loading);
    try {
      final user = await _userRepository.getUserWithId(userId: event.userId);
      final isCurrentUser = _authBloc.state.user.uid == event.userId;

      final isFollowing = await _userRepository.isFollowing(
        userId: _authBloc.state.user.uid,
        otherUserId: event.userId,
      );

      _postsSubscription?.cancel();
      _postsSubscription = _postRepository
          .getUserPosts(userId: event.userId)
          .listen((posts) async {
        final allPosts = await Future.wait(posts);
        add(ProfileUpdatePosts(posts: allPosts));
      });

      yield state.copyWith(
        user: user,
        isCurrentUser: isCurrentUser,
        isFollowing: isFollowing,
        status: ProfileStatus.loaded,
      );
    } catch (err) {
      yield state.copyWith(
        status: ProfileStatus.error,
        failure: const Failure(message: 'We were unable to load this profile.'),
      );
    }
  }

  Stream<ProfileState> _mapProfileToggleGridViewToState(
    ProfileToggleGridView event,
  ) async* {
    yield state.copyWith(isGridView: event.isGridView);
  }

  Stream<ProfileState> _mapProfileUpdatePostsToState(
    ProfileUpdatePosts event,
  ) async* {
    yield state.copyWith(posts: event.posts);
    final likedPostIds = await _postRepository.getLikedPostIds(
      userId: _authBloc.state.user.uid,
      posts: event.posts,
    );
    _likedPostsCubit.updateLikedPosts(postIds: likedPostIds);
  }

  Stream<ProfileState> _mapProfileFollowUserToState() async* {
    try {
      _userRepository.followUser(
        userId: _authBloc.state.user.uid,
        followUserId: state.user.id,
      );
      final updatedUser =
          state.user.copyWith(followers: state.user.followers + 1);
      yield state.copyWith(user: updatedUser, isFollowing: true);
    } catch (err) {
      yield state.copyWith(
        status: ProfileStatus.error,
        failure:
            const Failure(message: 'Something went wrong! Please try again.'),
      );
    }
  }

  Stream<ProfileState> _mapProfileUnfollowUserToState() async* {
    try {
      _userRepository.unfollowUser(
        userId: _authBloc.state.user.uid,
        unfollowUserId: state.user.id,
      );
      final updatedUser =
          state.user.copyWith(followers: state.user.followers - 1);
      yield state.copyWith(user: updatedUser, isFollowing: false);
    } catch (err) {
      yield state.copyWith(
        status: ProfileStatus.error,
        failure:
            const Failure(message: 'Something went wrong! Please try again.'),
      );
    }
  }
}
