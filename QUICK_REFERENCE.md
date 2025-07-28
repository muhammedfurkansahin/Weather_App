# Quick Reference Guide

## Common Code Snippets

### BLoC Integration

#### Listen to Weather State
```dart
BlocListener<WeatherCubit, WeatherState>(
  listener: (context, state) {
    if (state is WeatherError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: BlocBuilder<WeatherCubit, WeatherState>(
    builder: (context, state) {
      // UI based on state
    },
  ),
)
```

#### Fetch Weather Data
```dart
// By city name
context.read<WeatherCubit>().fetchWeather('Istanbul');

// By coordinates
context.read<WeatherCubit>().fetchWeatherByLocation(41.0082, 28.9784);

// Multiple cities
context.read<WeatherCubit>().fetchWeatherForCities(['Istanbul', 'Ankara']);
```

#### Manage Favorites
```dart
// Add favorite
context.read<FavoriteCubit>().addFavoriteCity('Paris');

// Remove favorite
context.read<FavoriteCubit>().removeFavoriteCity('Paris');

// Check if city is favorite
final isLoaded = state is FavoriteLoaded;
final isFavorite = isLoaded && state.favorites.contains('Paris');
```

#### Toggle Theme
```dart
// Toggle between light and dark
context.read<ThemeCubit>().toggleTheme();

// Check current theme
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### UI Patterns

#### Responsive Sizing
```dart
// Width/Height as percentage of screen
Container(
  width: 90.w,    // 90% of screen width
  height: 50.h,   // 50% of screen height
  margin: EdgeInsets.all(2.w),  // 2% margin
)

// Font sizes
Text(
  'Title',
  style: TextStyle(fontSize: 18.sp), // Responsive font size
)
```

#### Loading States
```dart
BlocBuilder<WeatherCubit, WeatherState>(
  builder: (context, state) {
    return switch (state) {
      WeatherInitial() => Center(child: Text('Search for weather')),
      WeatherLoading() => Center(child: CircularProgressIndicator()),
      WeatherLoaded() => WeatherDisplay(weather: state.weather),
      WeatherError() => ErrorDisplay(message: state.message),
      WeathersLoaded() => WeatherList(weathers: state.weathers),
    };
  },
)
```

#### Form Validation
```dart
TextFormField(
  validator: (value) {
    if (value?.isEmpty ?? true) return ErrorMessage.textfieldWarning;
    if (value!.length < 3) return ErrorMessage.textfieldBoundry;
    return null;
  },
  decoration: InputDecoration(
    hintText: ProjectKeywords.writeCity,
    prefixIcon: Icon(Icons.search),
  ),
)
```

### Navigation

#### Bottom Navigation Setup
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.location_on),
      label: 'Location',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
  ],
)
```

### Location Services

#### Get Current Position
```dart
Future<Position> getCurrentPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception(ErrorMessage.serviceDisabled);
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception(ErrorMessage.locationPermissionDenied);
    }
  }

  return await Geolocator.getCurrentPosition();
}
```

### Animations

#### Fade Animation Setup
```dart
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Troubleshooting

### Common Issues

#### 1. Weather API Not Working
**Problem**: API calls failing or returning errors

**Solutions**:
- Check API key in `lib/cubit/weather_cubit.dart`
- Verify internet connection
- Check API rate limits
- Ensure city name is spelled correctly

```dart
// Debug API calls
try {
  final response = await _dio.get(url);
  print('API Response: ${response.statusCode}');
} catch (e) {
  print('API Error: $e');
}
```

#### 2. Location Services Not Working
**Problem**: GPS location not being detected

**Solutions**:
- Check location permissions in AndroidManifest.xml / Info.plist
- Enable location services on device
- Test on physical device (location doesn't work in simulator)

```dart
// Debug location services
bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
LocationPermission permission = await Geolocator.checkPermission();
print('Service enabled: $serviceEnabled, Permission: $permission');
```

#### 3. Theme Not Updating
**Problem**: Theme changes not reflecting in UI

**Solutions**:
- Ensure MaterialApp is wrapped with BlocBuilder<ThemeCubit, ThemeData>
- Check if theme is properly provided to MaterialApp
- Restart app if changes persist

```dart
// Correct theme setup
BlocBuilder<ThemeCubit, ThemeData>(
  builder: (context, theme) {
    return MaterialApp(
      theme: theme,
      home: HomePage(),
    );
  },
)
```

#### 4. Favorites Not Persisting
**Problem**: Favorite cities lost after app restart

**Solutions**:
- Check SharedPreferences initialization
- Verify FavoriteCubit constructor receives SharedPreferences
- Clear app data and test again

```dart
// Debug SharedPreferences
final prefs = await SharedPreferences.getInstance();
final favorites = prefs.getStringList('favoriteCities') ?? [];
print('Stored favorites: $favorites');
```

#### 5. Responsive Sizing Issues
**Problem**: UI elements not sizing correctly on different devices

**Solutions**:
- Ensure ResponsiveSizer wraps MaterialApp
- Use .w, .h, .sp extensions for sizing
- Test on different screen sizes

```dart
// Correct responsive setup
ResponsiveSizer(
  builder: (context, orientation, screenType) {
    return MaterialApp(/* ... */);
  },
)
```

### Performance Issues

#### 1. Slow List Scrolling
**Problem**: ListView performance issues with many items

**Solution**: Use ListView.builder with keys
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return WeatherCard(
      key: ValueKey(items[index].cityName),
      weather: items[index],
    );
  },
)
```

