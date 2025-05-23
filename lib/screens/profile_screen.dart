import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/models/user_profile.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:good_morning/services/login_service.dart';
import 'package:good_morning/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
          SnackBar(
            content: Text(
              e is UserNotFoundException ? e.toString() : '프로필 로드 실패: $e',
            ),
            backgroundColor:
                e is UserNotFoundException ? Colors.orange : Colors.red,
          ),
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
    print(_userProfile?.profileImageUrl);
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

    return Container(
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
                          _userProfile!.bio ?? 'Type your bio',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: const Text(
                                '👍',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),

                            const SizedBox(width: 8),
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildGlassButton(
                          onPressed: () {
                            context.go('/login');
                            FirebaseAuth.instance.signOut();
                            LoginService.clearToken();
                          },
                          child: const Text(
                            '로그아웃',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildGlassButton(
                          onPressed: () {
                            context.go('/error');
                          },
                          child: const Text(
                            '에러 페이지',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildGlassButton(
                          onPressed: () async {
                            try {
                              final token =
                                  await FirebaseAuth.instance.currentUser
                                      ?.getIdToken();
                              developer.log('Firebase User Token: $token');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('토큰이 콘솔에 출력되었습니다'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            } catch (e) {
                              developer.log('Error getting token: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('토큰 가져오기 실패: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            '토큰 출력하기',
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
}
