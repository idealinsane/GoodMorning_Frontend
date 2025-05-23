import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:uuid/uuid.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/message.dart';
import 'package:good_morning/models/user_profile.dart';
import 'package:good_morning/providers/chat_rooms_provider.dart';
import 'package:good_morning/providers/location_provider.dart';
import 'package:go_router/go_router.dart';

class CreateChatRoomView extends ConsumerStatefulWidget {
  const CreateChatRoomView({super.key});

  @override
  ConsumerState<CreateChatRoomView> createState() => _CreateChatRoomViewState();
}

class _CreateChatRoomViewState extends ConsumerState<CreateChatRoomView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(locationProvider.notifier).updateLocation();
      final location = ref.read(locationProvider);
      if (location == null) throw Exception('No location');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Login required');
      final room = await ref
          .read(chatRoomsProvider.notifier)
          .createRoom(
            title: _titleController.text,
            firstMessage: _messageController.text,
            creator: UserProfile.fromFirebaseUser(currentUser),
            latitude: location.latitude,
            longitude: location.longitude,
          );
      if (mounted) {
        Navigator.of(context).pop();
        context.go('/chat/${room.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 370,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Room',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _GlassTextField(
                      controller: _titleController,
                      hintText: 'Room title',
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    _GlassTextField(
                      controller: _messageController,
                      hintText: 'First message',
                      minLines: 2,
                      maxLines: 4,
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Enter a message' : null,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _GlassButton(
                          text: 'Cancel',
                          onTap:
                              _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          color: Colors.grey[200]!,
                          textColor: Colors.grey[700]!,
                        ),
                        const SizedBox(width: 12),
                        _GlassButton(
                          text: _isLoading ? 'Creating...' : 'Create',
                          onTap: _isLoading ? null : _handleSubmit,
                          color: Colors.blue[600]!,
                          textColor: Colors.white,
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;
  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.minLines,
    this.maxLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[200]!, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final Widget? icon;
  const _GlassButton({
    required this.text,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
