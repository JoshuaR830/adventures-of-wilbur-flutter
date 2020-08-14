import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wilbur's Adventures",
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: "Wilbur's Adventures"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageUrl = 'https://adventures-of-wilbur-images.s3.eu-west-2.amazonaws.com/WP_20160601_20_38_09_Pro.jpg';
  var storyItemNumber = 3;

  String title;
  String description;

  void _incrementCounter() async {

    final _wilburApiGatewayBaseUrl = 'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url = '$_wilburApiGatewayBaseUrl?storyItemNumber=$storyItemNumber';

    String newImage;
    String newTitle;
    String newDescription;


    var response = await http.get(url);
    var status = response.statusCode;
    print(status);

    if(status != 200) {
      newImage = 'https://adventures-of-wilbur-images.s3.eu-west-2.amazonaws.com/WP_20160601_20_38_09_Pro.jpg';
    } else {
      await http.get(url)
          .then((response) => response.body)
          .then((responseImageUrl) {
        var parsedResponse = json.decode(responseImageUrl);
        newImage = parsedResponse["ImageUrl"];
        newTitle = parsedResponse["Title"];
        newDescription = parsedResponse["Description"];
      });
    }

    setState(() {
      imageUrl = newImage;
      title = newTitle;
      description = newDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Image.network(imageUrl),
            Text(title),
            Text(description),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _incrementCounter();
        },
        tooltip: 'Randomize',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
