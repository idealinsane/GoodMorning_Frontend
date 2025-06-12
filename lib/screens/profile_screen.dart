import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/user_profile.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:good_morning/services/login_service.dart';
import 'package:good_morning/services/user_service.dart';
import 'package:good_morning/services/chat_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _appVersion = '';
  int _chatRoomCount = 0;
  int _messageCount = 0;

  // Gradient 애니메이션 관련 변수 추가 (login_screen.dart에서 복사)
  static const Duration _gradientDuration = Duration(milliseconds: 1800);
  static const Duration _gradientInterval = Duration(milliseconds: 1800);
  final List<List<Color>> _gradientColors = [
    [
      Color(0xFF235390),
      Color(0xFF4F8DFD),
      Color(0xFFA7C7E7),
      Color(0xFFE3F0FF),
    ],
    [
      Color(0xFF4F8DFD),
      Color(0xFF235390),
      Color(0xFFE3F0FF),
      Color(0xFFA7C7E7),
    ],
    [
      Color(0xFFA7C7E7),
      Color(0xFFE3F0FF),
      Color(0xFF235390),
      Color(0xFF4F8DFD),
    ],
  ];
  int _gradientIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Gradient 애니메이션 타이머 세팅
    _timer = Timer.periodic(_gradientInterval, (timer) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradientColors.length;
      });
    });
    _loadProfile();
    _loadAppVersion();
    _loadStats();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadStats() async {
    try {
      final chatRooms = await ChatService().getChatRooms();
      setState(() {
        _chatRoomCount = chatRooms.length;
        // TODO: 메시지 수 API 구현 후 업데이트
        _messageCount = 0;
      });
    } catch (e) {
      print('통계 로드 실패: $e');
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _userProfile = await UserService.getCurrentUserProfile();
    } catch (e) {
      print('프로필 로드 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 로드 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_userProfile);

    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return const Center(child: Text('프로필을 불러올 수 없습니다'));
    }

    return Scaffold(
      body: Stack(
        children: [
          // AnimatedContainer: 배경 그라데이션
          AnimatedContainer(
            duration: _gradientDuration,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors[_gradientIndex],
              ),
            ),
          ),
          // 내용 전체를 SingleChildScrollView로 감싼다
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                // Glassmorphism 카드와 프로필 이미지를 Stack으로 겹치게 배치
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Glassmorphism 카드 (상단 패딩/마진 더 크게)
                    Container(
                      margin: const EdgeInsets.only(
                        top: 60,
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      padding: const EdgeInsets.only(
                        top: 100,
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _userProfile!.nickname,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userProfile!.bio ?? '자기소개를 입력해주세요',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Activity Stats
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  icon: Icons.chat_bubble_outline,
                                  label: 'Chats',
                                  value: _chatRoomCount.toString(),
                                ),
                                _buildStatItem(
                                  icon: Icons.message_outlined,
                                  label: 'Messages',
                                  value: _messageCount.toString(),
                                ),
                                _buildStatItem(
                                  icon: Icons.favorite_border,
                                  label: 'Likes',
                                  value: _userProfile!.likes.toString(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Settings
                          _buildMenuSection(
                            title: 'Settings',
                            items: [
                              _buildMenuItem(
                                icon: Icons.notifications_outlined,
                                label: 'Notification Settings',
                                onTap: () {
                                  // TODO: 알림 설정 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.dark_mode_outlined,
                                label: 'Theme Settings',
                                onTap: () {
                                  // TODO: 테마 설정 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.language_outlined,
                                label: 'Language Settings',
                                onTap: () {
                                  // TODO: 언어 설정 화면으로 이동
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Account Management
                          _buildMenuSection(
                            title: 'Account Management',
                            items: [
                              _buildMenuItem(
                                icon: Icons.security_outlined,
                                label: 'Change Password',
                                onTap: () {
                                  // TODO: 비밀번호 변경 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.delete_outline,
                                label: 'Delete Account',
                                onTap: () {
                                  _showDeleteAccountDialog();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // App Info
                          _buildMenuSection(
                            title: 'App Info',
                            items: [
                              _buildMenuItem(
                                icon: Icons.info_outline,
                                label: 'Version',
                                trailing: Text(
                                  _appVersion,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.description_outlined,
                                label: 'Terms of Service',
                                onTap: () {
                                  // TODO: 이용약관 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.privacy_tip_outlined,
                                label: 'Privacy Policy',
                                onTap: () {
                                  // TODO: 개인정보 처리방침 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.help_outline,
                                label: 'Contact Us',
                                onTap: () {
                                  // TODO: 문의하기 화면으로 이동
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Logout Button
                          _buildGlassButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              await LoginService.clearToken();
                              context.go('/login');
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 프로필 이미지 (카드 위에 겹치게)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage:
                              _userProfile?.profileImageUrl != null
                                  ? NetworkImage(_userProfile!.profileImageUrl!)
                                  : null,
                          child:
                              _userProfile?.profileImageUrl == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // FAB(프로필 편집 버튼)는 계속 Stack의 Positioned로 남겨둔다
          Positioned(
            bottom: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: FloatingActionButton(
                    onPressed: () async {
                      // 프로필 편집 화면으로 이동하고 결과 대기
                      await context.push('/profile/edit');
                      // 편집 화면에서 돌아오면 프로필 갱신
                      _loadProfile();
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              const Spacer(),
              if (trailing != null) trailing,
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account?\nDeleted accounts cannot be recovered.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
        await LoginService.clearToken();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
