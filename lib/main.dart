import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  WebSocketChannel channel = IOWebSocketChannel.connect("wss://ws.ifelse.io/");

  @override
  MyHomePageState createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:  const Text("Web Socket"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Send any message to the server"),
                controller: _controller,
              ),
            ),
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: sendData,
      ),
    );
  }

  void sendData() {
    if (_controller.text.isNotEmpty) {
      log("==>${_controller.text}");
      widget.channel.sink.add(_controller.text);

    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}