import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/languages/text_widgets.dart';
import 'package:weather_app/views/favorite_pages.dart';
import 'package:weather_app/views/search_page.dart';
import 'package:weather_app/cubit/favorite_cubit.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/weather_state.dart';
import 'package:weather_app/cubit/theme_cubit.dart';
import 'package:weather_app/views/weather_details_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 0.5.w,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '${ErrorMessage.error}: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 1.h,
                  ),
            ),
          );
        } else {
          final sharedPreferences = snapshot.data!;
          // Only provide FavoriteCubit here. WeatherCubit is provided in main.dart (MyApp).
          return BlocProvider(
            create: (context) => FavoriteCubit(
              sharedPreferences,
            ),
            child: const HomeView(),
          );
        }
      },
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready, though initState context is usually fine for reading providers if listen=false.
    // However, for async actions that might trigger rebuilds or navigations, this is safer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStartupWeather();
    });
  }

  Future<void> _loadStartupWeather({bool forceRefresh = false}) async {
    if (!mounted) return;
    final weatherCubit = context.read<WeatherCubit>();
    final favoriteCubit = context.read<FavoriteCubit>();

    // 1. Try Load Cached
    if (!forceRefresh) {
      await weatherCubit.loadCachedWeather();
    }

    // 2. Fetch Location & Update
    try {
      final position = await _determinePosition();
      if (!mounted) return;

      await weatherCubit.fetchWeatherByLocation(position.latitude, position.longitude);

      if (weatherCubit.state is WeatherLoaded) {
        final city = (weatherCubit.state as WeatherLoaded).weather.cityName;
        favoriteCubit.addFavoriteCity(city);
      }
    } catch (e) {
      debugPrint("Location error: $e");
      // Fallback
      if (weatherCubit.state is! WeatherLoaded) {
        await weatherCubit.fetchWeather('Istanbul');
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: _selectedIndex == 0,
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(
                ProjectKeywords.weather,
                style: theme.appBarTheme.titleTextStyle?.copyWith(
                  fontSize: 2.h,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.brightness_6_outlined,
                    color: colorScheme.onSurface,
                    size: 3.h,
                  ),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ],
            ),
      floatingActionButton: _selectedIndex == 0
          ? null
          : FloatingActionButton(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.9),
              onPressed: () {
                _loadStartupWeather(forceRefresh: true);
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: Icon(
                Icons.my_location,
                color: colorScheme.onPrimary,
                size: 3.h,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.cloud,
              color: _selectedIndex == 0
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 3.h,
            ),
            label: 'Hava Durumu',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
              color: _selectedIndex == 1
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 3.h,
            ),
            label: ProjectKeywords.favorites,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _selectedIndex == 2
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 3.h,
            ),
            label: ProjectKeywords.search,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: colorScheme.surface,
        selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 1.5.h,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 1.5.h,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: _onItemTapped,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeWeatherView(),
          const FavoritePage(),
          const SearchPage(),
        ],
      ),
    );
  }

  Widget _buildHomeWeatherView() {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoaded) {
          return WeatherDetailsView(
            weather: state.weather,
            showBackButton: false,
          );
        } else if (state is WeatherLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WeatherError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
