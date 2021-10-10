import 'package:artemis/schema/graphql_response.dart';
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

  const VideoResultItem({required this.videoResult, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () async {
            await RustyPipeClient.of(context)!
                .artemisClient
                .execute(PauseQuery());
            PlayerManager.of(context).setCurrentlyPlaying(videoResult);

            var vidResullt = await RustyPipeClient.of(context)!
                .artemisClient
                .execute(VideoQuery(
                    variables: VideoArguments(videoId: videoResult.videoId)));
            print(
                'Vid result $vidResullt Error ${vidResullt.errors?.isEmpty} Errors ${vidResullt.errors?.map((e) => e.message)} Data ${vidResullt.data}');
            var url = vidResullt.data?.video.audioOnlyStreams
                .firstWhere((element) => element.mimeType.contains('mp4'))
                .url;
            if (url != null) {
              var result = await RustyPipeClient.of(context)!
                  .artemisClient
                  .execute(PlayQuery(
                      variables: PlayArguments(
                          videoId: videoResult.videoId, url: url)));
              print(result);
              await RustyPipeClient.of(context)!
                  .artemisClient
                  .execute(ResumeQuery());
            }
          },
          child: Container(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 60,
                  child: Image.network(videoResult.thumbnail.first.url),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        videoResult.name,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        "${videoResult.uploaderName} • ${humanizeNumber(videoResult.viewCount ?? 0)} • ${humanizeDuration(Duration(seconds: videoResult.duration ?? 0))}",
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
