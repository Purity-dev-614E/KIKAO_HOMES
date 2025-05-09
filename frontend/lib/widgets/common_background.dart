import 'package:flutter/material.dart';
import 'dart:math' as math;

class CommonBackground extends StatefulWidget {
  final Widget child;
  final String backgroundImage;
  
  const CommonBackground({
    Key? key, 
    required this.child,
    this.backgroundImage = 'assets/images/house.jpg',
  }) : super(key: key);

  @override
  State<CommonBackground> createState() => _CommonBackgroundState();
}

class _CommonBackgroundState extends State<CommonBackground> {
  double _parallaxOffset = 0.0;
  final List<Map<String, dynamic>> _particles = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize particles for background effect
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add({
        'x': random.nextDouble() * 1.0,
        'y': random.nextDouble() * 1.0,
        'size': random.nextDouble() * 4 + 1,
        'speed': random.nextDouble() * 0.02 + 0.01,
        'opacity': random.nextDouble() * 0.5 + 0.1,
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onHover: (event) {
          // Calculate parallax effect based on mouse position
          setState(() {
            _parallaxOffset = (event.position.dx / MediaQuery.of(context).size.width - 0.5) * 20;
          });
        },
        child: Stack(
          children: [
            // Background Image with Gradient Overlay and Parallax Effect
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuad,
              transform: Matrix4.translationValues(_parallaxOffset, 0, 0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            
            // Particle overlay effect
            CustomPaint(
              size: Size.infinite,
              painter: ParticlesPainter(_particles),
            ),

            // Content
            widget.child,
          ],
        ),
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  
  ParticlesPainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final x = particle['x'] * size.width;
      final y = particle['y'] * size.height;
      final particleSize = particle['size'];
      final opacity = particle['opacity'];
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}