import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_morse_sounder/models/sounder_model.dart';
import 'package:the_morse_sounder/providers/image_provider.dart';
import 'package:the_morse_sounder/providers/project_provider.dart';

// Gilded Age Tech Palette
const Color kBakeliteBlack = Color(0xFF080808);
const Color kBrassCopper = Color(0xFFB07D3A);
const Color kWalnutBrown = Color(0xFF3E2723);

class _MagneticNode {
  final SounderModel item;
  final int globalIndex;

  double x;
  double y;
  double vx = 0;
  double vy = 0;

  final double targetX;
  final double targetY;

  bool isPressed = false;
  bool isDragging = false;

  final List<double> waveBuffer;

  _MagneticNode({
    required this.item,
    required this.globalIndex,
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
  }) : waveBuffer = List.filled(200, 0.0, growable: true);
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<_MagneticNode> _nodes = [];
  bool _isInitialized = false;
  int _lastHash = -1;

  _MagneticNode? _focusedNode;
  _MagneticNode? _lastFocusedNode;
  double _fieldHumPhase = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _init(List<SounderModel> entries, Size size) {
    if (entries.isEmpty) return;
    final hash = Object.hash(
      ref.read(projectProvider).stateVersion,
      entries.length,
      size.width,
    );
    if (_isInitialized && _lastHash == hash) return;
    _isInitialized = true;
    _lastHash = hash;

    _nodes.clear();
    double cx = size.width / 2;
    double cy = size.height / 2;

    int cols = 3;
    if (size.width < 400) cols = 2; // Responsive constraint
    if (entries.length == 1) cols = 1;

    for (int i = 0; i < entries.length; i++) {
      var e = entries[i];
      double row = (i ~/ cols).toDouble();
      double col = (i % cols).toDouble();

      double spacingX = 100.w;
      double spacingY = 110.h;
      double totalW = (cols - 1) * spacingX;
      double startX = cx - (totalW / 2);

      double tx = startX + col * spacingX;
      double ty = (cy - 120.h) + (row * spacingY);

      // Random drop-in spawn
      double sx = cx + (math.Random().nextDouble() - 0.5) * size.width;
      double sy = -150.0;

      _nodes.add(
        _MagneticNode(
          item: e,
          globalIndex: i,
          x: sx,
          y: sy,
          targetX: tx,
          targetY: ty,
        ),
      );
    }
  }

