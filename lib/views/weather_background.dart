import 'dart:math';
import 'package:flutter/material.dart';

enum WeatherCondition { sunny, snowy, cloudy, rainy, thunder, fog, unknown }

class WeatherBackground extends StatelessWidget {
  final String conditionText;
  final int conditionCode;

  const WeatherBackground({super.key, required this.conditionText, required this.conditionCode});

  WeatherCondition _getCondition(int code) {
    switch (code) {
      case 1000:
        return WeatherCondition.sunny;
      case 1003:
      case 1006:
      case 1009:
        return WeatherCondition.cloudy;
      case 1030:
      case 1135:
      case 1147:
        return WeatherCondition.fog;
      case 1063:
      case 1150:
      case 1153:
      case 1168:
      case 1171:
      case 1180:
      case 1183:
      case 1186:
      case 1189:
      case 1192:
      case 1195:
      case 1198:
      case 1201:
      case 1240:
      case 1243:
      case 1246:
        return WeatherCondition.rainy;
      case 1066:
      case 1114:
      case 1117:
      case 1210:
      case 1213:
      case 1216:
      case 1219:
      case 1222:
      case 1225:
      case 1255:
      case 1258:
      case 1069:
      case 1072:
      case 1204:
      case 1207:
      case 1237:
      case 1249:
      case 1252:
      case 1261:
      case 1264:
        return WeatherCondition.snowy;
      case 1087:
      case 1273:
      case 1276:
      case 1279:
      case 1282:
        return WeatherCondition.thunder;
      default:
        return _fallbackCondition(conditionText);
    }
  }

  WeatherCondition _fallbackCondition(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('kar') || lower.contains('snow')) return WeatherCondition.snowy;
    if (lower.contains('güneş') || lower.contains('sunny') || lower.contains('clear'))
      return WeatherCondition.sunny;
    if (lower.contains('yağmur') || lower.contains('rain')) return WeatherCondition.rainy;
    if (lower.contains('sis') || lower.contains('fog') || lower.contains('mist'))
      return WeatherCondition.fog;
    if (lower.contains('gök gürültüsü') || lower.contains('thunder'))
      return WeatherCondition.thunder;
    return WeatherCondition.cloudy;
  }

  @override
  Widget build(BuildContext context) {
    final condition = _getCondition(conditionCode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundGradient(condition),
        ),
      ),
      child: _getWeatherEffect(condition),
    );
  }

  List<Color> _getBackgroundGradient(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return [const Color(0xFF4FA8C5), const Color(0xFF85D8CE)]; // Sky blue to teal
      case WeatherCondition.cloudy:
        return [const Color(0xFF6E8594), const Color(0xFF93A7B6)]; // Grey blue
      case WeatherCondition.rainy:
        return [const Color(0xFF37474F), const Color(0xFF546E7A)]; // Dark slate
      case WeatherCondition.snowy:
        return [const Color(0xFF90A4AE), const Color(0xFFCFD8DC)]; // Cold grey/white
      case WeatherCondition.thunder:
        return [const Color(0xFF212121), const Color(0xFF37474F)]; // Very dark
      case WeatherCondition.fog:
        return [const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)]; // Misty grey
      default:
        return [const Color(0xFF6E8594), const Color(0xFF93A7B6)];
    }
  }

  Widget _getWeatherEffect(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.snowy:
        return const SnowEffect();
      case WeatherCondition.sunny:
        return const SunEffect();
      case WeatherCondition.cloudy:
        return const CloudEffect();
      case WeatherCondition.rainy:
        return const RainEffect();
      case WeatherCondition
            .fog: // Reusing CloudEffect with modifications for Fog could be better, but keeping simple
        return const CloudEffect(isFog: true);
      case WeatherCondition.thunder:
        return const ThunderEffect();
      default:
        return const CloudEffect();
    }
  }
}

// --- Effects ---

class SunEffect extends StatefulWidget {
  const SunEffect({super.key});

  @override
  State<SunEffect> createState() => _SunEffectState();
}

class _SunEffectState extends State<SunEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SunPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class SunPainter extends CustomPainter {
  final double animationValue;

  SunPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.85, size.height * 0.15); // Top right
    final radius = 60.0;

    // Sun Body
    final paintSun = Paint()
      ..color = const Color(0xFFFFC107) // Amber
      ..style = PaintingStyle.fill;

    // Sun Glow
    final paintGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFCA28).withOpacity(0.6),
          const Color(0xFFFFCA28).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 3));

    canvas.drawCircle(center, radius * 3, paintGlow);
    canvas.drawCircle(center, radius, paintSun);

    // Rays
    final paintRay = Paint()
      ..color = const Color(0xFFFFCA28).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final rayCount = 12;
    final rayLength = 30.0;
    final rotationOffset = animationValue * 2 * pi;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi / rayCount) + rotationOffset;
      final start = center + Offset(cos(angle), sin(angle)) * (radius + 10);
      final end = center + Offset(cos(angle), sin(angle)) * (radius + 10 + rayLength);
      canvas.drawLine(start, end, paintRay);
    }

    // Ambient light particles (dust motes)
    final random =
        Random(42); // Fixed seed for stable background particles if needed, but here we animate
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.2);

    // Draw some floating particles to give atmosphere
    for (int i = 0; i < 30; i++) {
      double x = (random.nextDouble() * size.width + animationValue * 50) % size.width;
      double y = (random.nextDouble() * size.height + animationValue * 20) % size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SunPainter oldDelegate) => true;
}

