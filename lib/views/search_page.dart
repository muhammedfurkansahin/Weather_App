import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/weather_state.dart';
import 'package:weather_app/cubit/favorite_cubit.dart';
import 'package:weather_app/languages/text_widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.streetAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                            labelText: ProjectKeywords.writeCity,
                            labelStyle: const TextStyle(color: Colors.blue),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return ErrorMessage.textfieldWarning;
                            }
                            if (value.length <= 2) {
                              return ErrorMessage.textfieldBoundry;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final weatherCubit = context.read<WeatherCubit>();
                              weatherCubit.fetchWeather(_controller.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            ProjectKeywords.fetchWeather,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              searchCityBlocBuilder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchCityBlocBuilder() {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherInitial) {
          return const Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                ProjectKeywords.writeCity,
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
          );
        } else if (state is WeatherLoading) {
          return const CircularProgressIndicator();
        } else if (state is WeatherLoaded) {
          return searchCityWeather(state, context);
        } else if (state is WeatherError) {
          return Card(
            elevation: 4,
            color: Colors.red.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${ErrorMessage.error}: ${state.message}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget searchCityWeather(WeatherLoaded state, BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Column(
          children: [
            Text(
              state.weather.cityName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
              ),
              child: Image.network(
                state.weather.icon,
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${state.weather.temperature}${MeasureUnit.centigrade}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.weather.description,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FavoriteCubit>().addFavoriteCity(state.weather.cityName);
              },
              icon: const Icon(Icons.favorite, color: Colors.white),
              label: const Text(
                ProjectKeywords.addFavorite,
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
