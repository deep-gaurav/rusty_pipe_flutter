import 'package:artemis/artemis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_bottom_bar/expandable_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rusty_pipe_flutter/api/api.graphql.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
import 'package:rusty_pipe_flutter/networking/songs_manager.dart';
import 'package:rusty_pipe_flutter/networking/theme_manager.dart';
import 'package:rusty_pipe_flutter/screens/search.dart';
import 'package:rusty_pipe_flutter/utils/humanize.dart';
import 'dart:math' as math;

import 'package:rusty_pipe_flutter/widgets/custom_nav_bar.dart';

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

  setCurrentlyPlaying(VideoResultFieldsMixin video, BuildContext context,
      {bool setQueue = false}) async {
    await RustyPipeClient.of(context)!.artemisClient.execute(PauseQuery());
    await SongsManager.of(context).cacheVideoResult(video);

    playerState.currentState?.setCurretlyPlaying(video);
    var vide = await SongsManager.of(context)
        .playVideo(video: video, context: context);
    if (setQueue) {
      playerState.currentState?.setQueue([
        video,
        ...vide.related.cast(),
      ]);
    }

    await RustyPipeClient.of(context)?.artemisClient.execute(ResumeQuery());
  }
}

class Player extends StatefulWidget {
  const Player({required this.cutouts, required this.child, required Key key})
      : super(key: key);

  final Widget child;
  final EdgeInsets cutouts;

  @override
  State<Player> createState() => PlayerState();
}

class PlayerState extends State<Player> with TickerProviderStateMixin {
  VideoResultFieldsMixin? currentyPlaying;
  PlayerStatusFieldsMixin? playingStatus;

  bool get isEnded => playingStatus?.currentStatus == playingStatus?.totalTime;

  bool isloading = false;

  Repeat repeatState = Repeat.off;

  Stream<GraphQLResponse<PlayerMessages$SubscriptionRoot>>? playerSubscription;

  late BottomBarController bottomBarController;
  late BottomBarController bottomBarController2;

  // Map<String, VideoFieldsMixin> preparedDatas = {};

  ScrollController queueScrollController = ScrollController();

  setCurretlyPlaying(VideoResultFieldsMixin video) {
    setState(() {
      currentyPlaying = video;
      isloading = true;
    });
    setTheme();
    setQueuePosition();
    prepareNext();
  }

  prepareNext() async {
    try {
      var nextI = queue
          .indexWhere((element) => element.videoId == currentyPlaying?.videoId);
      var next = queue[nextI + 1];

      var prep = await SongsManager.of(context)
          .prepareVideo(video: next, context: context);
      // preparedDatas.removeWhere((key, value) => key.)
    } catch (e) {}
  }

  setTheme() {
    try {
      var url = currentyPlaying?.thumbnail.first.url;
      var provider = CachedNetworkImageProvider(url!);
      ThemeManager.of(context).setColorFromImage(provider);
    } catch (e) {
      print(e);
    }
  }

  setQueuePosition() {
    try {
      var currentIndex = queue
          .indexWhere((element) => element.videoId == currentyPlaying?.videoId);
      queueScrollController.jumpTo(miniPlayerSize * (currentIndex + 1));
    } catch (e) {}
  }

  double? _tmpSliderValue;

  bool get isMobile => RustyPipeClient.of(context).isMobile(context);

  double get miniPlayerSize => 60;

  List<VideoResultFieldsMixin> queue = [];

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

  next() {
    var current = queue
        .indexWhere((element) => element.videoId == currentyPlaying!.videoId);
    if (current < queue.length - 1) {
      PlayerManager.of(context)
          .setCurrentlyPlaying(queue[current + 1], context);
    }
  }

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

  setQueue(List<VideoResultFieldsMixin> queue) {
    setState(() {
      this.queue = queue;
    });
    prepareNext();
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
        next();
        break;
      case Repeat.all:
        next();
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
    bottomBarController = BottomBarController(vsync: this);
    bottomBarController2 = BottomBarController(vsync: this);

    bottomBarController.addListener(() {
      if (bottomBarController.isClosing) {
        bottomBarController2.close();
      }
      if (bottomBarController.isOpen) {
        setQueuePosition();
      }
    });
    bottomBarController2.addListener(() {
      if (bottomBarController2.isClosed) {
        setQueuePosition();
      }
    });

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
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: widget.child),
            //  ...[