class CloudEffect extends StatefulWidget {
  final bool isFog;
  const CloudEffect({super.key, this.isFog = false});

  @override
  State<CloudEffect> createState() => _CloudEffectState();
}

class _CloudEffectState extends State<CloudEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CloudShape> _clouds = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _initClouds();
  }

  void _initClouds() {
    final random = Random();
    for (int i = 0; i < 5; i++) {
      _clouds.add(CloudShape(
          x: random.nextDouble() * 400,
          y: random.nextDouble() * 200,
          scale: 0.8 + random.nextDouble() * 0.7,
          speed: 0.2 + random.nextDouble() * 0.3));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CloudPainter(_clouds, _controller.value, isFog: widget.isFog),
          size: Size.infinite,
        );
      },
    );
  }
}

class CloudShape {
  double x;
  double y;
  double scale;
  double speed;
  CloudShape({required this.x, required this.y, required this.scale, required this.speed});
}

class CloudPainter extends CustomPainter {
  final List<CloudShape> clouds;
  final double animationValue;
  final bool isFog;

  CloudPainter(this.clouds, this.animationValue, {this.isFog = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFog ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    if (isFog) {
      // Draw a full wash for fog
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = Colors.grey.withOpacity(0.2));
    }

    for (var cloud in clouds) {
      double currentX = (cloud.x + animationValue * 100 * cloud.speed) % (size.width + 200) - 100;

      canvas.save();
      canvas.translate(currentX, cloud.y);
      canvas.scale(cloud.scale);

      final path = Path();
      path.addOval(Rect.fromLTWH(0, 0, 60, 40));
      path.addOval(Rect.fromLTWH(25, -10, 70, 50));
      path.addOval(Rect.fromLTWH(50, 0, 60, 40));

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CloudPainter oldDelegate) => true;
}

class RainEffect extends StatefulWidget {
  const RainEffect({super.key});

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _raindrops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1) // Using 1 second loop for continuous feel
        )
      ..repeat();

    for (int i = 0; i < 150; i++) {
      _raindrops.add(_Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainPainter(_raindrops, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<_Particle> raindrops;
  final double
      animationValue; // Not strictly needed to pass if we update state, but good for pure animation

  _RainPainter(this.raindrops, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    for (var drop in raindrops) {
      drop.y += drop.speed * 10;
      if (drop.y > size.height) {
        drop.y = -20;
        drop.x = Random().nextDouble() * size.width;
      }

      // Draw angled rain
      final p1 = Offset(drop.x, drop.y);
      final p2 = Offset(drop.x - 5, drop.y + 15);

      paint.strokeWidth = drop.radius; // slight variation in thickness
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowEffect extends StatefulWidget {
  const SnowEffect({super.key});

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _snowflakes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    for (int i = 0; i < 100; i++) {
      _snowflakes.add(_Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SnowPainter(_snowflakes),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SnowPainter extends CustomPainter {
  final List<_Particle> snowflakes;

  _SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (var flake in snowflakes) {
      flake.y += flake.speed * 2;
      // Add drift
      flake.x += sin(flake.y * 0.05) * 0.5;

      if (flake.y > size.height) {
        flake.y = -10;
        flake.x = Random().nextDouble() * size.width;
      }

      canvas.drawCircle(Offset(flake.x, flake.y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ThunderEffect extends StatefulWidget {
  const ThunderEffect({super.key});

  @override
  State<ThunderEffect> createState() => _ThunderEffectState();
}

class _ThunderEffectState extends State<ThunderEffect> {
  bool _flash = false;

  @override
  void initState() {
    super.initState();
    _startThunderLoop();
  }

  void _startThunderLoop() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: Random().nextInt(5) + 3));
      if (mounted) {
        setState(() => _flash = true);
        await Future.delayed(const Duration(milliseconds: 100)); // Quick flash
        if (mounted) setState(() => _flash = false);
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) setState(() => _flash = true); // Double flash often happens
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) setState(() => _flash = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Heavy Rain Background
        const RainEffect(),
        // Dark clouds
        const CloudEffect(),
        // Flash overlay
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          color: _flash ? Colors.white.withOpacity(0.3) : Colors.transparent,
        ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double speed;

  _Particle(Random random)
      : x = random.nextDouble() * 400, // Initial bounds, will be wrapped in painter
        y = random.nextDouble() * 800,
        radius = random.nextDouble() * 2 + 1,
        speed = random.nextDouble() * 2 + 0.5;
}
