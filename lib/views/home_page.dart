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
import 'package:weather_app/cubit/favorite_state.dart';
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
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final sharedPreferences = snapshot.data!;
          return BlocProvider(
            create: (context) => FavoriteCubit(sharedPreferences),
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
  int _bottomNavIndex = 0;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStartupData();
    });
  }

  void _loadStartupData() async {
    if (!mounted) return;
    final weatherCubit = context.read<WeatherCubit>();

    // Load cached first
    await weatherCubit.loadCachedWeather();

    // Fetch current location weather
    try {
      final position = await _determinePosition();
      if (!mounted) return;
      await weatherCubit.fetchWeatherByLocation(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
      if (weatherCubit.state is! WeatherLoaded) {
        await weatherCubit.fetchWeather('Istanbul'); // Fallback
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
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: _bottomNavIndex == 0,
      appBar: _bottomNavIndex == 0
          ? null
          : AppBar(
              title: Text(ProjectKeywords.weather),
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6_outlined),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud, size: 3.h),
            label: 'Hava Durumu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, size: 3.h),
            label: ProjectKeywords.favorites,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 3.h),
            label: ProjectKeywords.search,
          ),
        ],
        currentIndex: _bottomNavIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: colorScheme.surface,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildSwipeableWeatherView(),
          const FavoritePage(),
          const SearchPage(),
        ],
      ),
    );
  }

  Widget _buildSwipeableWeatherView() {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      builder: (context, favState) {
        return BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, weatherState) {
            // Collect all cities to show: [Current Location, ...Favorites]
            // We need the Current Location Weather object from WeatherCubit
            // And we need to fetch/have weather for Favorites.
            // Note: WeatherCubit currently holds ONE active weather (current location usually).
            // For the swipeable view to work efficiently, we might need a list of weathers.
            // HOWEVER, to keep it simple and responsive as requested:
            // 1. Page 0 is always the WeatherCubit's current state (Current Location)
            // 2. Pages 1..N are the Favorites. We can fetch them on demand or use a separate Cubit/List.

            // Ideally, we should have a 'MultiWeatherCubit' or similar, but let's adapt with what we have.
            // We will render Page 0 from WeatherCubit.
            // For favorites, we will generic 'WeatherDetailsView' but we need the data.
            // Since `FavoritePage` uses `WeatherCubit` to fetch list, we might interfere.
            // Let's create a temporary solution:
            // The Main WeatherCubit holds the "Current Location".
            // We can iterate favorites. But to show them, we need their data.

            // Better approach for this user request:
            // The PageView builder will delegate:
            // Index 0 -> Shows WeatherCubit state (assuming it's current location)
            // Index > 0 -> Shows a "FavoriteCityWeatherLoader" widget which fetches weather for that specific city.

            final favorites = (favState is FavoriteLoaded) ? favState.favorites : <String>[];
            final totalPages = 1 + favorites.length;

            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Current Location
                      return _buildCurrentLocationPage(weatherState);
                    } else {
                      // Favorite City
                      final cityName = favorites[index - 1];
                      return _FavoriteCityWeatherLoader(cityName: cityName);
                    }
                  },
                ),
                // Page Indicator
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildPageIndicator(totalPages, _currentPageIndex),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentLocationPage(WeatherState state) {
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
  }

  Widget _buildPageIndicator(int count, int current) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isSelected = index == current;
        final isMain = index == 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? (isMain ? 24 : 12) : (isMain ? 20 : 8),
          height: isSelected ? (isMain ? 24 : 12) : (isMain ? 20 : 8),
          decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ]),
          child: isMain
              ? Icon(Icons.star,
                  size: isSelected ? 16 : 14, color: isSelected ? Colors.orange : Colors.grey)
              : null,
        );
      }),
    );
  }
}

// Widget to fetch and display weather for a single favorite city in the PageView
class _FavoriteCityWeatherLoader extends StatefulWidget {
  final String cityName;

  const _FavoriteCityWeatherLoader({required this.cityName});

  @override
  State<_FavoriteCityWeatherLoader> createState() => _FavoriteCityWeatherLoaderState();
}

class _FavoriteCityWeatherLoaderState extends State<_FavoriteCityWeatherLoader> {
  // We need a separate cubit or just a Future for this to not mess up the main global WeatherCubit
  // Using a local WeatherCubit is safest.
  late WeatherCubit _localCubit;

  @override
  void initState() {
    super.initState();
    _localCubit = WeatherCubit();
    _localCubit.fetchWeather(widget.cityName);
  }

  @override
  void close() {
    _localCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _localCubit,
      child: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoaded) {
            return WeatherDetailsView(
              weather: state.weather,
              showBackButton: false,
            );
          } else if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                ElevatedButton(
                    onPressed: () => _localCubit.fetchWeather(widget.cityName),
                    child: const Text('Tekrar Dene'))
              ],
            ));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
