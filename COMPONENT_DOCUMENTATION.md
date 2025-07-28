# Component Documentation

## UI Components and Widgets

This document provides detailed information about the UI components, their implementation, and usage patterns in the Weather App.

## Core Pages

### HomePage Component

The main application entry point that orchestrates the overall app experience.

#### Class Definition
```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});
}
```

#### Key Features

1. **Bottom Navigation**: 3-tab navigation system
2. **SharedPreferences Integration**: Handles local storage initialization
3. **Loading States**: Proper loading UI while initializing preferences
4. **Error Handling**: Graceful error display for initialization failures

#### Implementation Details

```dart
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
```

#### Navigation Structure

| Index | Page | Description |
|-------|------|-------------|
| 0 | CurrentLocationPage | GPS-based weather |
| 1 | SearchPage | City search functionality |
| 2 | FavoritePages | Favorite cities management |

#### Usage Example

```dart
// In main.dart
MaterialApp(
  home: const HomePage(),
  // ... other properties
)
```

#### Responsive Design

The HomePage uses `ResponsiveSizer` for adaptive layouts:

```dart
ResponsiveSizer(
  builder: (context, orientation, screenType) {
    return MultiBlocProvider(
      // ... providers
    );
  },
)
```

### SearchPage Component

Advanced search interface with animations and comprehensive weather display.

#### Class Definition
```dart
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin
```

#### Key Features

1. **Animated UI**: Fade-in animations using `AnimationController`
2. **Form Validation**: Comprehensive input validation
3. **Weather Display**: Detailed weather information cards
4. **Favorites Integration**: Add/remove cities from favorites
5. **Responsive Design**: Adaptive layouts for different screen sizes

#### Animation Implementation

```dart
late AnimationController _animationController;
late Animation<double> _fadeAnimation;

@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ));
  _animationController.forward();
}
```

#### Form Validation Logic

```dart
String? _validateInput(String? value) {
  if (value == null || value.isEmpty) {
    return ErrorMessage.textfieldWarning;
  }
  if (value.length < 3) {
    return ErrorMessage.textfieldBoundry;
  }
  return null;
}
```

#### Weather Display Components

The SearchPage includes several sub-components:

1. **Current Weather Card**: Main weather information
2. **Hourly Forecast**: 24-hour weather timeline
3. **Daily Forecast**: 3-day weather forecast
4. **Weather Details**: Wind speed, humidity, feels-like temperature

### CurrentLocationPage Component

GPS-based weather functionality with comprehensive location handling.

#### Key Features

1. **Location Services**: GPS position detection
2. **Permission Handling**: Runtime permission requests
3. **Error Management**: Specific error handling for location scenarios
4. **Weather Display**: Location-based weather information

#### Location Permission Flow

```dart
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception(ErrorMessage.serviceDisabled);
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception(ErrorMessage.locationPermissionDenied);
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(ErrorMessage.locationPermissionPermaDenied);
  }

  return await Geolocator.getCurrentPosition();
}
```

### FavoritePages Component

Manages favorite cities with grid/list display options.

#### Key Features

1. **City Management**: Add/remove favorite cities
2. **Weather Display**: Weather information for each favorite city
3. **Grid Layout**: Responsive grid display
4. **Empty State**: Proper empty state handling

## UI Design Patterns

### Theme Integration

All components integrate with the `ThemeCubit` for consistent theming:

```dart
// Using theme colors
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Weather Info',
    style: Theme.of(context).textTheme.titleLarge,
  ),
)
```

### Responsive Design Patterns

Components use `ResponsiveSizer` for adaptive layouts:

```dart
// Responsive sizing
Container(
  width: 90.w,  // 90% of screen width
  height: 20.h, // 20% of screen height
  padding: EdgeInsets.all(2.w), // 2% of screen width
)
```

### Loading States

Consistent loading indicators across components:

```dart
Center(
  child: CircularProgressIndicator(
    color: Theme.of(context).colorScheme.primary,
    strokeWidth: 0.5.w,
  ),
)
```

## Custom Widgets

### Weather Card Widget

Reusable weather information display card.

