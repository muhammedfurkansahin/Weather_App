import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:weather_app/languages/text_widgets.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/cubit/weather_state.dart';

class _ApiKey {
  static const apiKey = '36a06512f3094315ad4112041240208';
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherInitial());

  final Dio _dio = Dio();

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ErrorMessage.networkError;
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 400) {
            return ErrorMessage.cityNotFound;
          } else if (error.response?.statusCode == 500) {
            return ErrorMessage.serverError;
          }
          return ErrorMessage.weatherDataFailed;
        case DioExceptionType.connectionError:
          return ErrorMessage.networkError;
        default:
          return ErrorMessage.unknownError;
      }
    }
    return ErrorMessage.unknownError;
  }

  Future<void> fetchWeather(String city) async {
    const apiKey = _ApiKey.apiKey;
    final url =
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=3&lang=tr';

    try {
      emit(WeatherLoading());
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        final weather = Weather.fromJson(jsonResponse);
        emit(WeatherLoaded(weather));
      } else {
        emit(WeatherError(ErrorMessage.weatherDataFailed));
      }
    } catch (e) {
      emit(WeatherError(_getErrorMessage(e)));
    }
  }

  Future<void> fetchWeatherForCities(List<String> cities) async {
    const apiKey = _ApiKey.apiKey;

    try {
      emit(WeatherLoading());

      final responses = await Future.wait(
        cities.map((city) {
          final url =
              'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=3&lang=tr';
          return _dio.get(url);
        }),
      );

      final weathers = responses.map((response) {
        final jsonResponse = response.data;
        return Weather.fromJson(jsonResponse);
      }).toList();

      emit(WeathersLoaded(weathers));
    } catch (e) {
      emit(WeatherError(_getErrorMessage(e)));
    }
  }

  Future<void> fetchWeatherByLocation(double latitude, double longitude) async {
    const apiKey = _ApiKey.apiKey;
    final url =
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=3&lang=tr';

    try {
      emit(WeatherLoading());
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        final weather = Weather.fromJson(jsonResponse);
        emit(WeatherLoaded(weather));
      } else {
        emit(WeatherError(ErrorMessage.weatherDataFailed));
      }
    } catch (e) {
      emit(WeatherError(_getErrorMessage(e)));
    }
  }
}
