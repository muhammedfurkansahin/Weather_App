# Weather App 🌤️

A modern, feature-rich Flutter weather application that provides comprehensive weather information with an elegant user interface.

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Documentation](#-documentation)
- [Installation](#-installation)
- [API Configuration](#-api-configuration)
- [Usage](#-usage)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### Core Functionality
- **Current Weather**: Real-time weather conditions for any city
- **Location-Based Weather**: GPS-based weather detection
- **3-Day Forecast**: Extended weather forecast
- **Hourly Forecast**: 24-hour weather timeline
- **Favorite Cities**: Save and manage favorite locations
- **Search**: Smart city search with validation

### UI/UX Features
- **Modern Design**: Clean, intuitive interface
- **Dark/Light Theme**: Toggle between themes
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Smooth Animations**: Elegant transitions and animations
- **Turkish Localization**: Full Turkish language support
- **Error Handling**: Comprehensive error management

### Technical Features
- **BLoC State Management**: Efficient state management
- **Local Storage**: Persistent favorite cities
- **Network Optimization**: Efficient API calls
- **Performance Optimized**: Smooth scrolling and rendering

## 📱 Screenshots

### App Structure
![Ekran görüntüsü 2024-08-07 170941](https://github.com/user-attachments/assets/c369441c-cdae-4061-915d-532aa68e5423)

### Screenshots
![Screenshot_1723039511](https://github.com/user-attachments/assets/3dbc119f-b003-4ce0-8ab3-38b941cd6590)
![Screenshot_1723039497](https://github.com/user-attachments/assets/da69e64f-2603-4626-bc6c-2fee829fdb9d)
![Screenshot_1723039491](https://github.com/user-attachments/assets/c389bb7c-741b-427e-9c42-59c29d51a0b3)

## 🏗️ Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── models/          # Data models and entities
├── cubit/           # State management (BLoC pattern)
├── views/           # UI components and pages
├── languages/       # Localization and constants
└── main.dart        # Application entry point
```

### Key Components

- **Models**: `Weather`, `DailyWeather`, `HourlyWeather`, `FavoriteCity`
- **Cubits**: `WeatherCubit`, `FavoriteCubit`, `ThemeCubit`
- **Views**: `HomePage`, `SearchPage`, `CurrentLocationPage`, `FavoritePages`

## 📚 Documentation

Comprehensive documentation is available in the following files:

- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)**: Complete API reference with examples
- **[COMPONENT_DOCUMENTATION.md](COMPONENT_DOCUMENTATION.md)**: Detailed component guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**: Quick reference and troubleshooting

## 🚀 Installation

### Prerequisites

- Flutter SDK (>=3.4.4)
- Dart SDK
- Android Studio / VS Code
- WeatherAPI.com account (free)

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

3. **Configure API key** (see [API Configuration](#-api-configuration))

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Configuration

The app uses [WeatherAPI.com](https://www.weatherapi.com/) for weather data.

1. **Get your free API key**:
   - Visit [weatherapi.com](https://www.weatherapi.com/)
   - Sign up for a free account
   - Copy your API key

2. **Update the API key**:
   ```dart
   // lib/cubit/weather_cubit.dart
   class _ApiKey {
     static const apiKey = 'YOUR_API_KEY_HERE';
   }
   ```

## 📱 Usage

### Basic Operations

#### Search for Weather
```dart
// Access weather cubit and search
final weatherCubit = context.read<WeatherCubit>();
await weatherCubit.fetchWeather('Istanbul');
```

#### Manage Favorites
```dart
// Add to favorites
context.read<FavoriteCubit>().addFavoriteCity('Paris');

// Remove from favorites
context.read<FavoriteCubit>().removeFavoriteCity('Paris');
```

#### Toggle Theme
```dart
// Switch between light and dark theme
context.read<ThemeCubit>().toggleTheme();
```

### Navigation

The app features a bottom navigation bar with three main sections:

1. **Location Tab**: GPS-based weather for current location
2. **Search Tab**: Search weather for any city
3. **Favorites Tab**: Manage and view favorite cities

## 🛠️ Development

### Dependencies

Key dependencies used in this project:

```yaml
dependencies:
  flutter_bloc: ^9.0.0          # State management
  dio: ^5.5.0+1                 # HTTP client
  shared_preferences: ^2.3.1    # Local storage
  geolocator: ^13.0.1          # Location services
  responsive_sizer: ^3.3.1     # Responsive design
```

### Code Quality

The project uses `flutter_lints` for maintaining code quality:

```bash
# Run linter
flutter analyze

# Format code
flutter format .
```

### Testing

Run tests with:

```bash
flutter test
```

### Building

#### Debug Build
```bash
flutter run --debug
```

#### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing architecture patterns
- Add proper error handling
- Include Turkish translations for new text
- Write tests for new functionality
- Update documentation for API changes

## 📄 License

This project is private and not published to pub.dev. All rights reserved.

## 🔧 Troubleshooting

### Common Issues

1. **API not working**: Check your API key in `weather_cubit.dart`
2. **Location not detected**: Ensure location permissions are granted
3. **Theme not updating**: Verify BlocBuilder setup in main.dart
4. **Favorites not saving**: Check SharedPreferences initialization

For detailed troubleshooting, see [QUICK_REFERENCE.md](QUICK_REFERENCE.md).

## 📞 Support

If you encounter any issues or have questions:

1. Check the [documentation files](#-documentation)
2. Review the [troubleshooting section](#-troubleshooting)
3. Search existing issues in the repository

---

**Built with ❤️ using Flutter**
