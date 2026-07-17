/// App-wide configuration.
///
/// Override the API base URL at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
///
/// Defaults:
///  * Android emulator reaches the host machine at 10.0.2.2
///  * A real device must use your machine's LAN IP (e.g. http://192.168.x.x:8000/api)
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
