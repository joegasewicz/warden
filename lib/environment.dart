

import 'package:ansicolor/ansicolor.dart';

class Environment {
  Map<String, String> devEnvVariables;
  Map<String, String> prodEnvVariables;
  AnsiPen blue = AnsiPen()..blue();

  Environment({
    required this.devEnvVariables,
    required this.prodEnvVariables,
  }) {
    if (devEnvVariables.isNotEmpty) {
      print(blue("[WARDEN]: 🛠️ Dev environment variables set successfully:"));
      devEnvVariables.forEach((key, value) {
        print("\t 🟢 $key: $value");
      });
    }
  }

}