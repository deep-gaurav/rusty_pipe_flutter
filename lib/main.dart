import 'dart:io';

import 'package:artemis/artemis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gql_websocket_link/gql_websocket_link.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
import 'package:rusty_pipe_flutter/networking/songs_manager.dart';
import 'package:rusty_pipe_flutter/networking/theme_manager.dart';
import 'package:rusty_pipe_flutter/screens/home.dart';
import 'package:rusty_pipe_flutter/screens/player.dart';
import 'package:rustypipeuinative/rustypipeuinative.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const AppRunner());
}

class AppRunner extends StatefulWidget {
  const AppRunner({Key? key}) : super(key: key);

  @override
  State<AppRunner> createState() => _AppRunnerState();
}

class _AppRunnerState extends State<AppRunner> {
  int? port;

  Directory? videoCacheDir;
  Directory? videoMetadataCacheDir;
  Directory? videoResultMetadataCacheDir;

  GlobalKey<MyAppState> appKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        port = Rustypipeuinative.getPort();
        Rustypipeuinative.startServer(port!);
      });
      getApplicationSupportDirectory().then((value) async {
        var videoDir = Directory(value.path + Platform.pathSeparator + 'video');
        await videoDir.create(recursive: true);
        var videoMetadataDir =
            Directory(value.path + Platform.pathSeparator + 'videoMetadata');
        await videoMetadataDir.create(recursive: true);
        var resultsDir = Directory(
            value.path + Platform.pathSeparator + 'videoResultsMetadata');
        await resultsDir.create(recursive: true);
        setState(() {
          videoCacheDir = videoDir;
          videoMetadataCacheDir = videoMetadataDir;
          videoResultMetadataCacheDir = resultsDir;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (port == null) {
      return MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Column(
            children: [
              Container(
                child: const Text("Cant start rustypipe."),
              ),
              TextField(
                decoration: const InputDecoration(helperText: 'Enter port'),
                onSubmitted: (val) {
                  var port = int.tryParse(val);
                  setState(() {
                    this.port = port;
                  });
                },
              )
            ],
          ),
        ),
      );
    } else if (videoCacheDir == null ||
        videoMetadataCacheDir == null ||
        videoResultMetadataCacheDir == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return MyApp(
          key: appKey,
          port: port!,
          videoCacheDir: videoCacheDir!,
          videoMetadataCacheDir: videoMetadataCacheDir!,
          videoResultMetadataCacheDir: videoResultMetadataCacheDir!);
    }
  }
}

class MyApp extends StatefulWidget {
  final int port;
  final Directory videoCacheDir;
  final Directory videoMetadataCacheDir;
  final Directory videoResultMetadataCacheDir;
  const MyApp({
    required GlobalKey<MyAppState> key,
    required this.port,
    required this.videoCacheDir,
    required this.videoMetadataCacheDir,
    required this.videoResultMetadataCacheDir,
  }) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  GlobalKey<PlayerState> playerKey = GlobalKey();

  MaterialColor currentColor = Colors.green;

  Map<int, Color> colorCodes(Color color) => {
        50: color.withOpacity(.1),
        100: color.withOpacity(.2),
        200: color.withOpacity(.3),
        300: color.withOpacity(.4),
        400: color.withOpacity(.5),
        500: color.withOpacity(.6),
        600: color.withOpacity(.7),
        700: color.withOpacity(.8),
        800: color.withOpacity(.9),
        900: color.withOpacity(1),
      };
  setColor(Color color) {
    print('Set color $color');
    setState(() {
      currentColor = MaterialColor(color.value, colorCodes(color));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RustyPipeClient(
      artemisClient: ArtemisClient.fromLink(
        WebSocketLink(
          null,
          channelGenerator: () => WebSocketChannel.connect(
            Uri.parse(
              'ws://localhost:${widget.port}/graphql',
              // 'ws://localhost:8000/',
            ),
            protocols: ['graphql-ws'],
          ),
        ),
      ),
      // artemisClient: ArtemisClient('http://localhost:$port'),
      port: widget.port,
      child: MaterialApp(
        home: ThemeManager(
          managerKey: widget.key as GlobalKey<MyAppState>,
          child: Builder(builder: (context2) {
            return MaterialApp(
              title: 'Rusty Pipe',
              builder: (context3, child) {
                return SongsManager(
                  videoCacheDir: widget.videoCacheDir,
                  videoMetadataDir: widget.videoMetadataCacheDir,
                  videoResultMetadataDir: widget.videoResultMetadataCacheDir,
                  child: Builder(builder: (context) {
                    print(
                        'Cutoffs ${MediaQuery.of(context).viewInsets} ${MediaQuery.of(context).viewPadding}');
                    return PlayerManager(
                        playerState: playerKey,
                        child: Player(
                            cutouts: MediaQuery.of(context2).viewPadding,
                            child: child ?? Container(),
                            key: playerKey));
                  }),
                );
              },
              theme: ThemeData(
                primarySwatch: ThemeManager.of(context2).getCurrentColor,
              ),
              home: Home(),
            );
          }),
        ),
      ),
    );
  }
}