```dart
class WeatherCard extends StatelessWidget {
  final Weather weather;
  final VoidCallback? onFavoriteToggle;

  const WeatherCard({
    Key? key,
    required this.weather,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Weather icon and temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(weather.icon, width: 15.w),
                Text(
                  '${weather.temperature.round()}°C',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            // City name and description
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              weather.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            // Additional weather details
            WeatherDetailsRow(weather: weather),
          ],
        ),
      ),
    );
  }
}
```

### Weather Details Row

Displays additional weather information in a row format.

```dart
class WeatherDetailsRow extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsRow({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        WeatherDetailItem(
          icon: Icons.air,
          label: ProjectKeywords.windSpeed,
          value: '${weather.windSpeed} ${MeasureUnit.kilometer}',
        ),
        WeatherDetailItem(
          icon: Icons.water_drop,
          label: ProjectKeywords.humidity,
          value: '${weather.humidity}${MeasureUnit.percent}',
        ),
        WeatherDetailItem(
          icon: Icons.thermostat,
          label: ProjectKeywords.feelsLike,
          value: '${weather.feelsLike}${MeasureUnit.centigrade}',
        ),
      ],
    );
  }
}
```

### Weather Detail Item

Individual weather detail display component.

```dart
class WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 6.w,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
```

## Animation Patterns

### Fade-in Animation

Standard fade-in animation used across components:

```dart
FadeTransition(
  opacity: _fadeAnimation,
  child: SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    )),
    child: WeatherCard(weather: weather),
  ),
)
```

### Loading Animation

Shimmer-like loading animation for weather cards:

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 1500),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.grey.shade300,
        Colors.grey.shade100,
        Colors.grey.shade300,
      ],
      stops: const [0.0, 0.5, 1.0],
    ),
  ),
)
```

## Error Handling Patterns

### Error Display Widget

Consistent error display across components:

```dart
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 20.w,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

## Input Validation Patterns

### Text Field Validation

Comprehensive validation for search inputs:

```dart
class ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmitted;

  const ValidatedTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator ?? _defaultValidator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
      ),
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessage.textfieldWarning;
    }
    if (value.length < 3) {
      return ErrorMessage.textfieldBoundry;
    }
    return null;
  }
}
```

## Performance Optimization

### Image Caching

Weather icons are cached for better performance:

```dart
CachedNetworkImage(
  imageUrl: weather.icon,
  width: 15.w,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### List Performance

Optimized list rendering for favorites:

```dart
ListView.builder(
  itemCount: favorites.length,
  itemBuilder: (context, index) {
    return WeatherCard(
      key: ValueKey(favorites[index]),
      weather: weatherData[index],
    );
  },
)
```

## Accessibility

### Screen Reader Support

All components include proper semantic labels:

```dart
Semantics(
  label: '${weather.cityName} weather: ${weather.temperature} degrees, ${weather.description}',
  child: WeatherCard(weather: weather),
)
```

### Focus Management

Proper focus handling for navigation:

```dart
Focus(
  autofocus: true,
  child: TextFormField(
    controller: _controller,
    // ... other properties
  ),
)
```

## Testing Patterns

### Widget Testing

Example widget tests for components:

```dart
testWidgets('WeatherCard displays weather information', (WidgetTester tester) async {
  final weather = Weather(
    cityName: 'Istanbul',
    temperature: 25.0,
    description: 'Sunny',
    // ... other properties
  );

  await tester.pumpWidget(
    MaterialApp(
      home: WeatherCard(weather: weather),
    ),
  );

  expect(find.text('Istanbul'), findsOneWidget);
  expect(find.text('25°C'), findsOneWidget);
  expect(find.text('Sunny'), findsOneWidget);
});
```

### Integration Testing

Example integration tests for page navigation:

```dart
testWidgets('Navigation between pages works correctly', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // Test initial page
  expect(find.byType(CurrentLocationPage), findsOneWidget);

  // Navigate to search page
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();

  expect(find.byType(SearchPage), findsOneWidget);
});
```

This component documentation provides detailed implementation guidance for developers working with the Weather App's UI components.