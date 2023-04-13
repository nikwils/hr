class AppSettings {
  static final _singleton = AppSettings._internal();
  factory AppSettings() => _singleton;
  AppSettings._internal();

  //NOTE: true - боевой, false - тестовый
  static const isProduction = true;

  //NOTE: ТОКЕН для доступа к серверу
  static const serverAuthenticationToken = isProduction
      ? ''
      : '';
  static const serverDomain =
      isProduction ? '' : '';

  static const myAppTitle = 'HR Events';
}
