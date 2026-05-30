import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/storage/hive_boxes.dart';
import 'core/storage/type_adapters.dart';
import 'core/notifications/notification_service.dart';

/// One-time app bootstrap. Keep this lean — everything that doesn't strictly
/// need to happen before the first frame should be deferred.
Future<void> bootstrap() async {
  // Lock to portrait for v1 (breathing UX is portrait-first).
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  // Opt into 120Hz on Android where supported. No-op on iOS.
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {/* ignore — emulator / unsupported device */}

  await Hive.initFlutter();
  registerAdapters();
  await HiveBoxes.openAll();

  // Initialize notifications. Permission requested later in onboarding.
  await NotificationService.instance.init();
}
