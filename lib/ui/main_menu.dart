import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  const MainMenuScreen({super.key, required this.onStartGame});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _scanCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _entryCtrl;

  late Animation<double> _pulse;
  late Animation<double> _scan;
  late Animation<double> _bgAnim;
  late Animation<double> _entryAnim;

  final _random = Random();
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 80; i++) {
      _stars.add(_Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 0.5,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.6 + 0.2,
      ));
    }

    _pulseCtrl = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)..repeat(reverse: true);
    _scanCtrl = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _bgCtrl = AnimationController(duration: const Duration(seconds: 8), vsync: this)..repeat(reverse: true);
    _entryCtrl = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..forward();

    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _scan = Tween<double>(begin: 0.0, end: 1.0).animate(_scanCtrl);
    _bgAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));
    _entryAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scanCtrl.dispose();
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _scanCtrl, _bgCtrl, _entryCtrl]),
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3 + _bgAnim.value * 0.2),
              radius: 1.4,
              colors: [
                Color.lerp(const Color(0xFF0D0020), const Color(0xFF200010), _bgAnim.value)!,
                InfernoColors.menuBg1,
                InfernoColors.void_,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Star field
              CustomPaint(
                painter: _StarFieldPainter(_stars, _scan.value),
                size: Size.infinite,
              ),
              // Scanline effect
              CustomPaint(
                painter: _ScanlinePainter(_scan.value),
                size: Size.infinite,
              ),
              // Red grid floor (perspective)
              CustomPaint(
                painter: _GridFloorPainter(_pulse.value),
                size: Size.infinite,
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo block
                    Transform.translate(
                      offset: Offset(0, (1.0 - _entryAnim.value) * -60),
                      child: Opacity(
                        opacity: _entryAnim.value,
                        child: _buildLogo(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle tagline
                    Transform.translate(
                      offset: Offset(0, (1.0 - _entryAnim.value) * -30),
                      child: Opacity(
                        opacity: (_entryAnim.value - 0.2).clamp(0, 1),
                        child: _buildTagline(),
                      ),
                    ),
                    const SizedBox(height: 56),
                    // Buttons
                    Opacity(
                      opacity: (_entryAnim.value - 0.4).clamp(0, 1),
                      child: Column(
                        children: [
                          _buildStartButton(),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Footer
                    Opacity(
                      opacity: (_entryAnim.value - 0.6).clamp(0, 1),
                      child: _buildFooter(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    double glowAmt = 0.5 + _pulse.value * 0.5;
    return Column(
      children: [
        // Main title
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow layer
            Text(
              'INFERNO',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: InfernoColors.menuTitle.withOpacity(glowAmt * 0.4),
                letterSpacing: 12,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(color: InfernoColors.menuTitle.withOpacity(glowAmt * 0.6), blurRadius: 40),
                  Shadow(color: InfernoColors.menuTitle.withOpacity(0.4), blurRadius: 80),
                ],
              ),
            ),
            // Sharp layer
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  InfernoColors.menuTitle,
                  Color(0xFFAA0020),
                ],
              ).createShader(bounds),
              child: const Text(
                'INFERNO',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        // "2D" with line decorations
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 60, height: 1, color: InfernoColors.menuTitle.withOpacity(0.5)),
            const SizedBox(width: 16),
            Text(
              '2D  MOBILE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: InfernoColors.menuTitle.withOpacity(0.7),
                letterSpacing: 10,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 16),
            Container(width: 60, height: 1, color: InfernoColors.menuTitle.withOpacity(0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      'DESCEND.  SURVIVE.  ESCAPE.',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: InfernoColors.textSecondary.withOpacity(0.7),
        letterSpacing: 4,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildStartButton() {
    double glow = 0.4 + _pulse.value * 0.6;
    return GestureDetector(
      onTap: widget.onStartGame,
      child: Container(
        width: 260,
        height: 58,
        decoration: BoxDecoration(
          color: InfernoColors.menuButton,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: InfernoColors.menuButtonBorder.withOpacity(glow),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: InfernoColors.playerCore.withOpacity(glow * 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left accent bar
            Positioned(
              left: 14,
              child: Container(
                width: 3,
                height: 20,
                color: InfernoColors.menuButtonBorder.withOpacity(glow),
              ),
            ),
            Text(
              'NUEVA PARTIDA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: InfernoColors.menuButtonText,
                letterSpacing: 4,
                fontFamily: 'monospace',
              ),
            ),
            // Right accent bar
            Positioned(
              right: 14,
              child: Container(
                width: 3,
                height: 20,
                color: InfernoColors.menuButtonBorder.withOpacity(glow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 30, height: 1, color: InfernoColors.textSecondary.withOpacity(0.3)),
            const SizedBox(width: 12),
            Text(
              'FLUTTER & DART  •  SIN MOTORES EXTERNOS',
              style: TextStyle(
                fontSize: 9,
                color: InfernoColors.textSecondary.withOpacity(0.4),
                letterSpacing: 3,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 30, height: 1, color: InfernoColors.textSecondary.withOpacity(0.3)),
          ],
        ),
      ],
    );
  }
}

class _Star {
  double x, y, size, speed, opacity;
  _Star({required this.x, required this.y, required this.size, required this.speed, required this.opacity});
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;
  _StarFieldPainter(this.stars, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      double twinkle = (0.6 + 0.4 * sin(time * 2 * pi * s.speed + s.x * 10));
      final paint = Paint()..color = Colors.white.withOpacity(s.opacity * twinkle);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => true;
}

class _ScanlinePainter extends CustomPainter {
  final double time;
  _ScanlinePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.025);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
    // Moving scan line
    double scanY = (time * size.height) % size.height;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          InfernoColors.playerCore.withOpacity(0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 60, size.width, 120));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 60, size.width, 120), scanPaint);
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => true;
}

class _GridFloorPainter extends CustomPainter {
  final double pulse;
  _GridFloorPainter(this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    double horizon = size.height * 0.72;
    int lines = 14;
    int cols = 20;

    Color lineColor = InfernoColors.menuTitle.withOpacity(0.12 + pulse * 0.05);
    final paint = Paint()..color = lineColor..strokeWidth = 0.8;

    // Horizontal lines (perspective)
    for (int i = 0; i <= lines; i++) {
      double t = i / lines;
      double y = horizon + (size.height - horizon) * t;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines converging at vanishing point
    double vx = size.width / 2;
    for (int i = 0; i <= cols; i++) {
      double t = i / cols;
      double bx = size.width * t;
      canvas.drawLine(Offset(vx, horizon), Offset(bx, size.height), paint);
    }

    // Fade overlay at top of grid
    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [InfernoColors.menuBg1, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, horizon - 40, size.width, 60));
    canvas.drawRect(Rect.fromLTWH(0, horizon - 40, size.width, 60), fadePaint);
  }

  @override
  bool shouldRepaint(_GridFloorPainter old) => true;
}