            // ]
          ],
        ),
        bottomNavigationBar:
            (currentyPlaying != null) ? buildPlayer(context) : null,
      ),
    );
  }

  Widget buildPlayer(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (bottomBarController.isOpen || bottomBarController.isOpening) {
          bottomBarController.close();
          return false;
        } else {
          return true;
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomBottomExpandableAppBar(
          applyOpacity: false,
          controller: bottomBarController,
          appBarHeight: miniPlayerSize,
          expandedHeight: constraints.biggest.height -
              widget.cutouts.vertical -
              miniPlayerSize,
          horizontalMargin: 0,
          expandedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
          ),
          bottomOffset: 0,
          expandedBody: buildFullPlayer(),
          // expandedHeight:
          bottomAppBarBody: buildAnimatedMiniPlayer(context),
          bottomAppBarColor: Colors.transparent,
          ignoreBottomPointer: isMobile,
        );
      }),
    );
  }

  Widget buildFullPlayer() {
    if (isMobile) {
      return buildFullMobilePlayer();
    } else {
      return buildFullDesktopPlayer();
    }
  }

  Widget buildFullMobilePlayer() {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).primaryColorLight,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onVerticalDragUpdate: bottomBarController.onDrag,
              onVerticalDragEnd: bottomBarController.onDragEnd,
              behavior: HitTestBehavior.opaque,
              child: ValueListenableBuilder<double>(
                  valueListenable: bottomBarController.state,
                  builder: (context, val, child) {
                    return ValueListenableBuilder<double>(
                        valueListenable: bottomBarController2.state,
                        builder: (context, val2, child) {
                          return Stack(
                            fit: StackFit.passthrough,
                            children: [
                              Opacity(
                                opacity: ((1 - val) + val2).clamp(0.0, 1.0),
                                child: Container(
                                  height: miniPlayerSize,
                                  child: buildMobileMiniPlayer(context),
                                ),
                              ),
                              Positioned.fill(
                                  child: Opacity(
                                opacity:
                                    (1 - ((1 - val) + val2)).clamp(0.0, 1.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          bottomBarController.close();
                                        },
                                        icon: Icon(Icons.arrow_drop_down)),
                                    Spacer(),
                                  ],
                                ),
                              )),
                            ],
                          );
                        });
                  }),
            ),
            Expanded(
                child: (getThumbnailUrl() != null)
                    ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          child:
                              CachedNetworkImage(imageUrl: getThumbnailUrl()!),
                          borderRadius: BorderRadius.circular(10),
                        ))
                    : Container()),
            if (currentyPlaying != null) ...[
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentyPlaying!.name,
                      style: Theme.of(context).textTheme.headline5?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      currentyPlaying!.uploaderName ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (playingStatus != null) buildSeekBar(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const IconButton(onPressed: null, icon: Icon(Icons.shuffle)),
                  IconButton(
                      onPressed: previous,
                      icon: const Icon(Icons.skip_previous)),
                  buildPlayPauseButton(),
                  IconButton(
                      onPressed: next, icon: const Icon(Icons.skip_next)),
                  IconButton(onPressed: repeat, icon: getRepeatIcon(context)),
                ],
              ),
            ],
            Spacer(),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: bottomBarController.state,
          builder: (context, val, child) {
            return bottomBarController.state.value > 0.5
                ? CustomBottomExpandableAppBar(
                    applyOpacity: false,
                    controller: bottomBarController2,
                    appBarHeight: miniPlayerSize,
                    horizontalMargin: 0,
                    expandedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                    ),
                    bottomOffset: 0,
                    expandedBody: Container(
                      color: Colors.white,
                      child: Container(
                        color: Theme.of(context).primaryColorLight,
                        child: Column(
                          children: [
                            Expanded(child: buildQueue()),
                          ],
                        ),
                      ),
                    ),
                    expandedHeight:
                        constraints.biggest.height - miniPlayerSize * 2,
                    bottomAppBarBody: Container(color: Colors.transparent),
                    bottomAppBarColor: Colors.transparent,
                    ignoreBottomPointer: isMobile,
                  )
                : IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  );
          },
        ),
      );
    });
  }

  Row buildFullDesktopPlayer() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Center(
            child: (getThumbnailUrl() != null)
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      child: CachedNetworkImage(imageUrl: getThumbnailUrl()!),
                      borderRadius: BorderRadius.circular(10),
                    ))
                : Container(),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            child: buildQueue(),
          ),
        )
      ],
    );
  }

  Widget buildQueue([bool gestures = false]) {
    if (queue.isEmpty) {
      return Container();
    }
    return Stack(
      fit: StackFit.passthrough,
      children: [
        ReorderableListView(
          scrollController: queueScrollController,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = queue.removeAt(oldIndex);
              queue.insert(newIndex, item);
            });
          },
          children: [
            // ...queue.sublist(0, 1).map((e) => GestureDetector(
            //       key: Key(e.videoId),
            //       child: VideoResultItem(
            //         key: Key(e.videoId),
            //         videoResult: e,
            //         inQueue: true,
            //         isPlaying: currentyPlaying?.videoId == e.videoId,
            //       ),
            //     )),
            ...queue.map((e) => VideoResultItem(
                  key: Key(e.videoId),
                  videoResult: e,
                  inQueue: true,
                  isPlaying: currentyPlaying?.videoId == e.videoId,
                ))
          ],
        ),
        Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: bottomBarController2.onDragEnd,
              onVerticalDragUpdate: bottomBarController2.onDrag,
              child: Container(
                height: miniPlayerSize,
              ),
            ))
      ],
    );
  }

  Widget buildAnimatedMiniPlayer(BuildContext context) {
    if (isMobile) {
      return Container(
        color: Colors.transparent,
      );
      return ValueListenableBuilder<double>(
          valueListenable: bottomBarController.state,
          builder: (context, value, child) {
            return Container(
              height: miniPlayerSize * (value),
              // scale: bottomBarController.isOpen || bottomBarController.isOpening
              //     ? (1 - value)
              //     : (1 - value),
              child: buildMiniPlayer(context),
            );
          });
    } else {
      return buildMiniPlayer(context);
    }
  }

  Widget buildMiniPlayer(BuildContext context) {
    return InkWell(
      onTap: () {
        bottomBarController.swap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          Container(
            height: miniPlayerSize,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Theme.of(context).primaryColorLight,
            child: isMobile
                ? buildMobileMiniPlayer(context)
                : buildDesktopMiniPlayer(context),
          ),
          if (playingStatus != null && playingStatus!.totalTime != null)
            Positioned(
              left: 0,
              right: 0,
              top: isMobile ? 0 : -25,
              child: buildProgress(),
            ),
        ],
      ),
    );
  }

  Widget buildProgress() {
    if (isMobile) {
      return LinearProgressIndicator(
        value: (_tmpSliderValue ?? playingStatus!.currentStatus!.toDouble()) /
            (playingStatus!.totalTime!.toDouble()),
      );
    } else {
      return buildSeekBar();
    }
  }

  Slider buildSeekBar() {
    return Slider(
      min: 0,
      max: playingStatus!.totalTime!.toDouble(),
      value: _tmpSliderValue ?? playingStatus!.currentStatus!.toDouble(),
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
    );
  }

  Row buildDesktopMiniPlayer(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildMainControls(),
        Expanded(child: buildCentralTitle()),
        buildEndControlButtons(context),
      ],
    );
  }

  Row buildMobileMiniPlayer(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: buildCentralTitle()),
        buildMainControls(),
      ],
    );
  }

  Row buildMainControls() {
    return Row(
      children: [
        if (!isMobile)
          IconButton(
              onPressed: previous, icon: const Icon(Icons.skip_previous)),
        buildPlayPauseButton(),
        if (!isMobile) ...[
          IconButton(onPressed: previous, icon: const Icon(Icons.skip_next)),
          Text(
              "${humanizeDuration(Duration(seconds: playingStatus?.currentStatus ?? 0))}/${humanizeDuration(Duration(seconds: playingStatus?.totalTime ?? 0))}"),
        ]
      ],
    );
  }

  Widget buildPlayPauseButton() {
    if (isloading) {
      return Container(child: const CircularProgressIndicator());
    } else {
      return TweenAnimationBuilder<double>(
        tween: Tween(
            begin: 0.0,
            end: (playingStatus?.playing ?? false) && !isEnded ? 1.0 : 0.0),
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
      );
    }
  }

  Widget buildCentralTitle() {
    return Align(
      alignment: isMobile ? Alignment.centerLeft : Alignment.center,
      child: IntrinsicWidth(
        child: Row(children: [
          if (getThumbnailUrl() != null)
            Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ClipRRect(
                  child: CachedNetworkImage(imageUrl: getThumbnailUrl()!),
                  borderRadius: BorderRadius.circular(10),
                )),
          if (currentyPlaying != null)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentyPlaying!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentyPlaying!.uploaderName ?? '',
                    ),
                  ],
                ),
              ),
            )
        ]),
      ),
    );
  }

  Row buildEndControlButtons(BuildContext context) {
    return Row(
      children: [
        const IconButton(onPressed: null, icon: Icon(Icons.volume_up)),
        IconButton(onPressed: repeat, icon: getRepeatIcon(context)),
        const IconButton(onPressed: null, icon: Icon(Icons.shuffle)),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: ValueListenableBuilder(
              valueListenable: bottomBarController.state,
              builder: (context, val, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(
                      begin: 0.0, end: bottomBarController.isOpen ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return InkWell(
                      onTap: () {
                        bottomBarController.swap();
                      },
                      child: Transform.rotate(
                          angle: math.pi * value,
                          child: Icon(
                            Icons.arrow_drop_up,
                            size: 40,
                          )),
                    );
                  },
                );
              }),
          //  IconButton(
          //   onPressed: () {
          //     bottomBarController.swap();
          //   },
          //   icon: Icon(
          //     Icons.arrow_drop_up,
          //     size: 40,
          //   ),
          // ),
        ),
      ],
    );
  }
}
