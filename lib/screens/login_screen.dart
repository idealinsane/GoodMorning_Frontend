import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:good_morning/layout/default_layout.dart';
import 'package:good_morning/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const double _maxCardWidth = 350;
  static const double _cardRadius = 32.0;
  static const double _cardPaddingH = 18.0;
  static const double _cardPaddingV = 64.0;
  static const double _logoSize = 240;
  static const double _gap = 48;

  // 그라데이션 애니메이션 속도 및 간격
  static const Duration _gradientDuration = Duration(
    milliseconds: 1800,
  ); // 전환 애니메이션 속도
  static const Duration _gradientInterval = Duration(
    milliseconds: 1800,
  ); // 그라데이션이 바뀌는 간격

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

  // 카드/로고 진입 애니메이션
  late AnimationController _controller;
  late Animation<double> _cardOpacity;
  late Animation<double> _logoScale;

  // 버튼 애니메이션
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _logoScale = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _timer = Timer.periodic(_gradientInterval, (timer) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradientColors.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth =
        MediaQuery.of(context).size.width * 0.9 > _maxCardWidth
            ? _maxCardWidth
            : MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: FadeTransition(
              opacity: _cardOpacity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_cardRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: _cardPaddingH,
                      vertical: _cardPaddingV,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF).withOpacity(0.38),
                      borderRadius: BorderRadius.circular(_cardRadius),
                      border: Border.all(
                        color: const Color(0xFFE3F0FF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F8DFD).withOpacity(0.10),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Good Morning',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: _gap),
                        ScaleTransition(
                          scale: _logoScale,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              128,
                            ), // 원하는 radius 값
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: _logoSize,
                            ),
                          ),
                        ),
                        const SizedBox(height: _gap),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTapDown: (_) {
                              setState(() => _buttonScale = 0.96);
                            },
                            onTapUp: (_) {
                              setState(() => _buttonScale = 1.0);
                            },
                            onTapCancel: () {
                              setState(() => _buttonScale = 1.0);
                            },
                            onTap: () async {
                              try {
                                await LoginService.signInWithGoogle();
                                context.go('/good_morning');
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('로그인에 실패했습니다: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: AnimatedScale(
                              scale: _buttonScale,
                              duration: const Duration(milliseconds: 100),
                              child: Image.asset(
                                'assets/images/google_login.png',
                                height: 64,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
