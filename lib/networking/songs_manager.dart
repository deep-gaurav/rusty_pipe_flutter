import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rusty_pipe_flutter/api/api.graphql.dart';
import 'package:rusty_pipe_flutter/screens/player.dart';

import 'client_provider.dart';

import 'package:http/http.dart' as http;

class SongsManager extends InheritedWidget {
  final Directory videoMetadataDir;
  final Directory videoResultMetadataDir;
  final Directory videoCacheDir;

  const SongsManager({
    required Widget child,
    required this.videoCacheDir,
    required this.videoMetadataDir,
    required this.videoResultMetadataDir,
    Key? key,
  }) : super(key: key, child: child);

  static SongsManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SongsManager>()!;
  }

  Future<Video$QueryRoot$Video> loadVideo(
      String videoId, RustyPipeClient client) async {
    var result = await client.artemisClient
        .execute(VideoQuery(variables: VideoArguments(videoId: videoId)));
    if (result.data != null) {
      return result.data!.video;
    } else {
      throw "Cant get video";
    }
  }

  Future<VideoResultFieldsMixin> cacheVideoResult(
      VideoResultFieldsMixin video) async {
    var cacheFile = File(videoResultMetadataDir.absolute.path +
        Platform.pathSeparator +
        '${video.videoId}.json');
    var data = json.encode((video as dynamic).toJson());
    await cacheFile.writeAsString(data);
    return video;
  }

  Future<VideoFieldsMixin> prepareVideo({
    required VideoResultFieldsMixin video,
    required BuildContext context,
  }) async {
    print('preparing video id ${video.videoId} name ${video.name}');
    var videoFile = File(videoMetadataDir.absolute.path +
        Platform.pathSeparator +
        '${video.videoId}.json');
    var videoCacheFile = File(videoCacheDir.absolute.path +
        Platform.pathSeparator +
        '${video.videoId}.m4a');
    late VideoFieldsMixin videoData;
    if (await videoFile.exists()) {
      print('Video file cached');
      videoData = Video$QueryRoot$Video.fromJson(
          json.decode(await videoFile.readAsString()));
    } else {
      print('video file Not cached');
      var data = await loadVideo(video.videoId, RustyPipeClient.of(context)!);
      videoFile.writeAsString(json.encode(data.toJson()));
      videoData = data;
    }

    if (await videoCacheFile.exists()) {
      print('video cache exist no need to get url');
      // await RustyPipeClient.of(context)!.artemisClient.execute(PlayQuery(
      //     variables: PlayArguments(
      //         videoId: video.videoId,
      //         url: '',
      //         filePath: videoCacheFile.absolute.path)));
    } else {
      var url = videoData.audioOnlyStreams
          .firstWhere((element) => element.mimeType.contains('mp4'))
          .url;
      if ((await http.head(Uri.parse(url))).statusCode ~/ 100 != 2) {
        print('video url expired taking new');
        var data = await loadVideo(video.videoId, RustyPipeClient.of(context));
        videoFile.writeAsString(json.encode(data.toJson()));
        videoData = data;

        url = videoData.audioOnlyStreams
            .firstWhere((element) => element.mimeType.contains('mp4'))
            .url;
      } else {
        print('video url fine not rerequesting');
      }
    }
    print('Prepared ${video.name}');
    videoFile.writeAsString(json.encode((videoData as dynamic).toJson()));

    return videoData;
  }

  Future<VideoFieldsMixin> playVideo({
    required VideoResultFieldsMixin video,
    required BuildContext context,
  }) async {
    var videoFile = File(videoMetadataDir.absolute.path +
        Platform.pathSeparator +
        '${video.videoId}.json');
    var videoCacheFile = File(videoCacheDir.absolute.path +
        Platform.pathSeparator +
        '${video.videoId}.m4a');

    late String url;
    var videoData = await prepareVideo(video: video, context: context);
    url = videoData.audioOnlyStreams
        .firstWhere((element) => element.mimeType.contains('mp4'))
        .url;

    if (PlayerManager.of(context)
            .playerState
            .currentState
            ?.currentyPlaying
            ?.videoId ==
        video.videoId) {
      await RustyPipeClient.of(context).artemisClient.execute(PlayQuery(
          variables: PlayArguments(
              videoId: video.videoId,
              url: url,
              filePath: videoCacheFile.absolute.path)));
    }
    return videoData;
  }

  Future<List<String>> getSavedVideoIds() async {
    var files = videoCacheDir
        .list()
        .where((event) {
          print('File $event');
          return event is File;
        })
        .cast<File>()
        .where((event) => event.path.endsWith('.m4a'))
        .map((event) =>
            event.path.split(Platform.pathSeparator).last.split('.m4a').first);
    return await files.toList();
  }

  Future<List<VideoResultFieldsMixin>> getSavedVideos() async {
    var ids = await getSavedVideoIds();
    print('Saved videos ${ids.length}');
    var metas = await videoResultMetadataDir
        .list()
        .where((event) => event is File)
        .cast<File>()
        .where((event) {
      var name =
          event.path.split(Platform.pathSeparator).last.split('.json').first;
      return ids.contains(name);
    }).asyncMap((event) async {
      var data = await event.readAsString();
      var jsondata = json.decode(data);
      return Search$QueryRoot$Search$SearchResult$VideoResult.fromJson(
          jsondata);
    }).toList();
    return metas;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
