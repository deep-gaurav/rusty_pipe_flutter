import 'dart:async';

import 'package:artemis/artemis.dart';
import 'package:flutter/material.dart';

class RustyPipeClient extends InheritedWidget {
  final ArtemisClient artemisClient;
  final int port;
  const RustyPipeClient({
    Key? key,
    required Widget child,
    required this.artemisClient,
    required this.port,
  }) : super(key: key, child: child);
  @override
  static RustyPipeClient of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RustyPipeClient>()!;
  }

  @override
  bool updateShouldNotify(RustyPipeClient oldWidget) {
    return true;
  }

  bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}
