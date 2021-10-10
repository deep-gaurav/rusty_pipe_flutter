import 'package:artemis/artemis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rusty_pipe_flutter/api/api.graphql.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
import 'package:rusty_pipe_flutter/utils/humanize.dart';

// repeat states enum
enum Repeat { off, all, single }

class PlayerManager extends InheritedWidget {
  const PlayerManager({
    Key? key,
    required this.playerState,
    required Widget child,
  }) : super(key: key, child: child);

  final GlobalKey<PlayerState> playerState;

  static PlayerManager of(BuildContext context) {
    final PlayerManager? result =
        context.dependOnInheritedWidgetOfExactType<PlayerManager>();
    assert(result != null, 'No PlayerManager found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(PlayerManager oldWidget) =>
      playerState != oldWidget.playerState;

  setCurrentlyPlaying(VideoResultFieldsMixin video) {
    playerState.currentState?.setCurretlyPlaying(video);
  }
}

class Player extends StatefulWidget {
  const Player({required this.child, required Key key}) : super(key: key);

  final Widget child;

  @override
  State<Player> createState() => PlayerState();
}

class PlayerState extends State<Player> {
  VideoResultFieldsMixin? currentyPlaying;
  PlayerStatusFieldsMixin? playingStatus;

  bool get isEnded => playingStatus?.currentStatus == playingStatus?.totalTime;

  bool isloading = false;

  Repeat repeatState = Repeat.off;

  Stream<GraphQLResponse<PlayerMessages$SubscriptionRoot>>? playerSubscription;

  setCurretlyPlaying(VideoResultFieldsMixin video) {
    setState(() {
      currentyPlaying = video;
      isloading = true;
    });
  }

  double? _tmpSliderValue;

  previous() {}
  resume() async {
    if (isEnded) {
      await RustyPipeClient.of(context)!.artemisClient.execute(SeekQuery(
          variables: SeekArguments(seconds: -(playingStatus?.totalTime ?? 0))));
    }
    await RustyPipeClient.of(context)!.artemisClient.execute(ResumeQuery());
  }

  pause() async {
    await RustyPipeClient.of(context)!.artemisClient.execute(PauseQuery());
  }

  next() {}

  repeat() {
    setState(() {
      repeatState = Repeat.values[(repeatState.index + 1) %
          Repeat.values.length]; // change to next state
    });
  }

  seekTo(int seconds) async {
    var distance = seconds - (playingStatus?.currentStatus ?? 0);
    await RustyPipeClient.of(context)!
        .artemisClient
        .execute(SeekQuery(variables: SeekArguments(seconds: distance)));
  }

  String? getThumbnailUrl() {
    if (currentyPlaying?.thumbnail.isNotEmpty ?? false) {
      return currentyPlaying?.thumbnail.first.url;
    }
  }

  void onEnd() async {
    // check and handle repeat
    switch (repeatState) {
      case Repeat.off:
        break;
      case Repeat.all:
        break;
      case Repeat.single:
        await RustyPipeClient.of(context)!.artemisClient.execute(SeekQuery(
            variables: SeekArguments(
                seconds: 0 - (playingStatus?.currentStatus ?? 0))));
        break;
    }
  }

  Icon getRepeatIcon(BuildContext context) {
    switch (repeatState) {
      case Repeat.off:
        return Icon(Icons.repeat, color: Theme.of(context).disabledColor);
      case Repeat.all:
        return const Icon(Icons.repeat);
      case Repeat.single:
        return const Icon(Icons.repeat_one);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      print("Subscribing");
      playerSubscription = RustyPipeClient.of(context)
          ?.artemisClient
          .stream(PlayerMessagesSubscription())
          .asBroadcastStream();
      // playerSubscription!.asBroadcastStream()
      playerSubscription!.forEach((element) {
        bool isEndedPreviously = isEnded;
        if (element.data != null) {
          if (element.data?.playerMessages
              is PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus) {
            PlayerMessages$SubscriptionRoot$PlayerMessage? message =
                element.data?.playerMessages;

            setState(() {
              playingStatus = (message
                  as PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus);
              if (playingStatus!.playing) {
                isloading = false;
              }
            });
          }
        }
        if (isEnded && !isEndedPreviously) {
          onEnd();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: widget.child),
          if (currentyPlaying != null) ...[
            Stack(
              clipBehavior: Clip.none,
              fit: StackFit.passthrough,
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Theme.of(context).primaryColorLight,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: previous,
                              icon: const Icon(Icons.skip_previous)),
                          if (isloading) ...[
                            Container(child: const CircularProgressIndicator()),
                          ] else ...[
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                  begin: 0.0,
                                  end: (playingStatus?.playing ?? false) &&
                                          !isEnded
                                      ? 1.0
                                      : 0.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return InkWell(
                                  onTap: () {
                                    if (playingStatus?.playing ?? false) {
                                      pause();
                                    } else {
                                      resume();
                                    }
                                  },
                                  child: AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: AlwaysStoppedAnimation(value),
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ],
                          IconButton(
                              onPressed: previous,
                              icon: const Icon(Icons.skip_next)),
                          Text(
                              "${humanizeDuration(Duration(seconds: playingStatus?.currentStatus ?? 0))}/${humanizeDuration(Duration(seconds: playingStatus?.totalTime ?? 0))}"),
                        ],
                      ),
                      const Spacer(),
                      Row(children: [
                        if (getThumbnailUrl() != null)
                          Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ClipRRect(
                                child: Image.network(getThumbnailUrl()!),
                                borderRadius: BorderRadius.circular(10),
                              )),
                        if (currentyPlaying != null)
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentyPlaying!.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  currentyPlaying!.uploaderName ?? '',
                                ),
                              ],
                            ),
                          )
                      ]),
                      const Spacer(),
                      Row(
                        children: [
                          const IconButton(
                              onPressed: null, icon: Icon(Icons.volume_up)),
                          IconButton(
                              onPressed: repeat, icon: getRepeatIcon(context)),
                          const IconButton(
                              onPressed: null, icon: Icon(Icons.shuffle)),
                          Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: const IconButton(
                              onPressed: null,
                              icon: Icon(
                                Icons.arrow_drop_up,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (playingStatus != null && playingStatus!.totalTime != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -25,
                    child: Slider(
                      min: 0,
                      max: playingStatus!.totalTime!.toDouble(),
                      value: _tmpSliderValue ??
                          playingStatus!.currentStatus!.toDouble(),
                      onChanged: (val) {
                        setState(() {
                          _tmpSliderValue = val;
                        });
                      },
                      onChangeEnd: (val) {
                        seekTo(val.toInt());
                        setState(() {
                          _tmpSliderValue = null;
                          playingStatus?.currentStatus = val.toInt();
                          if (playingStatus!.playing) {
                            isloading = true;
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
