class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double windSpeed;
  final double humidity;
  final double feelsLike;
  final double uv;
  final double pressureMb;
  final double precipMm;
  final int cloud;
  final List<DailyWeather> dailyWeather;
  final List<HourlyWeather> hourlyWeather;
  final int conditionCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.conditionCode,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
    required this.feelsLike,
    required this.uv,
    required this.pressureMb,
    required this.precipMm,
    required this.cloud,
    required this.dailyWeather,
    required this.hourlyWeather,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    List<DailyWeather> dailyWeather =
        (json['forecast']['forecastday'] as List).map((day) => DailyWeather.fromJson(day)).toList();
    List<HourlyWeather> hourlyWeather = (json['forecast']['forecastday'][0]['hour'] as List)
        .map((hour) => HourlyWeather.fromJson(hour))
        .toList();

    return Weather(
      cityName: json['location']['name'],
      temperature: (json['current']['temp_c'] as num).toDouble(),
      description: json['current']['condition']['text'],
      conditionCode: (json['current']['condition']['code'] as num).toInt(),
      icon: 'https:${json['current']['condition']['icon']}',
      windSpeed: (json['current']['wind_kph'] as num).toDouble(),
      humidity: (json['current']['humidity'] as num).toDouble(),
      feelsLike: (json['current']['feelslike_c'] as num).toDouble(),
      uv: (json['current']['uv'] as num).toDouble(),
      pressureMb: (json['current']['pressure_mb'] as num).toDouble(),
      precipMm: (json['current']['precip_mm'] as num).toDouble(),
      cloud: (json['current']['cloud'] as num).toInt(),
      dailyWeather: dailyWeather,
      hourlyWeather: hourlyWeather,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'location': {'name': cityName},
      'current': {
        'temp_c': temperature,
        'condition': {
          'text': description,
          'code': conditionCode,
          'icon': icon.replaceFirst('https:', ''),
        },
        'wind_kph': windSpeed,
        'humidity': humidity,
        'feelslike_c': feelsLike,
        'uv': uv,
        'pressure_mb': pressureMb,
        'precip_mm': precipMm,
        'cloud': cloud,
      },
      'forecast': {
        'forecastday': dailyWeather.map((d) => d.toJsonWithHours(hourlyWeather)).toList()
      }
    };
  }
}

class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String icon;
  final String sunrise;
  final String sunset;
  final double totalPrecipMm;
  final int dailyChanceOfRain;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.totalPrecipMm,
    required this.dailyChanceOfRain,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: json['date'],
      maxTemp: (json['day']['maxtemp_c'] as num).toDouble(),
      minTemp: (json['day']['mintemp_c'] as num).toDouble(),
      icon: 'https:${json['day']['condition']['icon']}',
      sunrise: json['astro']['sunrise'],
      sunset: json['astro']['sunset'],
      totalPrecipMm: (json['day']['totalprecip_mm'] as num).toDouble(),
      dailyChanceOfRain: (json['day']['daily_chance_of_rain'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJsonWithHours(List<HourlyWeather>? hours) {
    return {
      'date': date,
      'day': {
        'maxtemp_c': maxTemp,
        'mintemp_c': minTemp,
        'condition': {'icon': icon.replaceFirst('https:', '')},
        'totalprecip_mm': totalPrecipMm,
        'daily_chance_of_rain': dailyChanceOfRain,
      },
      'astro': {
        'sunrise': sunrise,
        'sunset': sunset,
      },
      'hour': hours?.map((h) => h.toJson()).toList() ?? []
    };
  }
}

class HourlyWeather {
  final String time;
  final double temperature;
  final String icon;
  final double precipMm;
  final int chanceOfRain;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.precipMm,
    required this.chanceOfRain,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: json['time'],
      temperature: (json['temp_c'] as num).toDouble(),
      icon: 'https:${json['condition']['icon']}',
      precipMm: (json['precip_mm'] as num).toDouble(),
      chanceOfRain: (json['chance_of_rain'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temp_c': temperature,
      'condition': {'icon': icon.replaceFirst('https:', '')},
      'precip_mm': precipMm,
      'chance_of_rain': chanceOfRain,
    };
  }
}
