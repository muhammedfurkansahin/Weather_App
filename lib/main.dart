import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:weather_app/languages/text_widgets.dart';
import 'package:weather_app/views/home_page.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/theme_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => WeatherCubit()),
            BlocProvider(create: (context) => ThemeCubit()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, theme) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: ProjectKeywords.weather,
                theme: theme,
                home: const HomePage(),
              );
            },
          ),
        );
      },
    );
  }
}
