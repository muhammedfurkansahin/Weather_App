import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/weather_state.dart';
import 'package:weather_app/cubit/favorite_cubit.dart';
import 'package:weather_app/cubit/favorite_state.dart';
import 'package:weather_app/languages/text_widgets.dart';
import 'package:weather_app/views/weather_details_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Provide a NEW WeatherCubit strictly for this page (List of Weathers)
    return BlocProvider<WeatherCubit>(
      create: (context) {
        final weatherCubit = WeatherCubit();
        final favoriteState = context.read<FavoriteCubit>().state;
        if (favoriteState is FavoriteLoaded) {
          if (favoriteState.favorites.isNotEmpty) {
            weatherCubit.fetchWeatherForCities(favoriteState.favorites);
          }
        }
        return weatherCubit;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.03),
              theme.colorScheme.tertiary.withOpacity(0.02),
            ],
          ),
        ),
        child: BlocListener<FavoriteCubit, FavoriteState>(
          listener: (context, state) {
            if (state is FavoriteLoaded) {
              if (state.favorites.isNotEmpty) {
                context.read<WeatherCubit>().fetchWeatherForCities(state.favorites);
              } else {
                // If favorites become empty, clear the weather list
                context.read<WeatherCubit>().fetchWeatherForCities([]);
              }
            }
          },
          child: BlocBuilder<FavoriteCubit, FavoriteState>(
            builder: (context, favoriteState) {
              if (favoriteState is FavoriteInitial) {
                return _buildEmptyState(context);
              } else if (favoriteState is FavoriteLoaded) {
                if (favoriteState.favorites.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildWeatherContent(context);
              }
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
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
        // Initial state or unexpected state
        return const SizedBox.shrink();
      },
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
              color: theme.colorScheme.primary.withOpacity(0.1),
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
                color: theme.colorScheme.primary.withOpacity(0.1),
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 1.8.h,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            color: theme.colorScheme.error.withOpacity(0.1),
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

  Widget _favoriteListView(BuildContext context, WeathersLoaded weatherState) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        final favoriteCubit = context.read<FavoriteCubit>();
        if (favoriteCubit.state is FavoriteLoaded) {
          final favoriteCities = (favoriteCubit.state as FavoriteLoaded).favorites;
          await context.read<WeatherCubit>().fetchWeatherForCities(favoriteCities);
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
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherDetailsPage(weather: weather),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildWeatherHeader(context, weather),
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
}
