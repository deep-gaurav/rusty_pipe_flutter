import 'package:artemis/schema/graphql_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:rusty_pipe_flutter/api/api.graphql.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
import 'package:rusty_pipe_flutter/utils/humanize.dart';

import 'player.dart';

class SearchPage extends StatefulWidget {
  final String query;
  SearchPage({required this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<GraphQLResponse<Search$QueryRoot>>? results;
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        results = RustyPipeClient.of(context)!.artemisClient.execute(
            SearchQuery(variables: SearchArguments(query: widget.query)));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query),
      ),
      body: FutureBuilder<GraphQLResponse<Search$QueryRoot>>(
        future: results,
        builder: (context, ass) {
          if (ass.hasData) {
            var results = ass.data?.data?.search.result;
            var items = results?.map((e) {
              if (e is Search$QueryRoot$Search$SearchResult$VideoResult) {
                return VideoResultItem(videoResult: e);
              } else {
                return Container();
              }
            }).toList();
            return ListView(
              children: [...(items ?? [])],
            );
          } else if (ass.hasError) {
            return Container(
              child: Center(
                child: Text("Error ${ass.error}"),
              ),
            );
          } else if (results == null) {
            return Container(
              child: const Center(
                child: Text("Client not found"),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class VideoResultItem extends StatelessWidget {
  final VideoResultFieldsMixin videoResult;

  final bool inQueue;
  final bool isPlaying;

  const VideoResultItem(
      {required this.videoResult,
      Key? key,
      this.inQueue = false,
      this.isPlaying = false})
      : super(key: key);

  String get views => humanizeNumber(videoResult.viewCount ?? 0);
  String get duration =>
      humanizeDuration(Duration(seconds: videoResult.duration ?? 0));

  @override
  Widget build(BuildContext context) {
    return Container(
      height: inQueue ? 60 : 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                await RustyPipeClient.of(context)!
                    .artemisClient
                    .execute(PauseQuery());
                PlayerManager.of(context).setCurrentlyPlaying(
                    videoResult, context,
                    setQueue: !inQueue);

                // var vidResullt = await RustyPipeClient.of(context)!
                //     .artemisClient
                //     .execute(VideoQuery(
                //         variables: VideoArguments(videoId: videoResult.videoId)));
                // print(
                //     'Vid result $vidResullt Error ${vidResullt.errors?.isEmpty} Errors ${vidResullt.errors?.map((e) => e.message)} Data ${vidResullt.data}');
                // var url = vidResullt.data?.video.audioOnlyStreams
                //     .firstWhere((element) => element.mimeType.contains('mp4'))
                //     .url;
                // if (url != null) {
                //   var result = await RustyPipeClient.of(context)!
                //       .artemisClient
                //       .execute(PlayQuery(
                //           variables: PlayArguments(
                //               videoId: videoResult.videoId, url: url)));
                //   print(result);
                // }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isPlaying ? Theme.of(context).highlightColor : null,
                ),
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Opacity(
                          opacity: isPlaying ? 0.5 : 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: CachedNetworkImage(
                                imageUrl: videoResult.thumbnail.first.url),
                          ),
                        ),
                        if (isPlaying)
                          Positioned.fill(
                              child: Center(
                            child: Icon(Icons.pause),
                          ))
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            videoResult.name,
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                            maxLines: inQueue ? 1 : 2,
                          ),
                          Text(
                            inQueue
                                ? videoResult.uploaderName.toString()
                                : "${videoResult.uploaderName} • $views • $duration",
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    if (inQueue)
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 35),
                        child: Text(
                          duration,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
