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

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAppVersion();
    _loadStats();
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

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade200],
          ),
        ),
        child: Stack(
          children: [
            Column(
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
                const SizedBox(height: 80),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
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

                          // 활동 통계
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
                                  label: '채팅방',
                                  value: _chatRoomCount.toString(),
                                ),
                                _buildStatItem(
                                  icon: Icons.message_outlined,
                                  label: '메시지',
                                  value: _messageCount.toString(),
                                ),
                                _buildStatItem(
                                  icon: Icons.favorite_border,
                                  label: '좋아요',
                                  value: _userProfile!.likes.toString(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 설정 메뉴
                          _buildMenuSection(
                            title: '설정',
                            items: [
                              _buildMenuItem(
                                icon: Icons.notifications_outlined,
                                label: '알림 설정',
                                onTap: () {
                                  // TODO: 알림 설정 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.dark_mode_outlined,
                                label: '테마 설정',
                                onTap: () {
                                  // TODO: 테마 설정 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.language_outlined,
                                label: '언어 설정',
                                onTap: () {
                                  // TODO: 언어 설정 화면으로 이동
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 계정 관리
                          _buildMenuSection(
                            title: '계정 관리',
                            items: [
                              _buildMenuItem(
                                icon: Icons.security_outlined,
                                label: '비밀번호 변경',
                                onTap: () {
                                  // TODO: 비밀번호 변경 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.delete_outline,
                                label: '계정 삭제',
                                onTap: () {
                                  _showDeleteAccountDialog();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 앱 정보
                          _buildMenuSection(
                            title: '앱 정보',
                            items: [
                              _buildMenuItem(
                                icon: Icons.info_outline,
                                label: '버전',
                                trailing: Text(
                                  _appVersion,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.description_outlined,
                                label: '이용약관',
                                onTap: () {
                                  // TODO: 이용약관 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.privacy_tip_outlined,
                                label: '개인정보 처리방침',
                                onTap: () {
                                  // TODO: 개인정보 처리방침 화면으로 이동
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.help_outline,
                                label: '문의하기',
                                onTap: () {
                                  // TODO: 문의하기 화면으로 이동
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 로그아웃 버튼
                          _buildGlassButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              LoginService.clearToken();
                              context.go('/login');
                            },
                            child: const Text(
                              '로그아웃',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 140,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: Container(
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
            ),
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
            title: const Text('계정 삭제'),
            content: const Text('정말로 계정을 삭제하시겠습니까?\n삭제된 계정은 복구할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
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
              content: Text('계정 삭제 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
