import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class AppConfig {
  static String get apiBaseUrl {
    if(kIsWeb) return 'http://localhost:5073';
    if(Platform.isAndroid) return 'http://192.168.0.103:5073';
    return 'http://localhost:5073';
  }
}