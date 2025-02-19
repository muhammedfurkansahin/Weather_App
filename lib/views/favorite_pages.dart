import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/weather_state.dart';
import 'package:weather_app/cubit/favorite_cubit.dart';
import 'package:weather_app/cubit/favorite_state.dart';
import 'package:weather_app/languages/text_widgets.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.secondary.withOpacity(0.2),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '${ErrorMessage.error}: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            final sharedPreferences = snapshot.data!;
            return favoriteWeatherBlocProvider(context, sharedPreferences);
          }
        },
      ),
    );
  }

  BlocProvider<FavoriteCubit> favoriteWeatherBlocProvider(BuildContext context, SharedPreferences sharedPreferences) {
    return BlocProvider(
      create: (context) => FavoriteCubit(
        BlocProvider.of<WeatherCubit>(context),
        sharedPreferences,
      ),
      child: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, favoriteState) {
          if (favoriteState is FavoriteInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ProjectKeywords.addFavoriteCity,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
          } else if (favoriteState is FavoriteLoaded) {
            return _favoriteWeatherBlocProvider(context);
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }

  BlocProvider<WeatherCubit> _favoriteWeatherBlocProvider(BuildContext context) {
    return BlocProvider(
      create: (context) => BlocProvider.of<WeatherCubit>(context),
      child: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, weatherState) {
          if (weatherState is WeatherLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (weatherState is WeathersLoaded) {
            return _favoriteListView(context, weatherState);
          } else if (weatherState is WeatherError) {
            return Center(
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${ErrorMessage.error}: ${weatherState.message}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _favoriteListView(BuildContext context, WeathersLoaded weatherState) {
    return RefreshIndicator(
      onRefresh: () async {
        final favoriteCubit = BlocProvider.of<FavoriteCubit>(context);
        if (favoriteCubit.state is FavoriteLoaded) {
          final favoriteCities = (favoriteCubit.state as FavoriteLoaded).favorites;
          await BlocProvider.of<WeatherCubit>(context).fetchWeatherForCities(favoriteCities);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weatherState.weathers.length,
        itemBuilder: (context, index) {
          final weather = weatherState.weathers[index];
          return Dismissible(
            key: ValueKey(weather.cityName),
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              context.read<FavoriteCubit>().removeFavoriteCity(weather.cityName);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.purple.shade50,
                    ],
                  ),
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Image.network(
                        weather.icon,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.cityName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            Text(
                              '${weather.temperature}${MeasureUnit.centigrade}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWeatherDetail(
                            Icons.thermostat,
                            '${ProjectKeywords.feelsLike}: ${weather.feelsLike}${MeasureUnit.centigrade}',
                          ),
                          _buildWeatherDetail(
                            Icons.water_drop,
                            '${ProjectKeywords.humidity}: ${weather.humidity}${MeasureUnit.percent}',
                          ),
                          const Divider(color: Colors.purple),
                          const Text(
                            'Günlük Tahmin',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: weather.dailyWeather.map((daily) {
                                return Card(
                                  color: Colors.purple.shade50,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          daily.date,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.network(
                                          daily.icon,
                                          width: 40,
                                          height: 40,
                                        ),
                                        Text(
                                          '${daily.maxTemp}/${daily.minTemp}${MeasureUnit.centigrade}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