  void _onTick(Duration delta) {
    if (!mounted || _focusedNode != null) return; // Freeze Physics on Focus

    _fieldHumPhase += 0.02; // Background field progression

    // 1. Shift waveform buffers to simulate Ticker Tape moving
    for (var node in _nodes) {
      node.waveBuffer.removeLast();
      node.waveBuffer.insert(0, node.isPressed ? 1.0 : 0.0);
    }

    // 2. Magnetic Resistance Physics
    const double springStiffness = 0.025;
    const double damping = 0.78; // High friction/weight
    const double repulsionStrength = 1800.0;

    for (int i = 0; i < _nodes.length; i++) {
      var n = _nodes[i];
      if (n.isDragging) continue;

      // Electromagnetic Anchor
      double fx = (n.targetX - n.x) * springStiffness;
      double fy = (n.targetY - n.y) * springStiffness;

      // Magnetic Pole Repulsion from neighbors
      for (int j = 0; j < _nodes.length; j++) {
        if (i == j) continue;
        var other = _nodes[j];
        double dx = n.x - other.x;
        double dy = n.y - other.y;
        double distSq = dx * dx + dy * dy;

        if (distSq < 10.0) distSq = 10.0; // Collision buffer
        if (distSq < 40000.0) {
          // Local field radius
          double dist = math.sqrt(distSq);
          double force = repulsionStrength / distSq;
          fx += (dx / dist) * force;
          fy += (dy / dist) * force;
        }
      }

      n.vx = (n.vx + fx) * damping;
      n.vy = (n.vy + fy) * damping;

      n.x += n.vx;
      n.y += n.vy;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final size = MediaQuery.of(context).size;

    // Only init if we actually have a valid size
    if (size.width > 0) {
      _init(entries, size);
    }

    return Scaffold(
      backgroundColor: kBakeliteBlack,
      body: entries.isEmpty
          ? _buildEmpty()
          : Stack(
              children: [
                // ── 1. The Electromagnetic Field (Background & Waves) ──
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RhythmFieldPainter(
                      nodes: _nodes,
                      humPhase: _fieldHumPhase,
                      sizeW: size.width,
                      sizeH: size.height,
                      isFrozen: _focusedNode != null,
                    ),
                  ),
                ),

                // ── 2. The Interactive Brass Armatures (Nodes) ─────────
                ..._nodes.map((n) => _buildNode(n)),

                // ── 3. The Walnut Desk Plaque (Focus State) ────────────
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _focusedNode != null ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _focusedNode == null,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _focusedNode = null);
                        },
                        child: Container(
                          color: Colors.black.withAlpha(150), // Dim overlay
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _focusedNode == null,
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        scale: _focusedNode != null ? 1.0 : 0.8,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _focusedNode != null ? 1.0 : 0.0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: _lastFocusedNode != null
                                ? _buildWalnutPlaque(size, _lastFocusedNode!)
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── 4. App Bar Context ──────────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20.h,
                  left: 24.w,
                  right: 24.w,
                  child: IgnorePointer(child: _buildRhythmHeader()),
                ),
              ],
            ),
    );
  }

  Widget _buildRhythmHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RHYTHM FIELD',
              style: GoogleFonts.outfit(
                color: kBrassCopper,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Tap heavy nodes to emit telegraph pulses.',
              style: GoogleFonts.jetBrainsMono(
                color: kBrassCopper.withAlpha(150),
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        if (_focusedNode == null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border.all(color: kBrassCopper.withAlpha(60)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'LIVE',
              style: GoogleFonts.jetBrainsMono(
                color: kBrassCopper,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waves, color: kBrassCopper.withAlpha(100), size: 60.sp),
          SizedBox(height: 24.h),
          Text(
            'FIELD SILENT',
            style: GoogleFonts.outfit(
              color: kBrassCopper,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Log specimens to begin simulating\nmagnetic resistance fields.',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white54,
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(_MagneticNode n) {
    final double r = 36.w; // Radius of node
    // Force scaling constraint via container transform

    return Positioned(
      left: n.x - r,
      top: n.y - r,
      child: GestureDetector(
        onPanDown: (_) {
          HapticFeedback.heavyImpact();
          if (_focusedNode == null) setState(() => n.isPressed = true);
        },
        onPanUpdate: (d) {
          if (_focusedNode != null) return;
          setState(() {
            n.x += d.delta.dx;
            n.y += d.delta.dy;
            n.isDragging = true;
          });
        },
        onPanEnd: (_) {
          if (_focusedNode == null) HapticFeedback.selectionClick();
          setState(() {
            n.isDragging = false;
            n.isPressed = false;
          });
        },
        onPanCancel: () {
          setState(() {
            n.isDragging = false;
            n.isPressed = false;
          });
        },
        onLongPress: () {
          HapticFeedback.heavyImpact(); // The locking clack!
          setState(() {
            _focusedNode = n;
            _lastFocusedNode = n;
            n.isPressed = false;
            n.isDragging = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: r * 2,
          height: r * 2,
          transform: Matrix4.diagonal3Values(
            n.isPressed ? 0.93 : 1.0,
            n.isPressed ? 0.93 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Heavy brass gradient
            gradient: RadialGradient(
              colors: [
                kBrassCopper, // shiny apex
                kBrassCopper.withRed(150), // deeper edge
                const Color(0xFF4A3317), // shadow rim
              ],
              radius: 0.85,
              focal: const Alignment(-0.3, -0.3), // Top left light source
            ),
            boxShadow: [
              // Magnetic Glow when pressed
              if (n.isPressed)
                BoxShadow(
                  color: kBrassCopper.withAlpha(200),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              // Heavy casting shadow
              BoxShadow(
                color: Colors.black.withAlpha(n.isPressed ? 180 : 255),
                blurRadius: n.isPressed ? 6 : 24,
                offset: Offset(0, n.isPressed ? 3 : 16),
              ),
            ],
          ),
          child: Center(
            // Indented Bakelite core
            child: Container(
              width: r * 1.1,
              height: r * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBakeliteBlack,
                border: Border.all(
                  color: kBrassCopper.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  n.item.telegraphIdentifier.isNotEmpty
                      ? n.item.telegraphIdentifier[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.outfit(
                    color: kBrassCopper,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalnutPlaque(Size size, _MagneticNode n) {
    final imgPath = ref.watch(imageProvider).getImagePath(n.item.photoPath);
    final hasImg = imgPath != null && File(imgPath).existsSync();

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5A392B), // Lighter walnut
            kWalnutBrown, // Solid core
            Color(0xFF271410), // Deep edge
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kBakeliteBlack, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Brass Screws ──
          Positioned(top: 14.h, left: 14.w, child: _buildBrassScrew()),
          Positioned(top: 14.h, right: 14.w, child: _buildBrassScrew()),
          Positioned(bottom: 34.h, left: 14.w, child: _buildBrassScrew()),
          Positioned(bottom: 34.h, right: 14.w, child: _buildBrassScrew()),

          // ── Content ──
          Padding(
            padding: EdgeInsets.fromLTRB(28.w, 40.h, 28.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Engraved Title
                Text(
                  n.item.manufacturer.isNotEmpty
                      ? n.item.manufacturer.toUpperCase()
                      : 'UNKNOWN MAKER',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: kBrassCopper,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Container(height: 1.5, color: kBrassCopper.withAlpha(40)),
                SizedBox(height: 20.h),

                // Moody Photo inset
                Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: kBakeliteBlack,
                    border: Border.all(color: kBrassCopper, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: hasImg
                      ? Image.file(
                          File(imgPath),
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.colorBurn,
                          color: kBrassCopper.withAlpha(20),
                        )
                      : Center(
                          child: Icon(
                            Icons.flash_on,
                            color: kBrassCopper.withAlpha(50),
                            size: 40.sp,
                          ),
                        ),
                ),

                SizedBox(height: 24.h),

                // Specs Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _plaqueSpec(
                        'NETWORK',
                        n.item.telegraphCompany.isNotEmpty
                            ? n.item.telegraphCompany
                            : 'PRIVATE',
                      ),
                    ),
                    Expanded(
                      child: _plaqueSpec(
                        'RESISTANCE',
                        n.item.coilResistance.isNotEmpty
                            ? '${n.item.coilResistance} Ω'
                            : 'N/A',
                      ),
                    ),
                    Expanded(
                      child: _plaqueSpec(
                        'ERA',
                        n.item.presumedEra.isNotEmpty
                            ? n.item.presumedEra
                            : 'UNKNOWN',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // Button to full specific record
                GestureDetector(
                  onTap: () {
                    setState(() => _focusedNode = null);
                    Navigator.pushNamed(
                      context,
                      '/info_screen',
                      arguments: n.globalIndex,
                    );
                  },
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: kBrassCopper.withAlpha(20),
                        border: Border.all(color: kBrassCopper),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VIEW FULL SCHEMATICS',
                        style: GoogleFonts.jetBrainsMono(
                          color: kBrassCopper,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrassScrew() {
    return Container(
      width: 14.w,
      height: 14.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kBrassCopper,
        gradient: RadialGradient(colors: [kBrassCopper, Color(0xFF6E4D20)]),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: math.Random().nextDouble(), // Random screw angle
          child: Container(
            width: 8.w,
            height: 1.5,
            color: kBakeliteBlack.withAlpha(150),
          ),
        ),
      ),
    );
  }

  Widget _plaqueSpec(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: kBrassCopper.withAlpha(120),
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value.toUpperCase(),
          style: GoogleFonts.outfit(
            color: kBrassCopper,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Ticker Tape & Output Physics ──────────────────────────────────────────────
class _RhythmFieldPainter extends CustomPainter {
  final List<_MagneticNode> nodes;
  final double humPhase;
  final double sizeW;
  final double sizeH;
  final bool isFrozen;

  _RhythmFieldPainter({
    required this.nodes,
    required this.humPhase,
    required this.sizeW,
    required this.sizeH,
    required this.isFrozen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw raw background magnetic fields (Ticker tape lines)
    final bgPaint = Paint()
      ..color = kBrassCopper.withAlpha(isFrozen ? 5 : 12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i < 10; i++) {
      double y = size.height * (i / 10);
      final bp = Path();
      for (double x = 0; x <= size.width; x += 20) {
        double wave = math.sin(x * 0.05 + humPhase + (i * 0.5)) * 4.0;
        if (x == 0) {
          bp.moveTo(x, y + wave);
        } else {
          bp.lineTo(x, y + wave);
        }
      }
      canvas.drawPath(bp, bgPaint);
    }

    // 2. Transpose generated Square Waves from each node
    final wavePaint = Paint()
      ..color = kBrassCopper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.miter
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3); // Glow!

    final freezePaint = Paint()
      ..color = kBrassCopper.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var n in nodes) {
      if (n.waveBuffer.every((v) => v == 0.0)) {
        continue; // Optimization: don't draw flatlines over nothing if empty
      }

      final path = Path();

      // We draw from the node horizontally to the left (like tape unspooling)
      double currentX = n.x;
      const double stepSpeed =
          3.5; // How fast the wave moves left per buffer tick
      const double maxAmp = 45.0; // How tall the square wave gets

      path.moveTo(currentX, n.y - n.waveBuffer[0] * maxAmp);

      for (int b = 0; b < n.waveBuffer.length; b++) {
        double px = n.x - (b * stepSpeed);
        double py = n.y - (n.waveBuffer[b] * maxAmp);

        // Square wave horizontal drag
        path.lineTo(px, py);

        // Vertical transient jump to the next state (if available)
        if (b < n.waveBuffer.length - 1) {
          double nextPy = n.y - (n.waveBuffer[b + 1] * maxAmp);
          path.lineTo(px, nextPy);
        }
      }

      canvas.drawPath(path, isFrozen ? freezePaint : wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmFieldPainter old) => true;
}
