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
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: "Wilbur's Adventures"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageUrl = 'https://adventures-of-wilbur-images.s3.eu-west-2.amazonaws.com/WP_20160601_20_38_09_Pro.jpg';
  var storyItemNumber = 3;

  String title = "";
  String description = "";

  final _pages = <Widget>[];

  @override
  void initState() {
   _pages.add(ListView(
      children: <Widget>[
         Image.network(imageUrl),
         Text(title),
         Text(description),
       ],
     ),
   );

   _pages.add(ListView(
       children: <Widget>[
         Image.network(imageUrl),
         Text(title),
         Text(description),
       ],
     ),
   );

   _pages.add(ListView(
       children: <Widget>[
         Image.network(imageUrl),
         Text(title),
         Text(description),
       ],
     ),
   );
   super.initState();
  }

  Future<void> _getRandomImage(int currentIndex) async {
    final _wilburApiGatewayBaseUrl = 'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url = '$_wilburApiGatewayBaseUrl?imageTime=random&storyItemNumber=1';
    await _getImage(url, currentIndex);
  }

  Future<void> _getOrderedImage(int currentIndex) async {
    final _wilburApiGatewayBaseUrl = 'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url = '$_wilburApiGatewayBaseUrl?imageTime=ordered&storyItemNumber=2';
    await _getImage(url, currentIndex);
  }

  Future<void> _getLatestImage(int currentIndex) async {
    final _wilburApiGatewayBaseUrl = 'https://7rxf8z5z9h.execute-api.eu-west-2.amazonaws.com/v0/lambda';
    var url = '$_wilburApiGatewayBaseUrl?imageTime=latest&storyItemNumber=3';
    await _getImage(url, currentIndex);
  }

  // This should do the shared stuff
  // Should take a parameter to indicate what sort of image we are looking for
  // Url should be passed in from another method
  Future<void> _getImage(String url, int currentIndex) async {
    print("Asked for current index: $currentIndex");
    String newImage;
    String newTitle;
    String newDescription;

    if (currentIndex == _postSelectedIndex){
      _pages[currentIndex] = ListView(
        children: <Widget>[
          Image.network(imageUrl),
          Text(title),
          Text(description),
        ],
      );
    return;
  }


    var response = await http.get(url);
    var status = response.statusCode;
    print(status);
    print(response.body);

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

    if(currentIndex != _selectedIndex) {
      print("Took too long $currentIndex");
      return;
    }

    setState(() {
      print(_selectedIndex);
      _pages[_selectedIndex] = ListView(
        children: <Widget>[
          Image.network(newImage),
          Text(newTitle),
          Text(newDescription),
        ],
      );

      imageUrl = newImage;
      title = newTitle;
      description = newDescription;
    });
  }


  int _selectedIndex = 0;
  int _pendingIndex = 0;
  int _postSelectedIndex = 0;

  void _onItemTapped(int index) async {
    print(index);

    _pendingIndex = index;

    setState(() {
      _selectedIndex = index;
      _pages[index] = ListView(
        children: <Widget>[
          Text("Loading $index"),
        ],
      );
    });

    if (index == 0) {
      await _getLatestImage(index);
      _postSelectedIndex = 0;
    }

    if (index == 1) {
      await _getOrderedImage(index);
      _postSelectedIndex = 1;
    }

    if (index == 2) {
      await _getRandomImage(index);
      _postSelectedIndex = 2;
    }
  }

  Widget _floatingActionButton(int index) {

    if(index == 1) {
      return FloatingActionButton(
        onPressed: () async {
          _getOrderedImage(index);
        },
        tooltip: 'Next',
        child: Icon(Icons.navigate_next),
      );
    }

    if(index == 2) {
      return FloatingActionButton(
        onPressed: () async {
          _getRandomImage(index);
        },
        tooltip: 'Randomize',
        child: Icon(Icons.refresh),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.today,
            ),
            title: Text('Latest'),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_library
            ),
            title: Text('Story'),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.mood
            ),
            title: Text('Random'),
            backgroundColor: Colors.blue,
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      floatingActionButton: _floatingActionButton(_selectedIndex),
    );
  }
}
