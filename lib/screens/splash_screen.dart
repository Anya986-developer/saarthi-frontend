import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

//  COLOUR CONSTANTS (Theme Matching)
const Color kNavy    = Color(0xFF0C447C);
const Color kBlue    = Color(0xFF185FA5);
const Color kMidBlue = Color(0xFF378ADD);
const Color kBgBlue  = Color(0xFFF4F8FD);
const Color kSaffron = Color(0xFFFF9933);
const Color kGreen   = Color(0xFF138808);

class SchemeSarthiSplash extends StatefulWidget {
  final VoidCallback? onComplete;
  const SchemeSarthiSplash({super.key, this.onComplete});

  @override
  State<SchemeSarthiSplash> createState() => _SchemeSarthiSplashState();
}

class _SchemeSarthiSplashState extends State<SchemeSarthiSplash> with TickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _revealCtrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. 3D Spin Animation (Rotates the seal)
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 2. Continuous Pulsing Aura (After it lands)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 3. Reveal Animation (Text sliding up)
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Start text reveal and the 3D spin
    _revealCtrl.forward();

    // Use an elastic/ease-out curve so it spins fast then locks smoothly
    _spinCtrl.animateTo(1.0, curve: Curves.easeOutCubic);

    // Wait 3.5 seconds total, then navigate
    _timer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlue,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, kBgBlue],
                ),
              ),
            ),
          ),

          // Subtle Dot Grid
          const _DotGrid(),

          // Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // --- 3D Spinning Seal & Background Rings ---
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Static Concentric Rings
                      const _RingDecorations(),

                      // 2. Ambient glowing pulsing aura
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, child) {
                          return Container(
                            width: 250 + (_pulseCtrl.value * 20),
                            height: 250 + (_pulseCtrl.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kMidBlue.withOpacity(0.05 - (_pulseCtrl.value * 0.02)),
                            ),
                          );
                        },
                      ),

                      // 3. 3D Spinning Seal
                      AnimatedBuilder(
                        animation: _spinCtrl,
                        builder: (context, child) {
                          // 3.5 full rotations (7 * pi)
                          final angle = _spinCtrl.value * pi * 7;

                          // Calculate if we are looking at the front or back
                          // Normalizing angle to 0 - 2pi to check facing direction
                          final normalizedAngle = angle % (pi * 2);
                          final isFront = normalizedAngle < (pi / 2) || normalizedAngle > (pi * 3 / 2);

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002) // 3D Perspective depth
                              ..rotateY(angle), // Spin on Y axis
                            child: isFront
                                ? _buildSealFront()
                                : Transform(
                              // Mirror the back face so it's not drawn backwards!
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: _buildSealBack(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // --- Text Reveal ---
                AnimatedBuilder(
                    animation: _revealCtrl,
                    builder: (context, child) {
                      final slideUp = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).evaluate(
                          CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutBack)
                      );
                      final fade = Tween<double>(begin: 0.0, end: 1.0).evaluate(
                          CurvedAnimation(parent: _revealCtrl, curve: Curves.easeIn)
                      );

                      return Opacity(
                        opacity: fade,
                        child: SlideTransition(
                          position: AlwaysStoppedAnimation(slideUp),
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(children: [
                                  TextSpan(text: 'Scheme ', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: kNavy, letterSpacing: -0.5)),
                                  TextSpan(text: 'Sarthi', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: kMidBlue, letterSpacing: -0.5)),
                                ]),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: kMidBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'GOVERNMENT SCHEME ELIGIBILITY ENGINE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold,
                                    color: kBlue, letterSpacing: 2.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),

                const Spacer(flex: 3),

                // --- Loading Bar & Footer ---
                AnimatedBuilder(
                  animation: _revealCtrl,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _revealCtrl.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 3,
                        child: LinearProgressIndicator(
                          backgroundColor: kMidBlue.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(kMidBlue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _miniFlag(),
                          const SizedBox(width: 8),
                          const Text('MADE FOR BHARAT', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xFF8AAAC8), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // FRONT OF SEAL (White & Gold/Saffron/Green accents)
  Widget _buildSealFront() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E8F0), width: 3),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner Tricolor Ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent),
              gradient: const SweepGradient(
                colors: [kSaffron, Colors.white, kGreen, Colors.white, kSaffron],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),

          // Center Icon
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBgBlue,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 45,
              color: kBlue,
            ),
          ),
        ],
      ),
    );
  }

  // BACK OF SEAL (Uploaded Document Image)
  Widget _buildSealBack() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kMidBlue, kNavy],
        ),
        border: Border.all(color: kSaffron.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 85,
          height: 85,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/image_001137.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _miniFlag() {
    return Row(
      children: [
        Container(width: 8, height: 6, decoration: BoxDecoration(color: kSaffron, borderRadius: BorderRadius.circular(1))),
        const SizedBox(width: 2),
        Container(width: 8, height: 6, decoration: BoxDecoration(color: const Color(0xFFE8EEF6), borderRadius: BorderRadius.circular(1))),
        const SizedBox(width: 2),
        Container(width: 8, height: 6, decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(1))),
      ],
    );
  }
}

//  RING DECORATIONS
class _RingDecorations extends StatelessWidget {
  const _RingDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _ring(380, const Color(0xFFEAF2FA)),
        _ring(320, const Color(0xFFDCE9F5)),
        _ring(260, const Color(0xFFC8DFF2)),
        Container(
          width: 340,
          height: 340,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF5DBDFF).withOpacity(0.25),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ring(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 0.75),
      ),
    );
  }
}


//  BACKGROUND DOT GRID
class _DotGrid extends StatelessWidget {
  const _DotGrid();
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.04,
      child: CustomPaint(size: Size.infinite, painter: _DotGridPainter()),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kBlue..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}