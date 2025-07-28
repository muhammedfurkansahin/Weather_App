# Weather App - API Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Models](#models)
4. [State Management (Cubits)](#state-management-cubits)
5. [Views/Components](#viewscomponents)
6. [Localization](#localization)
7. [Usage Examples](#usage-examples)
8. [Installation & Setup](#installation--setup)

## Overview

The Weather App is a Flutter application that provides weather information for cities worldwide. It features:

- Current weather conditions
- 3-day weather forecast
- Hourly weather forecast
- Favorite cities management
- Location-based weather
- Dark/Light theme support
- Turkish localization

### Key Technologies
- **Flutter**: UI framework
- **BLoC/Cubit**: State management
- **Dio**: HTTP client for API calls
- **SharedPreferences**: Local storage
- **Geolocator**: Location services
- **ResponsiveSizer**: Responsive design

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── models/          # Data models
├── cubit/           # State management (BLoC pattern)
├── views/           # UI components/pages
├── languages/       # Localization and text constants
└── main.dart        # App entry point
```

## Models

### Weather Model

The main data model representing weather information.

```dart
class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double windSpeed;
  final double humidity;
  final double feelsLike;
  final List<DailyWeather> dailyWeather;
  final List<HourlyWeather> hourlyWeather;
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `cityName` | `String` | Name of the city |
| `temperature` | `double` | Current temperature in Celsius |
| `description` | `String` | Weather condition description |
| `icon` | `String` | URL to weather icon |
| `windSpeed` | `double` | Wind speed in km/h |
| `humidity` | `double` | Humidity percentage |
| `feelsLike` | `double` | Feels-like temperature in Celsius |
| `dailyWeather` | `List<DailyWeather>` | 3-day forecast |
| `hourlyWeather` | `List<HourlyWeather>` | 24-hour forecast |

#### Factory Constructor

```dart
factory Weather.fromJson(Map<String, dynamic> json)
```

Creates a `Weather` instance from WeatherAPI JSON response.

**Example:**
```dart
final weather = Weather.fromJson(apiResponse);
print('Temperature in ${weather.cityName}: ${weather.temperature}°C');
```

### DailyWeather Model

Represents daily weather forecast data.

```dart
class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String icon;
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `date` | `String` | Date in YYYY-MM-DD format |
| `maxTemp` | `double` | Maximum temperature for the day |
| `minTemp` | `double` | Minimum temperature for the day |
| `icon` | `String` | URL to weather condition icon |

### HourlyWeather Model

Represents hourly weather forecast data.

```dart
class HourlyWeather {
  final String time;
  final double temperature;
  final String icon;
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `time` | `String` | Time in YYYY-MM-DD HH:mm format |
| `temperature` | `double` | Temperature at specific hour |
| `icon` | `String` | URL to weather condition icon |

### FavoriteCity Model

Simple model for favorite cities.

```dart
class FavoriteCity {
  final String cityName;
}
```

## State Management (Cubits)

### WeatherCubit

Manages weather data fetching and state.

#### States

```dart
abstract class WeatherState {}
class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherLoaded extends WeatherState {
  final Weather weather;
}
class WeathersLoaded extends WeatherState {
  final List<Weather> weathers;
}
class WeatherError extends WeatherState {
  final String message;
}
```

#### Public Methods

##### `fetchWeather(String city)`

Fetches weather data for a specific city.

**Parameters:**
- `city` (String): Name of the city

**Usage:**
```dart
final weatherCubit = context.read<WeatherCubit>();
await weatherCubit.fetchWeather('Istanbul');
```

##### `fetchWeatherForCities(List<String> cities)`

Fetches weather data for multiple cities (used for favorites).

**Parameters:**
- `cities` (List<String>): List of city names

**Usage:**
```dart
final cities = ['Istanbul', 'Ankara', 'Izmir'];
await weatherCubit.fetchWeatherForCities(cities);
```

##### `fetchWeatherByLocation(double latitude, double longitude)`

Fetches weather data using geographical coordinates.

**Parameters:**
- `latitude` (double): Latitude coordinate
- `longitude` (double): Longitude coordinate

**Usage:**
```dart
await weatherCubit.fetchWeatherByLocation(41.0082, 28.9784);
```

### FavoriteCubit

Manages favorite cities functionality.

#### States

```dart
abstract class FavoriteState {}
class FavoriteInitial extends FavoriteState {}
class FavoriteLoaded extends FavoriteState {
  final List<String> favorites;
}
```

#### Constructor

```dart
FavoriteCubit(this.weatherCubit, this.sharedPreferences)
```

**Parameters:**
- `weatherCubit` (WeatherCubit): Reference to weather cubit
- `sharedPreferences` (SharedPreferences): Local storage instance

#### Public Methods

##### `addFavoriteCity(String cityName)`

Adds a city to favorites and persists it locally.

**Parameters:**
- `cityName` (String): Name of the city to add

**Usage:**
```dart
final favoriteCubit = context.read<FavoriteCubit>();
favoriteCubit.addFavoriteCity('Paris');
```

##### `removeFavoriteCity(String cityName)`

Removes a city from favorites.

**Parameters:**
- `cityName` (String): Name of the city to remove

**Usage:**
```dart
favoriteCubit.removeFavoriteCity('Paris');
```

### ThemeCubit

Manages application theme (light/dark mode).

#### Public Methods

##### `toggleTheme()`

Switches between light and dark themes.

**Usage:**
```dart
final themeCubit = context.read<ThemeCubit>();
themeCubit.toggleTheme();
```

#### Theme Properties

The cubit provides two predefined themes:

- **Light Theme**: Modern, soft colors with indigo primary
- **Dark Theme**: Elegant dark colors with light indigo accents

## Views/Components

### HomePage

Main entry point with bottom navigation.

```dart
class HomePage extends StatefulWidget
```

**Features:**
- Bottom navigation with 3 tabs
- Integration with SharedPreferences
- Loading states management

**Usage:**
```dart
// Set as home in MaterialApp
home: const HomePage()
```

### SearchPage

Weather search functionality with animated UI.

```dart
class SearchPage extends StatefulWidget
```

**Features:**
- City search with validation
- Animated transitions
- Weather display with detailed information
- Add to favorites functionality

**Key Components:**
- Search form with validation
- Weather information cards
- Hourly and daily forecast displays
- Responsive design

### CurrentLocationPage

Location-based weather display.

**Features:**
- GPS location detection
- Permission handling
- Location-based weather fetching

### FavoritePages

Displays favorite cities and their weather.

**Features:**
- Grid/list view of favorite cities
- Weather information for each city
- Remove from favorites functionality

## Localization

### ProjectKeywords

Contains all UI text constants in Turkish.

```dart
class ProjectKeywords {
  static const weather = 'Weather App';
  static const havaDurumu = 'Hava Durumu';
  static const favorites = 'Favoriler';
  static const search = 'Ara';
  // ... more constants
}
```

### ErrorMessage

Error messages and warnings.

```dart
class ErrorMessage {
  static const error = 'Error';
  static const serviceDisabled = 'Location services are disabled.';
  static const weatherDataFailed = 'Failed to load weather data';
  // ... more error messages
}
```

### MeasureUnit

Measurement unit constants.

```dart
class MeasureUnit {
  static const centigrade = '°C';
  static const percent = '%';
  static const kilometer = 'km/s';
}
```

## Usage Examples

### Basic Weather Fetching

```dart
// In a widget
class WeatherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return CircularProgressIndicator();
        } else if (state is WeatherLoaded) {
          return Column(
            children: [
              Text('${state.weather.cityName}'),
              Text('${state.weather.temperature}°C'),
              Text('${state.weather.description}'),
            ],
          );
        } else if (state is WeatherError) {
          return Text('Error: ${state.message}');
        }
        return Container();
      },
    );
  }
}
```

### Managing Favorites

```dart
// Add to favorites
void addToFavorites(String cityName) {
  context.read<FavoriteCubit>().addFavoriteCity(cityName);
}

// Remove from favorites
void removeFromFavorites(String cityName) {
  context.read<FavoriteCubit>().removeFavoriteCity(cityName);
}

// Listen to favorites changes
BlocBuilder<FavoriteCubit, FavoriteState>(
  builder: (context, state) {
    if (state is FavoriteLoaded) {
      return ListView.builder(
        itemCount: state.favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(state.favorites[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => removeFromFavorites(state.favorites[index]),
            ),
          );
        },
      );
    }
    return Container();
  },
)
```

### Theme Management

```dart
// Toggle theme
FloatingActionButton(
  onPressed: () {
    context.read<ThemeCubit>().toggleTheme();
  },
  child: Icon(Icons.brightness_6),
)

// Listen to theme changes
BlocBuilder<ThemeCubit, ThemeData>(
  builder: (context, theme) {
    return MaterialApp(
      theme: theme,
      home: HomePage(),
    );
  },
)
```

### Location-Based Weather

```dart
// Fetch weather by current location
Future<void> fetchCurrentLocationWeather() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    context.read<WeatherCubit>().fetchWeatherByLocation(
      position.latitude,
      position.longitude,
    );
  } catch (e) {
    // Handle location errors
    print('Location error: $e');
  }
}
```

### Form Validation

```dart
// Search form with validation
Form(
  key: _formKey,
  child: TextFormField(
    controller: _controller,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return ErrorMessage.textfieldWarning;
      }
      if (value.length < 3) {
        return ErrorMessage.textfieldBoundry;
      }
      return null;
    },
    decoration: InputDecoration(
      hintText: ProjectKeywords.writeCity,
    ),
  ),
)
```

## Installation & Setup

### Prerequisites

- Flutter SDK (>=3.4.4)
- Dart SDK
- WeatherAPI key

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd weather_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   
   Update the API key in `lib/cubit/weather_cubit.dart`:
   ```dart
   class _ApiKey {
     static const apiKey = 'YOUR_WEATHER_API_KEY';
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following key dependencies:

```yaml
dependencies:
  flutter_bloc: ^9.0.0          # State management
  dio: ^5.5.0+1                 # HTTP client
  shared_preferences: ^2.3.1    # Local storage
  geolocator: ^13.0.1          # Location services
  responsive_sizer: ^3.3.1     # Responsive design
  go_router: ^14.2.2           # Navigation (if used)
```

### Permissions

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location for weather information.</string>
```

### API Configuration

The app uses WeatherAPI.com for weather data. Get your free API key from [weatherapi.com](https://www.weatherapi.com/) and update the `_ApiKey` class.

### Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Error Handling

The app includes comprehensive error handling:

- **Network errors**: Handled in WeatherCubit with user-friendly messages
- **Location errors**: Specific error messages for different location scenarios
- **Form validation**: Input validation with Turkish error messages
- **API errors**: Proper error state management in BLoC pattern

## Contributing

When contributing to this project:

1. Follow the existing architecture patterns
2. Add proper error handling
3. Include Turkish translations for new text
4. Write comprehensive tests
5. Update this documentation for new APIs

## License

This project is private and not published to pub.dev as specified in `pubspec.yaml`.