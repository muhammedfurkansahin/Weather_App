import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/views/weather_details_view.dart';

class WeatherDetailsPage extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsPage({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // Transparent app bar to allow back navigation but let content shine through?
      // WeatherDetailsView handles back button internally if we want, or we can use AppBar here.
      // In WeatherDetailsView I added "showBackButton" logic.
      // So here we can just pass showBackButton: true.
      // We don't need a Scaffold AppBar if the View handles the header/back button.
      body: WeatherDetailsView(
        weather: weather,
        showBackButton: true,
      ),
    );
  }
}
