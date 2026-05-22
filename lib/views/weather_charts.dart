import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:intl/intl.dart';

class HourlyTemperatureChart extends StatelessWidget {
  final List<HourlyWeather> hourlyWeather;

  const HourlyTemperatureChart({super.key, required this.hourlyWeather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Filter for the next 24 hours or just take the list as is if it's already filtered
    final chartData = hourlyWeather;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saatlik Sıcaklık',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                majorGridLines: const MajorGridLines(width: 0),
                labelPlacement: LabelPlacement.onTicks,
                interval: 4, // Show every 4th hour label to avoid crowding
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                minimum: chartData.map((e) => e.temperature).reduce((a, b) => a < b ? a : b) - 2,
                maximum: chartData.map((e) => e.temperature).reduce((a, b) => a > b ? a : b) + 2,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <SplineSeries<HourlyWeather, String>>[
                SplineSeries<HourlyWeather, String>(
                  dataSource: chartData,
                  xValueMapper: (HourlyWeather weather, _) {
                    // Extract just the hour "HH:mm" from "YYYY-MM-DD HH:mm"
                    try {
                      final dt = DateTime.parse(weather.time);
                      return DateFormat('HH:mm').format(dt);
                    } catch (e) {
                      return weather.time.split(' ').last;
                    }
                  },
                  yValueMapper: (HourlyWeather weather, _) => weather.temperature,
                  name: 'Sıcaklık',
                  color: theme.colorScheme.primary,
                  markerSettings: const MarkerSettings(isVisible: false),
                  width: 3,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyPrecipitationChart extends StatelessWidget {
  final List<DailyWeather> dailyWeather;

  const DailyPrecipitationChart({super.key, required this.dailyWeather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yağış İhtimali',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
                labelFormat: '{value}%',
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ColumnSeries<DailyWeather, String>>[
                ColumnSeries<DailyWeather, String>(
                  dataSource: dailyWeather,
                  xValueMapper: (DailyWeather weather, _) {
                    try {
                      final dt = DateTime.parse(weather.date);
                      return DateFormat('EEE', 'tr').format(dt); // Short day name
                    } catch (e) {
                      return weather.date;
                    }
                  },
                  yValueMapper: (DailyWeather weather, _) => weather.dailyChanceOfRain,
                  name: 'Yağış',
                  color: theme.colorScheme.tertiary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AstroDetailsGrid extends StatelessWidget {
  final Weather weather;

  const AstroDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather.dailyWeather.isEmpty) return const SizedBox.shrink();

    // Uses the first day's astro data
    final today = weather.dailyWeather[0];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildGridItem(context, Icons.sunny, 'UV İndeksi', '${weather.uv}'),
        _buildGridItem(context, Icons.water_drop, 'Nem', '${weather.humidity}%'),
        _buildGridItem(context, Icons.air, 'Rüzgar', '${weather.windSpeed} km/h'),
        _buildGridItem(context, Icons.compress, 'Basınç', '${weather.pressureMb} mb'),
        _buildGridItem(context, Icons.wb_twilight, 'Gün Doğumu', today.sunrise),
        _buildGridItem(context, Icons.nights_stay, 'Gün Batımı', today.sunset),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
