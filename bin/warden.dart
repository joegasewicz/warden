import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:warden/conf/conf.dart';
import 'package:warden/warden.dart';

void main(List<String> arguments) async {
  printLogo();

  final parser =
      ArgParser()..addOption("file", abbr: "f", help: "The warden yaml file.");

  // Handle args
  final argResults = parser.parse(arguments);
  String wardenFile = "warden.yaml";
  if (argResults.wasParsed("file")) {
    wardenFile = argResults["file"];
  }
  print("file = $wardenFile");

  final conf = Conf(wardenFilePath: wardenFile);

  final warden = Warden(config: conf);
  warden.run();
}

void printLogo() {
  AnsiPen cyan = AnsiPen()..cyan();
  AnsiPen bold = AnsiPen()..white(bold: true);
  print(
    cyan(r"""
 ___       __   ________  ________  ________  _______   ________      
|\  \     |\  \|\   __  \|\   __  \|\   ___ \|\  ___ \ |\   ___  \    
\ \  \    \ \  \ \  \|\  \ \  \|\  \ \  \_|\ \ \   __/|\ \  \\ \  \   
 \ \  \  __\ \  \ \   __  \ \   _  _\ \  \ \\ \ \  \_|/_\ \  \\ \  \  
  \ \  \|\__\_\  \ \  \ \  \ \  \\  \\ \  \_\\ \ \  \_|\ \ \  \\ \  \ 
   \ \____________\ \__\ \__\ \__\\ _\\ \_______\ \_______\ \__\\ \__\
    \|____________|\|__|\|__|\|__|\|__|\|_______|\|_______|\|__| \|__|    
    """),
  );
  print(bold("                   Static Builder CLI\n"));
}
