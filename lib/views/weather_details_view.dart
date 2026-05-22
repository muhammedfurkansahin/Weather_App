import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/languages/text_widgets.dart';
import 'package:weather_app/views/weather_background.dart';
import 'package:weather_app/views/weather_charts.dart';

class WeatherDetailsView extends StatefulWidget {
  final Weather weather;
  final bool showBackButton;

  const WeatherDetailsView({
    super.key,
    required this.weather,
    this.showBackButton = true,
  });

  @override
  State<WeatherDetailsView> createState() => _WeatherDetailsViewState();
}

class _WeatherDetailsViewState extends State<WeatherDetailsView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Background Layer
        // Background Layer
        // Removed redundant container as WeatherBackground handles the gradient now
        Positioned.fill(
          child: WeatherBackground(
            conditionText: widget.weather.description,
            conditionCode: widget.weather.conditionCode,
          ),
        ),

        // Content Layer
        SafeArea(
          child: Column(
            children: [
              if (widget.showBackButton)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: theme.colorScheme.onSurface,
                            size: 2.5.h,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Expanded(
                          child: Center(
                        child: Text(
                          widget.weather.cityName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 2.2.h,
                          ),
                        ),
                      )),
                      SizedBox(width: 10.w), // Balance for centering
                    ],
                  ),
                ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 2.h),
                                _buildMainWeatherCard(context),
                                SizedBox(height: 3.h),
                                // New Grid for UV, Pressure, Astro
                                AstroDetailsGrid(weather: widget.weather),
                                SizedBox(height: 3.h),
                                // Hourly Temp Chart
                                HourlyTemperatureChart(hourlyWeather: widget.weather.hourlyWeather),
                                SizedBox(height: 3.h),
                                // Daily Precip Chart
                                DailyPrecipitationChart(dailyWeather: widget.weather.dailyWeather),
                                SizedBox(height: 3.h),
                                // Keeping Daily Forecast list as it's useful
                                _buildDailyForecast(context),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.network(
            widget.weather.icon,
            width: 12.h,
            height: 12.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.cloud,
                size: 100,
                color: theme.colorScheme.primary,
              );
            },
          ),
          SizedBox(height: 2.h),
          Text(
            '${widget.weather.temperature}${MeasureUnit.centigrade}',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            widget.weather.description,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Günlük Tahmin',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.weather.dailyWeather
            .map((daily) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(daily.date,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Image.network(daily.icon, width: 32, height: 32),
                      const SizedBox(width: 16),
                      Text('${daily.maxTemp}° / ${daily.minTemp}°',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }
}
