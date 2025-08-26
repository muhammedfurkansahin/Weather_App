import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/languages/text_widgets.dart';
import 'package:weather_app/views/favorite_pages.dart';
import 'package:weather_app/views/search_page.dart';
import 'package:weather_app/views/current_location.dart';
import 'package:weather_app/cubit/favorite_cubit.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/theme_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

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
          return homeMultiBlocProvider(sharedPreferences, context);
        }
      },
    );
  }

  MultiBlocProvider homeMultiBlocProvider(SharedPreferences sharedPreferences, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocProvider(
      providers: [
        homeWeatherBlocCubitProvider(),
        homeFavoriteBlocCubitProvider(sharedPreferences),
      ],
      child: Scaffold(
        appBar: AppBar(
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
        floatingActionButton: FloatingActionButton(

          backgroundColor: colorScheme.primary.withValues(alpha: 0.9),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CurrentLocationPage(),
              ),
            );
          },
          child: Icon(
            Icons.sunny,
            color: colorScheme.onPrimary,
            size: 3.h,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.star,

                color: _selectedIndex == 0 ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
                size: 3.h,
              ),
              label: ProjectKeywords.favorites,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,

                color: _selectedIndex == 1 ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
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
          children: const [
            FavoritePage(),
            SearchPage(),
          ],
        ),
      ),
    );
  }

  BlocProvider<FavoriteCubit> homeFavoriteBlocCubitProvider(SharedPreferences sharedPreferences) {
    return BlocProvider(
      create: (context) => FavoriteCubit(
        context.read<WeatherCubit>(),
        sharedPreferences,
      ),
    );
  }

  BlocProvider<WeatherCubit> homeWeatherBlocCubitProvider() => BlocProvider(create: (context) => WeatherCubit());
}
