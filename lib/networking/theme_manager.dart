import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rusty_pipe_flutter/main.dart';

class ThemeManager extends InheritedWidget {
  final GlobalKey<MyAppState> managerKey;
  ThemeManager({Key? key, required Widget child, required this.managerKey})
      : super(key: key, child: child);

  static ThemeManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeManager>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  MaterialColor get getCurrentColor =>
      managerKey.currentState?.currentColor ?? Colors.green;

  setColorFromImage(ImageProvider provider) async {
    var pallete = await PaletteGenerator.fromImageProvider(provider);
    managerKey.currentState!
        .setColor(pallete.vibrantColor?.color ?? pallete.dominantColor!.color);
  }
}