#### 2. Memory Leaks
**Problem**: App consuming too much memory

**Solutions**:
- Dispose animation controllers
- Cancel HTTP requests in dispose()
- Use const constructors where possible

```dart
@override
void dispose() {
  _animationController.dispose();
  _textController.dispose();
  super.dispose();
}
```

## Testing

### Unit Tests

#### Test Weather Model
```dart
void main() {
  group('Weather Model', () {
    test('should create Weather from JSON', () {
      final json = {
        'location': {'name': 'Istanbul'},
        'current': {
          'temp_c': 25.0,
          'condition': {'text': 'Sunny', 'icon': '//icon.png'},
          'wind_kph': 10.0,
          'humidity': 60.0,
          'feelslike_c': 27.0,
        },
        'forecast': {'forecastday': []},
      };

      final weather = Weather.fromJson(json);

      expect(weather.cityName, 'Istanbul');
      expect(weather.temperature, 25.0);
      expect(weather.description, 'Sunny');
    });
  });
}
```

#### Test WeatherCubit
```dart
void main() {
  group('WeatherCubit', () {
    late WeatherCubit cubit;

    setUp(() {
      cubit = WeatherCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is WeatherInitial', () {
      expect(cubit.state, isA<WeatherInitial>());
    });

    test('emits [WeatherLoading, WeatherLoaded] when fetchWeather succeeds', () {
      // Mock successful API call
      // Test implementation
    });
  });
}
```

### Widget Tests

#### Test SearchPage
```dart
void main() {
  testWidgets('SearchPage displays search form', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => WeatherCubit(),
          child: SearchPage(),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
```

## Build & Deployment

### Debug Build
```bash
flutter run --debug
```

### Release Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Environment Setup
```bash
# Check Flutter setup
flutter doctor

# Get dependencies
flutter pub get

# Clean build
flutter clean
flutter pub get
```

## Code Quality

### Linting
The project uses `flutter_lints` for code quality. Check `analysis_options.yaml` for rules.

```bash
# Run linter
flutter analyze

# Format code
flutter format .
```

### Best Practices

1. **Use const constructors** where possible
2. **Dispose resources** in dispose() method
3. **Use meaningful variable names**
4. **Add proper error handling**
5. **Write tests** for critical functionality

### Code Organization
```
lib/
├── models/          # Data models
│   ├── weather_model.dart
│   └── favorites_model.dart
├── cubit/           # State management
│   ├── weather_cubit.dart
│   ├── weather_state.dart
│   ├── favorite_cubit.dart
│   ├── favorite_state.dart
│   └── theme_cubit.dart
├── views/           # UI pages
│   ├── home_page.dart
│   ├── search_page.dart
│   ├── current_location.dart
│   └── favorite_pages.dart
├── languages/       # Localization
│   └── text_widgets.dart
└── main.dart        # App entry point
```

## Useful Commands

### Flutter Commands
```bash
# Hot reload
r

# Hot restart
R

# Quit
q

# Run tests
flutter test

# Build runner (if using code generation)
flutter packages pub run build_runner build
```

### Git Commands
```bash
# Check status
git status

# Add changes
git add .

# Commit
git commit -m "feat: add weather search functionality"

# Push
git push origin main
```

This quick reference guide provides essential information for developers working on the Weather App project.