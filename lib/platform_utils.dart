import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

bool isWeb() => kIsWeb;

bool isMobile() => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
