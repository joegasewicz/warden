import 'dart:ffi';

import 'package:ansicolor/ansicolor.dart';

void printLogo(bool isWatching) {
  AnsiPen greenPen = AnsiPen()..green();

  print(drawLogo());

  if (isWatching) {
    print(greenPen("[WARDEN]: 👀Watching..."));
  } else {
    print(greenPen("[WARDEN]: 🛠️ Building..."));
  }

}

String drawLogo() {
  AnsiPen cyan = AnsiPen()..cyan();
  AnsiPen bold = AnsiPen()..white(bold: true);
  var logo = cyan(r"""
 ___       __   ________  ________  ________  _______   ________      
|\  \     |\  \|\   __  \|\   __  \|\   ___ \|\  ___ \ |\   ___  \    
\ \  \    \ \  \ \  \|\  \ \  \|\  \ \  \_|\ \ \   __/|\ \  \\ \  \   
 \ \  \  __\ \  \ \   __  \ \   _  _\ \  \ \\ \ \  \_|/_\ \  \\ \  \  
  \ \  \|\__\_\  \ \  \ \  \ \  \\  \\ \  \_\\ \ \  \_|\ \ \  \\ \  \ 
   \ \____________\ \__\ \__\ \__\\ _\\ \_______\ \_______\ \__\\ \__\
    \|____________|\|__|\|__|\|__|\|__|\|_______|\|_______|\|__| \|__|    
    """);
  logo += bold("                   Static Builder CLI\n");
  return logo;
}
