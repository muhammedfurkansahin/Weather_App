import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [

            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.03),
            theme.colorScheme.tertiary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 3,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: _buildErrorCard(
                context,
                '${ErrorMessage.error}: ${snapshot.error}',
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

  Widget _buildErrorCard(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(

            color: theme.colorScheme.error.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            return _buildEmptyState(context);
          } else if (favoriteState is FavoriteLoaded) {
            return _favoriteWeatherBlocProvider(context);
          }
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: EdgeInsets.all(8.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6.w),
          boxShadow: [
            BoxShadow(

              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 5.w,
              offset: Offset(0, 2.w),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(

                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 8.h,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              ProjectKeywords.addFavoriteCity,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 2.2.h,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Text(
              'Favori şehirlerinizi ekleyerek hava durumunu kolayca takip edin',
              style: theme.textTheme.bodyMedium?.copyWith(

                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 1.8.h,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  BlocProvider<WeatherCubit> _favoriteWeatherBlocProvider(BuildContext context) {
    return BlocProvider(
      create: (context) => BlocProvider.of<WeatherCubit>(context),
      child: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, weatherState) {
          if (weatherState is WeatherLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
            );
          } else if (weatherState is WeathersLoaded) {
            return _favoriteListView(context, weatherState);
          } else if (weatherState is WeatherError) {
            return Center(
              child: _buildErrorCard(context, '${ErrorMessage.error}: ${weatherState.message}'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _favoriteListView(BuildContext context, WeathersLoaded weatherState) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        final favoriteCubit = BlocProvider.of<FavoriteCubit>(context);
        if (favoriteCubit.state is FavoriteLoaded) {
          final favoriteCities = (favoriteCubit.state as FavoriteLoaded).favorites;
          await BlocProvider.of<WeatherCubit>(context).fetchWeatherForCities(favoriteCities);
        }
      },
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: weatherState.weathers.length,
        itemBuilder: (context, index) {
          final weather = weatherState.weathers[index];
          return Dismissible(
            key: ValueKey(weather.cityName),
            background: _buildDismissBackground(context),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              context.read<FavoriteCubit>().removeFavoriteCity(weather.cityName);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${weather.cityName} favorilerden kaldırıldı'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(

                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(

                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  childrenPadding: const EdgeInsets.all(20),
                  backgroundColor: theme.colorScheme.surface,
                  collapsedBackgroundColor: theme.colorScheme.surface,
                  iconColor: theme.colorScheme.primary,
                  collapsedIconColor: theme.colorScheme.primary,
                  title: _buildWeatherHeader(context, weather),
                  children: [
                    _buildWeatherDetails(context, weather),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Sil',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(BuildContext context, weather) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(

            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            weather.icon,
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.cloud,
                size: 48,
                color: theme.colorScheme.primary,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.cityName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${weather.temperature}${MeasureUnit.centigrade}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(

                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      weather.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetails(BuildContext context, weather) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.thermostat_rounded,
                      'Hissedilen',
                      '${weather.feelsLike}${MeasureUnit.centigrade}',
                      theme.colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,

                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.water_drop_rounded,
                      'Nem',
                      '${weather.humidity}${MeasureUnit.percent}',
                      theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Günlük Tahmin',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.dailyWeather.length,
            itemBuilder: (context, index) {
              final daily = weather.dailyWeather[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [

                      theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(

                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      daily.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Image.network(
                      daily.icon,
                      width: 36,
                      height: 36,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.cloud,
                          size: 36,
                          color: theme.colorScheme.primary,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${daily.maxTemp}°',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${daily.minTemp}°',
                      style: theme.textTheme.bodySmall?.copyWith(

                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(

            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
