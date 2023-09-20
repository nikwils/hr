import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';

import 'package:hr_events/services/exception_handlers/dialog_exception.dart';

class ExceptionHandlers {
  static final _singleton = ExceptionHandlers._internal();
  factory ExceptionHandlers() => _singleton;
  ExceptionHandlers._internal();

  getExceptionString([error]) {
    if (error is SocketException) {
      return _openDialogException('global.errors.socket_exception'.tr());
    } else if (error is HttpException) {
      return _openDialogException('global.errors.http_exception'.tr());
    } else if (error is FormatException) {
      return _openDialogException('global.errors.format_exception'.tr());
    } else if (error is TimeoutException) {
      return _openDialogException('global.errors.timeout_exception'.tr());
    } else if (error is BadRequestException) {
      return _openDialogException('global.errors.bad_request_exception'.tr());
    } else {
      return _openDialogException('global.errors.unknown_error'.tr());
    }
  }

  void _openDialogException(String err) {
    DialogException().showAlertDialog(
      content: err,
      title: 'global.errors.error'.tr(),
    );
  }
}

class AppException implements Exception {
  final String? message;
  final String? prefix;
  final String? url;
  AppException([this.message, this.prefix, this.url]);
}

class BadRequestException extends AppException {
  BadRequestException([String? message, String? url])
      : super(message, 'Bad request', url);
}
