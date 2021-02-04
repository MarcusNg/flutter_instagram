import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/extensions/extensions.dart';
import 'package:flutter_instagram/models/models.dart';
import 'package:flutter_instagram/screens/screens.dart';
import 'package:flutter_instagram/widgets/widgets.dart';

class PostView extends StatelessWidget {
  final Post post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  const PostView({
    Key key,
    @required this.post,
    @required this.isLiked,
    @required this.onLike,
    this.recentlyLiked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              ProfileScreen.routeName,
              arguments: ProfileScreenArgs(userId: post.author.id),
            ),
            child: Row(
              children: [
                UserProfileImage(
                  radius: 18.0,
                  profileImageUrl: post.author.profileImageUrl,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    post.author.username,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: onLike,
          child: CachedNetworkImage(
            height: MediaQuery.of(context).size.height / 2.25,
            width: double.infinity,
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: isLiked
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const Icon(Icons.favorite_outline),
              onPressed: onLike,
            ),
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              onPressed: () => Navigator.of(context).pushNamed(
                CommentsScreen.routeName,
                arguments: CommentsScreenArgs(post: post),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${recentlyLiked ? post.likes + 1 : post.likes} likes',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: post.author.username,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                post.date.timeAgo(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
