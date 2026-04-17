import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_morse_sounder/providers/user_provider.dart';
import 'package:the_morse_sounder/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = ref.watch(userProvider);
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Animated waveform background ───────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (_, _) => CustomPaint(
                painter: _WaveformBgPainter(progress: _waveController.value),
              ),
            ),
          ),

          // ── Layout ────────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // ── Tiny breadcrumb ────────────────────────────────────
                  Text(
                    'TMS — v1.0',
                    style: GoogleFonts.jetBrainsMono(
                      color: kAccent.withAlpha(120),
                      fontSize: 10.sp,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const Spacer(),

                  // ── Display type ───────────────────────────────────────
                  Text(
                    'THE',
                    style: GoogleFonts.outfit(
                      color: kPrimaryText,
                      fontSize: 64.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'MORSE',
                        style: GoogleFonts.outfit(
                          color: kPrimaryText,
                          fontSize: 64.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        width: 9.w,
                        height: 9.w,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SOUNDER',
                    style: GoogleFonts.outfit(
                      color: kAccent,
                      fontSize: 64.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // ── Description ────────────────────────────────────────
                  SizedBox(
                    width: size.width * 0.72,
                    child: Text(
                      'A collector\'s archive for electromagnetic'
                      ' sound receivers — the metallic voices of Morse code.',
                      style: GoogleFonts.dmSans(
                        color: kSecondaryText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w300,
                        height: 1.7,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Bottom row ─────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '·  ·  —  ·',
                            style: GoogleFonts.jetBrainsMono(
                              color: kSecondaryText.withAlpha(70),
                              fontSize: 14.sp,
                              letterSpacing: 6,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'ELECTROMAGNETIC ARCHIVE',
                            style: GoogleFonts.jetBrainsMono(
                              color: kSecondaryText.withAlpha(80),
                              fontSize: 8.sp,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),

                      // Gold CTA circle
                      GestureDetector(
                        onTap: () {
                          userProv.setFirstTimeUser(false);
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kAccent.withAlpha(70),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: kBackground,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: bottom + 28.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformBgPainter extends CustomPainter {
  final double progress;
  _WaveformBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kAccent.withAlpha(48)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final morseSignal = [
      1,
      0,
      1,
      0,
      1,
      0,
      0,
      3,
      0,
      3,
      0,
      3,
      0,
      0,
      1,
      0,
      1,
      0,
      1,
    ];
    final totalUnits = morseSignal.fold(0, (a, b) => a + b);

    final double startY = size.height * 0.35;
    final double amplitude = size.height * 0.055;
    final double unitW = size.width / (totalUnits + 4);

    double x = unitW * 2;

    for (final unit in morseSignal) {
      if (unit == 0) {
        x += unitW;
        continue;
      }
      final segW = unit * unitW;
      final path = Path();
      const steps = 30;
      for (int s = 0; s <= steps; s++) {
        final t = s / steps;
        final segX = x + t * segW;
        final phase = (segX / size.width + progress) * 2 * math.pi * 3;
        final y =
            startY +
            math.sin(phase) * amplitude * math.min(1.0, unit.toDouble());
        if (s == 0) {
          path.moveTo(segX, y);
        } else {
          path.lineTo(segX, y);
        }
      }
      canvas.drawPath(path, paint);
      x += segW;
    }

    canvas.drawLine(
      Offset(0, startY),
      Offset(size.width, startY),
      Paint()
        ..color = kOutline.withAlpha(35)
        ..strokeWidth = 0.5,
    );

    final arcPaint = Paint()
      ..color = kOutline.withAlpha(20)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 1.1, size.height * 0.5),
        radius: size.width * 0.7,
      ),
      math.pi * 0.5,
      math.pi * 1.0,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 1.1, size.height * 0.5),
        radius: size.width * 0.9,
      ),
      math.pi * 0.55,
      math.pi * 0.9,
      false,
      arcPaint..color = kOutline.withAlpha(10),
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformBgPainter old) =>
      old.progress != progress;
}
