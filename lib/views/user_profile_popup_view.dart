import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/user_profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProfilePopupView extends StatefulWidget {
  UserProfile user;
  final VoidCallback onLike;

  UserProfilePopupView({super.key, required this.user, required this.onLike});

  @override
  State<UserProfilePopupView> createState() => _UserProfilePopupViewState();
}

class _UserProfilePopupViewState extends State<UserProfilePopupView> {
  late int likes;

  @override
  void initState() {
    super.initState();
    likes = widget.user.likes;
  }

  Future<void> _handleLike() async {
    setState(() {
      likes++;
      widget.user.likes++;
    });

    // try {
    //   final response = await http.post(
    //     Uri.parse('https://your-api-endpoint.com/like'), // TODO: 실제 엔드포인트로 변경
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({'userId': widget.user.uid}),
    //   );

    //   if (response.statusCode != 200) {
    //     debugPrint('공감 API 실패: ${response.body}');
    //   }
    // } catch (e) {
    //   debugPrint('공감 API 에러: $e');
    // }

    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    final profileImage =
        widget.user.profileImageUrl?.isNotEmpty == true
            ? widget.user.profileImageUrl!
            : 'https://placedog.net/100/100';

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(profileImage),
            ),
            const SizedBox(height: 12),
            Text(
              widget.user.nickname,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.user.bio!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text('$likes'),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleLike,
                  child: const Text("공감하기"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.pop(), child: const Text("닫기")),
          ],
        ),
      ),
    );
  }
}
