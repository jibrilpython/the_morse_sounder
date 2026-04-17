import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_morse_sounder/screens/home_screen.dart';
import 'package:the_morse_sounder/screens/stats_screen.dart';
import 'package:the_morse_sounder/screens/showcase_screen.dart';
import 'package:the_morse_sounder/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    ShowcaseScreen(),
  ];

  static const _tabs = [
    _NavTab(icon: Icons.list_alt_rounded, label: 'Archive'),
    _NavTab(icon: Icons.bar_chart_rounded, label: 'Stats'),
    _NavTab(icon: Icons.wifi_tethering_rounded, label: 'Signal'),
  ];

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // ── Modern Floating Nav ──────────────────────────────────────────
          Positioned(
            left: 32.w,
            right: 32.w,
            bottom: bottom + 24.h,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(160),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: kOutline.withAlpha(80), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: EdgeInsets.all(10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = _currentIndex == i;
                return GestureDetector(
                  onTap: () => _setIndex(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? kAccent.withAlpha(30)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isActive ? kAccent : kSecondaryText,
                          size: 20.sp,
                        ),
                        if (isActive) ...[
                          SizedBox(width: 8.w),
                          Text(
                            tab.label.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: kAccent,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
