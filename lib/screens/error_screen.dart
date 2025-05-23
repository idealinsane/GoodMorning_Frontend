import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/layout/default_layout.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Center(
        child: Column(
          children: [
            Text('Error message: $error'),
            // 굿모닝으로
            ElevatedButton(
              onPressed: () {
                context.go('/good_morning');
              },
              child: Text('Go to Good Morning'),
            ),
          ],
        ),
      ),
    );
  }
}
