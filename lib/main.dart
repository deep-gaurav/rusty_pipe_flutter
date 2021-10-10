import 'package:artemis/artemis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gql_websocket_link/gql_websocket_link.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        //port = Rustypipeuinative.getPort();
        //Rustypipeuinative.startServer(port!);
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
    } else {
      return MyApp(port: port!);
    }
  }
}

class MyApp extends StatefulWidget {
  final int port;
  const MyApp({Key? key, required this.port}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<PlayerState> playerKey = GlobalKey();

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
        home: Builder(builder: (context) {
          return MaterialApp(
            title: 'Rusty Pipe',
            builder: (context, child) {
              return PlayerManager(
                  playerState: playerKey,
                  child: Player(child: child ?? Container(), key: playerKey));
            },
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            home: Home(),
          );
        }),
      ),
    );
  }
}
