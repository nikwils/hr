class AppSettings {
  static final _singleton = AppSettings._internal();
  factory AppSettings() => _singleton;
  AppSettings._internal();

  //NOTE: ТОКЕН для доступа к серверу
  static const serverAuthenticationToken = '';
  static const serverDomain = '';

  static const myAppTitle = 'HR Events';
}
