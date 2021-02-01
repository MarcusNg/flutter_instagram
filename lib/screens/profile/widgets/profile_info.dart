import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String username;
  final String bio;

  const ProfileInfo({
    Key key,
    @required this.username,
    @required this.bio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          username,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          bio,
          style: const TextStyle(fontSize: 15.0),
        ),
        const Divider(),
      ],
    );
  }
}
