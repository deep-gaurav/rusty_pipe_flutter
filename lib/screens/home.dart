import 'package:flutter/material.dart';
import 'package:rusty_pipe_flutter/networking/client_provider.dart';
import 'package:rusty_pipe_flutter/screens/search.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
        ],
      ),
    );
  }
}
