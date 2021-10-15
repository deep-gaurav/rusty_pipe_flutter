import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rusty_pipe_flutter/screens/player.dart';

class PlayerNotificationManager extends BaseAudioHandler {
  final GlobalKey<PlayerState> playerKey;

  PlayerNotificationManager({required this.playerKey});

  updateCurrentItem() {
    print('Updating current item');
    mediaItem.add(MediaItem(
      id: playerKey.currentState!.currentyPlaying!.videoId,
      title: playerKey.currentState!.currentyPlaying!.name,
      artist: playerKey.currentState!.currentyPlaying!.uploaderName,
      duration: Duration(
          seconds: playerKey.currentState?.playingStatus?.totalTime ??
              playerKey.currentState!.currentyPlaying!.duration ??
              0),
      artUri: Uri.parse(
          playerKey.currentState!.currentyPlaying!.thumbnail.first.url),
    ));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playerKey.currentState?.setState(() {
      playerKey.currentState?.repeatState = repeatMode;
    });
    updateState();
  }

  updateState() {
    print('Updating state');

    mediaItem.add(MediaItem(
      id: playerKey.currentState!.currentyPlaying!.videoId,
      title: playerKey.currentState!.currentyPlaying!.name,
      artist: playerKey.currentState!.currentyPlaying!.uploaderName,
      duration: Duration(
          seconds: playerKey.currentState?.playingStatus?.totalTime ??
              playerKey.currentState!.currentyPlaying!.duration ??
              0),
      artUri: Uri.parse(
          playerKey.currentState!.currentyPlaying!.thumbnail.first.url),
    ));
    playbackState.add(
      PlaybackState(
        repeatMode: playerKey.currentState!.repeatState,
        processingState: playerKey.currentState!.isloading
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
        controls: [
          MediaControl.skipToPrevious,
          playerKey.currentState?.playingStatus?.playing ?? false
              ? MediaControl.pause
              : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setRepeatMode,
        },
        speed: 1.0,
        playing: playerKey.currentState!.playingStatus!.playing,
        updatePosition: Duration(
            seconds: playerKey.currentState?.playingStatus?.currentStatus ?? 0),
      ),
    );
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
    playerKey.currentState?.resume();
  }

  @override
  Future<void> pause() async {
    playerKey.currentState?.pause();
  }

  @override
  Future<void> stop() async {
    super.stop();
    SystemNavigator.pop();
    exit(0);
  }

  @override
  Future<void> seek(Duration position) async {
    playerKey.currentState?.seekTo(position.inSeconds);
  }

  @override
  Future<void> skipToNext() async {
    playerKey.currentState?.next();
  }

  @override
  Future<void> skipToPrevious() async {
    playerKey.currentState?.previous();
  }
  // @override
  // Future<void> skipToQueueItem(int i) async {}
}
