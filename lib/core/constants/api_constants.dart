class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String horses = '/horses';
  static const String health = '/health';
  static const String workouts = '/workouts';
  static const String reports = '/reports';
}
