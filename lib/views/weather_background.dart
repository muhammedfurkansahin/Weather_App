import 'dart:math';
import 'package:flutter/material.dart';

enum WeatherCondition { sunny, snowy, cloudy, rainy, thunder, fog, unknown }

class WeatherBackground extends StatelessWidget {
  final String conditionText;
  final int conditionCode;

  const WeatherBackground({super.key, required this.conditionText, required this.conditionCode});

  WeatherCondition _getCondition(int code) {
    // Mapping codes provided by user
    switch (code) {
      // Sunny / Clear
      case 1000:
        return WeatherCondition.sunny;

      // Cloudy
      case 1003: // Partly cloudy
      case 1006: // Cloudy
      case 1009: // Overcast
        return WeatherCondition.cloudy;

      // Fog / Mist
      case 1030: // Mist
      case 1135: // Fog
      case 1147: // Freezing fog
        return WeatherCondition.fog;

      // Rain / Drizzle / Sleet
      case 1063: // Patchy rain possible
      case 1150: // Patchy light drizzle
      case 1153: // Light drizzle
      case 1168: // Freezing drizzle
      case 1171: // Heavy freezing drizzle
      case 1180: // Patchy light rain
      case 1183: // Light rain
      case 1186: // Moderate rain at times
      case 1189: // Moderate rain
      case 1192: // Heavy rain at times
      case 1195: // Heavy rain
      case 1198: // Light freezing rain
      case 1201: // Moderate or heavy freezing rain
      case 1240: // Light rain shower
      case 1243: // Moderate or heavy rain shower
      case 1246: // Torrential rain shower
        return WeatherCondition.rainy;

      // Snow / Ice
      case 1066: // Patchy snow possible
      case 1114: // Blowing snow
      case 1117: // Blizzard
      case 1210: // Patchy light snow
      case 1213: // Light snow
      case 1216: // Patchy moderate snow
      case 1219: // Moderate snow
      case 1222: // Patchy heavy snow
      case 1225: // Heavy snow
      case 1255: // Light snow showers
      case 1258: // Moderate or heavy snow showers
      // Mixing sleet/ice with snow for simplicity
      case 1069: // Patchy sleet possible
      case 1072: // Patchy freezing drizzle possible
      case 1204: // Light sleet
      case 1207: // Moderate or heavy sleet
      case 1237: // Ice pellets
      case 1249: // Light sleet showers
      case 1252: // Moderate or heavy sleet showers
      case 1261: // Light showers of ice pellets
      case 1264: // Moderate or heavy showers of ice pellets
        return WeatherCondition.snowy;

      // Thunder
      case 1087: // Thundery outbreaks possible
      case 1273: // Patchy light rain with thunder
      case 1276: // Moderate or heavy rain with thunder
      case 1279: // Patchy light snow with thunder
      case 1282: // Moderate or heavy snow with thunder
        return WeatherCondition.thunder;

      default:
        // Fallback to text matching if code is unknown
        if (conditionText.toLowerCase().contains('kar') ||
            conditionText.toLowerCase().contains('snow')) return WeatherCondition.snowy;
        if (conditionText.toLowerCase().contains('güneş') ||
            conditionText.toLowerCase().contains('sunny') ||
            conditionText.toLowerCase().contains('clear')) return WeatherCondition.sunny;
        if (conditionText.toLowerCase().contains('yağmur') ||
            conditionText.toLowerCase().contains('rain')) return WeatherCondition.rainy;
        return WeatherCondition.cloudy; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = _getCondition(conditionCode);

    switch (condition) {
      case WeatherCondition.snowy:
        return const SnowEffect();
      case WeatherCondition.sunny:
        return const SunEffect();
      case WeatherCondition.cloudy:
        return const CloudEffect();
      case WeatherCondition.rainy:
        return const RainEffect();
      case WeatherCondition.fog:
        return const FogEffect();
      case WeatherCondition.thunder:
        return const ThunderEffect();
      default:
        return const CloudEffect();
    }
  }
}

// --- Effects ---

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
      duration: const Duration(seconds: 10),
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

class _Particle {
  double x;
  double y;
  double radius;
  double speed;

  _Particle(Random random)
      : x = random.nextDouble() * 400,
        y = random.nextDouble() * 800,
        radius = random.nextDouble() * 2 + 1,
        speed = random.nextDouble() * 2 + 1;
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
      double newY = (flake.y + flake.speed);
      if (newY > size.height) {
        newY = -10;
        flake.x = Random().nextDouble() * size.width;
      }
      flake.y = newY;

      canvas.drawCircle(Offset(flake.x, flake.y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.wb_sunny,
              size: 300,
              color: Colors.orange.withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 50,
                    spreadRadius: 20,
                  )
                ]),
          ),
        ),
      ],
    );
  }
}

class CloudEffect extends StatefulWidget {
  const CloudEffect({super.key});

  @override
  State<CloudEffect> createState() => _CloudEffectState();
}

class _CloudEffectState extends State<CloudEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
        return Stack(
          children: [
            _buildCloud(100 + _controller.value * 20, 50, 80, 0.4),
            _buildCloud(250 - _controller.value * 50, 150, 60, 0.3),
            _buildCloud(50 + _controller.value * 30, 300, 100, 0.2),
          ],
        );
      },
    );
  }

  Widget _buildCloud(double x, double y, double size, double opacity) {
    return Positioned(
      left: x,
      top: y,
      child: Icon(
        Icons.cloud,
        size: size,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
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
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    for (int i = 0; i < 100; i++) {
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
          painter: _RainPainter(_raindrops),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<_Particle> raindrops;

  _RainPainter(this.raindrops);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var drop in raindrops) {
      double newY = (drop.y + drop.speed * 4); // Faster than snow
      if (newY > size.height) {
        newY = -20;
        drop.x = Random().nextDouble() * size.width;
      }
      drop.y = newY;

      canvas.drawLine(
          Offset(drop.x, drop.y),
          Offset(drop.x - 2, drop.y + 10), // Angled rain
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FogEffect extends StatelessWidget {
  const FogEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
            Colors.grey.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}

class ThunderEffect extends StatefulWidget {
  const ThunderEffect({super.key});

  @override
  State<ThunderEffect> createState() => _ThunderEffectState();
}

class _ThunderEffectState extends State<ThunderEffect> {
  // We can reuse RainEffect and overlay flashes

  bool _flash = false;

  @override
  void initState() {
    super.initState();
    _startThunderLoop();
  }

  void _startThunderLoop() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: Random().nextInt(5) + 2));
      if (mounted) {
        setState(() => _flash = true);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => _flash = false);
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) setState(() => _flash = true);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) setState(() => _flash = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const RainEffect(), // Thunder usually comes with rain
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          color: _flash ? Colors.white.withOpacity(0.3) : Colors.transparent,
          child: _flash
              ? const Center(child: Icon(Icons.flash_on, color: Colors.yellow, size: 100))
              : null,
        ),
      ],
    );
  }
}
