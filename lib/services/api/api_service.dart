import 'package:hr_events/services/device_service.dart';
import 'package:http/http.dart' as http;

import 'package:hr_events/services/exception_handlers/exception_handlers.dart';
import 'package:hr_events/app_settings.dart';
import 'package:hr_events/services/api/api_controller_service.dart';

class ApiService {
  static const subController = '/api/';

  //TODO: локализация?
  Map<String, dynamic> subBody = {
    'lang': 'ru',
    'uid': DeviceService().deviceUID,
  };

  Map<String, String> headersRequest = {
    'Authentication': AppSettings.serverAuthenticationToken,
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  Future<http.Response?> post(
      {required ApiControllerService controller,
      Map<String, String>? body}) async {
    try {
      final data = '$subController${controller.url()}';
      final url = Uri.https(AppSettings.serverDomain, data);

      if (body != null) {
        subBody.addAll(body);
      }

      final response = await http.post(
        url,
        headers: headersRequest,
        body: subBody,
      );
      return response;
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
      return null;
    }
  }

  Future<http.Response?> get(
      {required ApiControllerService controller,
      Map<String, String>? body}) async {
    try {
      final data = '$subController${controller.url()}';
      final queryParameters = subBody;
      final url = Uri.https(AppSettings.serverDomain, data, queryParameters);

      final response = await http.get(url, headers: headersRequest);
      return response;
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
      return null;
    }
  }
}
