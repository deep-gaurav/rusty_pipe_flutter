import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rusty_pipe_flutter/api/api.graphql.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
import 'package:rusty_pipe_flutter/networking/songs_manager.dart';
import 'package:rusty_pipe_flutter/screens/player.dart';
import 'package:rusty_pipe_flutter/screens/search.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchEditingController = TextEditingController();

  List<VideoResultFieldsMixin> savedSongs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      SongsManager.of(context).getSavedVideos().then((value) => setState(() {
            print('Loaded songs ${value.length}');
            savedSongs = value;
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: TextField(
                controller: searchEditingController,
                onSubmitted: (val) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchPage(query: val)));
                },
              ),
            ),
            Container(
              child: Text('Running on ${RustyPipeClient.of(context)!.port}'),
            ),
            if (savedSongs.isNotEmpty)
              Container(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Saved Songs'),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...savedSongs.map((e) => InkWell(
                                onTap: () {
                                  PlayerManager.of(context)
                                      .setCurrentlyPlaying(e, context);
                                  PlayerManager.of(context)
                                      .playerState
                                      .currentState
                                      ?.setQueue(savedSongs);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: CachedNetworkImage(
                                            imageUrl: e.thumbnail.first.url),
                                      ),
                                      Text(e.name),
                                    ],
                                  ),
                                ),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
