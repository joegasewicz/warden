

import 'package:ansi_styles/ansi_styles.dart';

class Environment {
  Map<String, String> devEnvVariables;
  Map<String, String> prodEnvVariables;

  Environment({
    required this.devEnvVariables,
    required this.prodEnvVariables,
  }) {
    if (devEnvVariables.isNotEmpty) {
      print("${AnsiStyles.green("◆")} ${AnsiStyles.cyan("dev environment variables set successfully:")}");
      devEnvVariables.forEach((key, value) {
        print("\t ${AnsiStyles.blueBright("◆")} ${AnsiStyles.cyan("$key: ")}${AnsiStyles.magenta("[$value]")}");
      });
    }
  }

}