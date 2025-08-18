import 'package:logging/logging.dart';

Logger createLogger() {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    print(
      "${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}",
    );
  });

  return Logger("Warden");
}
